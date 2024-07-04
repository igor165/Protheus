#include "PLSMGER.CH"                                                                                 
#Include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA400
PTU - A400 - Movimentacao Cadastral de RDA
@author Thiago Machado Correa
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------

Function PLSUA400(lAuto)
 
Local   cNomArq := ""
Local   cPasta  := "\PTU\"
Local   cPerg   := padr("PLSU04",10)
Local 	lGera450:=.F.
Private lGuiMed	 := .F.
Private Inclui   := .T.
Private lImpostos:= .F.
Private cUniOri
Private cUniDes
Private cRdaIni
Private cRdaFim
Private dDatGer
Private cEmpIni
Private cEmpFin
Private cEmpAtu
Private cTipEnv     
Private cCodLay   := ""
Private cGuiMed	:= ""
Private cTpPrest:= ""
Private aTipEnv := {"A","M","P"}
Private n_TOT_R302     :=0
Private n_TOT_R304     :=0
Private n_TOT_INCL     :=0
Private n_TOT_EXC      :=0
Private n_TOT_ALT      :=0
Private n_TOT_TPPLANO  :=0
Private n_TOT_R305     :=0
Private n_TOT_R306     :=0
Private n_TOT_R307     :=0
Private aEspec := {{"00","00"," "," ","","","","N","","","","","000"},{"00","00"," "," ","","","","N","","","","","000"}} //criado 5 campos a mais no array: BBF_NRESP2, BBF_CDATU2, BBF_POSGRA, BBF_GRADU e BBF_PPRCER
Private l402Valid      := .T.
Private l403Valid      := .T.
Private l404Valid      := .T.
Private l405Valid      := .T.
Private l406Valid      := .F.
Private l407Valid      := .F.
Private cPresta        := ""
Private cLocAte        := ""
Private cCodInt        := ""
Private cTipLoc        := ""
Private aGrpSer        := {}
Private nQtdGrpSer     := 1
Private aStru          := {}
Private aStr2          := {}
Private aStr3          := {}
Private aStr4          := {} 
Private aStr6          := {}
PRIVATE cNomDir		   := Space(70)	
PRIVATE cCrmDir		   := Space(15)
PRIVATE cUFCDir		   := Space(02)
PRIVATE cTipRed        := '0'
PRIVATE cTipGrad	   := '0'	
PRIVATE	cSgCDir        := Space(12)
PRIVATE aCriticas 	   := {}
PRIVATE aCabec    	   := { {"DescriГЦo","@!",800},{"DescriГЦo","@!",0} }
PRIVATE aTitEsp 	   := {{.F.,.F.},{.F.,.F.}}
PRIVATE cCodLoc        := ""
PRIVATE cDatAtu        := Space(8)
PRIVATE cDtBloI        := Space(8)
PRIVATE cDtBloF        := Space(8)
PRIVATE cBAUName := RetSQLName("BAU") //Redes de Atendimento (RDA)
PRIVATE cBAWName := RetSQLName("BAW") //Operadoras da Rede Atendimento
PRIVATE cBB8Name := RetSQLName("BB8") //Locais Atendimento/Rede Atend.
PRIVATE cB0GName := RetSQLName("B0G") //Locais Atendimento/Rede Atend.
PRIVATE cTipOpe  := GetNewPar("MV_PLSTPIN","OPE")
PRIVATE	lImpBloq := .F.
PRIVATE cDirNov       
PRIVATE cNomArq2
PRIVATE NTOTR452  := 0  
PRIVATE lGera408  := .T.
PRIVATE nTotal408:=0
PRIVATE lGera410  := .f.
PRIVATE nBB8Tot	  := 0
PRIVATE nImpBB8	  := 0
PRIVATE lexib180d := .t.

PRIVATE oTempTMP
PRIVATE oTempR04
PRIVATE oTempR05
PRIVATE oTempR06
PRIVATE oTempR07
PRIVATE oTempR08
PRIVATE oTempR53
PRIVATE oTempR54

default lAuto := .f.

aadd(aStru,{"REDEREF","C",5,0})
aadd(aStru,{"DESREF","C",40,0})
aadd(aStr2,{"GRPSER","C",3,0})
aadd(aStr2,{"ATELOC","C",3,0})
AADD(aStr2,{"CODPRE","C",6,0})  
aadd(aStr3,{"CODIMP","C",2,0})
aadd(aStr3,{"VALOR","C",5,0})
AADD(aStr4,{"CGC","C",15,0})
AADD(aStr4,{"ACREDI","C",05,0})
AADD(aStr4,{"NIVEL","C",01,0}) 
AADD(aStr4,{"REFEND","C",02,0})    
AADD(aStr6,{"IDSUBST","C",1,0})
AADD(aStr6,{"CNPJCPF","C",15,0})     
AADD(aStr6,{"DATINI","C",8,0})
AADD(aStr6,{"MOTEXC","C",2,0})       
AADD(aStr6,{"NVLEXC","C",2,0})
AADD(aStr6,{"REDEEXC","C",4,0})
AADD(aStr6,{"DATEXC","C",8,0})
AADD(aStr6,{"PLANEXC","C",20,0})
AADD(aStr6,{"ENDEXC","C",2,0})     
AADD(aStr6,{"MOTSUB","C",2,0})
AADD(aStr6,{"OFICIO","C",10,0})  

BAU->(DbSetOrder(1)) // RDA
BB8->(DbSetOrder(1)) // Local de Atendimento da RDA
BIN->(DbSetOrder(1)) // Grupo de Servico por RDA

//зддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica/Inclui barra no final do diretorio.Ё
//юддддддддддддддддддддддддддддддддддддддддддддды
If Right(cPasta,1) # "\"
	cPasta += "\"
Endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁPerguntas																						Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lAuto .or. Pergunte(cPerg,.T.)
	
    cUniOri := mv_par01
    cUniDes := mv_par02
    cRdaIni := mv_par03
    cRdaFim := mv_par04
    cDtBloI := DtoS(mv_par05)
    cDtBloF := DtoS(mv_par06)
    dDatGer := dDataBase 
    cDirNov := mv_par07
    cTpPrest:= alltrim(mv_par09)//tipos de prestadores que devem ser enviados
 	lGuiMed := (mv_par10 == 1) 		//Imprime RDA com o campo BAU_GUIMED = "Nao"    
 	lImpBloq:= (mv_par11 == 1)
 	cCodLay := mv_par12
 	lImpostos:=(mv_par13 == 1)  //Imprime registro R407 Impostos
 	lGera450:=(mv_par14 == 1)  //Gera os registros 450
    lexib180d:= iif(empty(mv_par16), .t., mv_par16 == 1) //Exibe registros mesmo se a data ultrapassar os 180 dias
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta o nome do arquivo do 400				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды
	if lGera450 .and. !("450" $ mv_par15)
		alert("Layout A450 invalido.")
		return
	endif
    cNomArq := "C"+Substr(DtoS(dDataBase),7,2)+Substr(DtoS(dDataBase),5,2)+Substr(DtoS(dDataBase),3,2)+"."+Substr(cUniOri,2,3)
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta o nome do arquivo	do	450				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды

    cNomArq2 := "C1"+Substr(DtoS(dDataBase),7,2)+Substr(DtoS(dDataBase),5,2)+Substr(DtoS(dDataBase),3,2)+"."+Substr(cUniOri,2,3)
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta a query							 				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды
	UA400Qry(lImpBloq)   
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Verifica se tem registro					Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды
    If EOF()
   		MsgStop("Nenhum registro encontrado para os parametros informados.")   
    Else 
    	//зддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Como inicio no R401, posiciono na operadora origem  Ё
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BA0->(DbSetOrder(1))//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
		BA0->(DbSeek(xFilial("BA0")+cUniOri)) 
		  		 
        PlsPTU(mv_par12,cNomArq,cDirNov)
    EndIf                       
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fecha a query								Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды
    DBSelectArea("TMP")
    DBCloseArea()                 
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Gerando o arquivo 450Fecha a query				Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды
    
    If lGera450
       Gera450Ptu()
    Endif

	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Exibe tela com inconsistencias encontradas durante o processo...    Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If mv_par08 == 1
		If Len(aCriticas) > 0
			PlsCriGen(aCriticas, aCabec, "Log de GeraГЦo...")
		Endif
	Endif
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} UA400Qry
Selecao dos registros
@author Thiago Machado Correa
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Static Function UA400Qry(lImpBloq)
Local cQuery   := ""                                                                 
DEFAULT lImpBloq:= .F.       

cQuery := "SELECT DISTINCT BAU.R_E_C_N_O_, BAU.BAU_CODIGO CODIGO, BAW.BAW_CODINT CODINT, BB8.BB8_CODLOC CODLOC, BB8.BB8_LOCAL TIPLOC "
cQuery += ", BAU.BAU_DATBLO DATBLO, BAU.BAU_RDASUB RDASUB "
cQuery += "FROM " 	+ cBAUname + " BAU "	

cQuery += " INNER JOIN " + cBAWname + " BAW "
cQuery += "  ON BAW.BAW_FILIAL = BAU.BAU_FILIAL "
cQuery += "  AND BAW.BAW_CODIGO = BAU.BAU_CODIGO "
cQuery += "  AND BAW.BAW_CODINT = '" + cUniOri + "' "
cQuery += "  AND BAW.D_E_L_E_T_ <> '*' "

cQuery += " INNER JOIN " + cBB8name + " BB8 "
cQuery += "  ON BB8.BB8_FILIAL  = BAU.BAU_FILIAL "
cQuery += "  AND BB8.BB8_CODIGO = BAU.BAU_CODIGO "
if !lGuiMed
	cQuery += "  AND BB8.BB8_GUIMED <> '0' "
endif
cQuery += "  AND (BB8.BB8_DATBLO = ' ' "
If lImpBloq
	cQuery += " OR BB8.BB8_DATBLO  BetWeen '"+ cDtBloI +"' AND '"+ cDtBloF + "'"
EndIf
cQuery += ") AND BB8.D_E_L_E_T_ <> '*' "

cQuery += "WHERE BAU.BAU_FILIAL = '" + xFilial("BAU") + "' "
cQuery += "  AND BAU.BAU_CODIGO >= '" + cRdaIni + "' "
cQuery += "  AND BAU.BAU_CODIGO <= '" + cRdaFim + "' " 
cQuery += "  AND BAU.BAU_TIPPRE <> '" + cTipOpe + "' "
cQuery += "  AND BAU.BAU_COPCRE <> '4' "
cQuery += "  AND (BAU.BAU_DATBLO = '        '" 
If lImpBloq
	cQuery += " OR BAU.BAU_DATBLO  BetWeen '"+ cDtBloI +"' AND '"+ cDtBloF + "'"
EndIf
cQuery += ") AND BAU.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY BAU.BAU_CODIGO, BB8.BB8_CODLOC "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP",.F.,.T.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A400UrgeEmer
A400UrgeEmer
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400UrgeEmer()    
Local cRetorno

	If A400VeTipPre() $ "01#03#05#06#07#08"
		cRetorno := "N"
	ElseIf A400VeTipPre() == "12" .And. cCodLay >= "A400D"
		cRetorno := "S"
	Else
		If BAU->BAU_URGEME == "1"
			cRetorno := "S"
		Else
			cRetorno := "N"
		Endif
	Endif

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} A400TPEst
PTU - A400 - Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400TPEst()    
Local cRetorno

	If BAU->BAU_CLAEST == "1"
		If A400VeTipPre() $ "02#10"
			cRetorno := "1"
		Else
			cRetorno := " "
		Endif
	ElseIf BAU->BAU_CLAEST == "2"
		If A400VeTipPre() $ "03#04#06#10#11"
			cRetorno := "2"
		Else
			cRetorno := " "
		Endif
	ElseIf BAU->BAU_CLAEST == "3"
		If A400VeTipPre() $ "01#03#04#05#06#07#08#10#11"
			cRetorno := "3"
		Else
			cRetorno := " "
		Endif
	Endif	
Return cRetorno              

//-------------------------------------------------------------------
/*/{Protheus.doc} A400DtOpc
PTU - A400 - Movimentacao Cadastral de RDA	
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400DtOpc()    
Local cRetorno

	If 	dDatGer > stod("20081231")
		cRetorno := BAU->BAU_CNES
	Else
		If Empty(BAU->BAU_CNES)
			cRetorno := " "
		Else
			cRetorno := BAU->BAU_CNES
		Endif			
	Endif

Return cRetorno
                      
//-------------------------------------------------------------------
/*/{Protheus.doc} A400DtIniCont╨Autor
PTU - A400 - Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400DtIniCont()
Local cRetorno := ""
If BAU->BAU_RECPRO == "1"
	cRetorno := PADR('',8)
Else
If BAU->BAU_COPCRE == "2" // Credenciado/Cooperado

	If BAU->BAU_CLAEST == "1" .or. BAU->BAU_CLAEST == "2"
		If (BAU->BAU_DTINCT) >= stod("20030707")
			cRetorno := padr(dtos(BAU->BAU_DTINCT),8)
		else
			cRetorno := padr('',8)			
		Endif
	ElseIf BAU->BAU_CLAEST == "3"
		If (BAU->BAU_DTINCT) >= stod("20031201")
			cRetorno := padr(dtos(BAU->BAU_DTINCT),8)
		else
			cRetorno := padr('',8)
		Endif
	Endif	
Else
    cRetorno := padr('',8)			
EndIf	                            
EndIf

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} A400VeTipPre
PTU - A400 - Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400VeTipPre()
LOCAL cRet := STRZERO(VAL(POSICIONE("BAG",1,XFILIAL("BAG")+BAU->BAU_TIPPRE,"BAG_CODPT")),2)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё NR_CRM_DIRETOR_TEC = NЗmero do CRM do Diretor TИcnico da entidade de saude. Ё
//Ё NM_DIRETOR_TECNICO = Nome do Diretor TИcnico da entidade de saude 		    Ё
//Ё 																			Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

	Do Case
		Case Val(BAU->BAU_SIGDIR) == 1
			cSgCDir := PadR("CRESS",12)
		Case Val(BAU->BAU_SIGDIR) == 2
			cSgCDir := PadR("COREN",12)	
		Case Val(BAU->BAU_SIGDIR) == 3
			cSgCDir := PadR("CRF",12)	
		Case Val(BAU->BAU_SIGDIR) == 4
			cSgCDir := PadR("CREFONO",12)	
		Case Val(BAU->BAU_SIGDIR) == 5
			cSgCDir := PadR("CREFITO",12)	
		Case Val(BAU->BAU_SIGDIR) == 6
			cSgCDir := PadR("CRM",12)	
		Case Val(BAU->BAU_SIGDIR) == 7
			cSgCDir := PadR("CRV",12)	
		Case Val(BAU->BAU_SIGDIR) == 8
			cSgCDir := PadR("CRN",12)		
		Case Val(BAU->BAU_SIGDIR) == 9
			cSgCDir := PadR("CRO",12)		
		Case Val(BAU->BAU_SIGDIR) == 10
			cSgCDir := PadR("CRP",12)		
		OtherWise 
			cSgCDir := PadR("OUT",12)
	EndCase

	
cNomDir := IIf(Empty(BAU->BAU_DIRTEC),Space(70),BAU->BAU_DIRTEC)
cCrmDir := IIf(Empty(BAU->BAU_DIRREG),Space(15),BAU->BAU_DIRREG)
cUFCDir := IIf(Empty(BAU->BAU_UFCDIR),Space(02),BAU->BAU_UFCDIR)
cTipRed := IIf(Empty(BAU->BAU_TIPRED),'0',BAU->BAU_TIPRED)
  
Return cRet
                        
//-------------------------------------------------------------------
/*/{Protheus.doc} A402Inicio
PTU - A400 - Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A402Inicio()
local lFlag400
local cSQL		:= ""
local nFor  	:= 0 
local nRecBB8 	:= 0
local nAliqISS 	:= 0
local aImpostos := {}   
local aAreaBAU  := {}
local cCodRDA   := ""
local cDtIni    
local aABAU     := {}
local cSqlBC4	:= ""
local cMotSub 	:= "00"
local cNumOfi 	:= space(10)
local lMen180dias := .T. //Flag para prestadores com substituicao com menos de 180 dias
local cCodBlo	:=""
	//зддддддддддддддддддддддд©
	//Ё Zera Variaveis		  Ё
	//юддддддддддддддддддддддды
	l402Valid := .T.
	l403Valid := .T.
	l404Valid := .T.
	l405Valid := .T.
	l406Valid := .F.
	l407Valid := .F.
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza variaveis							Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды	
	cPresta   := TMP->CODIGO
	cLocAte   := TMP->CODLOC
	cCodInt   := TMP->CODINT
	cTipLoc   := TMP->TIPLOC
	
	//Posiciona BAU
    If (! BAU->(MsSeek(xFilial("BAU")+cPresta))) .and. l402Valid 
        Aadd(aCriticas, {"BAU nao encontrado: " + cPresta,""} )
		l402Valid := .F. 	
		
    EndIf

    cGuiMed := If(BAU->BAU_GUIMED <> "0","S","N") 
	cDatAtu := Dtos(BAU->BAU_DATATU)
 
   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria arquivo temporario QUALIFICAгцO DOS PRESTADORES 408   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	//--< CriaГЦo do objeto FWTemporaryTable >---
	if( select( "R08" ) > 0 )
		R08->( dbCloseArea() )
	endIf

	oTempR08 := FWTemporaryTable():New( "R08" )
	oTempR08:SetFields( aStr4 )
	oTempR08:AddIndex( "INDR08",{ "CGC" } )		
	
	oTempR08:Create()
	dbSelectArea("R08")

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Cria arquivo temporario para gravar as Redes Referenciadas Ё
    //Ё Gera registro A404 Impostos                                Ё
	//Ё Cria arquivo temporario para gravar os Grupos de Servicos  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	if( select( "R04" ) > 0 )		
		R04->( dbCloseArea() )		
	endIf

	//--< CriaГЦo do objeto FWTemporaryTable >---
	oTempR04 := FWTemporaryTable():New( "R04" )
	oTempR04:SetFields( aStr2 )
	oTempR04:AddIndex( "INDR04",{ "CODPRE","ATELOC","GRPSER" } )	
	
	oTempR04:Create()
	
	DbSelectArea("R04")

	R04->(dbsetorder(1))
	BAG->(dbsetorder(1))
	//Posiciona Grupos de Servicos x RDA						   
	If !BIN->(MsSeek(xFilial("BIN")+cPresta+cCodInt)) .and. !(strzero(val(posicione("BAG",1,xfilial("BAG")+BAU->BAU_TIPPRE,"BAG_CODPT")),2) $ '01,05')
    	PlsPtuLog("Prestador 'BAU' sem nenhum grupo de servico 'BIN': " + cPresta,"plsptu400.log")
	    Aadd(aCriticas, {"Prestador 'BAU' sem nenhum grupo de servico 'BIN': " + cPresta,""} )
	 	l402Valid := .F.
	Else
		While (xFilial("BIN")+cPresta+cCodInt)==(BIN->BIN_FILIAL+BIN->BIN_CODIGO+BIN->BIN_CODINT) .and. BIN->(!Eof())
	  		If BB8->(DbSeek(BIN->BIN_FILIAL+BIN->BIN_CODIGO+BIN->BIN_CODINT+BIN->BIN_CODLOC))
		 	   If BB8->BB8_GUIMED <> "0" .or. lGuiMed
					R04->(Reclock("R04",.T.))
					R04->GRPSER := BIN->BIN_CODGRU                 
					R04->ATELOC := BIN->BIN_CODLOC   
	   				R04->CODPRE := cPresta 
	   				R04->(MsUnlock())
	   			Endif	
   			Endif	
			BIN->(DBSKIP())
		Enddo
	Endif
	 
	R04->(DbGoTop())  

    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Gera registro A405 Impostos                                Ё
	//Ё Registra no log							                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	if( select( "R05" ) > 0 )
		R05->( dbCloseArea() )
	endIf	
	//--< CriaГЦo do objeto FWTemporaryTable >---
	oTempR05 := FWTemporaryTable():New( "R05" )
	oTempR05:SetFields( aStru )
	oTempR05:AddIndex( "INDR05",{ "REDEREF" } )
		
	oTempR05:Create()

	dbSelectArea( "R05" )
	R05->( dbSetorder( 1 ) )
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alimenta registro da Redes Referenciadas Rde basicaЁ
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	cSQL := "SELECT B0G_ABRRED, B0G_CODREF, B0G_DESCRI FROM "
    cSQL += RetSqlName("B0G")+" WHERE "
    cSQL += "B0G_FILIAL = '"+xFilial("B0G")+"' AND "
    cSQL += "B0G_CODRDA = '"+BAU->BAU_CODIGO+"' AND "
    cSQL += "D_E_L_E_T_ = ' ' "
    cSQL += "ORDER BY B0G_ABRRED, B0G_CODREF "      
    
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"B0GTMP",.F.,.T.)
	
    If B0GTMP->(Eof())
        If (BAU->(DbSeek(xFilial("BAU")+cPresta))) 
       		If BAU->BAU_COPCRE <> '1'
       			AADD(aCriticas, {"Abrangencia de rede de atendimento 'B0G' nao encontrado: " + cPresta,""} )
       			l402Valid := .F.    	    
       		EndIf	
		EndIf		
    Endif    
    While !B0GTMP->(Eof())
	    R05->(Reclock("R05",.T.))         
	   	R05->REDEREF := B0GTMP->B0G_ABRRED+StrZero(Val(B0GTMP->B0G_CODREF),2)+Space(1)				
  		R05->DESREF  := B0GTMP->B0G_DESCRI
	  	R05->(MsUnlock())     
	  	B0GTMP->(dbSkip())			     
    EndDo                                 
    B0GTMP->(dbCloseArea())

	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicio do Arquivo							Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды    
	R05->(DbGoTop())  
	cBAGPT := STRZERO(VAL(POSICIONE("BAG",1,XFILIAL("BAG")+BAU->BAU_TIPPRE,"BAG_CODPT")),2)                                                                                             
	If !Empty(cTpPrest)		
		If !(cBAGPT $ cTpPrest)
			Aadd(aCriticas, {"Tipo de prestador["+cBAGPT+"] nЦo processado. Tipos selecionados["+alltrim(cTpPrest)+"] BAU: "+ BAU->BAU_CODIGO,""} )
			l402Valid := .F.
		Endif      
	Else
		If R04->(Eof()) .And. !(cBAGPT $ '01,05')    
	        Aadd(aCriticas, {"Tipo de prestador["+cBAGPT+"] nЦo processado. Tipos selecionados["+alltrim(cTpPrest)+"] BAU: "+ BAU->BAU_CODIGO,""} )
		    l402Valid := .F.
		Endif
    Endif
        
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Gera registro A407 Impostos                                Ё
    //Ё Cria arquivo temporario para gravar os impostos            Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    if( select( "R07" ) > 0 )
		R07->( dbCloseArea() )
	endIf
    //--< CriaГЦo do objeto FWTemporaryTable >---
	oTempR07 := FWTemporaryTable():New( "R07" )
	oTempR07:SetFields( aStr3 )
	oTempR07:AddIndex( "INDR07",{ "CODIMP" } )	
	
	oTempR07:Create()
	
	dbSelectArea( "R07" )
	R07->( dbSetorder( 1 ) )
	                
	l407Valid := .F. //Reinicializa variavel de controle 
	nAliqISS  :=  0
    If lImpostos
        DbSelectArea("SA2")
        DbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
        If SA2->(DbSeek(xFilial("SA2")+BAU->(BAU_CODSA2+BAU_LOJSA2)))  
            DbSelectArea("SED")
            DbSetOrder(1)//ED_FILIAL+ED_CODIGO
            If SED->(DbSeek(xFilial("SED")+SA2->A2_NATUREZ))   
                //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    	        //Ё Monta Array com as aliquotas                               Ё
         	    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         	    //ISS
         	    If SA2->A2_RECISS <> "1" .And. SED->ED_CALCISS == "S"    
         	        nAliqISS := GetNewPar("MV_ALIQISS",0)
         	        If nAliqISS > 0 
         	            aadd(aImpostos,{"01",StrZero(nAliqISS*100,5)})    
         	        EndIf    
         	    EndIf
                 
                //INSS
                If  SA2->A2_RECINSS == "S" .And. SED->ED_CALCINS == "S"
                    aadd(aImpostos,{"02",StrZero(SED->ED_PERCINS*100,5)})      
                EndIf
                    
                //IRRF 
                If SED->ED_CALCIRF == "S"
                    aadd(aImpostos,{"03",StrZero(SED->ED_PERCIRF*100,5)}) 
                EndIf
                
                //PIS
                If SA2->A2_RECPIS <> "1"  .And. SED->ED_CALCPIS == "S"  
                    aadd(aImpostos,{"04",StrZero(SED->ED_PERCPIS*100,5)})
                EndIf   
                
                //COFINS
                If SA2->A2_RECCOFI <> "1" .And. SED->ED_CALCCOF == "S" 
                    aadd(aImpostos,{"05",StrZero(SED->ED_PERCCOF*100,5)})
                EndIf
                
                //CSSL
                If SA2->A2_RECCSLL <> "1" .And. SED->ED_CALCCSL == "S"
                    aadd(aImpostos,{"06",StrZero(SED->ED_PERCCSL*100,5)}) 
                EndIf 
                   
                If len(aImpostos) > 0 
                    
                    For nFor := 1 to len(aImpostos) 
	                   R07->(Reclock("R07",.T.))
	                       R07->CODIMP := aImpostos[nFor][1]
	                       R07->VALOR  := aImpostos[nFor][2]
	                   R07->(MsUnlock())
                    Next 
                    R07->(DbGoTop())
                    l407Valid := .T.                     
                   
                EndIf 
            EndIf
        EndIf
    EndIf    
    
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
    //Ё Gera registro A406 Exclusao                                Ё
    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    if( select( "R06" ) > 0 )
		R06->( dbCloseArea() )
	endIf
	//--< CriaГЦo do objeto FWTemporaryTable >---
	oTempR06 := FWTemporaryTable():New( "R06" )
	oTempR06:SetFields( aStr6 )
	oTempR06:AddIndex( "INDR06",{ "CNPJCPF" } )	
	
	oTempR06:Create()
	
	DbSelectArea( "R06" )
	R06->( dbSetorder( 1 ) )
	
	//Alimenta Especialidades da RDA
	If l402Valid
		l402Valid := A400EncEsp()
		If !l402Valid
			AADD(aCriticas, {"Verificar Tipo Prestador/ Especialidade para gerar R402: " + cPresta,""} )
       	Endif		
	Endif
	// Verifica se RDA Bloqueado para Gerar R406
	If !Empty(BAU->BAU_RDASUB) .Or. (!Empty(dTos(BAU->BAU_DATBLO)) .And. (cDtBloI <= dTos(BAU->BAU_DATBLO) .And. cDtBloF >= dTos(BAU->BAU_DATBLO)))
		l406Valid := .T.  
	EndIf
	If l402Valid		
		
		cSqlBC4	:= " SELECT BC4_DTBLQ, BC4_HORA, BC4_TIPO, BC4_MOTSUB, BC4_OFICIO "
		cSqlBC4 += " FROM " + retsqlname("BC4") + " BC4 "
		cSqlBC4 += " WHERE BC4_FILIAL = '" + BAU->BAU_FILIAL +"' "
		cSqlBC4 += " AND BC4_CODCRE	= '" + BAU->BAU_CODIGO +"' "
		cSqlBC4 += " AND BC4.D_E_L_E_T_ = ' ' "
		cSqlBC4 += " ORDER BY "
		cSqlBC4 += " BC4_DTBLQ || BC4_HORA DESC " 
		cSqlBC4 := ChangeQuery(cSqlBC4)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSqlBC4),"tmpBC4",.F.,.T.)
		
		if !tmpBC4->(eof()) .and. tmpBC4->BC4_TIPO == '0' .and. !empty(tmpBC4->BC4_MOTSUB) 
			cMotSub	:= iif(!empty(tmpBC4->BC4_MOTSUB),tmpBC4->BC4_MOTSUB,"00")
			cNumOfi := iif(!empty(tmpBC4->BC4_OFICIO),tmpBC4->BC4_OFICIO,space(10))
		else
			cMotSub := "00"
			cNumOfi := space(10)
		endif
		tmpBC4->(dbCloseArea())

	 	B7O->(DbSetOrder(1))
	 	If B7O->(DbSeek(xFilial("B7O")+BAU->BAU_CODIGO))  			

	 		l406Valid := .T.
	 		cCodRDA  := BAU->BAU_CODIGO
	 		aAreaBAU := BAU->(GetArea()) 
	 		cDtIni   := iif(empty(BAU->BAU_DATBLO),space(8),dTos(BAU->BAU_DATBLO +1))		
	 		BAU->(DbSetOrder(1))
			nRecBB8	:= BB8->(recno())

            //Verifica se vai exibir ou nao prestadores substituidos ha mais de 180 dias
            if lexib180d 
                lMen180dias := .T. //Ira exibir como se fosse um registro com menos de 180 dias
            Else
                lMen180dias := IIF( DateDiffDay(B7O->B7O_DTBLOQ,Date())<181 , .T. , .F. )
            endif

	 		While B7O->(B7O_FILIAL+B7O_CODRDA )== xFilial("B7O")+cCodRDA .And. !B7O->(Eof()) .And. lMen180dias
	 		  	//BB8_FILIAL, BB8_CODIGO, BB8_CODINT, BB8_CODLOC, BB8_LOCAL, R_E_C_N_O_, D_E_L_E_T_
				if B7O->B7O_NVEXC == '04' .and. BB8->(msseek(xFilial("BB8") + B7O->B7O_CODRDA + cCodInt + '0' + B7O->B7O_ENDEXC)) .and. BB8->BB8_GUIMED == '0'
					B7O->(DbSkip())
					loop
				endif
	 		  	R06->(Reclock("R06",.T.)) 
					aABAU    := BAU->(GetArea())					
					If BAU->(DbSeek(xFilial("BAU")+B7O->B7O_PRESUB))
						R06->CNPJCPF 	:= Strzero(Val(BAU->BAU_CPFCGC),15) 
					EndIf   
					if empty(R06->CNPJCPF)
						R06->CNPJCPF 	:= Replicate("0",15) 
					endif
					RestArea(aABAU)  	                        
					R06->IDSUBST   	:= Iif(Empty(B7O->B7O_PRESUB),'N','S')
					R06->DATINI 	:= iif(R06->IDSUBST == "S",cDtIni,'')  

					//Motivo de exlcusЦo do Local
					if B7O->B7O_NVEXC == '04'						
						cCodblo:= PTUBB8EXC(BAU->BAU_CODIGO,PlsIntPad(),B7O->B7O_ENDEXC)
						R06->MOTEXC := iif(!empty(cCodblo) .and. R06->IDSUBST == 'N' ,cCodblo,"00" )
					else
						R06->MOTEXC := IIf(!Empty(BAU->BAU_EXCEDI) .and. R06->IDSUBST == 'N' ,BAU->BAU_EXCEDI,"00") 
					endif
					R06->NVLEXC  	:= Iif(Empty(B7O->B7O_NVEXC),'01',B7O->B7O_NVEXC) 
					R06->REDEEXC	:= B7O->B7O_REDEXC
					R06->DATEXC		:= Iif(!Empty(R06->IDSUBST) .And. Empty(B7O->B7O_DTBLOQ), DToS(BAU->BAU_DATBLO+1) ,DToS(B7O->B7O_DTBLOQ))
					R06->PLANEXC	:= B7O->B7O_PLAEXC 
					R06->ENDEXC		:= Iif(Empty(B7O->B7O_ENDEXC),'00',B7O->B7O_ENDEXC)	
					R06->MOTSUB		:= iif(R06->NVLEXC == '01',cMotSub,"00")
					R06->OFICIO		:= iif(R06->NVLEXC == '01',cNumOfi,space(10))	
					
				R06->(MsUnlock())                  
		 		
		 		B7O->(DbSkip())
			EndDo
			BB8->(dbgoto(nRecBB8))
			R06->(DbGoTop())
			RestArea(aAreaBAU)  		
		// RN 365
		// Assim que o cooperado deixar de prestar atendimento enviar o A400 com o R406, informando a data fim de atendimento 
		// no campo DT_TERMINO_PREST do R406, com ID_SUBSTITUTO "NЦo" e o motivo 06	
		Elseif BAU->BAU_INATIV == '1' .And. BAU->(fieldPos("BAU_DTINAT")) > 0			
			R06->(Reclock("R06",.T.))         
			 	R06->IDSUBST    := "N"
				R06->CNPJCPF 	:= Replicate("0",15) 
				R06->DATINI 	:= Space(8)
				R06->MOTEXC 	:= "06"
				R06->NVLEXC   	:= "01"				
				R06->REDEEXC	:= Space(4)
				R06->PLANEXC	:= Space(20) 
				R06->DATEXC		:= dTos(BAU->BAU_DTINAT)
				R06->ENDEXC		:= REPLICATE("0",2)	
				R06->MOTSUB		:= "00"
				R06->OFICIO		:= space(10)					
			R06->(MsUnlock()) 
			  				
			R06->(DbGoTop())  
			l406Valid := .T.
			If empty(dTos(BAU->BAU_DTINAT))
				aAdd(aCriticas, {"Prestador 'BAU' inativo sem data de fim de atendimento(BAU_DTINAT) preenchida - RDA: " + cPresta,""} )		
			EndIf 		
	 	ElseIf l406Valid
	 		R06->(Reclock("R06",.T.))         
			R06->IDSUBST    := "N"
			R06->CNPJCPF 	:= Replicate("0",15) 
			R06->DATINI 	:= Space(8)
			R06->MOTEXC 	:= IIf(!Empty(BAU->BAU_EXCEDI),BAU->BAU_EXCEDI,"00")
			R06->NVLEXC   := Iif(Empty(B7O->B7O_NVEXC ),'01', B7O->B7O_NVEXC )
			If B7O->(FieldPos('B7O_DTBLOQ')) > 0
				R06->REDEEXC	:= Iif(Empty(B7O->B7O_REDEXC),Space(4), B7O->B7O_REDEXC)
				R06->PLANEXC	:= Iif(Empty(B7O->B7O_PLAEXC),Space(20),B7O->B7O_PLAEXC) 
				R06->DATEXC		:= dTos(BAU->BAU_DATBLO)
				R06->ENDEXC		:= Iif(Empty(B7O->B7O_ENDEXC),REPLICATE("0",2), B7O->B7O_ENDEXC)
			Else 
				R06->REDEEXC	:= Space(4)
				R06->PLANEXC	:= Space(20)
				R06->ENDEXC		:= REPLICATE("0",2)
				R06->DATEXC		:= Space(8)
			EndIf
			R06->MOTSUB		:= iif(R06->NVLEXC == '01',cMotSub,"00")
			R06->OFICIO		:= iif(R06->NVLEXC == '01',cNumOfi,space(10))
			R06->(MsUnlock())   
			
			R06->(DbGoTop())  
			l406Valid := .T.
		 EndIf 	 	
	Endif
	
	lGera410 := .f.
	if l402Valid .and. !empty(BAU->BAU_OBSGUI)
		lGera410 := .t.
	endIf
		
Return l402Valid

//-------------------------------------------------------------------
/*/{Protheus.doc} A400EncEsp
PTU - A400 - Movimentacao Cadastral de RDA	
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400EncEsp()
Local nI        
Local nPos      
Local lRet := .F.     
Local cQryGer := ""
//зддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ordem										Ё
//юддддддддддддддддддддддддддддддддддддддддддддды
BBF->(DbSetOrder(1))
BAQ->(DbSetOrder(1))
BAX->(DbSetOrder(3))

nI     := 1  
aEspec := {{"00","00"," "," ","","","","N","","","","","000"},{"00","00"," "," ","","","","N","","","","","000"}}
aTitEsp:= {{.F.,.F.},{.F.,.F.}}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verificando se o campo BBF_GERPTU esta preenchido em alguma especialidadeЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cQryGer := "SELECT COUNT(*) QTD FROM "+RetSqlName("BBF")+" WHERE BBF_GERPTU = '1'"
	cQryGer += " AND BBF_CODIGO = '"+TMP->CODIGO+"'"
	cQryGer += " AND D_E_L_E_T_ <> '*'"
	
	cQryGer := ChangeQuery(cQryGer)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryGer),"CntPTU",.F.,.T.)

//зддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no BBF							Ё
//юддддддддддддддддддддддддддддддддддддддддддддды
If BBF->(MsSeek(xFilial("BBF")+TMP->CODIGO))

	While (nI <= 2 .And. BBF->BBF_CODIGO == TMP->CODIGO .And. ! BBF->(Eof()))
        
		If (dtos(BBF->BBF_DATBLO) == Space(8)) .Or. (BBF->BBF_DATBLO > dDatGer) .Or. (BBF->BBF_DATBLO >= StoD(cDtBloI) .And. BBF->BBF_DATBLO <= StoD(cDtBloF))
			If BAQ->(MsSeek(xFilial("BAQ")+BBF->(BBF_CODINT+BBF_CDESP)))     
				//Se o campo BBF_GERPTU nao existe ou nao esta configurado, pego as duas primeiras especialidades para a geracao do arquivo
				If  CntPTU->QTD <> 0
					If BBF->BBF_GERPTU <> "1"
						BBF->(DbSkip())
						Loop
					Endif
				Endif 
				
				lRet := .F.
				
				BAX->(dbSeek(xFilial("BAX")+BBF->(BBF_CODINT+BBF_CDESP+BBF_CODIGO)))
				While BAX->(BAX_FILIAL+BAX_CODINT+BAX_CODESP+BAX_CODIGO) ==;
					 	xFilial("BAX")+BBF->(BBF_CODINT+BBF_CDESP+BBF_CODIGO) .And.;
						!BAX->(Eof())				
				 	If BAX->BAX_GUIMED == '1'	    
				 		lRet := .T.
				 		Exit	
				 	EndIf	
				 	BAX->(dbSkip())					
				EndDo
			                       
				If lRet
					
					nPos := aScan(aEspec,{|x| x[1] == StrZero(Val(BAQ->BAQ_INTERC),2)+StrZero(Val(BBF->BBF_CODATU),2)})
	             
					If  nPos == 0 .AND. A400VETIPPRE() == "01"
	
							aEspec[nI][1] := StrZero(Val(BAQ->BAQ_INTERC),2)
						If !Empty(BBF->BBF_CODATU)
							aEspec[nI][2] := StrZero(Val(BBF->BBF_CODATU),2)
						Else 
                            aEspec[nI][2] := "00"  
                       	Endif
		
	                   	aEspec[nI][3] 	:= IIf(BBF->BBF_GUIESP $'0/ ',IIf(aEspec[nI][1]== "00"," ",'N'),'S')
	                   	aEspec[nI][4] 	:= IIf(BBF->BBF_GUIATU $'0/ ',IIf(aEspec[nI][2]== "00"," ",'N'),'S')
  						aEspec[nI][5] 	:= Strzero(Val(BBF->BBF_NRESP),Len(BBF->BBF_NRESP))
  						aEspec[nI][6] 	:= Strzero(Val(BBF->BBF_NRESP2),Len(BBF->BBF_NRESP2))
	  					aEspec[nI][7] 	:= Strzero(Val(BBF->BBF_NRATU),Len(BBF->BBF_NRATU))
	                 	aEspec[nI][8] 	:= IIF(BBF->BBF_POSGRA$'0/ ',IIf(aEspec[nI][1]=="00"," ",'N'),'S')         
						cTipGrad 		:= IIf(Empty(BBF->BBF_GRADU),'0',BBF->BBF_GRADU)
						aEspec[nI][9] 	:= cTipGrad
	                 	aEspec[nI][10] 	:= IIF(BBF->BBF_PPRCER$'0/ ',IIf(aEspec[nI][1]=="00"," ",'N'),'S')         
		               	aEspec[nI][11] 	:= Strzero(Val(BBF->BBF_NRATU2),Len(BBF->BBF_NRATU2))    
			 			aEspec[nI][12] 	:= BBF->BBF_GINOBS 
	        		    aTitEsp[nI][1] 	:= If(BBF->BBF_TITESP=='1',.T.,.F.) 
		        	    aTitEsp[nI][2] 	:= If(BBF->BBF_TITATU=='1',.T.,.F.)
		
				 	Else            
						aEspec[nI][1] := " "
						aEspec[nI][2] := " "
						aEspec[nI][3] := " "
						aEspec[nI][4] := " "
						aEspec[nI][5] := STRZERO(0,10)
					Endif  
				
					If nPos == 0 .AND. A400VETIPPRE()=="05"
						aEspec[nI][8] := IIF(BBF->BBF_POSGRA$'0/ ',IIf(aEspec[nI][1]=="00"," ",'N'),'S')         
						cTipGrad := IIf(Empty(BBF->BBF_GRADU),'0',BBF->BBF_GRADU)
						aEspec[nI][9] := cTipGrad
	            	   	aEspec[nI][10] := IIF(BBF->BBF_PPRCER$'0/ ',IIf(aEspec[nI][1]=="00"," ",'N'),'S')         
					EndIF				
	                				
					aEspec[nI][13] := IIf(Empty(BBF->BBF_CODTIT),"000",BBF->BBF_CODTIT)								
					nI++
				EndIf
			EndIf
		Endif
			
		BBF->(DbSkip())
	EndDo

EndIf
	CntPTU->(dbCloseArea())

If nI == 1 .and. A400VeTipPre() = '01'
	l402Valid := .F.
Endif

Return l402Valid

//-------------------------------------------------------------------
/*/{Protheus.doc} A403Inicio
PTU - A400 - Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A403Inicio()

	aGrpSer    := {}
	nQtdGrpSer := 1
	l403Valid  := .T.
	//зддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alimenta variaveis							Ё
	//юддддддддддддддддддддддддддддддддддддддддддддды	
	cPresta    := TMP->CODIGO
	cLocAte    := TMP->CODLOC
	cCodInt    := TMP->CODINT
	cTipLoc    := TMP->TIPLOC
	
	//Reposiciona BB8
    If ! BB8->(MsSeek(xFilial("BB8")+cPresta+cCodInt+cLocAte+cTipLoc))
		l403Valid := .F.
	Else

		While (xFilial("BB8")+cPresta+cCodInt+cLocAte+cTipLoc)==(BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL)) .and. BB8->(!Eof())
			If ( BB8->BB8_DATBLO >= StoD(cDtBloI) .AND. BB8->BB8_DATBLO <= StoD(cDtBloF) ) .or. (!Empty(BB8->BB8_DATBLO) .and. !empty(cDtBloF))
				//Segue a mesma regra do R406, se passou 180 dias nЦo mostra mais
				if !lexib180d .and. dateDiffDay(BB8->BB8_DATBLO,Date()) > 181
					BB8->(DbSkip())   
			    else
					exit         	 
           		endif			
			Else
			    Exit
			Endif
		Enddo

		If !(xFilial("BB8")+cPresta+cCodInt+cLocAte+cTipLoc)==(BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL)) .OR. BB8->(Eof())
			l403Valid := .F.
		Endif

    Endif

Return l403Valid

//-------------------------------------------------------------------
/*/{Protheus.doc} A400Valid
PTU - A400 - Movimentacao Cadastral de RDA	
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400Valid(cReg)
Local lRet

	Do Case 
		Case cReg == "402"
			lRet := A402Inicio()
		Case cReg == "403"
			A403INICIO()
			lRet := ( l402Valid .and. l403Valid )
			R04->(dbSelectArea("R04"))
			R04->(dbSeek(TMP->CODIGO+TMP->CODLOC))
		Case cReg == "404"
			If A400VeTipPre() == "01"
				lRet := ( l402Valid .and. l403Valid )
			Else
				lRet := ( l402Valid .and. l403Valid .and. l404Valid )
			Endif
		Case cReg == "405"
			If A400VeTipPre() == "01"
				lRet := ( l402Valid .and. l403Valid )
			ElseIf A400VeTipPre() == "05"
				lRet := ( l402Valid .and. l403Valid .and. l404Valid )			
			Else
				lRet := ( l402Valid .and. l403Valid .and. l404Valid .and. l405Valid )			
			Endif
		Case cReg == "406" 
		  		lRet := l406Valid
		Case cReg == "407"
				lRet := (l402Valid .And. l407Valid)
		Otherwise
			lRet := .F.
	Endcase

Return lRet
  
//-------------------------------------------------------------------
/*/{Protheus.doc} A400GrpSer 
PTU - A400 - Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400GrpSer()
	nQtdGrpSer++
Return aGrpSer[nQtdGrpSer-1]

//-------------------------------------------------------------------
/*/{Protheus.doc} A400RANS 
Pega o codigo a ans da operadora do RDA 
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400RANS()         
Local cRet := ""
	
BA0->( DbSetOrder(1) )//BA0_FILIAL+BA0_CODIDE+BA0_CODINT 
BA0->(MsSeek(xFilial("BA0")+cUniOri))	
	
If BA0->BA0_TPOPED == "1"
	cRet := "000000"
Else
   	cRet := Alltrim(BA0->BA0_SUSEP)
EndIf
	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A400Email
Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400Email(cTipo)
Local cRetorno       
Local nSize   := 80   
Default cTipo := ""
	
cRetorno := space(nSize)

// Email principal
If cTipo == "P" .Or. Empty(cTipo)

	If Empty(BB8->BB8_EMAIL) .And. !Empty(BAU->BAU_EMAIL)
		cRetorno := Padr(BAU->BAU_EMAIL,nSize)
	Else                     
		cRetorno := Padr(BB8->BB8_EMAIL,nSize)
	Endif

// Email secundario 
ElseIf cTipo == "S"
	cRetorno := Padr(BB8->BB8_EMASEC,nSize)
EndIf
                       
If Existblock("P400EMAL")
	cRetorno := ExecBlock("P400EMAL",.F.,.F.,{cRetorno})
Endif
	
Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} A400ObsG
Retorna a observacao da guia

@author TOTVS
@since 11/12/2015
@version P11
/*/
//-------------------------------------------------------------------
function A400ObsG()
local cRetorno := space(250) 

cRetorno := padR(allTrim(BAU->BAU_OBSGUI),250)
	
return cRetorno
     
//-------------------------------------------------------------------
/*/{Protheus.doc} A400Web
Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400Web()
Local cRetorno 

cRetorno := space(80)

If alltrim(BB8->BB8_WEB) == ""
	If alltrim(BAU->BAU_WEB) <> ""
		cRetorno := substr(BAU->BAU_WEB + space(80),1,80)
	Endif
Else                     
	cRetorno := substr(BB8->BB8_WEB + space(80),1,80)
Endif

Return cRetorno
                       
//-------------------------------------------------------------------
/*/{Protheus.doc} A400Fone
Movimentacao Cadastral de RDA
@author PLS TEAM
@since 08/06/04 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400Fone(cFone)
Local nTam  
local lNume := .F.
    
    cFone := SubString(alltrim(cFone),1,12)
	nTam  := 1
	
	While nTam <= len(cFone)
		If ! (substr(cFone,nTam,1) $ "0123456789")
			cFone := substr(cFone,1,nTam-1) + substr(cFone,nTam+1,len(cFone)-nTam)
			nTam  := 0  
		Else
			lNume := .T.	
		Endif
		nTam++
	Enddo
	If lNume 
	   cFone := strzero(val(cFone),12)       
	Else 
	   cFone := '000000000000'
	EndIf   

Return cFone           

//-------------------------------------------------------------------
/*/{Protheus.doc} A400DDD
Verifica se existe o campo DDD caso contrario informa 0000
@author Helio F. R. Lecchi
@since 24/10/06 
@version AP6
/*/
//-------------------------------------------------------------------
Function A400DDD(cValor)
Local cRetorno	:= ''
default cValor	:= '' 

cValor := iif( empty(cValor), BB8->BB8_DDD, cValor )
cRetorno := "0000"
cRetorno := StrZero(Val(cValor),4)

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSLSC400
F3 da listagem das criticas do ptu 400  
@author Daher
@since 01.06.2005
@version AP6
/*/
//-------------------------------------------------------------------
Function PLSLSC400(cDado1,lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL oDlg
LOCAL nOpca     := 0
LOCAL bOK       := { || nOpca := K_OK, oDlg:End() }
LOCAL bCancel   := { || oDlg:End() }
LOCAL oCritica
LOCAL aData
LOCAL cSQL
LOCAL aLista    := {}
LOCAL nInd                     
LOCAL nPos     
default lAuto := .f.                                                                      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё coloca virgula no comeco (caso tenha inicializador padrao)               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cDado1  := AllTrim(cDado1)

if subs(cDado1,len(cDado1),1) != "," .AND. cDado1 != ""
	cDado1 += ","
endif

aData := {}
aadd(aData,{"01","MИdico"})
aadd(aData,{"02","Hospital"})
aadd(aData,{"03","LaboratСrio"})
aadd(aData,{"04","ClМnica"})
aadd(aData,{"05","Pessoa FМsica - NЦo mИdico"})
aadd(aData,{"06","Centro de DiagnСsticos"})
aadd(aData,{"07","Parceiro Comercial"})
aadd(aData,{"08","Home Care (atendimentos domiciliares)"})
AADD(aData,{"10","Hospital Dia"})
AADD(aData,{"11","Pronto Atendimento"})
AADD(aData,{"12","Pronto Socorro"})

For nInd := 1 To Len(aData)
		aadd(aLista,{aData[nInd,1],aData[nInd,2],If(aData[nInd,1]$cDado1,.T.,.F.)})
Next
if !lAuto
   DEFINE MSDIALOG oDlg TITLE "Tipos de Prestadores" FROM ndLinIni,ndColIni TO ndLinFin,ndColFin OF GetWndDefault()

   @ 020,012 SAY oSay PROMPT "Selecione o(s) tipo(s) de prestador(es) que deve(m) ser enviados" SIZE 300,010 OF oDlg PIXEL COLOR CLR_HBLUE

   oCritica := TcBrowse():New( 035, 012, 330, 150,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
                                            
   oCritica:AddColumn(TcColumn():New(" ",{ || IF(aLista[oCritica:nAt,3],LoadBitmap( GetResources(), "LBOK" ),LoadBitmap( GetResources(), "LBNO" )) },;
            "@c",nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))     

   oCritica:AddColumn(TcColumn():New("CСdigo",{ || OemToAnsi(aLista[oCritica:nAt,1]) },;
            "@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     

   oCritica:AddColumn(TcColumn():New("DescriГЦo",{ || OemToAnsi(aLista[oCritica:nAt,2]) },;
            "@C",nil,nil,nil,200,.F.,.F.,nil,nil,nil,.F.,nil))     

   oCritica:SetArray(aLista)         
   oCritica:bLDblClick := { || aLista[oCritica:nAt,3] := IF(aLista[oCritica:nAt,3],.F.,.T.) }

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{})
endif

If nOpca == K_OK .or. lAuto
                  
   cDado1 := ""
   For nInd := 1 To Len(aLista)
   
       If aLista[nInd,3]
			If nInd <= 20
             cDado1 += aLista[nInd,1]+","
          Endif   
          
          nPos := Ascan(aData,{|x| x[1] == aLista[nInd,1]})

       Endif   
   Next
Endif
                                  
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё tira a virgula do final                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if subs(cDado1,len(cDado1),1) == ","
	cDado1 := subs(cDado1,1,len(cDado1)-1)
endif  
    
Return .T.
      
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS400VLDA
Gera log de critica para campo obrigatorio nao preenchido
@author PLS TEAM
@since 02.02.2011
@version AP6
/*/
//-------------------------------------------------------------------
Function PLS400VLDA(cRegistro)
Local cRet := ""

Do Case
    Case cRegistro == "NM_DIR_TEC"
        If BAU->BAU_TIPPE == "J" .And. Empty(cNomDir)
            Aadd(aCriticas, {"ATENCAO - RDA "+BAU->BAU_CODIGO+" -> Prestador sem Nome do Diretor Tecnico de Saude",""} )
            cRet := Space(60)
        Else
            cRet := substr(cNomDir + space(60),1,60) 
        EndIf
        
    
    Case cRegistro == "SG_CONS_DI" 
        If BAU->BAU_TIPPE == "J" .And. Empty(cSgCDir)  
            Aadd(aCriticas, {"ATENCAO - RDA "+BAU->BAU_CODIGO+" -> Informe a Sigla do Conselho Profissional do diretor tecnico da entidade de saude.",""} )
            cRet := Space(12)
        Else
            cRet := cSgCDir 
        EndIf
        
    Case cRegistro == "CD_CONS_DI" 
        If BAU->BAU_TIPPE == "J" .And. Empty(cCrmDir)  
            Aadd(aCriticas, {"ATENCAO - RDA "+BAU->BAU_CODIGO+" -> Informe o Numero do Conselho do diretor tecnico da entidade de saude.",""} )
            cRet := Space(15)
        Else
            cRet := cCrmDir 
        EndIf  
        
    Case cRegistro == "SG_UF_CONS" 
        If BAU->BAU_TIPPE == "J" .And. Empty(cUFCDir)  
            Aadd(aCriticas, {"ATENCAO - RDA "+BAU->BAU_CODIGO+" -> Informe a Sigla da Unidade Federativa do Conselho do diretor tecnico da entidade de saude.",""} )
            cRet := Space(2)
        Else
            cRet := cUFCDir 
        EndIf        
    
EndCase
        
Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Gera450Ptu
Gera o arquivo texto do ptu 450
@author PLS TEAM
@since 20/09/11
@version AP6
/*/
//-------------------------------------------------------------------
Static Function Gera450Ptu()
Local cQuery:=""

PTULn("R451",.T.,.F.)     // zerando o contador de linha

If Select("TMP") > 0
	TMP->(dbCloseArea())
Endif
                   
If Select("TMP1") > 0
	TMP1->(dbCloseArea())                                                    
Endif

//зддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a query							  				Ё
//юддддддддддддддддддддддддддддддддддддддддддддды
cQuery := "SELECT DISTINCT BAU.BAU_CODIGO CODIGO,B0G.B0G_ABRRED,B0G.B0G_CODREF,B0G.B0G_DESCRI AS DESCRI,BB8.BB8_CODLOC "
cQuery += "FROM " 	+ cBAUname + " BAU, "	
cQuery += 		  	+ cBAWname + " BAW, "
cQuery += 			+ cBB8name + " BB8,  "
cQuery += 			+ cB0GName + " B0G  "
cQuery += "WHERE BAU.BAU_FILIAL = '" + xFilial("BAU") + "' "
cQuery += "  AND BAU.BAU_TIPPRE <> '" + cTipOpe + "' "
cQuery += "  AND BAU.BAU_CODIGO >= '" + cRdaIni + "' "
cQuery += "  AND BAU.BAU_CODIGO <= '" + cRdaFim + "' "
cQuery += "  AND (BAU.BAU_DATBLO = '        '" 
If lImpBloq
	cQuery += " OR BAU.BAU_DATBLO  BetWeen '"+ cDtBloI +"' AND '"+ cDtBloF + "'"
EndIf
cQuery += ") AND BAU.D_E_L_E_T_ <> '*' "
cQuery += "  AND BAW.BAW_CODIGO = BAU.BAU_CODIGO "
cQuery += "  AND BAW.BAW_FILIAL = '" + xFilial("BAW") + "' "
cQuery += "  AND BAW.BAW_CODINT = '" + cUniOri + "' "
cQuery += "  AND BAW.D_E_L_E_T_ <> '*' "
cQuery += "  AND BB8.BB8_FILIAL = '" + xFilial("BB8") + "' "
cQuery += "  AND BB8.BB8_CODIGO = BAU.BAU_CODIGO "
cQuery += "  AND BB8.BB8_GUIMED <> '0' "
cQuery += "  AND (BB8.BB8_DATBLO = ' ' "
If lImpBloq
	cQuery += " OR BB8.BB8_DATBLO  BetWeen '"+ cDtBloI +"' AND '"+ cDtBloF + "'"
EndIf
cQuery += ") AND BB8.D_E_L_E_T_ <> '*' "
cQuery += "  AND B0G.B0G_FILIAL = '" + xFilial("B0G") + "' "
cQuery += "  AND B0G.B0G_CODRDA = BAU.BAU_CODIGO "
cQuery += "  AND B0G.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY BAU.BAU_CODIGO "
PLSQuery(cQuery,"TMP1")

	If TMP1->(!Eof())     
		DBSelectArea("TMP1")
		DbGotop()         
		Cria450Arq()    
	Endif	

If Select("TMP") > 0
	TMP->(dbCloseArea())
Endif
                   
If Select("TMP1") > 0
	TMP1->(dbCloseArea())                                                    
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AcumulaA109
Acumula A109
@author PLS TEAM
@since 09/02/11
@version AP6
/*/
//-------------------------------------------------------------------
Function AcumulaA459(cLayOut)

NTOTR452 ++


Return NTOTR452      

//-------------------------------------------------------------------
/*/{Protheus.doc} Cria450Arq
Cria arquivo A450
@author Equipe PLS
@since 09/20/11
@version P11
/*/
//-------------------------------------------------------------------
Static Function Cria450Arq()
Local aStru452		:= {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis R53 e R454						                       		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local cCodGruSer := ""
Local nCont      := 0
Local aStru453   := {}
Local aStru454   := {}   
Local aRdaInc    := {}
Local aRdaExc    := {}

Private cAliasTrb	:= GetNextAlias()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Estrutura R452								                       		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
AADD(aStru452,{"B0G_ABRRED","C",(TamSx3("B0G_ABRRED")[1]),(TamSx3("B0G_ABRRED")[2])})
AADD(aStru452,{"B0G_CODREF","C",(TamSx3("B0G_ABRRED")[1]),(TamSx3("B0G_CODREF")[2])})
AADD(aStru452,{"DESCRI", "C",(TamSx3("BI3_DESCRI")[1]),(TamSx3("BI3_DESCRI")[2])})
AADD(aStru452,{"IDREG","C",1,0})                                                 
AADD(aStru452,{"RPLANS","C",(TamSx3("BI3_SUSEP")[1]),(TamSx3("BI3_SUSEP")[2])})
AADD(aStru452,{"CLAPLS","C",(TamSx3("BI3_CLAPLS")[1]),(TamSx3("BI3_CLAPLS")[2])})
AADD(aStru452,{"SITANS","C",(TamSx3("BI3_SITANS")[1]),(TamSx3("BI3_SITANS")[2])})
AADD(aStru452,{"CODSEG","C",(TamSx3("BI3_CODSEG")[1]),(TamSx3("BI3_CODSEG")[2])})   
AADD(aStru452,{"CODACO","C",1,0})  
AADD(aStru452,{"ABRANG","C",1,0})
AADD(aStru452,{"TPREDE","C",1,0})    
AADD(aStru452,{"CHAVE" ,"C",11,0}) 
              
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Estrutura R53								                       		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды   
AADD(aStru453,{"CHAVE"    ,"C",15,0})  
AADD(aStru453,{"REDEATEND","C",04,0})  
AADD(aStru453,{"NMPRODUTO","C",60,0})  
AADD(aStru453,{"REGPLANO" ,"C",20,0})  
AADD(aStru453,{"IDEXCECAO","C",01,0})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Estrutura R54								                       		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
AADD(aStru454,{"CHAVE"    ,"C",15,0})  
AADD(aStru454,{"CDUNIPRE" ,"C",04,0})  
AADD(aStru454,{"CDCNPJCPF","C",15,0})  
AADD(aStru454,{"CDGRSERV" ,"C",03,0})  


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria areas de trabalho						                       		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//--< CriaГЦo do objeto FWTemporaryTable >---
oTempTMP := FWTemporaryTable():New( "TMP" )
oTempTMP:SetFields( aStru452 )
oTempTMP:AddIndex( "INDTMP",{ "B0G_CODREF","DESCRI" } )

if( select( "TMP" ) > 0 )
	TMP->( dbCloseArea() )
endIf

oTempTMP:Create()

dbSelectArea( "TMP" )
dbSetOrder( 1 )
 
B3Z->(DbSetOrder(1))//B3Z_FILIAL+B3Z_CODIGO+B3Z_VERSAO+B3Z_CODRDA
BAU->(DbSetOrder(1))//BAU_FILIAL+BAU_CODIGO

//--< CriaГЦo do objeto FWTemporaryTable >---
oTempR53 := FWTemporaryTable():New( "R53" )
oTempR53:SetFields( aStru453 )
oTempR53:AddIndex( "INDR53",{ "CHAVE" } )

if( select( "R53" ) > 0 )
	R53->( dbCloseArea() )
endIf

oTempR53:Create()

dbSelectArea( "R53" )
R53->( dbSetOrder( 1 ) )
//--< CriaГЦo do objeto FWTemporaryTable >---
oTempR54 := FWTemporaryTable():New( "R54" )
oTempR54:SetFields( aStru454 )
oTempR54:AddIndex( "INDR54",{ "CHAVE" } )

if( select( "R54" ) > 0 )
	R54->( dbCloseArea() )
endIf

oTempR54:Create()

dbSelectArea( "R54" )
R54->( dbSetOrder( 1 ) )

BeginSql Alias cAliasTrb    
    
	SELECT * FROM %table:BI3% BI3
	WHERE BI3.BI3_GUIMED<>'0' AND BI3_REDEDI<>%exp:Space(TamSx3("BI3_REDEDI")[1])% AND BI3.%notDel%
Endsql	

BI6->(dbSetOrder(1))//BI6_FILIAL + BI6_CODSEG	  
BF7->(dbSetOrder(1))//BF7_FILIAL + BF7_CODORI                            
BI4->(dbSetOrder(1))//BI4_FILIAL + BI4_CODACO
BIN->(dBSetOrder(1))//BIN_FILIAL + BIN_CODIGO + BIN_CODINT + BIN_CODLOC + BIN_CODGRU

If (cAliasTrb)->(!Eof())
	While (cAliasTrb)->(!Eof())
	    If TMP->(!Dbseek(TMP1->B0G_CODREF+(cAliasTrb)->BI3_DESCRI))
			TMP->(Reclock("TMP",.T.))         
			TMP->B0G_ABRRED:=Substr((cAliasTrb)->BI3_REDEDI,1,2)
			TMP->B0G_CODREF:=Substr((cAliasTrb)->BI3_REDEDI,3,2)
			TMP->DESCRI:=(cAliasTrb)->BI3_DESCRI
			TMP->IDREG:=If(Empty((cAliasTrb)->BI3_SCPA),"1","2")
			
			If TMP->IDREG == "1"
				TMP->RPLANS:=(cAliasTrb)->BI3_SUSEP  
			Else
				TMP->RPLANS:=(cAliasTrb)->BI3_SCPA
			EndIf                                                         
			
			TMP->CLAPLS:=(cAliasTrb)->BI3_CLAPLS
			TMP->SITANS:=IIF(!Empty((cAliasTrb)->BI3_SITANS),(cAliasTrb)->BI3_SITANS,"0")				
			aArea := TMP->(GetArea())
				
			BI6->(DbSeek(xFilial("BI6")+(cAliasTrb)->BI3_CODSEG))
			TMP->CODSEG:= IIF(!Empty(BI6->BI6_SEGPTU),StrZero(Val(BI6->BI6_SEGPTU),2),"00")
			
			BF7->(DbSeek(xFilial("BF7")+(cAliasTrb)->BI3_ABRANG))
			TMP->ABRANG:= IIF(!Empty(BF7->BF7_CODEDI),BF7->BF7_CODEDI,"0")
			TMP->TPREDE:= iif(TMP->B0G_ABRRED == 'NA',"00",PadR(BAU->BAU_TIPRED,1))
			
			BI4->(DbSeek(xFilial("BI4")+(cAliasTrb)->BI3_CODACO))
			If BI4->BI4_CODEDI ==  "1" 		//Apartamento(Individual)
		   		TMP->CODACO := "B"
			ElseIf BI4->BI4_CODEDI ==  "2" 	//Enfermaria(Coletivo)
		   		TMP->CODACO := "A"
		   	ElseIf BI4->BI4_CODEDI $  "3/4" 	//Ambulatorial
		   		TMP->CODACO := "C"
			ElseIf !Empty(BI4->BI4_CODEDI)
				TMP->CODACO := BI4->BI4_CODEDI
		   	EndIf
		   	
		   	TMP->CHAVE := (cAliasTrb)->BI3_CODINT+(cAliasTrb)->BI3_CODIGO+(cAliasTrb)->BI3_VERSAO		
			RestArea(aArea)
						
		  	TMP->(MsUnlock())                  
		  	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Verifica se gera registros R453 e R454		                       		 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		  	If B3Z->(DbSeek(xFilial("B3Z")+(cAliasTrb)->BI3_CODINT+(cAliasTrb)->BI3_CODIGO+(cAliasTrb)->BI3_VERSAO))
		  		cCodGruSer := "000"
		  		aRdaInc    := {}
		  		aRdaExc    := {}  
		  				  		
		  		While (cAliasTrb)->BI3_CODINT+(cAliasTrb)->BI3_CODIGO+(cAliasTrb)->BI3_VERSAO == B3Z->(B3Z_CODIGO+B3Z_VERSAO) .And. !B3Z->(Eof())
		   			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Adiciona Rdas para array de controle  		                       		 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
		  			If BAU->(DbSeek(xFilial("BAU")+B3Z->B3Z_CODRDA)) .And. !Empty(BAU->BAU_CPFCGC)		  				
						cCodGruSer := B3Z->B3Z_CDGRSR						   
						If B3Z->B3Z_INDEXC == '1' //Inclusao
							Aadd(aRdaInc,{Strzero(Val(BAU->BAU_CPFCGC),15),cCodGruSer})  
		  				ElseIf B3Z->B3Z_INDEXC == '2' //Exclusao
		  					Aadd(aRdaExc,{Strzero(Val(BAU->BAU_CPFCGC),15),cCodGruSer}) 
		  				EndIf		  				
		            EndIf
		            
		  			B3Z->(DbSkip())
		  		EndDo 
		  		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gera R453 de inclusao               		                       		 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
		  		If len(aRdaInc) > 0  
			  		R53->(Reclock("R53",.T.))     
			  		R53->REDEATEND := Substr((cAliasTrb)->BI3_REDEDI,1,4)
					R53->NMPRODUTO := Padr((cAliasTrb)->BI3_DESCRI,60)  
					If TMP->IDREG == "1"
						R53->REGPLANO := (cAliasTrb)->BI3_SUSEP  
					Else
						R53->REGPLANO := (cAliasTrb)->BI3_SCPA
					EndIf  
				    
					R53->IDEXCECAO := "1"
			  		R53->CHAVE := (cAliasTrb)->BI3_CODINT+(cAliasTrb)->BI3_CODIGO+(cAliasTrb)->BI3_VERSAO + "4531"
			  		R53->(MsUnlock()) 
			  	EndIf	 
  				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gera R454 de inclusao               		                       		 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			  	For nCont := 1 to len(aRdaInc)  
			  		R54->(Reclock("R54",.T.))     
			  		R54->CDUNIPRE  := PlsIntPad()
					R54->CDCNPJCPF := aRdaInc[nCont,1] 
					R54->CDGRSERV  := aRdaInc[nCont,2]
			  		R54->CHAVE := (cAliasTrb)->BI3_CODINT+(cAliasTrb)->BI3_CODIGO+(cAliasTrb)->BI3_VERSAO  + "4541"
			  		R54->(MsUnlock()) 
			  	Next
			  	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gera R453 de exclusao               	                      	    	 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
		  		If len(aRdaExc) > 0  
			  		R53->(Reclock("R53",.T.))     
			  		R53->REDEATEND := Substr((cAliasTrb)->BI3_REDEDI,1,4)
					R53->NMPRODUTO := Padr((cAliasTrb)->BI3_DESCRI,60)  
					If TMP->IDREG == "1"
						R53->REGPLANO := (cAliasTrb)->BI3_SUSEP  
					Else
						R53->REGPLANO := (cAliasTrb)->BI3_SCPA
					EndIf  
				    
					R53->IDEXCECAO := "2"
			  		R53->CHAVE := (cAliasTrb)->BI3_CODINT+(cAliasTrb)->BI3_CODIGO+(cAliasTrb)->BI3_VERSAO + "4532"
			  		R53->(MsUnlock()) 
			  	EndIf	  
			  	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gera R454 de exclusao              		                         		 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
			  	For nCont := 1 to len(aRdaExc)  
			  		R54->(Reclock("R54",.T.))     
			  		R54->CDUNIPRE  := PlsIntPad()
					R54->CDCNPJCPF := aRdaExc[nCont,1] 
					R54->CDGRSERV  := aRdaExc[nCont,2]
			  		R54->CHAVE := (cAliasTrb)->BI3_CODINT+(cAliasTrb)->BI3_CODIGO+(cAliasTrb)->BI3_VERSAO + "4542"
			  		R54->(MsUnlock()) 
			  	Next   
		  	EndIf                
		Endif  	
 	 	(cAliasTrb)->(DbSkip())           
  	Enddo      
Else
	MsgStop("PTU A450 NЦo Gerado devido o campo BI3_REDEDI nЦo estar preenchido","AtenГЦo")
Endif

(cAliasTrb)->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no topo dos arquivos temporarios Ё
//юдддддддддддддддддддддддддддддддддддддддддддды
TMP->(DbGoTop())
 
R53->(DbGoTop())
R54->(DbGoTop())

//здддддддддддддддддддддддддддддддддддддддддддд©
//ЁPonto de entrada para manipulaГЦo do arq tmpЁ
//юдддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLU400TMP")
	Execblock("PLU400TMP",.F.,.F.,{})
Endif
//здддддддддддддддддддддддддддддддддддддддддддд©
//Ё Gera o arquivo A450                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддды
TMP->(DbGoTop())
If TMP->(!Eof())                    
	PlsPTU(mv_par15,cNomArq2,cDirNov)
Endif
//здддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha arquivos temporarios                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддды
TMP1->(DbCloseArea())

if( select( "TMP" ) > 0 )
	oTempTMP:delete()
endIf

if( select( "R53" ) > 0 )
	oTempR53:delete()
endIf

if( select( "R54" ) > 0 )
	oTempR54:delete()
endIf

Return              

//-------------------------------------------------------------------
/*/{Protheus.doc} Gera408 
Verifica se vai gerar o tipo 408  
@author PLS TEAM
@since 29/02/12
@version AP6
/*/
//-------------------------------------------------------------------
Function Gera408(n)                                                                                       

Local cTpPre    := ""                                                      
Local cTipPress := "" 
Local nRec05	:= R05->(RECNO())
Local nContR05	:= 0

cTpPre := "02|03|04|06|08|10|11|12"   

cTipPress:= IIf(A400VETIPPRE()$cTpPre ,IIF(BB8->BB8_PRTACD=='1','S','N'),'N')

If BB8->BB8_GUIMED == "1"  .AND. cTipPress == "S"
	lGera408 := .t.
	nTotal408++   
	R08->(Reclock("R08",.T.))         
	R08->CGC  	:= Strzero(Val(If(!Empty(BB8->BB8_CPFCGC),BB8->BB8_CPFCGC,BAU->BAU_CPFCGC)),15)
	R08->ACREDI	:= IIf(A400VETIPPRE()$cTpPre ,IIF(BB8->BB8_PRTACD=='1',BB8->BB8_INSACR,''),'')
	R08->NIVEL	:= IIf(A400VETIPPRE()$cTpPre ,IIF(BB8->BB8_PRTACD=='1',IIF(Len(ALLTRIM(BB8->BB8_NIVACR))>0,BB8->BB8_NIVACR,'4'),'4'),'4')
	R08->REFEND	:= SUBSTR(BB8->BB8_CODLOC,2,2)
	R08->(MsUnlock())                  
					
	R08->(DbGotop())
else
	lGera408 := .f.
EndIf



Return(cTipPress)                  

//-------------------------------------------------------------------
/*/{Protheus.doc} PTU400MEC
Verifica se ha indicador de residencia em saude reconhecida pelo MEC
@author PLS TEAM
@since 28/08/13
@version AP6
/*/
//-------------------------------------------------------------------
Function PTU400MEC(cInd)    
Local cSql := ""
Local cRet := "N"     
Default cInd := ""

If A400VeTipPre() ==  "01"
	cSql := " SELECT COUNT(BLJ_FILIAL) AS CONT FROM "+RetSqlName("BLJ")
	cSql += " WHERE BLJ_FILIAL = '"+xFilial("BLJ")+"' "
	cSql += " AND BLJ_CODIGO = '"+BAU->BAU_CODIGO+"' "
	cSql += " AND BLJ_TIPO = '0' "
	cSql += " AND BLJ_RECMEC = '1' "	
	cSql += " AND BLJ_INDEDI = '"+cInd+"' " 	
	cSql += " AND D_E_L_E_T_ <> '*' "   
	
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"BLJTEMP",.F.,.T.)
		
	If !BLJTEMP->(Eof()) .And. BLJTEMP->CONT > 0
		cRet := "S"
	EndIf		
	
	If !Empty(cInd) .And. (cInd == "1" .And. aEspec[1][1] == "00" .Or. cInd == "2" .And. aEspec[2][1] == "00" .Or. cInd == "3" .And. aEspec[1][2] == "00" .Or. cInd == "4" .And. aEspec[2][2] == "00") 		
		cRet := Space(1)		
	EndIf
	
	BLJTEMP->(DbCloseArea())
Else
	cRet := Space(1)
EndIf	

Return(cRet)      
      
//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA400CBO
Verifica se o CBOS do prestador de saude  
@author PLS TEAM
@since 19/09/13
@version AP6
/*/
//-------------------------------------------------------------------
Function PTUA400CBO()
Local cCBOS    := "000000"    
Local aAreaBAQ := BAQ->(GetArea()) 
Local aAreaBAX := BAX->(GetArea())

If A400VeTipPre() $  "01/05" 
    BAQ->(DbSetOrder(1))//BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP
	BAX->(DbSetOrder(1))//BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
	If BAX->(DbSeek(xFilial("BAX")+BAU->BAU_CODIGO)) 
		While xFilial("BAX")+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODIGO) .And. !BAX->(Eof())
			If Empty(BAU->BAU_DATBLO)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Prestador nao bloqueado devo considerar vigencia na BAX            		 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BAX->BAX_ESPPRI == "1" .And. (Empty(BAX->BAX_DATBLO) .Or. dDataBase < BAX->BAX_DATBLO) .And. (Empty(BAX->BAX_VIGDE) .Or. dDataBase >= BAX->BAX_VIGDE)
					If BAQ->(DbSeek(xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP))) .And. !Empty(BAQ->BAQ_CBOS)
				    	cCBOS := Substr(PLSDELIM(BAQ->BAQ_CBOS),1,6)
				    	Exit
				    EndIf			
				EndIf  
			Else 
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Prestador bloqueado nao considero vigencia na BAX                  		 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BAX->BAX_ESPPRI == "1"
					If BAQ->(DbSeek(xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP))) .And. !Empty(BAQ->BAQ_CBOS)
				    	cCBOS := Substr(PLSDELIM(BAQ->BAQ_CBOS),1,6)
				    	Exit
				    EndIf			
				EndIf  
			EndIf	
			BAX->(DbSkip())
		EndDo
	EndIf 
	
	If cCBOS == "000000" .And. !Empty(BAU->BAU_CBO)                    
		cCBOS := Substr(PLSDELIM(BAU->BAU_CBO),1,6)
	EndIf
Endif   

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para tratar CBOS                                                     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PL400CBO")
	cCBOS := ExecBlock("PL400CBO",.F.,.F.,{cCBOS,BAU->BAU_CODIGO,BAQ->(Recno())})
    cCBOS := Substr(PLSDELIM(cCBOS),1,6)
EndIf 
   
RestArea(aAreaBAQ) 
RestArea(aAreaBAX)

Return(cCBOS)

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA400SEX
Verifica se o sexo do profissional e exibe critica   
@author PLS TEAM
@since 19/09/13
@version AP6
/*/
//-------------------------------------------------------------------
Function PTUA400SEX()
Local cRet := Space(1)

If A400VETIPPRE()$ "01|05"
	If BAU->BAU_SEXO == "0"
		cRet := "M"
    ElseIf  BAU->BAU_SEXO == "1" 
    	cRet := "F"
    Else
		AADD(aCriticas, {"Profissional pessoa fМsica sem Sexo informado - RDA: " + BAU->BAU_CODIGO,""} )
	EndIf	
EndIf

Return(cRet)	

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA400GIN
Verifica se o profissional atende ginecologia/obstetricia
@author PLS TEAM
@since 19/09/13
@version AP6
/*/
//-------------------------------------------------------------------
Function PTUA400GIN()
Local cRet := "0"
Local nI   := 0

For nI := 1 to len(aEspec)
	If aEspec[nI][01] == "60"
		If !Empty(aEspec[nI][12])
			cRet := aEspec[nI][12]
		Else
			AADD(aCriticas, {"Informe se o profissional atende Ginec/Obstr (BBF_GINOBS) - RDA: " + BAU->BAU_CODIGO,""} )	
	    EndIf
	EndIf	
Next 
			 			
Return cRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA400CNE
Retorna CNES da RDA ja tratado 
@author PLS TEAM
@since 19/09/13
@version AP6
/*/
//-------------------------------------------------------------------
Function PTUA400CNE()
Local cRet := ""
Local lOnlyNumb := .T.
Local nCont := 0

cRet := Alltrim(BB8->BB8_CNES) 
If !Empty(cRet)
	For nCont := 1 to len(cRet)
		If !Substr(cRet,nCont,1) $ "0123456789"
			lOnlyNumb := .F.
			Exit
		EndIf
	Next
	If lOnlyNumb
		cRet := Strzero(Val(cRet),7)
	Else
		cRet := Padr(cRet,7)	
	EndIf
Else
	cRet := "9999999"
EndIf	

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P400SUBS
Retorna Se Existe RDA EXCLUSцO / SUBSTITUIгцO
@author PLS TEAM
@since 21/06/15
@version AP6
/*/
//-------------------------------------------------------------------
Function P400SUBS()
Local cSubs,cCNPJCPF := ""
Local cRDASUB  	:= Alltrim(BAU->BAU_RDASUB)
Local cDtIni   := dTos(BAU->BAU_DATBLO+1)
//Local aAreaBAU 	:= BAU->(GetArea())
Local nRecnoBAU := BAU->(Recno())
Local cMotExcl  := "00" 
Local cNvlExc	  := Space(2)
Local cRedeExc  := Space(4)
Local cPlanExc  := Space(20)   
Local cEndExc   := Space(2)
Local cDatExc   := Space(8)
                            
BAU->(dbSetOrder(1))
If !Empty(cRDASUB) .And. BAU->(MsSeek(xFilial("BAU")+cRDASUB))  
	cSubs    := "S"
	cCNPJCPF := Strzero(Val(BAU->BAU_CPFCGC),15)
//	cDtIni   := dTos(BAU->BAU_DATBLO+1)
Else
	cSubs    := "N"
	cCNPJCPF := "000000000000000"
	cDtIni   := Space(8)
Endif    
	
//RestArea(aAreaBAU)  

BAU->(dbGoto(nRecnoBAU))

Return {cSubs,cCNPJCPF,cDtIni,cMotExcl,cNvlExc,cRedeExc,cPlanExc,cEndExc,cDatExc}

//-------------------------------------------------------------------
/*/{Protheus.doc} P400INATIVO
FunГЦo para preencher o campo ID_INATIV do PTU A400
@author Lucas Nonato
@since 18/05/2016
@version P12
/*/
//-------------------------------------------------------------------

Function P400INATIVO()
Local cRet := ''
Local cTpVinc := IIF(BAU->BAU_RECPRO == '1','2', IIF (BAU->BAU_COPCRE == '2','3','1'))
	
If A400VETIPPRE()=='01' .And. BAU->BAU_INATIV == '1' .And. cTpVinc == '1'
	cRet := 'S'
Else
	cRet := 'N'
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PTUA400BLJ
Verifica tabela BLJ e retorna IndicaГЦo de doutorado ou mestrado. 

@author Lucas Nonato
@since  29/05/2017
@param  nOpcao, number, 1=Indicador de Doutorado ou PСs-doutorado; 2=Indicador de Mestrado
@version P11
/*/
//-------------------------------------------------------------------
Function PTUA400BLJ(cTipPre, cTipo)
Local cRet := Space(1)
Local cSql := ""
                         
If A400VeTipPre() $ cTipPre
	cRet := "N"		
	If cTipo == "3" .And. !Empty(BAU->BAU_INDDOU)	
		cRet := Iif(BAU->BAU_INDDOU == "1","S","N")		
	Else			
		cSql := "SELECT BLJ_TIPO FROM " + RetSqlName("BLJ")
		cSql += " WHERE BLJ_FILIAL = '"+xFilial("BLJ")+"' "
		cSql += " AND BLJ_CODIGO = '"+BAU->BAU_CODIGO+"' "		
		cSql += " AND BLJ_TIPO = '" + cTipo + "'" 	
		cSql += " AND D_E_L_E_T_ = ' ' "  
			
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbBLJ",.F.,.T.)	
		
		If !TrbBLJ->(Eof()) 
			cRet := "S"		
		EndIf
		
		TrbBLJ->(dbCloseArea())
	EndIf
EndIf

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} PTUBB8EXC
Verifica o bloqueio do local e o motivo da exclusЦo do mesmo
@author Thiago Rodrigues
@since  11/08/2020
@param  Codigo da RDA, Codigo da operadora, Codigo do local
@version P12
/*/

//-------------------------------------------------------------------
Static Function PTUBB8EXC(cBau,cCodop,clocal)
local cSql :=""
local cCodBlo := " "

if BB8->(fieldPos("BB8_CODEXC")) > 0

   cSql := " SELECT BB8_CODEXC FROM " + RetSqlName("BB8") 
   cSql += " WHERE BB8_FILIAL = '"    + xFilial("BB8") + "' "
   cSql += " AND BB8_CODIGO =  '"     + cBau   + "' " 
   cSql += " AND BB8_CODINT = '"      + cCodop + "' "
   cSql += " AND BB8_CODLOC = '0"     + clocal + "' "
   cSql += " AND D_E_L_E_T_ = ' ' "  

   dbUseArea(.t.,"TOPCONN",tcGenQry(,,ChangeQuery(cSQL)),"VerRep",.f.,.t.)
	if ( !VerRep->(eof()) )		
		cCodBlo:= BB8->BB8_CODEXC   
	endif
   VerRep->(DBCloseArea())
Endif
Return cCodBlo
