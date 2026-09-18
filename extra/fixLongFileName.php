<?php
//error_reporting(E_ERROR);
//class GenFunc::
$root = __DIR__;
//require_once $root . '/lib_php/bootloader.php';
require_once $root . '/lib_php/GenFunc.php';
//class Cache::
require_once $root . '/lib_php/Cache.php';
//inner
//require_once 'Cookies.php';
require_once $root . '/lib_php/Lib.php';
require_once $root . '/lib_php/ORMPG.php';
require_once $root . '/lib_php/DBPG.php';
require_once $root . '/dbConf.php';

$rootPath = 'G:/Shares/';
$extPath  = [
    '',
    '_/',
    '__/',
    '___/',
];

$fileLs      = explode("\r\n", file_get_contents(__FILE__ . '.txt'));
$filePathArr = [];
$i           = 0;
foreach ($fileLs as $filePathStr) {
    //屏蔽生成文件
    if (stripos($filePathStr, '_') === 0) continue;
    //
    $filePath = explode('/', $filePathStr);
    foreach ($filePath as $dirName) {
        $dirName = str_replace(["'", '‛'], '', $dirName);
        $dirLen  = strlen($dirName);
        if ($dirLen > 200) {
            $i++;
            $ifExs = ORMPG::table('node')->where('title', $dirName)->first();
            if (empty($ifExs)) continue;
            echo $i, ':', $dirLen, ':', ($ifExs['id'] ?? ''), ':', $dirName, "\r\n";
//            if (empty($ifExs)) exit();
            //
            $pathInfo = pathinfo($dirName) + [
                    'extension' => '',
                    'filename'  => '',
                ];
            if (strlen($pathInfo['extension']) > 10) {
                $pathInfo['filename']  .= '.' . $pathInfo['extension'];
                $pathInfo['extension'] = '';
            };
            //
            $tDirName = $pathInfo['filename'];
            while (strlen($tDirName . $pathInfo['extension']) > 200) {
                $tDirName = mb_substr($tDirName, 0, mb_strlen($tDirName) - 10);
            }
            if (!empty($pathInfo['extension']))
                $tDirName .= '.' . $pathInfo['extension'];
            echo 'to:', $tDirName, "\r\n";
//            continue;
            foreach ($extPath as $ext) {
//                $srcPath = mb_convert_encoding($rootPath . $ext . $ifExs['node_path'] . '/' . $ifExs['title'], 'SHIFT-JIS');
//                $srcPath = iconv('UTF-8', 'JIS', $rootPath . $ext . $ifExs['node_path'] . '/' . $ifExs['title']);
//                $srcPath = html_entity_decode(utf8_decode($rootPath . $ext . $ifExs['node_path'] . '/' . $ifExs['title']));
                $srcPath = $rootPath . $ext . $ifExs['node_path'] . '/' . $ifExs['title'];
                if (!file_exists($srcPath)) {
                    echo 'src not exs:', $srcPath, "\r\n";
                    continue;
                }
                $tgtPath = $rootPath . $ext . $ifExs['node_path'] . '/' . $tDirName;
                continue;
                @rename($srcPath, $tgtPath);
            }
            exit;
            ORMPG::table('node')->where('id', $ifExs['id'])->update([
                'title'      => $tDirName,
                'node_index' => str_replace($ifExs['title'], $tDirName, $ifExs['node_index'])
            ]);
            $subLs = ORMPG::table('node')->whereRaw('node_id_list @> \'' . $ifExs['id'] . '\'')->select();
            if (!empty($subLs))
                foreach ($subLs as $sub) {
                    ORMPG::table('node')->where('id', $sub['id'])->update([
                        'node_path' => str_replace($ifExs['title'], $tDirName, $sub['node_path']),
                    ]);
                }
        }
    }
}
