<?php
libxml_use_internal_errors(true);
function crawlpage($letter){
    $doc = new DOMDocument;
    $homepage = file_get_contents('http://www.debinnenvaart.nl/schepen_a_z/'. $letter .'/1/order=BDT_Name;ASC/');
    $doc->loadHTML($homepage);

    $xpath = new DOMXPath($doc);

    $query = '//table//a';

    $entries = $xpath->query($query);
    foreach($entries as $entry){
        crawlboat($entry->getAttribute('href'));
    }
}

function crawlboat($url){
    $doc = new DOMDocument;
    $homepage = file_get_contents('http://www.debinnenvaart.nl' . $url);
    $doc->loadHTML($homepage);

    $xpath = new DOMXPath($doc);
    $naam = $xpath->query('//h1')[0]->textContent;
    echo ($url . ',');
    echo ($naam . ',');


    $result = $xpath->query('//table[@id="boatdetail"]//td[contains(.,"EU Nummer")]');
    if ($result ->length >0){
        if($result[0]->parentNode->childNodes ->length >= 3) {
            $EU_nummer = $result[0]->parentNode->childNodes[2]->textContent;
            echo($EU_nummer . ',');
        }else{
            $EU_nummer = $result[0]->parentNode->childNodes[1]->textContent;
            echo($EU_nummer . ',');
        }
    }else{
        $EU_nummer = "";
        echo ($EU_nummer . ',');
    }
//    var_dump($result[0]->parentNode->childNodes[2]);

    $result = $xpath->query('//table[@id="boatdetail"]//td[contains(.,"ENI Nummer")]');
    if ($result ->length >0){
        if($result[0]->parentNode->childNodes ->length >= 3) {
            $ENI_nummer = $result[0]->parentNode->childNodes[2]->textContent;
            echo ($ENI_nummer . ',');
        }else{
            $ENI_nummer = $result[0]->parentNode->childNodes[1]->textContent;
            echo($ENI_nummer . ',');
        }
    }else{
        $ENI_nummer = "";
        echo ($ENI_nummer . ',');
    }

//    var_dump($result[0]->parentNode);
    $result = $xpath->query('//td[contains(.,"Bouwjaar")]');
    if ($result ->length >0){
        $Bouwjaar = $result[0]->parentNode->lastChild->textContent;
        echo ($Bouwjaar . ',');
    }else{
        $Bouwjaar = "";
        echo ($Bouwjaar . ',');
    }

    $result = $xpath->query('//table[@id="boatdetail"]//td[contains(.,"Scheepstype")]');
    if ($result ->length >0){
        $Scheepstype = $result[0]->parentNode->childNodes[2]->textContent;
        echo ($Scheepstype . ',');
    }else{
        $Scheepstype = "";
        echo ($Scheepstype . ',');
    }

    $result = $xpath->query('//td[contains(.,"Tonnage")]');
    if ($result ->length >0){
        $Tonnage = $result[0]->parentNode->lastChild->textContent;
        echo ($Tonnage . ',');
    }else{
        $Tonnage = "";
        echo ($Tonnage . ',');
    }

    $result = $xpath->query('//td[contains(.,"Lengte")]');
    if ($result ->length >0){
        $Lengte = $result[0]->parentNode->lastChild->textContent;
        echo ($Lengte . ',');
    }else{
        $Lengte = "";
        echo ($Lengte . ',');
    }

    $result = $xpath->query('//td[contains(.,"Breedte")]');
    if ($result ->length >0){
        $Breedte = $result[0]->parentNode->lastChild->textContent;
        echo ($Breedte . ',');
    }else{
        $Breedte = "";
        echo ($Breedte . ',');
    }

    $result = $xpath->query('//td[contains(.,"Diepgang")]');
    if ($result ->length >0){
        $Diepgang = $result[0]->parentNode->lastChild->textContent;
        echo ($Diepgang . ',');
    }else{
        $Diepgang = "";
        echo ($Diepgang . ',');
    }

    $result = $xpath->query('//td[contains(.,"Voortstuwing")]');
    if ($result ->length >0){
        $Voortstuwing = $result[0]->parentNode->lastChild->textContent;
        echo ($Voortstuwing);
    }else{
        $Voortstuwing = "";
        echo ($Voortstuwing);
    }

    echo "\n";
}
echo ("Scheepsnaam,EU Nummer,ENI Nummer,Bouwjaar,Scheepstype,Tonnage,Lengte,Breedte,Diepgang,Voortstuwing");
echo "\n";
foreach (str_split('ABCDEFGHIJKLMNOPQRSTUVWXYZ') as $letter){
    crawlpage($letter);
}
crawlboat("/schip_detail/16965/");






