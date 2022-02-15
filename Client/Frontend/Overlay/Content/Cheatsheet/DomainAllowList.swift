// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation

public enum DomainAllowList {
    public typealias RawValue = [String: Bool]

    public static let recipeDomains = [
        "101cookbooks.com": true,
        "aclassictwist.com": true,
        "acouplecooks.com": true,
        "africanbites.com": true,
        "allrecipes.com": false,
        "allshecooks.com": true,
        "altonbrown.com": true,
        "ambitiouskitchen.com": true,
        "amyshealthybaking.com": true,
        "anitalianinmykitchen.com": true,
        "askchefdennis.com": true,
        "awortheyread.com": true,
        "bakerella.com": true,
        "bakingmad.com": true,
        "barefootcontessa.com": true,
        "bbcgoodfood.com": true,
        "bbc.co.uk": true,
        "bettycrocker.com": true,
        "blackfoodie.co": true,
        "blueapron.com": true,
        "bonappetit.com": true,
        "booyahbuffet.com": true,
        "bowlofdelicious.com": true,
        "browneyedbaker.com": true,
        "bsugarmama.com": true,
        "budgetbytes.com": true,
        "butterbeready.com": true,
        "cafedelites.com": true,
        "caribbeanpot.com": true,
        "carnaldish.com": true,
        "chasingdaisiesblog.com": true,
        "chefjet.com": true,
        "chinasichuanfood.com": true,
        "chocolatecoveredkatie.com": true,
        "chowhound.com": true,
        "cookiesandcups.com": true,
        "cookieandkate.com": true,
        "cooking.nytimes.com": false,
        "cookingchanneltv.com": true,
        "cookingclassy.com": true,
        "cookinglight.com": true,
        "cooks.com": true,
        "countryliving.com": true,
        "crateandbarrel.com": true,
        "crayonsandcravings.com": true,
        "crazyforcrust.com": true,
        "curiouscuisiniere.com": true,
        "damndelicious.net": true,
        "daringgourmet.com": true,
        "dashofjazz.com": true,
        "delish.com": true,
        "delishably.com": true,
        "dessertfortwo.com": true,
        "dinnerthendessert.com": true,
        "domnthecity.com": true,
        "easyanddelish.com": true,
        "eatathomecooks.com": true,
        "eatingwell.com": false,
        "eatingwitherica.com": true,
        "eatwell101.com": true,
        "epicurious.com": true,
        "feedmephoebe.com": true,
        "firstandfull.com": true,
        "fitmencook.com": true,
        "food.com": true,
        "food52.com": true,
        "foodandwine.com": false,
        "foodiecrush.com": true,
        "foodnetwork.com": true,
        "fortheloveofcooking.net": true,
        "gimmedelicious.com": true,
        "gimmesomeoven.com": true,
        "goodhousekeeping.com": true,
        "goop.com": true,
        "grandbaby-cakes.com": true,
        "greatbritishchefs.com": true,
        "halfbakedharvest.com": true,
        "hebbarskitchen.com": true,
        "iambaker.net": true,
        "imbibemagazine.com": true,
        "indianhealthyrecipes.com": true,
        "instyle.com": false,
        "jessicainthekitchen.com": true,
        "jocooks.com": true,
        "joyfoodsunshine.com": true,
        "joyofbaking.com": true,
        "justapinch.com": true,
        "justonecookbook.com": true,
        "kaluhiskitchen.com": true,
        "kannammacooks.com": true,
        "kingarthurbaking.com": true,
        "kmariekitchen.com": true,
        "koreanbapsang.com": true,
        "laraclevenger.com": true,
        "latimes.com": true,
        "letscookchinesefood.com": true,
        "lifeloveandsugar.com": true,
        "littlespicejar.com": true,
        "loveandlemons.com": true,
        "maangchi.com": true,
        "marthastewart.com": false,
        "masterclass.com": true,
        "medium.com": true,
        "melskitchencafe.com": true,
        "menshealth.com": true,
        "minimalistbaker.com": true,
        "ministryofcurry.com": true,
        "modernhoney.com": true,
        "momontimeout.com": true,
        "mrbcooks.com": true,
        "mybakingaddiction.com": true,
        "myfoodstory.com": true,
        "myfrugalhome.com": true,
        "mykoreankitchen.com": true,
        "myrecipes.com": true,
        "natashaskitchen.com": true,
        "ohmyfoodrecipes.com": true,
        "ohsweetbasil.com": true,
        "omnivorescookbook.com": true,
        "onceuponachef.com": true,
        "orchidsandsweettea.com": true,
        "passionforbaking.com": true,
        "pinchofyum.com": true,
        "preciouscore.com": true,
        "rachelcooks.com": true,
        "rasamalaysia.com": true,
        "realsimple.com": false,
        "recipetineats.com": true,
        "redhousespice.com": true,
        "sallysbakingaddiction.com": true,
        "seriouseats.com": true,
        "simpleveganblog.com": true,
        "simplyrecipes.com": true,
        "smittenkitchen.com": true,
        "southernliving.com": false,
        "southernshelle.com": true,
        "spendwithpennies.com": true,
        "spoonuniversity.com": true,
        "sweetpotatosoul.com": true,
        "sweetsavant.com": true,
        "taiwanduck.com": true,
        "tasteasianfood.com": true,
        "tasteofhome.com": true,
        "tastesbetterfromscratch.com": true,
        "tasty.co": true,
        "thebakingchocolatess.com": true,
        "theburningkitchen.com": true,
        "thecakeblog.com": true,
        "thecookierookie.com": true,
        "thedailymeal.com": true,
        "thehongkongcookery.com": true,
        "thehungryhutch.com": true,
        "thekitchn.com": true,
        "themediterraneandish.com": true,
        "thepioneerwoman.com": true,
        "therecipecritic.com": true,
        "thewoksoflife.com": true,
        "thismamacooks.com": true,
        "tonysmarket.com": true,
        "verywellfit.com": true,
        "wandercooks.com": true,
        "washingtonpost.com": true,
        "webstaurantstore.com": true,
        "weightwatchers.com": true,
        "wellplated.com": true,
        "whiskitrealgud.com": true,
        "whiskyadvocate.com": true,
        "williams-sonoma.com": true,
        "winemag.com": true,
        "womenshealthmag.com": true,
        "yummly.com": true,
    ]
}
