#INCLUDE "protheus.ch"
#include "FILEIO.CH

#DEFINE CRLF Chr(10) + Chr(13)
#DEFINE D_TABOPME "19"
#DEFINE D_TABMED  "20"
#DEFINE D_TABPRO  "00"
STATIC cCodInt 	:= plsintpad()
static dDataVaz := Stod("")	

//-----------------------------------------------
/*/{Protheus.doc} PLSP900 
Importação PTU A900
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
function PLSP900(lAuto)

local aPergs	:= {}
local n902		:= 0
local n905		:= 0
local n902OP	:= 0
local lRet		:= .t.
private aPBox	:= {}
private oProcess
default lAuto	:= .f.

aAdd(/*01*/aPergs,{ 6,"Arquivo",space(200),"","","",85,.T.,"PTU A900 |*.*"})
aAdd(/*02*/aPergs,{ 2,"Criar TDE","1",{ "0=Não","1=Sim" },60,/*'.T.'*/,.t. } )
aAdd(/*03*/aPergs,{ 1,"Tab Padrao Mat Própria "	,space(2), "@!", 'Vazio() .or. ExistCpo("BR4",mv_par03,1)', 'B41PLS', "mv_par02=='1'", 10, .f. } )
aAdd(/*04*/aPergs,{ 1,"Tab Padrao Mat TISS"		,space(2), "@!", 'Vazio() .or. ExistCpo("BR4",mv_par04,1)', 'B41PLS', "mv_par02=='1'", 10, .f. } )
aAdd(/*05*/aPergs,{ 1,"Tab Padrao Med Própria"	,space(2), "@!", 'Vazio() .or. ExistCpo("BR4",mv_par05,1)', 'B41PLS', "mv_par02=='1'", 10, .f. } )
aAdd(/*06*/aPergs,{ 1,"Tab Padrao Med TISS"		,space(2), "@!", 'Vazio() .or. ExistCpo("BR4",mv_par06,1)', 'B41PLS', "mv_par02=='1'", 10, .f. } )
aAdd(/*07*/aPergs,{ 1,"Tab Padrao OPME Própria"	,space(2), "@!", 'Vazio() .or. ExistCpo("BR4",mv_par07,1)', 'B41PLS', "mv_par02=='1'", 10, .f. } )
aAdd(/*08*/aPergs,{ 1,"Tab Padrao OPME TISS"	,space(2), "@!", 'Vazio() .or. ExistCpo("BR4",mv_par08,1)', 'B41PLS', "mv_par02=='1'", 10, .f. } )
aAdd(/*09*/aPergs,{ 1,"TDE Materiais Própria"	,space(7), "@!", 'Vazio() .or. ExistCpo("BF8",mv_par09,1)', 'B68PLS', "mv_par02=='0'", 15, .f. } )
aAdd(/*10*/aPergs,{ 1,"TDE Materiais TISS"		,space(7), "@!", 'Vazio() .or. ExistCpo("BF8",mv_par10,1)', 'B68PLS', "mv_par02=='0'", 15, .f. } )
aAdd(/*11*/aPergs,{ 1,"TDE Medicamento Própria"	,space(7), "@!", 'Vazio() .or. ExistCpo("BF8",mv_par11,1)', 'B68PLS', "mv_par02=='0'", 20, .f. } )
aAdd(/*12*/aPergs,{ 1,"TDE Medicamento TISS"	,space(7), "@!", 'Vazio() .or. ExistCpo("BF8",mv_par12,1)', 'B68PLS', "mv_par02=='0'", 20, .f. } )
aAdd(/*13*/aPergs,{ 1,"TDE OPME Própria"		,space(7), "@!", 'Vazio() .or. ExistCpo("BF8",mv_par13,1)', 'B68PLS', "mv_par02=='0'", 20, .f. } ) 
aAdd(/*14*/aPergs,{ 1,"TDE OPME TISS"			,space(7), "@!", 'Vazio() .or. ExistCpo("BF8",mv_par14,1)', 'B68PLS', "mv_par02=='0'", 20, .f. } ) 

if !lAuto
	if( paramBox( aPergs,"Importação Tabela Nacional de Materiais e Medicamentos PTU A900",aPBox,/*bOK*/,/*aButtons*/,.f.,/*nPosX*/,/*nPosY*/,/*oDlgWizard*/,/*cLoad*/'PLSP900',/*lCanSave*/.t.,/*lUserSave*/.t. ) )
		if validPerg()	
			cIni := time()
			oProcess := MsNewProcess():New( { || PLSP900PRO(.f.,@n902,@n905,@lRet,@n902OP) } , "Processando" , "Aguarde..." , .f. )
			oProcess:Activate()
			cFim := time()
			if lRet
				aviso( "Resumo","Processamento finalizado. " + CRLF + ;
				"Materiais Processados: " 		+ cvaltochar(n902) + CRLF + ;
				"Medicamentos Processados: " 	+ cvaltochar(n905) + CRLF + ;
				"OPME Processados: " 	+ cvaltochar(n902OP) + CRLF + ;
				'Inicio: ' + cvaltochar( cIni ) + "  -  " + 'Fim: ' + cvaltochar( cFim ) + CRLF + "TOTAL: " + ElapTime( cIni, cFim ) ,{ "Ok" }, 2 )
			endif
			PLSP900()	
		else
			PLSP900()
		endif

	endif
endif

return 

//-----------------------------------------------
/*/{Protheus.doc} PLSP900PRO 
Processamento do arquivo PTU A900
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
function PLSP900PRO(lAuto,n902,n905,lRet,n902OP)
local oFile 		as object
local cLinAtu 		as char
local nTot			:= 0
local nX			:= 0
local cArq			:= aPBox[1]
local aBF8			:= {}
local nSize			:= 0
local nPosicTab		:= 0
local nPosicPad		:= 0
local xFiliBA8		:= xFilial("BA8")
local xFiliBD4		:= xFilial("BD4")
local xFiliBR8		:= xFilial("BR8")
local lExsDETANV	:= BA8->(fieldpos("BA8_DETANV")) > 0
local lExsTUSEDI	:= BR8->(fieldpos("BR8_TUSEDI")) > 0
local lExsCODIFI	:= BA8->(fieldpos("BA8_CODIFI")) > 0
local cTimDatInt	:= dtoc(date()) + " " + time()

//901
local cTpCarga   	as char
local cNrVerTra 	as char

//902
local cCdMaterial	as char
local nVlMax		as numeric
local dDtInicio		as date
local dDtFim		as date
local cRegAnvisa	as char
local cDetAnvisa	as char
local cMotivo		as char
local cCnpj			as char
local cTpProduto 	as char
local cTpCodific	as char
local cDescr		as char
local cDsProd 		as char
local cDsEsp 		as char
local cDsClas		as char

//905
local cCdMedic		as char
local cTpMed		as char	
local cConfaz 		as char
local cDescAtiv		as char
local cDescGFarm	as char
local cDescCFarm	as char

//906
local cFiliBTQ 	:= xFilial("BTQ")
local cAreaBTQ 	:= RetSqlName("BTQ")
local cDatPesq	:= dtos(dDataBase)
//Pesquisa Hash
local oHashUnd	:= HMNew()
local oR902Esp	:= HMNew()
local oR902Clas	:= HMNew()
local oR905GrFa	:= HMNew()
local oR905ClFa	:= HMNew()
local oHashAnvi	:= HMNew()
Local lNaoVaiNao := .T.

default lAuto 	:= .f.
default n902 	:= 0
default n905 	:= 0
default n902OP	:= 0
default lRet  	:= .f.

BF8->(dbSetOrder(1))
BA8->(dbSetOrder(1))
BD4->(dbSetOrder(1))                                                                                    
BR7->(dbSetOrder(1))
BR8->(dbSetOrder(1))

cDescr   := ""

oFile := FWFileReader():New( cArq )
oFile:setBufferSize(131072) //128Kb buffer
if oFile:Open()
	if !lAuto
		oProcess:SetRegua1(1)
		oProcess:IncRegua1("Processando arquivo")
		oProcess:SetRegua2(-1)
	endif
	nSize := oFile:getFileSize()
    while /*!(oFile:eof()) .and.*/ (oFile:hasLine())
		cLinAtu := oFile:getLine()
		nTot++
    	if nTot == 1
			if substr(cLinAtu,9,3) <> "901"
				if !lAuto
					msgAlert("O Arquivo A900 informado é invalido. " + CRLF + cArq)
				endif
				lRet := .f.
				exit
			endif
		endif	
		if !lAuto
			oProcess:IncRegua2(cvaltochar(oFile:getBytesRead()) +" de "+ cvaltochar(nSize))
		endif
		if substr(cLinAtu,9,3) == "901"
			cTpCarga  	:= substr(cLinAtu,24,1)
			cNrVerTra	:= substr(cLinAtu,25,2)
			if aPBox[2] == "1"
				aadd(aBF8, {gravaBF8("TABELA NACIONAL DE MATERIAIS UNIMED (Própria)"	, aPBox[3], D_TABPRO  , "1"), PlRetNivel(D_TABPRO)}  )
				aadd(aBF8, {gravaBF8("TABELA NACIONAL DE MATERIAIS UNIMED (TISS)"		, aPBox[4], D_TABOPME , "1"), PlRetNivel(D_TABOPME)} )
				aadd(aBF8, {gravaBF8("TABELA NACIONAL DE MEDICAMENTOS UNIMED (Própria)" , aPBox[5], D_TABPRO  , "2"), PlRetNivel(D_TABPRO)}  )
				aadd(aBF8, {gravaBF8("TABELA NACIONAL DE MEDICAMENTOS UNIMED (TISS)"	, aPBox[6], D_TABMED  , "2"), PlRetNivel(D_TABMED)}  )
				aadd(aBF8, {gravaBF8("TABELA NACIONAL DE OPME UNIMED (Própria)"			, aPBox[7], D_TABPRO  , "1"), PlRetNivel(D_TABPRO)}  )
				aadd(aBF8, {gravaBF8("TABELA NACIONAL DE OPME UNIMED (TISS)"			, aPBox[8], D_TABOPME , "1"), PlRetNivel(D_TABOPME)} )
			else
				aadd(aBF8, {aPBox[9] , PlRetNivel(aPBox[3])}  )
				aadd(aBF8, {aPBox[10], PlRetNivel(aPBox[4])} )
				aadd(aBF8, {aPBox[11], PlRetNivel(aPBox[5])} )
				aadd(aBF8, {aPBox[12], PlRetNivel(aPBox[6])} )
				aadd(aBF8, {aPBox[13], PlRetNivel(aPBox[7])} )
				aadd(aBF8, {aPBox[14], PlRetNivel(aPBox[8])} )
			endif
		endif
		if substr(cLinAtu,9,3) == "902"		
			cTpProduto 		:= substr(cLinAtu,365,1) // 1 – Material de consumo hospitalar / 5 – OPME / 6 - Equipamento/Instrumental
			cTpCodific		:= substr(cLinAtu,366,1) 	// 1 – TNUMM 2 – TUSS
			
			if cTpProduto == "5" //.and. cTpCodific == "1" 
				nPosicPad 	:= iif( cTpCodific == "1", 7, 8 )	
				nPosicTab 	:= iif( cTpCodific == "1", 5, 6 ) 
			else
				nPosicPad 	:= iif( cTpCodific == "1", 3, 4 )
				nPosicTab 	:= iif( cTpCodific == "1", 1, 2 )
			endif

			iif(cTpProduto == "5", n902OP++, n902++ )

			cCdMaterial		:= iif(cTpCodific == "1", substr(cLinAtu,12,8), substr(cLinAtu,413,10) )
			nVlMax			:= val(substr(cLinAtu,229,11)+"."+substr(cLinAtu,240,4))
			dDtInicio		:= stod( iif(!empty(substr(cLinAtu,367,8)), substr(cLinAtu,367,8), cDatPesq) )
			dDtFim			:= stod( iif(!empty(substr(cLinAtu,375,8)), substr(cLinAtu,375,8), "") )
			cMotivo			:= iif( !empty(substr(cLinAtu,174,40)), LimpaNome( substr(cLinAtu,174,40) ), "" )    
			cCnpj			:= substr(cLinAtu,30,14)
			cDetAnvisa		:= LimpaNome( alltrim(substr(cLinAtu,44,50)), @oHashAnvi, .t. )
		    cRegAnvisa  	:= substr(cLinAtu,290,15)		    
			cTpProduto		:= iif(cTpProduto=='5','5','1') // BR8_TPPROC 1=Materiais, 5=OPME
			cCodUnd			:= RetUniMedida(Alltrim(substr(cLinAtu,20,10)), cFiliBTQ, cAreaBTQ, cDatPesq, @oHashUnd)

			for nX:=1 to 7
				cLinAtu := oFile:getLine()
				nTot++
				do case 
				case nX == 1
					cDescr	:= LimpaNome( alltrim(cLinAtu) )
				case nX == 2
					cDsProd := LimpaNome( alltrim(cLinAtu) )
				case nX == 3
					cDsEsp 	:= LimpaNome( alltrim(cLinAtu), @oR902Esp, .t. )
				case nX == 4
					cDsClas	:= LimpaNome( alltrim(cLinAtu), @oR902Clas, .t. )
				endcase

			next
			gravaProc(aBF8[nPosicTab,1], aPBox[nPosicPad], cCdMaterial,nVlMax,cTpCarga,dDtInicio,dDtFim,cRegAnvisa,cDetAnvisa,cMotivo,cCnpj,cTpProduto,cTpCodific,cDescr,;
					  cDsProd,cDsEsp,cDsClas,"VMT",,,,,,cCodUnd,xFiliBA8,xFiliBD4,xFiliBR8,lExsDETANV,lExsTUSEDI,cTimDatInt,lExsCODIFI,aBF8[nPosicTab,2])

		endif

		if empty(cLinAtu)
			loop
		endif

		if substr(cLinAtu,9,3) == "905"
			n905++
			cTpCodific	:= substr(cLinAtu,159,1)
			
			nPosicPad 	:= iif( cTpCodific == "1", 5, 6 )	
			nPosicTab 	:= iif( cTpCodific == "1", 3, 4 )
			
			cCdMedic	:= iif( cTpCodific == "1", substr(cLinAtu,211,10), substr(cLinAtu,221,10) )					

			lNaoVaiNao := cCdMedic == "0000000000" //se vier o código com todos zerados, não faz nada
			if !lNaoVaiNao
				dDtInicio	:= stod( iif(!empty(substr(cLinAtu,160,8)), substr(cLinAtu,160,8), cDatPesq) )
				dDtFim		:= stod( iif(!empty(substr(cLinAtu,168,8)), substr(cLinAtu,168,8), "") )
				cRegAnvisa	:= substr(cLinAtu,144,15)			
				cMotivo		:= iif( !empty(substr(cLinAtu,73,40)), LimpaNome( substr(cLinAtu,73,40) ), "" )
				cCnpj		:= substr(cLinAtu,58,14)
				cTpMed		:= substr(cLinAtu,187,1)
				cConfaz 	:= iif(substr(cLinAtu,188,1) == "S", "1", "0")
				cCodUnd		:= RetUniMedida(Alltrim(substr(cLinAtu,20,10)), cFiliBTQ, cAreaBTQ, cDatPesq, @oHashUnd)

				for nX:=1 to 7
					cLinAtu := oFile:getLine()
					nTot++
					do case 
					case nX == 1
						cDescAtiv	:= LimpaNome( alltrim(cLinAtu) )
					case nX == 2
						cDescr 		:= LimpaNome( alltrim(cLinAtu) )
					case nX == 3
						cDescGFarm 	:= LimpaNome( alltrim(cLinAtu), @oR905GrFa, .t. )
					case nX == 4
						cDescCFarm	:= LimpaNome( alltrim(cLinAtu), @oR905ClFa, .t. )
					case nX == 6
						cDetAnvisa	:= LimpaNome( alltrim(cLinAtu), @oHashAnvi, .t. )
					case nX == 7
						nVlMax := val(substr(cLinAtu,17,11)+"."+substr(cLinAtu,28,4))
					endcase
				next
				gravaProc(aBF8[nPosicTab,1],aPBox[nPosicPad],cCdMedic,nVlMax,cTpCarga,dDtInicio,dDtFim,cRegAnvisa,cDetAnvisa,cMotivo,cCnpj,"2",cTpCodific,cDescr,,,,"VMD",;
						cTpMed,cConfaz,cDescAtiv,cDescGFarm,cDescCFarm,cCodUnd,xFiliBA8,xFiliBD4,xFiliBR8,lExsDETANV,lExsTUSEDI,cTimDatInt,lExsCODIFI,aBF8[nPosicTab,2])
			endif
		endif

	enddo
    oFile:Close()
else
	if !lAuto
		msgAlert("Falha na abertura do arquivo: fError[" +cvaltochar(ferror())+"]")
	endif
endif

HMClean(oHashUnd)
HMClean(oR902Esp)
HMClean(oR902Clas)
HMClean(oR905GrFa)
HMClean(oR905ClFa)
HMClean(oHashAnvi)

return lRet

//-----------------------------------------------
/*/{Protheus.doc} validPerg 
Valida perguntas
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
static function validPerg()
local lRet := .t.

BF8->(dbSetOrder(1))
if aPBox[2] == "1"

	lRet := VldCmpPerg(3, 8)
	if !lRet
		MsgAlert("Para criar uma nova TDE é necessário informar os códigos da Tabela Padrão!")
	endif

else
	lRet := VldCmpPerg(9, 14)
	if lRet
		aPBox[3]	:= getBF8(aPBox[9])
		aPBox[4]	:= getBF8(aPBox[10])
		aPBox[5]	:= getBF8(aPBox[11])
		aPBox[6]	:= getBF8(aPBox[12])
		aPBox[7]	:= getBF8(aPBox[13])
		aPBox[8]	:= getBF8(aPBox[14])
		lRet := VldCmpPerg(3, 8) 
		if !lRet
			MsgAlert("TDE informada não possui código de tabela padrão vinculado!")
		endif
	else
		MsgAlert("Para atualizar uma TDE é necessário informar os códigos das TDEs existes!")
	endif
endif

return lRet

//-----------------------------------------------
/*/{Protheus.doc} gravaBF8 
Grava BF8
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
static function gravaBF8(cDesc, cCodPad, cTabTISS, cTpProc)
local cCodigo as array

cCodigo := PLBF8VLC(cCodInt)
BF8->(RecLock("BF8",.T.))
BF8->BF8_FILIAL := xFilial("BF8")
BF8->BF8_CODINT := cCodInt
BF8->BF8_CODIGO := cCodigo
BF8->BF8_DESCM 	:= cDesc
BF8->BF8_CODPAD := cCodPad
BF8->BF8_ESPTPD := "1"
BF8->BF8_TPPROC := cTpProc
BF8->BF8_TABTIS := cTabTISS 
BF8->(MsUnLock())

return cCodInt + BF8->BF8_CODIGO

//-----------------------------------------------
/*/{Protheus.doc} gravaProc 
Grava os procedimentos
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
static function gravaProc(cCodTab,cCodPad,cCdProc,nVlMax,cTpCarga,dDtInicio,dDtFim,cRegAnvisa,cDetAnvisa,cMotivo,cCnpj,cTpProduto,cTpCodific,cDescr,cDsProd,cDsEsp,;
						  cDsClas,cUnidade,cTpMed,cConfaz,cDescAtiv,cDescGFarm,cDescCFarm,cUniMedida,xFiliBA8,xFiliBD4,xFiliBR8,lExsDETANV,lExsTUSEDI,cTimDatInt,lExsCODIFI, cNivel)
local cAtivo := "1"

default cDsProd		:= ""
default cDsEsp		:= ""
default cDsClas		:= ""
default cTpMed		:= ""
default cConfaz		:= ""
default cDescAtiv	:= ""
default cDescGFarm	:= ""
default cDescCFarm	:= ""
default cUniMedida	:= "000"
default lExsDETANV	:= .f.
default lExsTUSEDI	:= .f.
default lExsCODIFI	:= .f.

if cTpCarga == "3"
	cAtivo := "0"
endif

if !BA8->(MsSeek(xFiliBA8+cCodTab+cCodPad+cCdProc))
	BA8->(RecLock("BA8",.T.))
	BA8->BA8_FILIAL := xFiliBA8
	BA8->BA8_CDPADP := cCodPad
	BA8->BA8_CODPRO := cCdProc
	BA8->BA8_DESCRI := cDescr
	BA8->BA8_NIVEL  := cNivel
	BA8->BA8_ANASIN := "1"
	BA8->BA8_CODPAD := cCodPad
	BA8->BA8_CODTAB := cCodTab
	BA8->BA8_RGANVI := cRegAnvisa
	if lExsDETANV
		BA8->BA8_DETANV := cDetAnvisa
	endif
	if lExsCODIFI
		BA8->BA8_CODIFI := cTpCodific
	endif
	BA8->BA8_DSAINA := cMotivo
	BA8->BA8_CNPJ	:= cCnpj
	BA8->BA8_NMFABR := ""
	BA8->BA8_DSPROD	:= cDsProd
    BA8->BA8_DESESP	:= cDsEsp 
	BA8->BA8_DSCLAS	:= cDsClas
	BA8->BA8_SITUAC	:= '1'
	BA8->BA8_ORIGEM	:= '1'
	BA8->BA8_TPPROD := cTpMed 
	BA8->BA8_CONFAZ := cConfaz
	BA8->BA8_DPRINC	:= cDescAtiv    
	BA8->BA8_DGRUFA	:= cDescGFarm
	BA8->BA8_DCFARM	:= cDescCFarm
	BA8->BA8_UNMEDI	:= cUniMedida
	BA8->(MsUnLock()) 	                 
endif
//BD4_FILIAL+BD4_CODTAB+BD4_CDPADP+BD4_CODPRO+BD4_CODIGO+DTOS(BD4_VIGINI)                                                                                         
If BD4->(MsSeek(xFiliBD4+BA8->BA8_CODTAB+BA8->BA8_CDPADP+BA8->BA8_CODPRO))
	BD4->(Reclock("BD4",.F.))
	if BD4->BD4_VIGINI <> dDtInicio
		if empty(BD4->BD4_VIGFIM) .or. BD4->BD4_VIGFIM >= dDtInicio		
			BD4->BD4_VIGFIM := dDtInicio
		endif
	endif
	BD4->(MsUnlock())
endif
cCodPro := BA8->BA8_CODPRO 
cCodTab := BA8->BA8_CODTAB
cCdPaDp := BA8->BA8_CDPADP

If !BD4->(MsSeek(xFiliBD4+BA8->BA8_CODTAB+BA8->BA8_CDPADP+BA8->BA8_CODPRO+cUnidade+dtos(dDtInicio)))		
	BD4->(Reclock("BD4",.T.))
	BD4->BD4_FILIAL := xFiliBD4
	BD4->BD4_CODPRO := BA8->BA8_CODPRO
	BD4->BD4_CODTAB := BA8->BA8_CODTAB
	BD4->BD4_CDPADP := BA8->BA8_CDPADP
	BD4->BD4_CODIGO := cUnidade
	BD4->BD4_VALREF := nVlMax
	BD4->BD4_VIGINI	:= iif(Empty(dDtInicio),dDataBase,dDtInicio)
	BD4->BD4_VIGFIM	:= iif(Empty(dDtFim), dDataVaz, dDtFim)
	BD4->(MsUnlock())		
Endif

if !BR8->(msSeek(xFiliBR8+BA8->BA8_CDPADP+BA8->BA8_CODPRO))
	BR8->(RecLock("BR8",.T.))
    BR8->BR8_FILIAL := xFiliBR8

    BR8->BR8_CODPAD := BA8->BA8_CDPADP
    BR8->BR8_CODPSA := BA8->BA8_CODPRO
    BR8->BR8_NIVEL  := BA8->BA8_NIVEL
	BR8->BR8_ANASIN := BA8->BA8_ANASIN
	BR8->BR8_DESCRI := BA8->BA8_DESCRI

    BR8->BR8_AUTORI := "1"
	BR8->BR8_BENUTL := cAtivo
    BR8->BR8_TPPROC := cTpProduto
    if lExsTUSEDI
		BR8->BR8_TUSEDI := iif(cTpCodific=="2",iif(cTpProduto=="5","1",cTpProduto),"")
	endif
    BR8->BR8_AOINT 	:= "N"
    BR8->BR8_ACAO 	:= "3"
    BR8->BR8_DTINT 	:= cTimDatInt

	BR8->(MsUnLock())
elseif BR8->BR8_BENUTL == "1" .and. cAtivo == "0"
	BR8->(RecLock("BR8",.f.))
	BR8->BR8_BENUTL := cAtivo
	BR8->(MsUnLock())
elseif BR8->BR8_BENUTL == "0" .and. cAtivo == "1"
	BR8->(RecLock("BR8",.f.))
	BR8->BR8_BENUTL := cAtivo
	BR8->(MsUnLock())
endif

return

//-----------------------------------------------
/*/{Protheus.doc} PLSED900MV 
Compatibilidade com o menu antigo
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
function PLSED900MV()
PLSP900()
return

//-----------------------------------------------
/*/{Protheus.doc} getBF8 
Retorna CODPAD da BF8.
@author  Lucas Nonato 
@version P12 
@since   27/01/2020
/*/ 
static function getBF8(cCodigo)
local cRet as char

if BF8->(msSeek(xfilial("BF8")+cCodigo))
	cRet := BF8->BF8_CODPAD
else
	cRet := ""
endif

return cRet

//-----------------------------------------------
/*/{Protheus.doc} RetUniMedida 
Retorna a unidade  de Medida, conforme BTQ, tabela 60, e armazena em hash, para otimizar pesquisa
@version P12 
@since   08/2020
/*/ 
static function RetUniMedida(cCodUnd, cFiliBTQ, cAreaBTQ, cDatPesq, oHashUnd)
local aRetUnd	:= {}
local cSql 		:= ""
local cRet 		:= "000"

if HMGet( oHashUnd, cCodUnd, @aRetUnd ) .and. len(aRetUnd) > 0
	cRet := aRetUnd[1,2]
else
	cSql := "SELECT BTQ_CDTERM COD FROM " + cAreaBTQ
	cSql += "  WHERE BTQ_FILIAL = '" + cFiliBTQ + "' "
	cSql += "    AND BTQ_CODTAB = '60' "
	cSql += "    AND BTQ_DESTER = '" + cCodUnd + "' "
	cSql += "    AND BTQ_VIGDE <= '" + cDatPesq + "' AND ( BTQ_VIGATE >= '" + cDatPesq + "' OR BTQ_VIGATE = ' ' ) "
	cSql += "    AND D_E_L_E_T_ = ' ' "

	dbUseArea(.t., "TOPCONN", TCGENQRY(,,cSql), "UNDMED", .f., .t.)

	cRet := iif( !UNDMED->(eof()), alltrim(UNDMED->COD), "000" )

	UNDMED->(dbclosearea())
	HmAdd(oHashUnd, {cCodUnd, cRet})
endif

return cRet


//-----------------------------------------------
/*/{Protheus.doc} VldCmpPerg 
Valida se os campos de TDE e Tabela do ParamBox estão preenchidos
@version P12 
@since   08/2020
/*/ 
static function VldCmpPerg(nIni, nFim)
local lRet	:= .t.
local nFor	:= 0

for nFor := nIni to nFim
	if empty(aPBox[nFor])
		lRet := .f.
		exit
	endif
next

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} LimpaNome
Retirar caracteres especiais e apóstrofo dos campos de descrição
@since 09/2020
@version P12 
/*/
//-------------------------------------------------------------------
static function LimpaNome(cDescri, oHashPesq, lVrfhash)
local aCaracSub 	:= {"'", '"', ";", "#", "°", 'ª', "$", "•", "=", "º", "§", "¬", "¢", "£"}
local aRetNome		:= {}
local cDescAjuste	:= ""	
local nFor      	:= 0
local lValNome		:= .t.
default lVrfhash	:= .f.

if lVrfhash
	if HMGet( oHashPesq, cDescri, @aRetNome ) .and. len(aRetNome) > 0
		cDescAjuste := aRetNome[1,2]
		lValNome := .f.
	endif
endif 

if lValNome
	cDescAjuste := fwcutoff(cDescri, .t.)
	cDescAjuste := strtran(cDescAjuste, "&", "E")

	for nFor := 1 to Len(aCaracSub)
		cDescAjuste := strtran(cDescAjuste, aCaracSub[nFor], "")
	next

	if lVrfhash
		HmAdd(oHashPesq, {cDescri, cDescAjuste})
	endif
endif

return cDescAjuste


//-------------------------------------------------------------------
/*/ {Protheus.doc} PlRetNivel
Retorna o nível de item da tabela padrão
@since 09/2020
@version P12 
/*/
//-------------------------------------------------------------------
function PlRetNivel(cCodPad)
local cSql 		:= ""
local cRet		:= ""

cSql := " SELECT MAX(BR4_CODNIV) NIV FROM " + RetSqlname("BR4")
cSql += "   WHERE BR4_FILIAL = '" + xFilial("BR4") + "' "
cSql += "   AND BR4_CODPAD = '" + cCodPad + "' "
cSql += "   AND BR4_DIGVER <> '1' "
cSql += "   AND D_E_L_E_T_ = ' '  "

dbUseArea(.t., "TOPCONN", TCGENQRY(,,cSql), "NIVITEM", .f., .t.)

cRet := iif( !NIVITEM->(eof()), cvaltochar(NIVITEM->NIV), "3" )

NIVITEM->(dbclosearea())

return cRet

