<?php
$str = '1.2024.01.05：更换火花塞，分火头，风扇离合器 2.2024.01.24：更换轮胎一只 3.2024.06.03：更换机油三滤，轮胎4只4.2024.07.04：年审';

function splitStr($str) {
    $dateArr = [];
    preg_match_all(
        '/\d{4}.\d{2}.\d{2}/im',
        $str,
        $dateArr
    );
    if (empty($dateArr)) throw new ErrorException('匹配失败');
    $dateArr = $dateArr[0];
    $strArr  = [];
    for ($i1 = 0; $i1 < sizeof($dateArr); $i1++) {
        $cur        = $i1;
        $next       = $i1 + 1;
        $curOffset  = strpos($str, $dateArr[$cur]);
        $nextOffset = strlen($str);
        if (isset($dateArr[$next])) $nextOffset = strpos($str, $dateArr[$next]);
        $subStr = substr($str, $curOffset, $nextOffset - $curOffset);
        //
        $subDate  = $dateArr[$cur];
        $subTxt   = substr($subStr, strlen($subDate));
        $subTxt   = str_replace(['：', ':', ' '], '', $subTxt);
        $subTxt   = preg_replace('/[\.\d\s]+$/', '', $subTxt);
        $strArr[] = [$subDate, $subTxt];
    }
    return $strArr;
}


$strArr = splitStr($str);
var_dump($strArr);
