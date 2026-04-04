function InitShopUserData  takes nothing returns nothing
// shops with the unitCode 'n000' sell this items
    call TasItemShopAddShop5('n00N', 'pdiv','pres','pghe','pgma', 'rej4')
    call TasItemShopAddShop5('n00N', 'pnvu','rej3','pnvl','pomn','rej2')
    call TasItemShopAddShop5('n00N', 'rej1','pspd','dust','pinv','phea')
    call TasItemShopAddShop5('n00N', 'pman','pgin','pclr','plcl', 0)

// shops with the unitCode 'n001' sell this items
    call TasItemShopAddShop5('n035', 'ckng','modt','tkno','ratf', 'ofro')
    call TasItemShopAddShop5('n035', 'desc','fgdg','infs','shar', 'sand')
    call TasItemShopAddShop5('n035', 'wild','srrc','odef','rde4', 'pmna')
    call TasItemShopAddShop5('n035', 'rhth','ssil','spsh','sres', 'pdiv')
    call TasItemShopAddShop5('n035', 'pres','totw','fgfh','fgrd', 'fgrg')
    call TasItemShopAddShop5('n035', 'hcun','hval','mcou','ajen', 'clfm')
    call TasItemShopAddShop5('n035', 'ratc','war2','kpin','lgdh', 'ankh')
    call TasItemShopAddShop5('n035', 'belv','bgst','ciri','lhst', 'afac')
    call TasItemShopAddShop5('n035', 'whwd','fgsk','wcyc','hlst', 'mnst')
    call TasItemShopAddShop5('n035', 'sbch','brac','rwiz','pghe', 'pgma')
    call TasItemShopAddShop5('n035', 'pnvu','sror','woms','crys', 'evtl')
    call TasItemShopAddShop5('n035', 'penr','prvt','rat9','rde3', 'rlif')
    call TasItemShopAddShop5('n035', 'bspd','rej3','will','wlsd', 'wswd')
    call TasItemShopAddShop5('n035', 'cnob','gcel','rat6','rde2', 0)

// this unit sells other items then his normal type would
    // call TasItemShopAddShop5Unit(udg_SpecialShop, 'ckng','tkno','rde4','tdx2', 'tin2')
    // call TasItemShopAddShop5Unit(udg_SpecialShop, 'tpow', 0, 0 , 0, 0)
endfunction