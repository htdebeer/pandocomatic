import fs from 'fs-extra';
import path from 'path';

generate_dir('/home/ht/test', 'desttt', {});

function generate_dir(src, dst, config) {
  let src_dir = path.normalize(src),
      dst_dir = path.normalize(dst);

  fs.ensureDirSync(dst_dir);
  fs.readdirSync(src_dir).forEach(generate);

  function generate(file) {
    if (!skip(file)) {
      let full_src_path = path.join(src_dir, file),
          full_dst_path = path.join(dst_dir, file);

      if (fs.statSync(full_src_path).isDirectory()) {
        generate_dir(full_src_path, full_dst_path, config);
      } else {
        if (convert(file)) {
          convert_file(full_src_path, full_dst_path, config);
        } else {
          fs.copySync(full_src_path, full_dst_path)
        }
      }
    }
  }

  function skip(file) {
    // All unix-style hidden files and directories are skipped
    return /^\..*$/.test(file);
  }

  function convert(file) {
    // All and only markdown files are converted
    return /$\.(markdown|md)$/.test(path.extname(file));
  }

}

function convert_file(src, dst, config) {
  consolel.log(`Convert ${src} into ${dst} using ${config}`);
}


