#INCLUDE  "TOTVS.CH"

/*/{Protheus.doc} QDSTDINV
(long_description)
@type  Function
@author katiane.koch
@since 10/06/2020
@version 1.0
@param p, numeric, param_descr
@param df, numeric, param_descr
@return cValor, caractere, return_description
@example
(examples)
@see (links_or_references)
/*/
Function QLDSTDINV(p, df)
Local cvalor, t, q
    q = 1 - p
    t = dt1(p,q,df)

    If(t<0)
        t = t *-1
    Endif

    cValor := transform(t, "9.99999999999999") 
    cValor := StrTran(cValor,".",",")
    
Return cValor

// Transcrição para C da função cdft e demais documentadas no link 
//https://people.sc.fsu.edu/~jburkardt/c_src/cdflib/cdflib.c
//Os nomes das variáveis foram matidos conforme original para facilitar a localização

//https://tdn.totvs.com/display/tec/Decimais+de+Ponto+Fixo+--+9661

/*/{Protheus.doc} dt1
(long_description)
@type  Static Function
@author katiane.koch
@since 10/06/2020
@version version
@param p, numeric, param_descr
@param q, numeric, param_descr
@param df, numeric, param_descr
@return dt1, numeric, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function  dt1( p, q, df )
/*
  static double coef[4][5] = {
    {1.0e0,1.0e0,0.0e0,0.0e0,0.0e0},
    {3.0e0,16.0e0,5.0e0,0.0e0,0.0e0},
    {-15.0e0,17.0e0,19.0e0,3.0e0,0.0e0},
    {-945.0e0,-1920.0e0,1482.0e0,776.0e0,79.0e0}
  };
  static double denom[4] = {
    4.0e0,96.0e0,384.0e0,92160.0e0
  };
  static int ideg[4] = {
    2,3,4,5
  };
  static double dt1,denpow,sum,term,x,xp,xx;
  static int i;

*/
Local coef :=  {{1, 1, 0, 0, 0},;
                {3,16,5,0,0},;
                {-15,17,19,3,0},;
                {-945,-1920,1482,776,79}}
Local denom := {4, 96, 384, 92160}
Local ideg := {2,3,4,5}
Local dt1,denpow,sum,term,x,xp,xx
Local i

// x = fabs(dinvnr(p,q));
x = abs(dinvnr(p,q)) //função
xx = x*x
sum = x
//denpow = 1.0e0
denpow = 1
    
    For i := 1 to 4
        //term = eval_pol ( @coef[i][1], @ideg[i], @xx ) * x //função
        term = eval_pol( @coef[i], @ideg[i], @xx ) * x
        denpow *= df
        sum += (term/(denpow*denom[i]))
    Next
    
    //if(!(p >= 0.5*10^0))
    If(!(p >= 0.5)) 
        xp = -sum
    Else
        xp = sum
    Endif

    dt1 = xp
Return dt1

/*/{Protheus.doc} dinvnr
(long_description)
@type  Static Function
@author katiane.koch
@since 10/06/2020
@version version
@param p, numeric, param_descr
@param q, numeric, param_descr
@return dinvnr, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function dinvnr( p, q )
local  dinvnr,strtx,xcur,cum,ccum,pp,dx
local  i
local  qporq
local maxit := 100
// define eps (1.0e-13)
Local  eps := 0.0000000000001
//# define r2pi 0.3989422804014326e0
Local r2pi := 0.3989422804014326
// define nhalf (-0.5e0)
Local nhalf := -0.5
//# define maxit 100
//# define eps (1.0e-13)
//# define r2pi 0.3989422804014326e0
//# define nhalf (-0.5e0)
//# define dennor(x) (r2pi*exp(nhalf*(x)*(x)))



//
//     FIND MINIMUM OF P AND Q
//
qporq = ( p <= q )

IF(!qporq) 
    pp = q
Else
    pp = p
Endif

strtx = stvaln(@pp) //função
xcur = strtx
//
//     NEWTON INTERATIONS
//
FOR i := 1 to maxit
    cumnor(@xcur,@cum,@ccum) //função
    //dx = (cum-pp)/dennor(xcur); //função
    dx = (cum-pp)/((r2pi)*exp(-(nhalf)*(xcur)*(xcur))) //função
    xcur -= dx
    
    If(abs(dx/xcur) < eps) //troquei fabs por abs
        Exit
    Endif
Next

If(!(abs(dx/xcur) < eps) )
    dinvnr = strtx
//
//     IF WE GET HERE, NEWTON HAS FAILED
//
    If(!qporq) 
        dinvnr = -dinvnr //Analisar isso
    Endif
    return dinvnr
Endif

dinvnr = xcur

If(!qporq) 
    dinvnr = -dinvnr //Analisar isso
Endif
   
Return dinvnr

/*/{Protheus.doc} cumnor
(long_description)
@type  Static Function
@author katiane.koch
@since 10/06/2020
@version version
@param arg, numeric, param_descr
@param result, param_type, param_descr
@param ccum, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function cumnor( arg, result, ccum )
/* Valores convertidos
  static double a[5] = {
    2.2352520354606839287e00,1.6102823106855587881e02,1.0676894854603709582e03,
    1.8154981253343561249e04,6.5682337918207449113e-2
  };
  static double b[4] = {
    4.7202581904688241870e01,9.7609855173777669322e02,1.0260932208618978205e04,
    4.5507789335026729956e04
  };
  static double c[9] = {
    3.9894151208813466764e-1,8.8831497943883759412e00,9.3506656132177855979e01,
    5.9727027639480026226e02,2.4945375852903726711e03,6.8481904505362823326e03,
    1.1602651437647350124e04,9.8427148383839780218e03,1.0765576773720192317e-8
  };
  static double d[8] = {
    2.2266688044328115691e01,2.3538790178262499861e02,1.5193775994075548050e03,
    6.4855582982667607550e03,1.8615571640885098091e04,3.4900952721145977266e04,
    3.8912003286093271411e04,1.9685429676859990727e04
  };
  static double half = 0.5e0;
  static double p[6] = {
    2.1589853405795699e-1,1.274011611602473639e-1,2.2235277870649807e-2,
    1.421619193227893466e-3,2.9112874951168792e-5,2.307344176494017303e-2
  };
  static double one = 1.0e0;
  static double q[5] = {
    1.28426009614491121e00,4.68238212480865118e-1,6.59881378689285515e-2,
    3.78239633202758244e-3,7.29751555083966205e-5
  };

  static double sixten = 1.60e0;
  static double sqrpi = 3.9894228040143267794e-1;
  static double thrsh = 0.66291e0;
  static double root32 = 5.656854248e0;
  static double zero = 0.0e0;

  */
local a := {2.2352520354606837,;
            161.02823106855587,;
            1067.6894854603709,;
            18154.98125334356,;
            0.06568233791820745}
Local b := {47.202581904688245,;
            976.0985517377767,;
            10260.932208618979,;
            45507.78933502673}
local c := {0.39894151208813466,;
            8.883149794388377,;
            93.50665613217785,;
            597.2702763948002,;
            2494.5375852903726,;
            6848.190450536283,;
            11602.65143764735,;
            9842.714838383978,;
            0.000000010765576773720192}
local d := {22.266688044328117,;
            235.387901782625,;
            1519.3775994075547,;
            6485.558298266761,;
            18615.571640885097,;
            34900.95272114598,;
            38912.00328609327,;
            19685.429676859992}
local half := 0.5
local p := {0.215898534057957,;
            0.12740116116024736,;
            0.022235277870649807,;
            0.0014216191932278934,;
            0.000029112874951168793,;
            0.023073441764940174}
local one := 1
local q := {1.284260096144911,;
            0.4682382124808651,;
            0.06598813786892856,;
            0.0037823963320275824,;
            0.00007297515550839662}

local sixten := 1.6
local sqrpi := 0.3989422804014327
local thrsh := 0.66291
local root32 := 5.656854248
local zero := 0
local K1 := 1
local K2 := 2
local i
local del,eps,temp,x,xden,xnum,y,xsq,min
//
//  Machine dependent constants
//
//  eps = dpmpar(&K1)*0.5e0
eps = dpmpar(@K1)*0.5 //funcao
min = dpmpar(@K2) //funcao
x = arg 
y = abs(x) //troquei abs por fabs

If(y <= thrsh) 
    xsq = zero
    If(y > eps) 
        xsq = x*x
    Endif
        
    xnum = a[5]*xsq
    xden = xsq
        
    For i := 1 to 3
        xnum = (xnum+a[i])*xsq
        xden = (xden+b[i])*xsq
    Next

    result = x*(xnum+a[4])/(xden+b[4])
    temp = result
        
    result = half+temp
    ccum = half-temp
        
Elseif(y <= root32) 
    
    xnum = c[9]*y
    xden = y
    For i := 1 to 7
        xnum = (xnum+c[i])*y
        xden = (xden+d[i])*y
    Next
    
    result = (xnum+c[8])/(xden+d[8])
    xsq = int(y*sixten)/sixten //troquei a funcção fifdint por int
    del = (y-xsq)*(y+xsq)
    result = exp(-(xsq*xsq*half))*exp(-(del*half))*result
    ccum = one-result
    If(x > zero) 
        temp = result
        result = ccum
        ccum = temp
    Endif
    
//
//  Evaluate  anorm  for |X| > sqrt(32)
//
Else  
    
    result = zero
    xsq = one/(x*x)
    xnum = p[6]*xsq
    xden = xsq
        
    For i := 1 to 4
        xnum = (xnum+p[i])*xsq
        xden = (xden+q[i])*xsq
    Next
        
    result = xsq*(xnum+p[5])/(xden+q[5])
    result = (sqrpi-result)/y
        
    xsq = int(x*sixten)/sixten //troquei a funcção fifdint por int
    del = (x-xsq)*(x+xsq)
        
    result = exp(-(xsq*xsq*half))*exp(-(del*half))*result
    ccum = one-result
        
    If(x > zero) 
        temp = result
        result = ccum
        ccum = temp
    Endif
    
Endif

If(result < min) 
    //result = 0.0e0
    result = 0
Endif
//
//  Fix up for negative argument, erf, etc.
//

If(ccum < min) 
    //ccum = 0.0e0
    ccum = 0
Endif

Return Nil

/*/{Protheus.doc} dpmpar
(long_description)
@type  Static Function
@author katiane.koch
@since 10/06/2020
@version version
@param i, numeric, param_descr
@return value, numeric, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function dpmpar( i )
Local K1 := 4
Local K2 := 8
Local K3 := 9
Local K4 := 10
Local  value,b,binv,bm1,one,w,z
Local emax,emin,ibeta,m

If(i = 1) 
    b = ipmpar(@K1)
    m = ipmpar(@K2)
    //value = pow(b,(double)(1-m));
    value = b^(1-m)
Elseif(i = 2) 
    b = ipmpar(@K1)
    emin = ipmpar(@K3)
    one = 1.0
    binv = one/b
    //w = pow(b,(double)(emin+2));
    w = b^(emin+2)
    value = w*binv*binv*binv
Else
    ibeta = ipmpar(@K1)
    m = ipmpar(@K2)
    emax = ipmpar(@K4)
    b = ibeta
    bm1 = ibeta-1
    one = 1.0
    //z = pow(b,(double)(m-1));
    z = b^(m-1)
    w = ((z-one)*b+bm1)/(b*z)
    //z = pow(b,(double)(emax-2));
    z = b^(emax-2)
    value = w*z*b*b
Endif
Return value

/*/{Protheus.doc} ipmpar
(long_description)
@type  Static Function
@author katiane.koch
@since 10/06/2020
@version version
@param i, numeric, param_descr
@return imach[i+1], numeric, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ipmpar( i )
local imach := {2,31,2147483647,2,24,-125,128,53,-1021,1024}
Return imach[i+1]

/*/{Protheus.doc} stvaln
(long_description)
@type  Static Function
@author katiane.koch
@since 10/06/2020
@version version
@param p, numeric, param_descr
@return stvaln, numeric, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function stvaln( p )
//  static double xden[5] = {
//    0.993484626060e-1,0.588581570495e0,0.531103462366e0,0.103537752850e0,
//    0.38560700634e-2
//  };
//  static double xnum[5] = {
//    -0.322232431088e0,-1.000000000000e0,-0.342242088547e0,-0.204231210245e-1,
//    -0.453642210148e-4
//  };
local xden := {0.099348462606,;
               0.588581570495,;
               0.531103462366,;
               0.10353775285,;
               0.0038560700634}
local xnum := {-0.322232431088,;
                -1,;
                -0.342242088547,;
                -0.0204231210245,;
                -0.0000453642210148}


local  K1 := 5
local  stvaln,sign,y,z

//if((p <= 0.5e0)) 
IF((p <= 0.5)) 
    //sign = -1.0e0;
    sign = -1
    z = p
Else
    //sign = 1.0e0;
    //z = 1.0e0-*p;   
    sign = 1
    z = 1-p
Endif


//y = sqrt(-(2.0e0*log(z))) convertido de notação cientifica para decimal
y = sqrt(-(2.0*log(z)))
stvaln = y+ eval_pol( xnum, K1, y )/eval_pol( xden, K1, y )
stvaln = sign*stvaln
Return stvaln

/*/{Protheus.doc} nomeStaticFunction
(long_description)
@type  Static Function
@author katiane.koch
@since 10/06/2020
@version version
@param a, array, param_descr
@param n, numeric, param_descr
@param x, numeric, param_descr
@return devlpl, numeric, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function eval_pol( a, n, x )
local  devlpl,term
local i

term = a[n]
For i = n-1 to 1 STEP -1
    term = a[i]+term*x
Next

devlpl = term
Return devlpl