use super::*;
use std::fs;
use std::fs::File;
use std::io::{BufRead, Cursor, Seek, SeekFrom, Write};

pub fn extract(
    format: &Format,
    archive: &mut zip::ZipArchive<Cursor<&Vec<u8>>>,
) -> Result<HashMap<String, Vec<u8>>> {
    let fp_folder_str = format!("{}.pretty", format.name);

    //ensure we have the footprint library folder
    let footprint_folder = PathBuf::from(&format.output_path).join(fp_folder_str.clone());
    if !footprint_folder.exists() {
        fs::create_dir_all(footprint_folder.clone())?;
    }

    // Create a separate folder for kicad_mod files (QoL improvement)
    let kicad_mod_folder =
        PathBuf::from(&format.output_path).join(format!("{}_footprints", format.name));
    if !kicad_mod_folder.exists() {
        fs::create_dir_all(kicad_mod_folder.clone())?;
    }

    //ensure the symbol library exists
    let fn_lib = PathBuf::from(&format.output_path).join(format!("{}.kicad_sym", format.name));

    if !fn_lib.exists() {
        fs::write(
            &fn_lib,
            "(kicad_symbol_lib (version 20211014) (generator library-loader)\n)\n",
        )
        .expect("Unable to create symbol library file");
    }

    let mut symbols: Vec<String> = Vec::new();
    let mut legacy_lib_contents: Vec<String> = Vec::new();
    let mut legacy_dcm_contents: Vec<String> = Vec::new();
    let mut has_legacy_lib_header = false;
    let mut has_legacy_dcm_header = false;

    for i in 0..archive.len() {
        let mut item = archive.by_index(i)?;
        let name = item.name();
        let path = PathBuf::from(name);
        let base_name = path.file_name().unwrap().to_string_lossy().to_string();
        if let Some(ext) = &path.extension() {
            match ext.to_str() {
                // Copy kicad_mod files to both locations for compatibility
                Some("kicad_mod") => {
                    let mut f_data = Vec::<u8>::new();
                    item.read_to_end(&mut f_data)?;

                    // Copy to .pretty folder (original location)
                    let mut f = File::create(footprint_folder.join(&base_name))?;
                    f.write_all(&f_data)?;

                    // Also copy to separate footprints folder (QoL improvement)
                    let mut f2 = File::create(kicad_mod_folder.join(&base_name))?;
                    f2.write_all(&f_data)?;
                }
                // 3D model files (only in .pretty folder)
                Some("stl") | Some("stp") | Some("wrl") => {
                    let mut f_data = Vec::<u8>::new();
                    item.read_to_end(&mut f_data)?;
                    let mut f = File::create(footprint_folder.join(base_name))?;
                    f.write_all(&f_data)?;
                }
                Some("kicad_sym") => {
                    //save these to add later, so KiCad will be able to load the footprints right away
                    symbols.push(name.to_owned());
                }
                // Legacy lib files - concatenate them (QoL improvement)
                Some("lib") => {
                    let mut f_data = Vec::<u8>::new();
                    item.read_to_end(&mut f_data)?;
                    let content = String::from_utf8_lossy(&f_data);

                    for line in content.lines() {
                        let trimmed = line.trim();
                        // Skip headers if we already have one, keep component definitions
                        if trimmed.starts_with("EESchema-LIBRARY") {
                            if !has_legacy_lib_header {
                                legacy_lib_contents.push(line.to_string());
                                has_legacy_lib_header = true;
                            }
                        } else if !trimmed.is_empty() && !trimmed.starts_with("#End Library") {
                            legacy_lib_contents.push(line.to_string());
                        }
                    }
                }
                // Legacy dcm files - concatenate them (QoL improvement)
                Some("dcm") => {
                    let mut f_data = Vec::<u8>::new();
                    item.read_to_end(&mut f_data)?;
                    let content = String::from_utf8_lossy(&f_data);

                    for line in content.lines() {
                        let trimmed = line.trim();
                        // Skip headers if we already have one, keep component descriptions
                        if trimmed.starts_with("EESchema-DOCLIB") {
                            if !has_legacy_dcm_header {
                                legacy_dcm_contents.push(line.to_string());
                                has_legacy_dcm_header = true;
                            }
                        } else if !trimmed.is_empty() && !trimmed.starts_with("#End Doc Library") {
                            legacy_dcm_contents.push(line.to_string());
                        }
                    }
                }
                // Ignore legacy .mod files (obsolete for recent KiCad versions)
                Some("mod") => {
                    // Skip these files as they're not needed for recent KiCad versions
                }
                _ => {
                    // ignore all other files
                }
            }
        }
    }

    // Write concatenated legacy .lib file if we have content
    if !legacy_lib_contents.is_empty() {
        let legacy_lib_path =
            PathBuf::from(&format.output_path).join(format!("{}.lib", format.name));
        let mut lib_file = File::create(legacy_lib_path)?;
        for line in &legacy_lib_contents {
            writeln!(lib_file, "{}", line)?;
        }
        writeln!(lib_file, "#End Library")?;
    }

    // Write concatenated legacy .dcm file if we have content
    if !legacy_dcm_contents.is_empty() {
        let legacy_dcm_path =
            PathBuf::from(&format.output_path).join(format!("{}.dcm", format.name));
        let mut dcm_file = File::create(legacy_dcm_path)?;
        for line in &legacy_dcm_contents {
            writeln!(dcm_file, "{}", line)?;
        }
        writeln!(dcm_file, "#End Doc Library")?;
    }

    let mut f = File::options().read(true).write(true).open(&fn_lib)?;
    f.seek(SeekFrom::End(-2))?;

    for symbol_file in symbols {
        let mut f_data = Vec::<u8>::new();
        let mut item = archive.by_name(&symbol_file)?;
        item.read_to_end(&mut f_data)?;
        let mut lines: Vec<String> = (&f_data[..])
            .lines()
            .map(|l| l.expect("Could not parse line"))
            .collect();
        let end = &lines.len() - 1;
        for i in 0..end {
            //this is necessary to point symbols to correct footprint library
            let parts = lines[i].split_whitespace().collect::<Vec<_>>();
            if parts.len() >= 2 && parts[0] == "(property" && parts[1] == "\"Footprint\"" {
                let footprint_name = &parts[2][1..(parts[2].len() - 1)];
                lines[i] = lines[i].replace(
                    footprint_name,
                    &format!("{}:{}", format.name, &footprint_name),
                );
            }
        }
        for line in &lines[1..end] {
            f.write_all(line.as_bytes())?;
            f.write_all("\n".as_bytes())?;
        }
    }
    f.write_all(")\n".as_bytes())?;

    Ok(Files::new())
}
