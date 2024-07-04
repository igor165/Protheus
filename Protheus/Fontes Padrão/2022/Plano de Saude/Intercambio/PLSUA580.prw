#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "FILEIO.CH"
#DEFINE CRLF chr( 13 ) + chr( 10 )
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA580
Tela MVC com FWMarkBrowse no PTU A580
@author Lucas Nonato
@since  22/05/2019
@version P12
/*/
function PLSUA580() 
local cFilMaster as char
private oBrwPrinc as object

setKey(VK_F2 ,{|| PLSU580FIL(.t.) })

cFilMaster := "@R_E_C_N_O_ in (" + PLSU580FIL() + ") "

oBrwPrinc:= FWMarkBrowse():New()
oBrwPrinc:SetAlias("BGQ")
oBrwPrinc:SetDescription("PTU A580" )
oBrwPrinc:SetMenuDef("PLSUA580")
oBrwPrinc:AddLegend("BGQ_ST580 <> '1'", "YELLOW",	"Não Enviado" )
oBrwPrinc:AddLegend("BGQ_ST580 == '1'", "GREEN",	"Enviado" )
oBrwPrinc:SetFieldMark( 'BGQ_OK' )	
oBrwPrinc:SetAllMark( { || A270Inverte(oBrwPrinc, "BGQ") } )
oBrwPrinc:SetWalkThru(.F.)
oBrwPrinc:SetFilterDefault(cFilMaster)
oBrwPrinc:SetAmbiente(.F.)
oBrwPrinc:ForceQuitButton()
oBrwPrinc:Activate()

return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS580CBX
Combo box BGQ_ID580
@author Lucas Nonato
@since  22/05/2019
@version P12
/*/
function PLS580CBX()
local cRet as char
cRet := "1=Benefício Família;2=Câmara Nacional de Compensação e Liquidação;3=Contribuição Confederativa;4=Programas/Fundos Especiais;"
cRet += "9=Outros;10=Produtos de TI;11=Consultorias;12=Rateios e mensalidades de serviços e/ou produtos;"
cRet += "13=Compensação do processo de aferição;14=Programas de atenção à saúde;15=Remoção/Transporte;16=RDA"
return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP520FIL
Filtro de tela

@author    Lucas Nonato
@version   V12
@since     26/01/2017
/*/
function PLSU580FIL(lF2)

local aPergs	:= {}
local aFilter	:= {}
local cFilter   as char
local cCodOpe   as char
default lF2  	:= .f.

aadd( aPergs,{ 1, "Operadora Destino ", space(4), "@!",'.T.','B39PLS',,40,.f. } )
aAdd( aPergs,{ 1, "Ano:",               space(4), "@R 9999", "", ""		, "", 40, .f.})
aAdd( aPergs,{ 1, "Mes:",               space(2), "@R 99", "", ""		, "", 40, .f.})
aadd( aPergs,{ 2, "Status:", 	        space(1),{ "0=Todas","1=Pendentes","2=Enviadas"},100,/*'.T.'*/,.t. } )

cFilter := " SELECT BGQ.R_E_C_N_O_ FROM " + RetSqlName("BAU") + " BAU "  
cFilter += " INNER JOIN " + RetSqlName("BGQ") + " BGQ "            
cFilter += " ON  BGQ_FILIAL = '" + xFilial("BGQ") + "' "
cFilter += " AND BGQ_CODIGO = BAU_CODIGO "

if( paramBox( aPergs,"Filtro de Tela",aFilter,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSUA580',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
	if !empty(aFilter[2])
        cFilter += " AND BGQ_ANO = '" + aFilter[2] + "' "
    endif
    if !empty(aFilter[3])
        cFilter += " AND BGQ_MES = '" + aFilter[3] + "' "
    endif
    if aFilter[4] <> "0"
		if aFilter[4] == "1"
			cFilter += " AND BGQ_ST580 <> '1' "
		else
			cFilter += " AND BGQ_ST580 = '1' "
		endif
	endif
    cCodOpe := aFilter[1]
endif

cFilter += " AND BGQ_TIPO = '1' "
cFilter += " AND BGQ_NUMLOT <> ' ' "
cFilter += " AND BGQ.D_E_L_E_T_ = ' ' " 
cFilter += " WHERE BAU_FILIAL = '" + xFilial("BAU") + "' "

if !empty(cCodOpe)
    cFilter += " AND BAU_CODOPE = '" + cCodOpe + "' "  
endif

cFilter += " AND BAU_TIPPRE = '" + GetNewPar("MV_PLSTPIN","OPE") + "' "  
cFilter += " AND BAU.D_E_L_E_T_ = ' ' " 

if lF2
	oBrwPrinc:SetFilterDefault("@R_E_C_N_O_ in (" + cFilter + ") ")
	oBrwPrinc:Refresh()
endif

return cFilter

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@version   12.1.17
@since     22/05/2019
/*/
static function MenuDef()
local aRotina := {}
	
ADD OPTION aRotina Title 'Gerar Arquivo' 		Action 'Processa({||PLSU580EXP()},"PTU A580","Processando...",.T.)' OPERATION MODEL_OPERATION_VIEW ACCESS 0
ADD OPTION aRotina Title "<F2> - Filtrar" 		Action 'PLSU580FIL(.t.)'    								 OPERATION MODEL_OPERATION_VIEW ACCESS 0 

return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSU580EXP
Exportação do PTU A580

@author    Lucas Nonato
@version   12.1.17
@since     22/05/2019
/*/
function PLSU580EXP
local cMascara	as char
local cTitulo	:= "Selecione o local"
local nMascpad	:= 0
local cRootPath	as char
local lSalvar	:= .f.	//.F. = Salva || .T. = Abre
local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
local l3Server	:= .f.
local cDir		as char
local cSql		as char
local cR581		as char
local cHash		as char
local cArq		as char
//local oFile 	as object
local aLog		as array
aLog := {}
cSql := " SELECT BGQ_CODSEQ, BGQ_CODOPE, BAU_CODOPE, E2_EMISSAO, BGQ_ANO, BGQ_MES, E2_IRRF, E2_PREFIXO, E2_NUM, BGQ_ID580, E2_VENCTO, BGQ_VALOR, BGQ.R_E_C_N_O_ Recno " 
cSql += " FROM " + RetSqlName("BGQ") + " BGQ "
cSql += " INNER JOIN " + RetSqlName("BAU") + " BAU "            
cSql += " ON  BAU_FILIAL = '" + xFilial("BAU") + "' "
cSql += " AND BAU_CODIGO = BGQ_CODIGO "
cSql += " AND BAU.D_E_L_E_T_ = ' '  "
cSql += " INNER JOIN " + RetSqlName("SE2") + " E2 "            
cSql += " ON  E2_FILIAL = '" + xFilial("SE2") + "' "
cSql += " AND E2_PLOPELT = BGQ_CODOPE "
cSql += " AND E2_PLLOTE = BGQ_NUMLOT "
cSql += " AND E2_FORNECE = BAU_CODSA2 "
cSql += " AND E2_LOJA = BAU_LOJSA2 "
cSql += " AND E2.D_E_L_E_T_ = ' '  "
cSql += " WHERE BGQ_FILIAL = '" + xfilial("BGQ") + "' "
cSql += " AND BGQ_OK = '" + oBrwPrinc:cMark + "' "
cSql += " AND BGQ.D_E_L_E_T_ = ' '  "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMP580",.F.,.T.)

if TMP580->(eof())
	TMP580->(dbclosearea())
	msgAlert("Nenhum registro encontrado.")
	return
endif

cDir := cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )

if empty(cDir)
	TMP580->(dbclosearea())
	return
endif

ProcRegua(-1)

while TMP580->(!eof())	
	cR581 := "00000001"												// 001 NR_SEQ
	cR581 += "581"													// 002 TP_REG
	cR581 += TMP580->BAU_CODOPE										// 003 CD_UNI_DES
	cR581 += TMP580->BGQ_CODOPE										// 004 CD_UNI_ORI
	cR581 += dtos(date())											// 005 DT_GERACAO
	cR581 += substr(TMP580->BGQ_ANO,3,2)+TMP580->BGQ_MES			// 006 NR_COMP
	cR581 += space(11)												// 007 RESERVADO
	cR581 += TMP580->E2_VENCTO										// 008 DT_VEN_DOC
	cR581 += TMP580->E2_EMISSAO										// 009 DT_EMI_ DOC
	cR581 += iif(TMP580->BGQ_VALOR<>0,strzero(noround(TMP580->BGQ_VALOR,2)*100,14),replicate("0",14))	// 010 VL_TOT_ DOC
	cR581 += "08"													// 011 NR_VER_TRA
	cR581 += "00000000000000"										// 012 VL_IR
	cR581 += padr(TMP580->E2_PREFIXO + TMP580->E2_NUM,20) 			// 013 NR_DOCUMENTO
	cR581 += padr(TMP580->E2_PREFIXO + TMP580->E2_NUM,20)			// 014 DOC_FISCAL
	cR581 += "1"													// 015 TP_DOC_A580
	cR581 += iif(!empty(TMP580->BGQ_ID580),strzero(val(TMP580->BGQ_ID580),2),"09")	// 016 ID_COBRANCA

	cHash := "00000002" + "998" + MD5( cR581, 2 )	
	if len(Alltrim(TMP580->E2_NUM)) < 7
	  	cArq	:= "F" + Replicate("_",7-len(alltrim(TMP580->E2_NUM)))+Alltrim(TMP580->E2_NUM)	+ "." + substr(TMP580->BGQ_CODOPE,2,3)		
	else
		cArq	:= "F" + strzero(val(substr(TMP580->E2_NUM,3,7)),7) + "." + substr(TMP580->BGQ_CODOPE,2,3)
	endif 
	//oFile := FWFileWriter():New( cDir +'\'+ cArq ) Função não exporta o nome do arquivo em letra maiuscula conforme manual do ptu
	nArqFull := fCreate( cDir +'\'+ cArq,FC_NORMAL,,.f. )
	if nArqFull > 0//oFile:Create()
		//oFile:Write(cR581 + CRLF + cHash)
		//oFile:Close()	
		fWrite( nArqFull,cR581 + CRLF + cHash )
		fClose( nArqFull )
		BGQ->(dbgoto(TMP580->Recno))
		BGQ->(reclock("BGQ",.f.))
		BGQ->BGQ_ST580 := "1"
		BGQ->(msunlock())
		aadd(aLog,{TMP580->BGQ_CODSEQ,cArq,"Exportado com sucesso!"})
	else	
		aadd(aLog,{TMP580->BGQ_CODSEQ,cArq,"Não foi possivel criar o arquivo!"})
	endif	

	TMP580->(dbskip())
enddo
TMP580->(dbclosearea())
if len(aLog) > 0
	PLSCRIGEN(aLog,{{"Sequencial","@!",30},{"Arquivo","@!",30},{"Mensagem","@!",120}},"Log de geração",nil,nil)
endif

return