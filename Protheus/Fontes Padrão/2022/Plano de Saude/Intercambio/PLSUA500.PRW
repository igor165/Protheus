#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSUA500.CH"
#Include "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSUA500 
Tela MVC com FWMarkBrowse na exportação do PTU A500

@author  Lucas Nonato
@version P12
@since   13/02/2020
/*/
function PLSUA500
local cFilter		:= ""
private oMBrw500 
//legado 
private cUniOri  	:= ""
private nTipEnv  	:= 0
private nEnviar  	:= 0
private cGrpIni  	:= ""
private cGrpFim  	:= ""
private nTipoNota	:= 0
private nTipoCRDA	:= 0
private nConvert 	:= 0
private dDataConv	:= stod("")
private cDirNov  	:= ""
private cTpTabCBH	:= ""
private lAgrupa  	:= .f.
private cCodLay  	:= ""
private nTipoLote	:= 0
private l500S		:= .f.

cFilter := PLSU500FIL(.f.)
setKey(VK_F2 ,{|| cFilter := PLSU500FIL(.t.) })

oMBrw500:= FWMarkBrowse():New()
oMBrw500:SetAlias("BTO")
oMBrw500:SetDescription("Exportação PTU A500" )
oMBrw500:SetMenuDef("PLSUA500")
oMBrw500:AddLegend("BTO_STATUS == '1'", "GREEN",	"Enviado" )
oMBrw500:AddLegend("BTO_STATUS <> '1'", "RED",		"Não Enviado" )
oMBrw500:SetFieldMark( 'BTO_OK' )	
oMBrw500:SetAllMark({ ||  A270Inverte(@oMBrw500,"BTO") })
oMBrw500:SetFilterDefault(cFilter)
oMBrw500:SetWalkThru(.F.)
oMBrw500:SetAmbiente(.F.)
oMBrw500:ForceQuitButton()
oMBrw500:Activate()

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef - MVC

@author    Lucas Nonato
@version   1.xx
@since     11/08/2016
/*/
static function MenuDef()
Local aRotina := {}
	
ADD OPTION aRotina Title 'Exportar'			Action 'PLSU500PRC'			OPERATION MODEL_OPERATION_VIEW ACCESS 0
ADD OPTION aRotina Title "<F2> - Filtrar" 	Action 'PLSU500FIL(.t.)'   	OPERATION MODEL_OPERATION_VIEW ACCESS 0 

return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSU500PRC
Processamento PTU A500

@author  PLS TEAM
@version P12
@since   01/07/04
/*/
Function PLSU500PRC
local cQuery   		:= ""
local cAno     		:= ""
local cOpeOriBTO  	:= ""
local cAnoIniBTO  	:= ""
local cMesIniBTO  	:= ""
local cPrefixoBTO 	:= ""
local cNumTitBTO  	:= ""
local cPreBTONDC  	:= ""
local cNumBTONDC  	:= ""
local cParBTONDC  	:= ""
local cTipBTONDC  	:= ""
local cParcelBTO  	:= ""
local cTipTitBTO  	:= ""
local cArqNom		:= ""	

local dVencSE1
local dEmisSE1

local lFoundFAT		:= .f.

local aDadE1		:= {}  
local aDadE1NDC     := {}
local aLoteProc     := {}

private lEnvia		:= .f.
private lCheck		:= .f.

private aLog  		:= {}
private aLog1 		:= {}
private aLog2 		:= {} 

private cNumNdc		:= ""
private	cNumFat		:= ""

private nValIR   	:= 0
private nValNdc		:= 0
private nValFat		:= 0
private nValFat2	:= 0

private oTempR02	:= nil
private oTempR03	:= nil
private oTempR04	:= nil
private oTempR05	:= nil
private oTempR06    := nil
private oTempR07	:= nil
private oTempR08	:= nil

BTO->(dBSetOrder(1)) // Item de fatura de intercambio eventual
SE1->(dBSetOrder(1)) // Contas a Receber
BD5->(dBSetOrder(1)) // Cabecalho de Guia Ambulatorial
BE4->(dBSetOrder(1)) // Cabecalho de Guia de Internacao
BEJ->(dBSetOrder(1)) // Itens da autorizacao da Internacao
BAU->(dBSetOrder(1)) // Rede de Atendimento
BR8->(dBSetOrder(1)) // Tabela Padrao
BAQ->(dBSetOrder(1)) // Especialidades Medicas
BD4->(dBSetOrder(1)) // Unidade de Saude
BD6->(dBSetOrder(1)) // Item da Nota
BD7->(dBSetOrder(1)) // Part. Hon. Medicos Itens
BB0->(dbSetOrder(4)) // Profissional da Saude
BBF->(dbSetOrder(1)) // Especialidades
B5S->(dbSetOrder(2)) // Cabeç. Guias Lote Aviso-Envio
B6S->(dbSetOrder(1)) // Itens Guias Lote Aviso-Envio
B2S->(dbSetOrder(1)) // Cabecalho Envio Lote - B2S_FILIAL+B2S_NUMLOT+B2S_TIPGUI 
BKF->(dbSetOrder(1)) // Porte Anestesico

//função para ajustar tamanho dos campos
if FindFunction("PlAjsTamCampo") 
	PlAjsTamCampo()
endif

cQuery := " SELECT BTO_CODOPE, BTO_NUMERO, BTO_OPEORI, R_E_C_N_O_ AS BTO_RECNO " 
cQuery += " FROM " + RetSqlName("BTO")
cQuery += " WHERE BTO_FILIAL = '" + xFilial("BTO") + "' "
cQuery += " AND BTO_OK = '" + oMBrw500:cMark + "' "
cQuery += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMP2",.F.,.T.)
	
While ! TMP2->(EOF())
	aDadE1 := {}
	aDadE1NDC := {}
	BTO->(dbGoTo(TMP2->BTO_RECNO))
	
	// Quando o lote e do tipo ambos, existirao dois BTOs, verifica se um ja foi gerado e aborta o outro 			
	If BTO->BTO_TPMOV == '3' 
		If Ascan(aLoteProc,{|x| x[1] == BTO->BTO_NUMERO}) > 0
	    	TMP2->(DbSkip())
	    	Loop
		Else
			Aadd(aLoteProc,{BTO->BTO_NUMERO})
        EndIf
	EndIf
	If BTO->BTO_TPMOV == '3' 
		BTO->(DbSetOrder(1))//BTO_FILIAL + BTO_CODOPE + BTO_NUMERO + BTO_OPEORI
  		BTO->(DbSeek(xFilial("BTO")+BTO->(BTO_CODOPE+BTO_NUMERO+BTO_OPEORI)))  
  		cKeyBTO := BTO->(BTO_FILIAL+BTO_CODOPE+BTO_NUMERO+BTO_OPEORI) 
		
  		While cKeyBTO == xFilial("BTO")+BTO->(BTO_CODOPE+BTO_NUMERO+BTO_OPEORI) .And. !BTO->(Eof())    
  			If BTO->BTO_TPCOB ==  '1'
  				cPreBTONDC := BTO->BTO_PREFIX
	  			cNumBTONDC  := BTO->BTO_NUMTIT
	  	  		cParBTONDC  := BTO->BTO_PARCEL
	   			cTipBTONDC  := BTO->BTO_TIPTIT     
				cNumNdc	    := BTO->BTO_NUMTIT
				nValNdc	    := BTO->BTO_VLRCOP + BTO->BTO_VLRCP2				
				
				// Posiciona no respectivo SE1 - Titulos a Receber					
				SE1->(DbSetOrder(1))
				If ! SE1->(MsSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)))
					lFoundFAT := .F.
				Else
					lFoundFAT := .T.
					If VerifIRRF(TMP2->BTO_OPEORI)
						nValIR := noround(SE1->E1_IRRF,2) 
					EndIf	
					If !(Empty(SE1->E1_PORTADO)	.Or. Empty(SE1->E1_AGEDEP) .Or. Empty(SE1->E1_CONTA) .Or. Empty(SE1->E1_MOVIMEN))							 
						aAdd(aDadE1NDC, SE1->E1_PREFIXO) 
						aAdd(aDadE1NDC, SE1->E1_NUM)
						aAdd(aDadE1NDC, SE1->E1_PARCELA)
						aAdd(aDadE1NDC, SE1->E1_TIPO)      
					EndIf
				Endif
  			
  			ElseIf BTO->BTO_TPCOB ==  '2'    
  				cPrefixoBTO := BTO->BTO_PREFIX
	  			cNumTitBTO  := BTO->BTO_NUMTIT
	  	  		cParcelBTO  := BTO->BTO_PARCEL
	   			cTipTitBTO  := BTO->BTO_TIPTIT 
   				cNumFat	    := BTO->BTO_NUMTIT	
				nValFat   	:= BTO->BTO_VLRTAX    
				
				// Posiciona no respectivo SE1 - Titulos a Receber					
				SE1->(DbSetOrder(1))
				If ! SE1->(MsSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)))
					lFoundFAT := .F.
				Else
					lFoundFAT := .T.
				If VerifIRRF(TMP2->BTO_OPEORI)
					nValIR := noround(SE1->E1_IRRF,2) 
				EndIf	
					If !(Empty(SE1->E1_PORTADO)	.Or. Empty(SE1->E1_AGEDEP) 	.Or. Empty(SE1->E1_CONTA) .Or. Empty(SE1->E1_MOVIMEN))								 
						aAdd(aDadE1, SE1->E1_PREFIXO) 
						aAdd(aDadE1, SE1->E1_NUM)
						aAdd(aDadE1, SE1->E1_PARCELA)
						aAdd(aDadE1, SE1->E1_TIPO)      
					EndIf
				Endif
		
  			EndIf 
  			BTO->(DbSkip())
  		EndDo  
  		BTO->(dbGoTo(TMP2->BTO_RECNO)) //Retorna para o registro original  
  		SE1->(MsSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)))//Reposiciona no SE1 original
	Else	
		cPrefixoBTO := BTO->BTO_PREFIX
		cNumTitBTO  := BTO->BTO_NUMTIT
		cParcelBTO  := BTO->BTO_PARCEL
		cTipTitBTO  := BTO->BTO_TIPTIT				
		
		// Posiciona no respectivo SE1 - Titulos a Receber				
		SE1->(DbSetOrder(1))
		If ! SE1->(MsSeek(xFilial("SE1")+BTO->(BTO_PREFIX+BTO_NUMTIT+BTO_PARCEL+BTO_TIPTIT)))
			lFoundFAT := .F.
		Else
			lFoundFAT := .T.
			If VerifIRRF(TMP2->BTO_OPEORI)
				nValIR := noround(SE1->E1_IRRF,2) 
			EndIf	
			If !(Empty(SE1->E1_PORTADO)	.Or. Empty(SE1->E1_AGEDEP) .Or. Empty(SE1->E1_CONTA) .Or. Empty(SE1->E1_MOVIMEN))						 
				aAdd(aDadE1, SE1->E1_PREFIXO) 
				aAdd(aDadE1, SE1->E1_NUM)
				aAdd(aDadE1, SE1->E1_PARCELA)
				aAdd(aDadE1, SE1->E1_TIPO)      
			EndIf
		Endif			
	EndIf  
	
	cAno        := dtos(stod(BTO->BTO_ANOINI + BTO->BTO_MESINI + "15")-30)
	cCodOpeBTO  := BTO->BTO_CODOPE
	cOpeOriBTO  := BTO->BTO_OPEORI
	cAnoIniBTO  := BTO->BTO_ANOINI
	cMesIniBTO  := BTO->BTO_MESINI
	dVencSE1    := SE1->E1_VENCTO
	dEmisSE1    := SE1->E1_EMISSAO
	if len(alltrim(cNumTitBTO)) > 7 
		cArqNom 	:= "N" + substr(cNumTitBTO, len(cNumTitBTO)-6,7) + "." + substr(cCodOpeBTO,2,3)
	elseif len(Alltrim(cNumTitBTO)) < 7 
   		cArqNom     := "N" + Replicate("_",7-len(Alltrim(cNumTitBTO)))+Alltrim(cNumTitBTO)	+ "." + substr(cCodOpeBTO,2,3)		
	Else
		cArqNom     := "N" + strzero(val(Iif(!Empty(cNumTitBTO),cNumTitBTO,BTO->BTO_NUMTIT)),7) + "." + substr(cCodOpeBTO,2,3)
    EndIf
	nTpCob		:= BTO->BTO_TPCOB     
	nTpMov		:= BTO->BTO_TPMOV			   
	
	// Reembolso e padrao fatura 
	If nTipoLote == 2
		nTpMov := "2"
	EndIf
	
	If nTpMov == "1" 
		cNumNdc	:= BTO->BTO_NUMTIT
		nValNdc	:= BTO->BTO_VLRCOP + BTO->BTO_VLRCP2
    ElseIf nTpMov == "2"
		nValFat2 := BTO->BTO_CUSTOT
	EndIf			
       		
	If mv_par14 == 1
		MsAguarde( {|| GERAA500(cAno,cCodOpeBTO,cOpeOriBTO,cAnoIniBTO,cMesIniBTO,cPrefixoBTO,cNumTitBTO,dVencSE1,;
							dEmisSE1,cArqNom,nTipoNota,nTipoCRDA,nConvert,nTipEnv,cUniOri,.T.,"BD6->BD6_VLRTPF",;
							nil,cDirNov,cTpTabCBH,cParcelBTO,cTipTitBTO,aDadE1,lAgrupa,nTpMov,nTpCob,;
							cPreBTONDC,cNumBTONDC,cParBTONDC,cTipBTONDC,aDadE1NDC) } )
	
	Else
  		MsAguarde( {|| GeraR507(cCodOpeBTO,cOpeOriBTO,cAnoIniBTO,cMesIniBTO,cPrefixoBTO,cNumTitBTO,dVencSE1,;
		                    dEmisSE1,cArqNom,cDirNov,nTpMov) } )
    EndIf
	
	If lFoundFAT
		PLSA500Enviado(TMP2->BTO_CODOPE,TMP2->BTO_NUMERO,TMP2->BTO_OPEORI)
	Else
		MsgAlert("Fatura "+BTO->(BTO_PREFIX+BTO_NUMTIT)+" nao pode ser exportada!")
	Endif
	
	TMP2->(DbSkip())
Enddo

TMP2->(DBCloseArea())	

// Mensagem de processamento 		
If len(aLog) > 0
	PLSCRIGEN(aLog,{{"Mensagem 1","@!",120},{"Mensagem 2","@!",120},{"Mensagem 3","@!",200}},"Ocorrencias no processamento",nil,nil)
EndIf
		
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GERAA500 
Processamento do PTU Layout A500

@author  PLS TEAM
@version P12
@since   01/07/04
/*/
//-------------------------------------------------------------------
static function GERAA500(cAno,cCodOpeBTO,cOpeOriBTO,cAnoIniBTO,cMesIniBTO,cPrefixoBTO,cNumTitBTO,dVencSE1,dEmisSE1,;
				  cArqNom,nTipoNota,nTipoCRDA,nConvert,nTipEnv,_cUniOri,lQuery,cCampoTOTPF,cQuebraBD7,cDirNov,cTpTabCBH,;
				  cParcelBTO,cTipTitBTO,aDadE1,lAgrupa,nTpMov,nTpCob,cPreBTONDC,cNumBTONDC,cParBTONDC,cTipBTONDC,aDadE1NDC,lAutoma)
local ii
local i
local nI
local iBD6
local cQuery   := ""
local cTipGui  := ""
local cChave   := ""
local cClasse  := ""
local cIndCli  := ""
local cTpReg  := ""
local cDeiRegra:= ""
local cR502    := ""
local cR503    := ""
local cR504    := ""
local cR505    := ""
local cR506    := ""
local cMes     := ""
local cFatSer  := ""  
local cFatUnd  := ''
local nPos     := 0
local nTotFat  := 0
local lAmbula  := .F.
local lInterc  := .F.
local aStru502 := {}
local aStru503 := {}
local aStru504 := {}
local aStru505 := {}     
local aStru506 := {}
local aStru507 := {} 
local aStru508 := {}
local aMatMed  := {}
local cBDHname := RetSqlName("BDH")   		
local cBD6name := RetSqlName("BD6")
local cBD7name := RetSqlName("BD7")  
local cPartAgrp := GetNewPar("MV_PLAGRPT","")
local cGNT      := "-03"
local cRdaHm
local aRetPto504
local aRetPto502
local aRetPto506
local aRetPto507  
local aRetPto508
local aRetPto509 
local aRetPto510
local aRetPto505
local cAnoMesAnt
local cMatAnt     
local cAliasCab
local nRecBAU
local nIndBAU
local lExiProc	:= .F.
local lDiaria	:= .F.
local lTemCon	:= .F.
local nRecBR8   := 0
local nOrdBR8   := 0
local aPacote   := {0,0,{},""} 
local nSlvVco   := 0
local nSlvCco   := 0
local nSlvFco   := 0
local nSlvTad   := 0   
local nSlvTco   := 0        
local nSlvTfi   := 0
local nVlrPag   := 0
local nNV		:= 0
local cTiAutUnim:= "1"
local cUNMEDIDA := "00"
local cSolicBase:= "" 
local cSenAut	:= ""
local cPrsGuiTis:= Space(20)
local cGuiPrTIS := Space(20)
local cCodItePac:= "" 
local cRetB1M   := ""
local cDescBr8	:= ""
local cCodUnmAnt:= ""
local aAreaBE4  := {}  
local aAreaBAU  := {}
local aAreaBB0  := {}
local aRetBTU   := {}
local aNRDCNV	:= {}
local cArqImp   := ""
local cDecItem  := ""
local cAliCrCBO := ""
local aItensBD6 := {}
              				    
local cNomMedAud := Space(40)
local cRegMedAud := Space(15)
local cUFMedAud  := Space(2)
local cNomEnfAud := Space(40)
local cRegEnfAud := Space(15)
local cUFEnfAud  := Space(2)
local cCarAtend  := "" 
local cAliCarAte := ""
local cAliTipCon := ""
local cMatMedGen := Alltrim(GetNewPar("MV_PLOPMPT",""))
local cIDPagForn := "0"
local cPagNomFor := Space(60)
local cDetRegAnv := Space(50)
local cNumNFForn := Space(20)
local cCodPct    := ""
local cDesPct    := ""
local cGuiJur    := ""
local cTpPeExec  := ""
local cCgcExec   := ""
local cCNESExec  := ""
local cCdMunExec := ""
local cTpRedMin  := Space(1)
local lPjRaufi   := GetNewPar("MV_PLRAUFI",.T.)
local cChvBZC	 := "" 
local cIndObs    := ""
local cIndJus    := "" 
local cIndEsp    := "" 
local cParBD7    := ""
local cCodMedGen := GetNewPar("MV_PLMEDPT","")
local cCodMatGen := GetNewPar("MV_PLMATPT","")
local cCodTaxGen := GetNewPar("MV_PLTAXPT","")
local cCodOpmGen := GetNewPar("MV_PLOPMPT","")
local cAvisoIt	 := "N"
local cAvisoGu	 := "N"
local cLotB5S	 := space(12)
local cIdHab	 := "N"
local cDtEnv	 := space(8)
local lR506      := .F.
local cNumDocNFE := ""
local cLinkNFE	 := ""

local lFounDePar := .F.
local lFindBE4GP := .F.
local lUsArImVe  := GetNewPar("MV_PLUSARI",.F.)
local lDeParaBTU := GetNewPar("MV_PLAJBTU","0") == "1"
local lPLS50002	 := ExistBlock("PLS50002")
local lPLS50003	 := ExistBlock("PLS50003")
local lPLS50004	 := ExistBlock("PLS50004")
local lPLS50005	 := ExistBlock("PLS50005")
local lPLS50006	 := ExistBlock("PLS50006")
local lPLS50007	 := ExistBlock("PLS50007")
local lPLS50008	 := ExistBlock("PLS50008")
local lPLS50009	 := ExistBlock("PLS50009")
local lPLS50010	 := ExistBlock("PLS50010")
local lPLS50011	 := ExistBlock("PLS50011")
local lPLS500EX	 := ExistBlock("PLS500EX")
local lPLS500REG := ExistBlock("PLS500REG")
local lPL500DESC := ExistBlock("PL500DESC")
Local nValItem	 := 0
Local n50004	:= 0
Local lZera		:= 0
Local cTipRol	:= ""

private cUniOri := _cUniOri //tem que ser assim por causa da macro
private cTpGuia := ""
private cUniDes
private dDatBas
private cCompet
private cNumDoc1 
private cFatura
private cNumDoc2
private cNdc 
private cTipDoc1 := "0"
private cTipDoc2 := "0"
private dDatVen
private dDatEmi
private nValor
private cLote
private cNota
private cChaNot
private cTipNot
private cIdNotPri
private cCodInt
private cCodEmp
private cMatric
private cTipReg
private cDigito
private cNomUsr
private cDtaAte
private cCodExc
private cCodCid
private cTipCon :=""
private cAteAmb
private cTipPac :=""
private cUniHos
private cCodHos
private cNomHos 	:= space(60)
private cTipAco 	:= "  " 
private cDtHrInt 	:= Space(21) 
private cDtHrSai 	:= Space(21) 
private	cIndAcid
private	cTipSai
private	cCGCHos
private cTipInt
private cTipNas
private cProPri
private cChaAut
private cUniPre
private cCodPre
private cNomPre
private cTipPar
private dDatSer
private cTipTab
private cCodPsa
private nQtdPsa
private nVlrCob
private nVCoCob
private nVFiCob
private cCodPoA
private cUniAut
private cNroAut
private cUniReq
private cPreReq
private cViaAce
private nTaxAdm
private nTaxaCo
private nTaxFil
private cCodEsp
private cTipPre
private cRecPro
private cTipPes 
private cCGCPre
private cPacote
private cCodAto
private cFatMul
private cNotPrg
private cHorPsa  
private cHorFim
private cQtNasViv	:= ""
private cQtNasMor	:= ""
private cQtNasVPr	:= ""
private cQtObiPre	:= ""
private cQtObiTar	:= ""
private cCNES       := ""
private cSgConsPr	:= ""
private cNrConsPr	:= ""
private cUFConsPr	:= ""
private cCNPJReq	:= ""
private cNomeReq	:= ""
private cSgConsReq	:= ""
private cNrConsReq	:= ""
private cUFConsReq	:= ""
private cTpAtend	:= ""
private cGuiPri		:= ""
private cID_OBT1	:= ""					  
private cID_OBT2	:= ""					
private cID_OBT3	:= ""					
private cID_OBT4	:= ""					
private cID_OBT5	:= ""					
private cID_OBT6	:= ""				
private cID_OBT7	:= ""			
private cID_OBT8	:= ""						 
private cID_OBT9	:= ""				
private cTP_FATURA	:= ""						  
private cCD_CIDOBT	:= ""					
private cNR_DECOBT	:= ""						  
private cNR_VIVO1	:= ""						  
private cNR_VIVO2	:= ""						  
private cNR_VIVO3	:= ""						 
private cNR_VIVO4	:= ""						 
private cNR_VIVO5	:= ""						  
private cTP_OBTMULH	:= ""	   
private cAliCab     := ""
private cNmExec		:= ""	      
private cAltoCusto  := ""
private cVerTISS    := ""
private cCBOSExec   := "" 
private cCBOSSol    := ""
private cTpRegInt   := ""
private cIDRN       := ""
private cDatAut     := ""
private cDatSol     := ""
private cTecUtil    := ""
private cRegAnvis   := ""   
private cCodUnMed   := ""
private cCodRefFab  := ""
private cCodRecPre  := ""
private cCodMun     := ""
private cMotEncer   := ""
private cDatProtoc  := ""
private cDatPagam   := ""
private cCnpjFor    := ""
private cTipCodifi	:= ""

private nQTD_502 := 0
private nQTD_503 := 0
private nQTD_504 := 0
private nQTD_505 := 0
private nQTD_507 := 0
private nQTD_508 := 0
private nNOT_EXC := 0
private nQTD_SER := 0
private nTOT_SER := 0
private nNOT_AMB := 0
private aReg504  := {}
private aR504    := {}
Private aPL50004 := {}

DEFAULT aDadE1	 := {}
DEFAULT lAgrupa	 := .F.
DEFAULT nTpMov   := '2'
DEFAULT nTpCob   := '2'
DEFAULT aDadE1NDC:= {}
DEFAULT lAutoma  := .F.
DEFAULT cQuebraBD7  := ".F."

DbSelectArea("BKC")                    
BKC->(DbSetOrder(1))
DE9->(DbSetOrder(1))
DE9->(MsSeek(xFilial("DE9")+cCodLay))

BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cOpeOriBTO)) .And. ! Empty(BA0->BA0_GNT)
	cGNT := BA0->BA0_GNT
Endif

// Seleciona registros de BD6
cMes := substr(cAno,5,2)
cAno := substr(cAno,1,4)

If lQuery
	cQuery := " SELECT BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN, BD6_CODPAD, BD6_CODPRO,  "
	cQuery += cBD6name + ".R_E_C_N_O_ BD6_RECNO "
	cQuery += "FROM "+cBD6name+","+cBDHname+" "
	cQuery += "WHERE "
	cQuery += "BDH_STATUS = '0' AND "
	
	If nTpMov == '1' .Or. (nTpMov == '3' .And. nTpCob == '1')
		cQuery += "BDH_PRENDC = '"+SE1->E1_PREFIXO+"' AND "
		cQuery += "BDH_NUMNDC = '"+SE1->E1_NUM+"' AND "
		cQuery += "BDH_PARNDC = '"+SE1->E1_PARCELA+"' AND "
		cQuery += "BDH_TIPNDC = '"+SE1->E1_TIPO+"' AND "
	ElseIf nTpMov == '2' .Or. (nTpMov == '3' .And. nTpCob == '2')   
		cQuery += "BDH_PREFIX = '"+SE1->E1_PREFIXO+"' AND "
		cQuery += "BDH_NUMTIT = '"+SE1->E1_NUM+"' AND "
		cQuery += "BDH_PARCEL = '"+SE1->E1_PARCELA+"' AND "
		cQuery += "BDH_TIPTIT = '"+SE1->E1_TIPO+"' AND "
	EndIf	
	cQuery += cBDHname+".D_E_L_E_T_ = ' ' AND "
	cQuery += cBD6name+".D_E_L_E_T_ = ' ' AND "
	cQuery += "BD6_FILIAL = '"+xFilial("BD6")+"' AND "
	cQuery += "BDH_FILIAL = '"+xFilial("BDH")+"' AND "
	cQuery += "BD6_OPEUSR = BDH_CODINT AND "
	cQuery += "BD6_CODEMP = BDH_CODEMP AND "
	cQuery += "BD6_MATRIC = BDH_MATRIC AND "
	cQuery += "BD6_TIPREG = BDH_TIPREG AND "
	cQuery += "BD6_SEQPF = BDH_SEQPF AND   "
	cQuery += "BD6_ANOPAG = BDH_ANOFT AND "
	cQuery += "BD6_MESPAG = BDH_MESFT AND "
	cQuery += "BD6_SITUAC = '1' AND "	
	cQuery += "((SELECT COUNT(*) FROM "+cBD7name+" WHERE "
	cQuery += "   BD7_FILIAL = BD6_FILIAL AND "
	cQuery += "   BD7_CODOPE = BD6_CODOPE AND "
	cQuery += "   BD7_CODLDP = BD6_CODLDP AND "
	cQuery += "   BD7_CODPEG = BD6_CODPEG AND "
	cQuery += "   BD7_NUMERO = BD6_NUMERO AND "
	cQuery += "   BD7_ORIMOV = BD6_ORIMOV AND "
	cQuery += "   BD7_SEQUEN = BD6_SEQUEN AND "
	cQuery += "   BD7_BLOPAG <> '1' ) > 0 OR BD6_MOTBPG IN ('066','067','068') )" //Itens de NF precisam entrar no arquivo
	cQuery += " ORDER BY BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN "
	
	If ExistBlock("PLS500QU")
 		cQuery := ExecBlock("PLS500QU",.F.,.F.,{cQuery,cBD7name,cBD6name,cBDHname,SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)})
 	Endif   

	PLSQuery(cQuery,"TMP")

Endif

TMP->(DbGoTop())

lEnvia := .T.

// Verifica se retornou algum registro								         

If  TMP->(EOF())
	lEnvia := .F.
Endif

If  lEnvia
    FERASE("LOG500.TXT")
      			                                 
	aLog1 := {}
	aLog2 := {}
	
	
	// Cria arquivo temporario 502	
	aadd(aStru502,{"Chave","C",022,0})
	aadd(aStru502,{"R502" ,"C",690,0})
	
	//--< Criação do objeto FWTemporaryTable >---
	oTempR02 := FWTemporaryTable():New( "R02" )
	oTempR02:SetFields( aStru502 )
	oTempR02:AddIndex( "INDR02",{ "CHAVE" } )
	
	if( select( "R02" ) > 0 )
		R02->( dbCloseArea() )
	endIf
	
	oTempR02:Create()
	dbSelectArea( "R02" )
	R02->( dbSetorder( 1 ) )	
	
	// Cria arquivo temporario 503	
	aadd(aStru503,{"Chave","C",022,0})
	aadd(aStru503,{"R503" ,"C",569,0})
	
	//--< Criação do objeto FWTemporaryTable >---
	oTempR03 := FWTemporaryTable():New( "R03" )
	oTempR03:SetFields( aStru503 )
	oTempR03:AddIndex( "INDR03",{ "CHAVE" } )
	
	if( select( "R03" ) > 0 )
		R03->( dbCloseArea() )
	endIf
	
	oTempR03:Create()
	dbSelectArea( "R03" )
	R03->( dbSetorder( 1 ) )
		
	// Cria arquivo temporario 504	
	aadd(aStru504,{"Chave","C",022,0})
	aadd(aStru504,{"R504" ,"C",1082,0})
	aadd(aStru504,{"R504R" ,"C",20,0})
	
	//--< Criação do objeto FWTemporaryTable >---
	oTempR04 := FWTemporaryTable():New( "R04" )
	oTempR04:SetFields( aStru504 )
	oTempR04:AddIndex( "INDR04",{ "CHAVE" } )
	
	if( select( "R04" ) > 0 )
		R04->( dbCloseArea() )
	endIf
	
	oTempR04:Create()
	dbSelectArea( "R04" )
	R04->( dbSetorder( 1 ) )

	
	// Cria arquivo temporario 505	
	aadd(aStru505,{"Chave","C",022,0})
	aadd(aStru505,{"R505" ,"C",151,0})
	
	//--< Criação do objeto FWTemporaryTable >---
	oTempR05 := FWTemporaryTable():New( "R05" )
	oTempR05:SetFields( aStru505 )
	oTempR05:AddIndex( "INDR05",{ "CHAVE" } )
	
	if( select( "R05" ) > 0 )
		R05->( dbCloseArea() )
	endIf
	
	oTempR05:Create()
	dbSelectArea( "R05" )
	R05->( dbSetorder( 1 ) )
	
	// Cria arquivo temporario 506	
	aadd(aStru506,{"Chave","C",022,0})
	aadd(aStru506,{"R506" ,"C",151,0})
	
	//--< Criação do objeto FWTemporaryTable >---
	oTempR06 := FWTemporaryTable():New( "R06" )
	oTempR06:SetFields( aStru506 )
	oTempR06:AddIndex( "INDR06",{ "CHAVE" } )
	
	if( select( "R06" ) > 0 )
		R06->( dbCloseArea() )
	endIf
	
	oTempR06:Create()
	dbSelectArea( "R06" )
	R06->( dbSetorder( 1 ) )
       	
	// Cria arquivo temporario 507
	aadd(aStru507,{"Chave","C",022,0})
	aadd(aStru507,{"R507" ,"C",227,0})
	
	//--< Criação do objeto FWTemporaryTable >---
	oTempR07 := FWTemporaryTable():New( "R07" )
	oTempR07:SetFields( aStru507 )
	oTempR07:AddIndex( "INDR07",{ "CHAVE" } )
	
	if( select( "R07" ) > 0 )
		R07->( dbCloseArea() )
	endIf
	
	oTempR07:Create()
	dbSelectArea( "R07" )
	R07->( dbSetorder( 1 ) )
	
	// Cria arquivo temporario 508	
	aadd(aStru508,{"Chave","C",022,0})
	aadd(aStru508,{"R508" ,"C",332,0})
	
	//--< Criação do objeto FWTemporaryTable >---
	oTempR08 := FWTemporaryTable():New( "R08" )
	oTempR08:SetFields( aStru508 )
	oTempR08:AddIndex( "INDR08",{ "CHAVE" } )
	
	if( select( "R08" ) > 0 )
		R08->( dbCloseArea() )
	endIf
		
	oTempR08:Create()
	dbSelectArea( "R08" )
	R08->( dbSetorder( 1 ) )	
	
	// Alimenta variaveis R501...	
	cUniDes  := cOpeOriBTO
	dDatBas  := dDatabase
	
	cAnoMesAnt := cAnoIniBTO+cMesIniBTO
	cCompet    := substr(cAnoMesAnt,3,2) + substr(cAnoMesAnt,5,2)	
   
	cNumDoc1  := PADR(cPrefixoBTO+cNumTitBTO,20) 
	
	// Ponto de entrada para manipular o numero do documeto e o nome do arquivo.	
	If ExistBlock("PLS50012")
       aRetPto512 := ExecBlock("PLS50012",.F.,.F.,{cNumDoc1,cPrefixoBTO,cNumTitBTO,cCompet})     
       cNumDoc1	  := aRetPto512[1]   
       cNumTitBTO  := aRetPto512[2]
       If len(aRetPto512) > 2 .And. !Empty(aRetPto512[3])
	       lR506      := .T.         
           cLinkNFE   := aRetPto512[3]
           cNumDocNFE := aRetPto512[1] 
       EndIf
      If len(Alltrim(cNumTitBTO)) < 7
	   		cArqNom     := "N" + Replicate("_",7-len(Alltrim(cNumTitBTO)))+Alltrim(cNumTitBTO)	+ "." + substr(cCodOpeBTO,2,3)		
		Else
			cArqNom     := "N" + strzero(val(Iif(!Empty(cNumTitBTO),cNumTitBTO,BTO->BTO_NUMTIT)),7) + "." + substr(cCodOpeBTO,2,3)
		EndIf 
    EndIf
	
	cFatura   := cNumDoc1	
	If lR506
		cTipDoc1  := "3"
	Else
		cTipDoc1  := "1"
	EndIf
	
	If nTpMov $ "1,3"   		
		cNumDoc2	 :=PADR(cPreBTONDC+cNumNdc,20)       
		cNdc         := cNumDoc2
		cTipDoc2     := "1"
	EndIf
	
	dDatVen  := dVencSE1
	dDatEmi  := dEmisSE1
	nValor   := 0
	nRecR504 := 0
	nVlrR504 := 0
	lRecR504 := .F.
	nRecMat  := 0
	nRecOut  := 0
	nMaiMat  := 0
	nMaiOut  := 0
	
	While ! TMP->(EOF())                                				 
		If !lAutoma
			MsProcTXT("Processando " + TMP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN))
			ProcessMessage()		
		EndIf
			
		lAmbula  := .F.
		lInterc  := .F.
		lDiaria  := .F.               
		lHonInd  := .F.
		xHorFim  := ''
		
		// Posiciona BD6
		If ! BD6->(MsSeek(xFilial("BD6")+TMP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				aadd(aLog2,{"   BD6 nao encontrado","Chave BD6: ",TMP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)})
				PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			TMP->(DbSkip())
			Loop
		Endif
		
		// Verifica se eh Ambulatorial
		
		cSenAut	:= ""
		If BD6->BD6_ORIMOV == "1" //guia de servico/consulta
			If BD5->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
				lAmbula := .T.
				cTipGui := "A"
				cAliCab := "BD5"
				cTpGuia := BD5->BD5_TIPGUI
				cSenAut	:= BD5->BD5_SENHA
				//cPrsGuiTis:=BD5->BD5_NUMIMP
			Endif     
			
			If BD6->BD6_TIPGUI == '06'
				lHonInd := .T.
			EndIf
		Else
			
			// Verifica se eh Internacao  
			
			If BE4->(MsSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
				
				   nRecBD6  := BD6->(Recno()) 
                   nOrdBD6  := BD6->(IndexOrd()) 
                   nRecBR8  := BR8->(Recno()) 
                   nOrdBR8  := BR8->(IndexOrd())
                   cSenAut	:= BE4->BE4_SENHA 
                   //cPrsGuiTis:=BE4->BE4_NUMIMP
                   
                   BD6->(DbSetOrder(1))
                   If BD6->(MsSeek(xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV)))
	                   While !BD6->(Eof()) .and. xFilial("BD6")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_ORIMOV) ==;
					          					  BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
	                      	
	                      	
	                      	cQuery := " SELECT COUNT(*) COUNT FROM "+cBD7name+" WHERE "
							cQuery += "   BD7_FILIAL = '"+BD6->BD6_FILIAL+"' AND "
							cQuery += "   BD7_CODOPE = '"+BD6->BD6_CODOPE+"' AND "
							cQuery += "   BD7_CODLDP = '"+BD6->BD6_CODLDP+"' AND "
							cQuery += "   BD7_CODPEG = '"+BD6->BD6_CODPEG+"' AND "
							cQuery += "   BD7_NUMERO = '"+BD6->BD6_NUMERO+"' AND "
							cQuery += "   BD7_ORIMOV = '"+BD6->BD6_ORIMOV+"' AND "
							cQuery += "   BD7_SEQUEN = '"+BD6->BD6_SEQUEN+"' "
							
							// Itens de NF inseridos pelo Compras precisam ser exportados		         
							
							If !BD6->BD6_MOTBPG $ '066-067-068'
								cQuery += " AND BD7_BLOPAG <> '1' "  
							EndIf	
							PlsQuery(cQuery,"QUERYBD7")
							
							If QUERYBD7->COUNT == 0 .or. BD6->BD6_BLOCPA == '1'
								QUERYBD7->(DbCloseArea())
								BD6->(DbSkip())
								Loop
							Else
								QUERYBD7->(DbCloseArea())
	                      	Endif
	                      	
	                      	cCodSer :=BD6->BD6_CODPRO
	                      	BR8->(DbSetOrder(3))  
	                      	If BR8->(MsSeek(xFilial("BR8")+cCodSer+BD6->BD6_CODPAD)) .and. BR8->BR8_TPPROC $ '4,6'
	                      		    lDiaria := .T.
	                      		    exit
	                      	Endif   	
	                      	BD6->(DbSkip())
	                      	
	                   Enddo
                   Endif   	
                    
				   BD6->(DbGoTo(nRecBD6))  
                   BD6->(DbSetOrder(nOrdBD6))
                   BR8->(DbGoTo(nRecBR8))  
                   BR8->(DbSetOrder(nOrdBR8))
            	   
				   If lDiaria .or.BE4->BE4_REGINT == "3"
				   		lInterc := .T.
				   		cTipGui := "I"
				   		cAliCab := "BE4"
				   Else
				   		lAmbula := .T.
				   		cTipGui := "A"
				   		cAliCab := "BE4"
				   Endif
			Endif
		Endif
		If ! lAmbula .and. ! lInterc
				aadd(aLog2,{"   A guia nao foi caracterizada como Ambulatorial nem como internacao. Verificar.","Chave BD6: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)})
				PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			TMP->(DbSkip())
			Loop
		Endif
		
		// Monta vetor com BD6		
		nRecnoBD6 := TMP->BD6_RECNO  
		cChave    := TMP->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
		aBD6      := {}
		lConsulta := .T.
		lTemCon   := .F.
		lExiProc  := .F. 
		nRecBR8   := BR8->(Recno())
		nOrdBR8   := BR8->(IndexOrd())          
		BR8->(DbSetOrder(1))
		While TMP->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)==cChave .and. ! TMP->(EOF())
			
			// Verifica se tem algum procedimento que nao eh consulta                   
			
			If cTipGui == "A"                                                 
				
		   		// Definido diretamente consulta em PS 10101019 como SADT pois nao e         
		   		// possivel altera-lo no PLSISCON a carater de SIB e demais rotinas         
		   		
				If AllTrim(TMP->BD6_CODPRO) == '10101039'
					lConsulta := .F.
				Else
					If !PLSISCON(AllTrim(TMP->BD6_CODPAD),AllTrim(TMP->BD6_CODPRO))
						lConsulta := .F.
					Else
						lTemCon   := .T.
					Endif    
				EndIf					
			Else
				lConsulta := .F.
			Endif
			
			aadd(aBD6,TMP->BD6_RECNO)
			TMP->(DbSkip())
		Enddo
		BR8->(dbGoTo(nRecBR8))
		BR8->(DbSetOrder(nOrdBR8))
		BD6->(dbGoTo(nRecnoBD6))
		
		// Alimenta variaveis R502		
		cLote   	:= strzero(val(BD6->BD6_CODPEG),8)
		cLotB5S	 	:= BD6->BD6_CODLDP + cLote
		cDtEnv   	:= dtos(BD6->BD6_DTDIGI)
		cAvisoIt 	:= "N"
 		cAvisoGu 	:= "N"

		if B5S->(msseek(xFilial("B5S") + BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO ))) 		
			if B2S->(MsSeek(xFilial("B2S")+B5S->B5S_NUMLOT)) .And. !empty(B2S->B2S_HORENV)				 
				cAvisoGu := "S"
				
				
				if B6S->(msseek(xFilial("B6S") + B5S->B5S_NUMLOT + BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN + BD6_CODPAD + BD6_CODPRO)))
					cAvisoIt := "S"
				endif
			endIf	
		endif
		
		If BR8->(MsSeek(xFilial("BR8")+TMP->BD6_CODPAD+TMP->BD6_CODPRO)) .and. BR8->BR8_TPPROC == '0' .and. (!PLSISCON(AllTrim(TMP->BD6_CODPAD),AllTrim(TMP->BD6_CODPRO)) .Or. AllTrim(TMP->BD6_CODPRO) == '10101039')					
			lExiProc := .T.				
		Endif

		If 	nTipoNota==1
			cNota := Alltrim(BD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))			
		ElseIf nTipoNota==2 
		    
    		// Caso o numero de impresso nao esteja preenchido, envia o numero da guia  
    		// pois o registro NR_NOTA e um campo mandatorio	     	
		    If Empty(BD6->BD6_NUMIMP)		    	
			    cNota := Alltrim(BD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))			    	
			Else
               	cNota := PadR(BD6->BD6_NUMIMP,20)
			EndIf    
		Else
			cNota := PadR(cSenAut,20) 
		EndIf           
				
		If Empty(cNota)			
			cNota := Alltrim(BD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))				
		EndIf                                         
		
		cChaNot := cLote + strzero(val(BD6->BD6_NUMERO),11)
		If cTipGui == "I"  // Internacao
			cTipNot := "3"
		Else
			If lHonInd
			    cTipNot := "4"  // Honorario Individual
			ElseIf  lConsulta
				cTipNot := "1"  // Consulta
			Else
				cTipNot := "2"  // SADT
			Endif
		Endif
	    
    	// Verifica se e a nota principal para preencher o campo ID_NOTA_PRINCIPAL	   	
		If lConsulta 
			cIdNotPri := 'S'    
		ElseIf lHonInd	      
			cIdNotPri := 'N'    
		ElseIf cTipGui == "I" 
			IIF(Empty(BE4->BE4_GUIINT),cIdNotPri := 'S',cIdNotPri := 'N')
		Else
			IIF(Empty(BD5->BD5_GUIINT),IIF(Empty(BD5->BD5_GUIPRI),cIdNotPri := 'S',cIdNotPri := 'N'),cIdNotPri := 'N')
		EndIf	
     	
    	// Verifica versao TISS do Prestador	   	       
	   	cArqImp  := ""  
	   	cVerTISS := "" 
	   	If cTipGui == "I" 
        	cArqImp := BE4->BE4_ARQIMP	
   		Else
   			If !lUsArImVe
	            BEA->(DbSetOrder(12))//BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
	            If BEA->(DbSeek(xFilial("BEA")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV))) .And. !Empty(BEA->BEA_ARQIMP)
	            	cArqImp := BEA->BEA_ARQIMP	
	            EndIf     
	        Else
	            BCI->(dbSetOrder(1)) //BCI_FILIAL, BCI_CODOPE, BCI_CODLDP, BCI_CODPEG, BCI_FASE, BCI_SITUAC, R_E_C_N_O_, D_E_L_E_T_
				If BCI->(MsSeek(xFilial("BCI")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG)))
					cArqImp := BCI->BCI_ARQUIV
				Endif
	        EndIf
	   	EndIf   
	   	
        If !lUsArImVe
		   	If !Empty(cArqImp) 
		   		BXX->(DbSetOrder(4))//BXX_FILIAL + BXX_CODINT + BXX_ARQIN
		   		If BXX->(DbSeek(xFilial("BXX")+PlsIntPad()+cArqImp ))
					cVerTISS := BXX->BXX_VERTIS
				EndIf   	
		   	EndIf    
		Else
		 	If !Empty(cArqImp) 
		   		BXX->(DbSetOrder(4))//BXX_FILIAL + BXX_CODINT + BXX_ARQIN
		   		If BXX->(DbSeek(xFilial("BXX")+PlsIntPad()+cArqImp ))
					cVerTISS := BXX->BXX_TISVER
				EndIf   	
 		  	EndIf  
		EndIf
			   	
	   	If !Empty(cArqImp) .And. Empty(	cVerTISS)
	   		BSA->(DbSetOrder(2))//BSA_FILIAL+BSA_CONTEU 
	   		If BSA->(DbSeek(xFilial("BSA")+cArqImp))
	   			cVerTISS := BSA->BSA_VERTIS
	   		EndIf	
	   	EndIf                       
	   	
	   	If !lUsArImVe
		   	If Empty(cVerTiss) 
		   	    aAreaBAU := BAU->(GetArea())
		   	    BAU->(DbSetOrder(1))//BAU_FILIAL + BAU_CODIGO
		   	    If BAU->(DbSeek(xFilial("BAU")+iif(cTipGui == "I",BE4->BE4_CODRDA,BD5->BD5_CODRDA)))
	            	cVerTISS := BAU->BAU_TISVER
	            EndIf 
	            RestArea(aAreaBAU)
		   	EndIf 
		Else
		 	If Empty(cVerTiss) 
	   	        aAreaBAU := BAU->(GetArea())
	   	        BAU->(DbSetOrder(1))//BAU_FILIAL + BAU_CODIGO
		   	    If BAU->(DbSeek(xFilial("BAU")+iif(cTipGui == "I",BE4->BE4_CODRDA,BD5->BD5_CODRDA)))
	            	cVerTISS := BAU->BAU_TISVER
	            EndIf 
	            RestArea(aAreaBAU)
	   		EndIf 
	   	EndIf
	   		   	   	
	   	If Empty(cVerTISS) 
	   		cVerTISS := PLSTISSVER()
	   	EndIf
		
    	// Verifica numero da Guia TISS Prestador	   	    
		If cTipGui == "I" .or. BD6->BD6_TIPGUI == "05"  
			If Empty(BE4->BE4_ANOINT) .And. Empty(BE4->BE4_MESINT) .And. Empty(BE4->BE4_NUMINT) .And. !Empty(BE4->BE4_GUIINT)
				aAreaBE4 := BE4->(GetArea())
				If BE4->(DbSeek(xFilial("BE4")+BE4->BE4_GUIINT))  
					IIf(Empty(BE4->BE4_NUMIMP),cPrsGuiTis := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cPrsGuiTis := Padr(BE4->BE4_NUMIMP,20))
				EndIf
				RestArea(aAreaBE4)	
			Else
				IIf(Empty(BE4->BE4_NUMIMP),cPrsGuiTis := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cPrsGuiTis := Padr(BE4->BE4_NUMIMP,20))
			EndIf
		Else  
		    If lHonInd		    	
		    	cPrsGuiTis := Padr(BD5->BD5_NUMIMP,20)		    	
		    Else    
		        BEA->(DbSetOrder(12))//BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
            	If !Empty(BD5->BD5_NUMIMP)
		    		cPrsGuiTis := Padr(BD5->BD5_NUMIMP,20)
            	ElseIf BEA->(DbSeek(xFilial("BEA")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
            		cPrsGuiTis := Padr(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),20)
            	EndIf 
		    EndIf
		EndIf      
		
    	// Verifica numero da Guia TISS Principal	   	    
	   	If cTipGui == "I" 
	    	aAreaBE4 := BE4->(GetArea()) 
	    	If !Empty(BE4->BE4_GUIINT) .And. BE4->(DbSeek(xFilial("BE4")+Alltrim(BE4->BE4_GUIINT))) 
	        	Iif(Empty(BE4->BE4_NUMIMP),cGuiPrTIS := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cGuiPrTIS := Padr(BE4->BE4_NUMIMP,20))
	    	EndIf
	    	RestArea(aAreaBE4)
		Else  
		    If lHonInd  
		    	aAreaBE4 := BE4->(GetArea()) 
	    		If !Empty(BD5->BD5_GUIINT) .And. BE4->(msSeek(xFilial("BE4")+Alltrim(BD5->BD5_GUIINT))) 
	        		Iif(Empty(BD5->BD5_NUMIMP),cGuiPrTIS := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cGuiPrTIS := Padr(BD5->BD5_NUMIMP,20))
	    		EndIf
	    		RestArea(aAreaBE4)
		    Else    
		    	aAreaBE4 := BE4->(GetArea())   
		    	If BE4->(DbSeek(xFilial("BE4")+Alltrim(BD5->BD5_GUIINT))) 
		    	 	Iif(Empty(BE4->BE4_NUMIMP),cGuiPrTIS := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cGuiPrTIS := Padr(BE4->BE4_NUMIMP,20))
		    	EndIf
		    	RestArea(aAreaBE4)
		    EndIf
		EndIf      
	   	
		// Campos de auditores Versao 6.0 		
		If cTipGui == "I" .and. BE4->(FieldPos("BE4_UMAUDI")) > 0 //TODO criar os campos no atusx
			cNomMedAud := Padr(BE4->BE4_NMAUDI,40)
			cRegMedAud := Padr(BE4->BE4_RMAUDI,15)
			cUFMedAud  := PadR(BE4->BE4_UMAUDI,2)
			cNomEnfAud := Padr(BE4->BE4_NEAUDI,40)
			cRegEnfAud := Padr(BE4->BE4_REAUDI,15)	   
			cUFEnfAud  := PadR(BE4->BE4_UEAUDI,2)
		EndIf

   		BA1->(DbSetOrder(2))
		If BA1->(MsSeek(xFilial("BA1")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG))) .And. ! Empty(BA1->BA1_MATEDI)
			cMatAnt := BA1->BA1_MATEDI
		Else
			cMatAnt := BD6->BD6_MATANT
		Endif                        
		
		cCodInt := if(len(alltrim(cMatAnt))=17,substr(cMatAnt,01,4),"0"+substr(cMatAnt,01,3))
		cCodEmp := if(len(alltrim(cMatAnt))=17,substr(cMatAnt,05,4),substr(cMatAnt,04,4))
		cMatric := if(len(alltrim(cMatAnt))=17,substr(cMatAnt,09,6),substr(cMatAnt,08,6))
		cTipReg := if(len(alltrim(cMatAnt))=17,substr(cMatAnt,15,2),substr(cMatAnt,14,2))
		cDigito := if(len(alltrim(cMatAnt))=17,substr(cMatAnt,17,1),substr(cMatAnt,16,1))
		
		If Empty(cDigito)
			cDigito := IIF(FindFunction("StrTPLS"),Modulo11(StrTPLS(cCodInt+cCodEmp+cMatric+cTipReg)),Modulo11(cCodInt+cCodEmp+cMatric+cTipReg))
		Endif
		
		cNomUsr := PlRetponto(substr(BD6->BD6_NOMUSR+Space(25),1,25))
		
		If cTipGui=="A"
			If ! empty(&(cAliCab+"->"+cAliCab+"_DATPRO"))
				cDt := substr(dtos(&(cAliCab+"->"+cAliCab+"_DATPRO")),1,4) + "/" + substr(dtos(&(cAliCab+"->"+cAliCab+"_DATPRO")),5,2) + "/" + substr(dtos(&(cAliCab+"->"+cAliCab+"_DATPRO")),7,2)
			Else
				cDt := "0000/00/00"
			Endif
			If ! empty(&(cAliCab+"->"+cAliCab+"_HORPRO"))
				cHr := StrZero(Val(substr(&(cAliCab+"->"+cAliCab+"_HORPRO"),1,2)), 2, 0) + ":" + StrZero(Val(substr(&(cAliCab+"->"+cAliCab+"_HORPRO"),3,2)), 2, 0) + ":00"+cGNT
			Else
				cHr := "00:00:00"+cGNT
			Endif
			cDtaAte :=  cDt + cHr
		Else
			If ! empty(&(cAliCab+"->"+cAliCab+"_DATPRO"))
				cDt := substr(dtos(&(cAliCab+"->"+cAliCab+"_DATPRO")),1,4) + "/" + substr(dtos(&(cAliCab+"->"+cAliCab+"_DATPRO")),5,2) + "/" + substr(dtos(&(cAliCab+"->"+cAliCab+"_DATPRO")),7,2)
			Else
				cDt := "0000/00/00"
			Endif
			If ! empty(&(cAliCab+"->"+cAliCab+"_HORPRO"))
				cHr := StrZero(Val(substr(&(cAliCab+"->"+cAliCab+"_HORPRO"),1,2)), 2, 0) + ":" + StrZero(Val(substr(&(cAliCab+"->"+cAliCab+"_HORPRO"),3,2)), 2, 0) + ":00"+cGNT
			Else
				cHr := "00:00:00"+cGNT
			Endif
			cDtaAte :=  cDt + cHr
		Endif		
		
		cIdHab	:= iif(PLS272VLD(cUniDes, cUniOri, BD6->(BD6_CODEMP+BD6_MATRIC+BD6_TIPREG+BD6_DIGITO), stod(cDtaAte), cUniOri),'S','N' )		

		cCodCid := &(cAliCab+"->"+cAliCab+"_CID")
		
		cCodCid := StrTran(cCodCid,"*","")
		cCodCid := StrTran(cCodCid,"+","")
		cCodCid := StrTran(cCodCid,".","")
		cCodCid := Subs(AllTrim(cCodCid)+Space(06),1,6)
		
		If empty(cCodCid)
			cCodCid := "Z00   "
		Endif                                        
		
		cAteAmb := IIF(cTipGui=="A" .And. lExiProc  ,"1","2")
		
		If lExiProc .and. lTemCon
			cAteAmb := "2"
		Endif
		//O atendimento SOMENTE pode ser ambulatorial caso nao seja uma consulta e nao seja uma GIH		
		// Busca a tabela de Alias de Carater de Atendimento e Consulta		
		
		BTP->(DbSetOrder(1))
		If BTP->(DbSeek(xFilial("BTP")+"23"))//Carater de Atendimento
			cAliCarAte := BTP->BTP_ALIAS
		EndIf	
		If BTP->(DbSeek(xFilial("BTP")+"52"))//Tipo de Consulta
			cAliTipCon := BTP->BTP_ALIAS
		EndIf	
		
		// Verifica o registro TP_CARATER_ATEND - Passo 1: Internacao		
		If cTipGui== "I" 		   	
			
			cCarAtend := Space(1)  //Reinicializa
			cTipCon   := Space(1) //A Partir da versao 6.1, o tipo de consulta so e preenchido para atendimentos de consulta
	        
			If !Empty(cAliCarAte)
				cCarAtend := Alltrim(PLSGETVINC("BTU_CDTERM", cAliCarAte, nil, "23" , AllTrim(BE4->BE4_TIPADM), .F. , nil, nil ) )
			EndIf	
			
			// Nao achou vinculo BTU, procura na regra antiga			
			If Empty(cCarAtend)
				DbSelectArea("BDR")
	        	BDR->(DbSetOrder(1))//BDR_FILIAL+BDR_CODOPE+BDR_CODTAD
	           	If BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+AllTrim(BE4->BE4_TIPADM))) 
	           		If !Empty(BDR->BDR_CODEDI) //Se estiver informado o campo BDR_CODEDI, o mesmo sera priorizado 
	               		cCarAtend := BDR->BDR_CODEDI 
	           		Else
	               		If BDR->BDR_CARINT == "E" //Eletiva
	               	 		cCarAtend := "1"
	               		ElseIf BDR->BDR_CARINT == "U" //Urgencia/Emergencia
	               			cCarAtend := "2"
	               		EndIf 
	               	EndIf	
	           	EndIf    
			EndIf 
 
			If Empty (cCarAtend)//Padrao e eletivo
				cCarAtend := '1'
			EndIf	 
		 	
    	
		// Guias de Consulta/SADT/Honorario Individual		
        ElseIf cTipGui=="A" 
	        
	        cTipCon := '0' //Padrao
		   	
			// Para guias de honorario, devo posicionar na internacao origem            
			
		    If BD6->BD6_TIPGUI == '06' 
	
		    	BE4->(DbSetOrder(1))//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
		    	If BE4->(DbSeek(xFilial("BE4")+BD5->BD5_GUIINT))
		    	
					cCarAtend := Space(1)  //Reinicializa
					cTipCon   := Space(1)
	                If !Empty(cAliTipCon)
		    	  		cTipCon := Alltrim(PLSGETVINC("BTU_CDTERM", cAliTipCon, nil, "52" , BD6->BD6_TIPCON, .F. , nil, nil ) )
			        EndIf    
	 				
					// Se nao achou De-Para TISS, usa De-Para pre-definido                   	   
					//	1=Primeira;2=Seguimento;3=Pre-Natal;4=Por Encaminhamento;5=Retorno					
			        If Empty(cTipCon)
			        	Do Case 
			        		Case BD6->BD6_TIPCON == "1"//Primeira  
			        			cTipCon := "1"
			        		Case BD6->BD6_TIPCON == "2"//Seguimento
			        		  	cTipCon := "5"
			        		Case BD6->BD6_TIPCON == "3"//Pre-Natal
			        		 	cTipCon := "3"
			        		Case BD6->BD6_TIPCON == "4"//Por Encaminhamento
			        			cTipCon := "4"   	  
			        		Case BD6->BD6_TIPCON == "5"//Retorno
			        			cTipCon := "2"   		
			        	EndCase
			        EndIf

			        If !lConsulta .And. !Empty(cAliCarAte)
						cCarAtend := Alltrim(PLSGETVINC("BTU_CDTERM", cAliCarAte, nil, "23" , AllTrim(BE4->BE4_TIPADM), .F. , nil, nil )) 
					EndIf
					
					// Nao achou vinculo BTU, procura na regra antiga					
					If Empty(cCarAtend) .And. !lConsulta
						DbSelectArea("BDR")
			        	BDR->(DbSetOrder(1))//BDR_FILIAL+BDR_CODOPE+BDR_CODTAD
			           		If BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+AllTrim(BE4->BE4_TIPADM))) 
			           		If !Empty(BDR->BDR_CODEDI) //Se estiver informado o campo BDR_CODEDI, o mesmo sera priorizado 
			               		cCarAtend := BDR->BDR_CODEDI 
			           		Else
			               		If BDR->BDR_CARINT == "E" //Eletiva
			               	 		cCarAtend := "1"
			               		ElseIf BDR->BDR_CARINT == "U" //Urgencia/Emergencia
			               			 cCarAtend := "2"
			               		EndIf 
			               	EndIf	
			           	EndIf    
					EndIf 
		            
					If Empty(cCarAtend) .And. !lConsulta//Padrao e eletivo
						cCarAtend := '1'
					EndIf	
  					
		    	EndIf  
	
		    
			// Caso exista uma guia de resumo sem diaria preciso posicionar na BE4      
			
		    ElseIf BD6->BD6_TIPGUI == '05' 
		    	
		    	BE4->(DbSetOrder(1))//BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
		    	If BE4->(DbSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))
		    		cCarAtend := Space(1)  //Reinicializa
					cTipCon   := Space(1)
		    		   
		    		If !Empty(cAliTipCon)
		       	  		cTipCon := Alltrim(PLSGETVINC("BTU_CDTERM", cAliTipCon, nil, "52" , BD6->BD6_TIPCON, .F. , nil, nil )) 
			       	EndIf  
			        
					// Se nao achou De-Para TISS, usa De-Para pre-definido                   	  
					//	1=Primeira;2=Seguimento;3=Pre-Natal;4=Por Encaminhamento;5=Retorno       	
					
			        If Empty(cTipCon)
			       		Do Case 
			           		Case BD6->BD6_TIPCON == "1"//Primeira  
			           			cTipCon := "1"
			           		Case BD6->BD6_TIPCON == "2"//Seguimento
			           		  	cTipCon := "5"
			           		Case BD6->BD6_TIPCON == "3"//Pre-Natal
			           		 	cTipCon := "3"
			           		Case BD6->BD6_TIPCON == "4"//Por Encaminhamento
			           			cTipCon := "4"   	  
			           		Case BD6->BD6_TIPCON == "5"//Retorno
			           			cTipCon := "2"   		
			           	EndCase
			      	EndIf  
			           
			      	If !lConsulta .And. !Empty(cAliCarAte)
						cCarAtend := Alltrim(PLSGETVINC("BTU_CDTERM", cAliCarAte, nil, "23" , AllTrim(BE4->BE4_TIPADM), .F. , nil, nil ) )
					EndIf
					
					// Nao achou vinculo BTU, procura na regra antiga                      	 	
					
					If Empty(cCarAtend) .And. !lConsulta						
			          	BDR->(DbSetOrder(1))//BDR_FILIAL+BDR_CODOPE+BDR_CODTAD
			           	If BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+AllTrim(BE4->BE4_TIPADM))) 
			            	If !Empty(BDR->BDR_CODEDI) //Se estiver informado o campo BDR_CODEDI, o mesmo sera priorizado 
			              		cCarAtend := BDR->BDR_CODEDI 
			            	Else
			              		If BDR->BDR_CARINT == "E" //Eletiva
			              	 		cCarAtend := "1"
			            		ElseIf BDR->BDR_CARINT == "U" //Urgencia/Emergencia
			              			cCarAtend := "2"
			              		EndIf 
			              	EndIf	
			            EndIf    
					EndIf 
		 
					If Empty (cCarAtend) .And. !lConsulta//Padrao e eletivo
						cCarAtend := '1'
					EndIf	
		  	 		  
		    	EndIf
		    
		   	
			// SADT e Consulta                                                          
				
		    Else 		    	
		    	cCarAtend := Space(1)  //Reinicializa
		    	cTipCon   := Space(1)  //Reinicializa
		    	If !Empty(cAliTipCon)
		 			cTipCon := Alltrim(PLSGETVINC("BTU_CDTERM", cAliTipCon, nil, "52" , BD6->BD6_TIPCON, .F. , nil, nil ) )
		 		EndIf	 
		 	    
				// Se nao achou De-Para TISS, usa De-Para pre-definido                   	   
				//	1=Primeira;2=Seguimento;3=Pre-Natal;4=Por Encaminhamento;5=Retorno       
				
			    If Empty(cTipCon)
			       	Do Case 
			       		Case BD6->BD6_TIPCON == "1"//Primeira  
			       			cTipCon := "1"
			       		Case BD6->BD6_TIPCON == "2"//Seguimento
			       		  	cTipCon := "5"
			       		Case BD6->BD6_TIPCON == "3"//Pre-Natal
			       		 	cTipCon := "3"
			       		Case BD6->BD6_TIPCON == "4"//Por Encaminhamento
			       			cTipCon := "4"   	  
			       		Case BD6->BD6_TIPCON == "5"//Retorno
			       			cTipCon := "2"   		
			    	EndCase
			    EndIf 
		    	 
				 // Novo campo BD5_TIPADM tambem indica Emergencia/Urgencia                  
				 
				If !lConsulta
					If AllTrim(BD5->BD5_TIPADM) == "4" .OR. AllTrim(BD5->BD5_TIPADM) == "5"
						cCarAtend := '2'
	               	ElseIf !Empty(cAliCarAte)
						cCarAtend := Alltrim(PLSGETVINC("BTU_CDTERM", cAliCarAte, nil, "23" , BD5->BD5_TIPADM, .F. , nil, nil ) )
					EndIf 
				EndIf  
				
				// Nao achou vinculo BTU, procura na regra antiga                      	 
				
				If Empty(cCarAtend) .And. !lConsulta
					DbSelectArea("BDR")
			      	BDR->(DbSetOrder(1))//BDR_FILIAL+BDR_CODOPE+BDR_CODTAD
			       		If BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+BD5->BD5_TIPADM)) 
			        	If !Empty(BDR->BDR_CODEDI) //Se estiver informado o campo BDR_CODEDI, o mesmo sera priorizado 
			           		cCarAtend := BDR->BDR_CODEDI 
			        	Else
			           		If BDR->BDR_CARINT == "E" //Eletiva
			           	 		cCarAtend := "1"
			     	   		ElseIf BDR->BDR_CARINT == "U" //Urgencia/Emergencia
			           			cCarAtend := "2"
			           		EndIf 
			           	EndIf	
			        EndIf    
				EndIf 
				
				If Empty (cCarAtend) .And. !lConsulta //Padrao e eletivo
					cCarAtend := '1'
				EndIf  			
				
			EndIf
		EndIf   

		
		// DT_PROTOCOLO e DT_PGTO_PRESTADOR                                         
		
		cDatProtoc := Dtos(BD6->BD6_DTANAL)
		If !Empty(BD6->BD6_DTPAGT) 
			cDatPagam  := Dtos(BD6->BD6_DTPAGT) 
		Else
		   BDT->(DbSetOrder(1))//BDT_FILIAL + BDT_CODINT + BDT_ANO + BDT_MES + dtos(BDT_DATINI) + dtos(BDT_DATFIN)
		   If BDT->(DbSeek(xFilial("BDT")+PlsIntPad()+BD6->(BD6_ANOPAG+BD6_MESPAG)))
               cDatPagam  := Dtos(BDT->BDT_DATFIN)	
		   EndIf
		Endif	
		
		// Ponto de entrada para tratar DT_PROTOCOLO e DT_PGTO_PRESTADOR            
		
		If lPLS50008
           aRetPto508 := ExecBlock("PLS50008",.F.,.F.,{BD6->(Recno())})     
           cDatProtoc := aRetPto508[1]   
           cDatPagam  := aRetPto508[2] 
        EndIf
	
		cTipPac := IIF(cTipGui=="A" .and. cAliCab == "BD5" ,strzero(val(BD5->BD5_TIPPAC),1),"1")
		If ! cTipPac $ "1,2,3,4,5,6,7,8,9"
			cTipPac := "1"
		Endif
		
		// Verifica o registro REG_INTERNACAO                                       
		
		If cTipGui == "I" 
			cTpRegInt := BE4->BE4_REGINT
		EndIf
 	    
 	    If lPLS50007
           aRetPto507 := ExecBlock("PLS50007",.F.,.F.,{cTipCon})
           If ValType(aRetPto507) == "A" .And. Len(aRetPto507) >= 1
               cTipCon := aRetPto507[1]
          Endif   
        Endif   
		
		// Alimenta variaveis R503
        cTipNas    	:= "00" 			// Tipo de Internacao Obstetrica
		cQtNasViv  	:= BE4->BE4_NASVIV 	// Nascidos Vivos a Termo
		cQtNasMor  	:= BE4->BE4_NASMOR 	// Nascidos Mortos
		cQtNasVPr  	:= BE4->BE4_NASVPR 	// Nascidos Vivos Prematuros
		cQtObiPre  	:= "0" 				// Obito Neonatal precoce
		cQtObiTar  	:= "0" 				// Obito Neonatal Tardio
		cID_OBT1  	:= Space(1)					  
		cID_OBT2   	:= Space(1)					
		cID_OBT3   	:= Space(1)					
		cID_OBT4   	:= Space(1)					
		cID_OBT5   	:= Space(1)					
		cID_OBT6   	:= Space(1)				
		cID_OBT7   	:= Space(1)			
		cID_OBT8   	:= Space(1)						 
		cID_OBT9   	:= Space(1)
		cTP_OBTMULH	:= Space(1)								
		cTP_FATURA 	:= "1"						  
		cCD_CIDOBT 	:= space(6)					
		cNR_DECOBT 	:= space(7)						  
		cNR_VIVO1  	:= space(15)						  
		cNR_VIVO2  	:= space(15)
		cNR_VIVO3  	:= space(15)
		cNR_VIVO4  	:= space(15)
		cNR_VIVO5  	:= space(15)		
		cIndAcid   	:= '9' //9 = Não Acidente		
		cTiAutUnim 	:=If(BD5->BD5_TPGRV=="1","1","2") // Tipo de autorizaçõa TP_AUTORIZ				      
		xHorFim  	:= ''

		If cTipGui == "A"
			
			// Grava a senha de Autorizacao	
			If len(Alltrim(&(cAliCab+"->"+cAliCab+"_NRAOPE"))) > 10 
				cNroAut := Substr(&(cAliCab+"->"+cAliCab+"_NRAOPE"),1,10)
			Else
				cNroAut := strzero(val(&(cAliCab+"->"+cAliCab+"_NRAOPE")),10)
			EndIf
			If val(cNroAut) == 0
				
				nRecBEA := BEA->(Recno())
				nOrdBEA := BEA->(IndexOrd())     
				cGuiSol := BD5->BD5_NRLBOR  
				
				//tratamento para virada de versao... tem q considerar que guias podem ter sido importadas na 10 e estao gerando na 11	
				If !Empty(cGuiSol) 
					BEA->(DbSetOrder(1))
					If BEA->(MsSeek(xFilial('BEA')+cGuiSol))		
						//pego o dado da guia orinal
						If ! empty(BEA->BEA_NRAOPE)
							cNroAut := strzero(val(BEA->BEA_NRAOPE),10)
						Endif                                          
					Endif
					BEA->(DbGoto(nRecBEA))
					BEA->(DbSetOrder(nOrdBEA))
				Endif
			Endif
			
			
			If val(cNroAut) > 0
				cUniAut := cCodInt
				cCodExc := "L"
			Else
				cUniAut := "0000"
				cCodExc := "0"
			EndIf
			
			// Guia de Honorario Individual                                             
			
			If BD6->BD6_TIPGUI == "06"    
			    aAreaBE4 := BE4->(GetArea())
    			cDtHrInt := Space(21) 
				cDtHrSai := Space(21)
			    If BE4->(DbSeek(xFilial("BE4")+BD5->BD5_GUIINT))   
			    	nRecBE4 := BE4->(Recno())	
			    	
					// Verifico se a Guia de Solicitação tem data de Alta					
			        xHorFim  := strtran(strtran(BD5->BD5_HORPRO,':',''),' ','')
                    xHorFim  := substr(xHorFim,1,2) + ":"+ substr(xHorFim,3,2)
                   	
					// Procura uma de resumo com data de alta preenchida dentro do periodo						
					cWhilBE4HI := xFilial("BE4")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)
					BE4->(DbSetOrder(15))//BE4_FILIAL + BE4_GUIINT  
			
					If BE4->(DbSeek(xFilial("BE4")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO)))    
							
						While cWhilBE4HI == xFilial("BE4")+BE4->BE4_GUIINT .And. !BE4->(Eof())
							    
					   		// Prioridade: Data Iicio e Fim de Faturamento								
							If !Empty(BE4->BE4_DTFIMF) .And. ;
							    ((BD6->BD6_DATPRO > BE4->BE4_DTINIF) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTINIF .And. BD6->BD6_HORPRO >= BE4->BE4_HRINIF)) .And. ;
							    ((BD6->BD6_DATPRO < BE4->BE4_DTFIMF) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTFIMF .And. BD6->BD6_HORPRO <= BE4->BE4_HRFIMF))  
								 
								cDtHrInt := substr(dtos(BE4->BE4_DTINIF),1,4) + "/" +; 
						  	   	substr(dtos(BE4->BE4_DTINIF),5,2) + "/" + ;
							    substr(dtos(BE4->BE4_DTINIF),7,2)       + ;
		 						substr(BE4->BE4_HRINIF,1,2)+":"+ ;
								substr(BE4->BE4_HRINIF,3,2)+":"+ ;
							   	Iif(Len(ALLTRIM(BE4->BE4_HRINIF)) >5, Substr(BE4->BE4_HRINIF,5,2),"00")+cGNT   

				     		
							    cDtHrSai := substr(dtos(BE4->BE4_DTFIMF),1,4) + "/" +;
				     			substr(dtos(BE4->BE4_DTFIMF),5,2) + "/" +;
							  	substr(dtos(BE4->BE4_DTFIMF),7,2)		  +;  
							  	substr(BE4->BE4_HRFIMF,1,2)+":"+ ;
							   	substr(BE4->BE4_HRFIMF,3,2)+":"+ ;
							   	Iif(Len(ALLTRIM(BE4->BE4_HRFIMF)) >5, Substr(BE4->BE4_HRFIMF,5,2),"00")+cGNT 
							    	
							   	Exit  
							EndIf
								
					   		// Nao achei Data Inicio/Fim de Faturamento, uso Data de Internacao/Alta 								
							If !Empty(BE4->BE4_DTALTA) .And. ;  
							    ((BD6->BD6_DATPRO > BE4->BE4_DATPRO) .Or. (BD6->BD6_DATPRO == BE4->BE4_DATPRO .And. BD6->BD6_HORPRO >= BE4->BE4_HORPRO)) .And. ;
								((BD6->BD6_DATPRO < BE4->BE4_DTALTA) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTALTA .And. BD6->BD6_HORPRO <= BE4->BE4_HRALTA))  
								       
						        cDtHrInt := substr(dtos(BE4->BE4_DATPRO),1,4) + "/" +; 
						  		    substr(dtos(BE4->BE4_DATPRO),5,2) + "/" + ;
								    substr(dtos(BE4->BE4_DATPRO),7,2)       + ;
								    Substr(BE4->BE4_HORPRO,1,2)+":"+ ;
								    Substr(BE4->BE4_HORPRO,3,2)+":"+ ;
								    Iif(Len(ALLTRIM(BE4->BE4_HORPRO)) >5, Substr(BE4->BE4_HORPRO,5,2),"00")+cGNT   
		
						     		
					     		cDtHrSai := substr(dtos(BE4->BE4_DTALTA),1,4) + "/" +; 
				    				substr(dtos(BE4->BE4_DTALTA),5,2) + "/" +;
							    	substr(dtos(BE4->BE4_DTALTA),7,2)		  +;
							    	Substr(BE4->BE4_HRALTA,1,2)+":"+ ;
							    	Substr(BE4->BE4_HRALTA,3,2)+":"+ ;
							    	Iif(Len(ALLTRIM(BE4->BE4_HRALTA)) >5, Substr(BE4->BE4_HRALTA,5,2),"00")+cGNT   								
								
								Exit
							EndIf
							
							BE4->(DbSkip())
						EndDo
					EndIf                                                                    

					// Nao achei resumo, busco a solicitacao
					If Empty(cDtHrInt) .And. Empty(cDtHrSai)  
					  	BE4->(DbSetOrder(1))
					 	BE4->(dbGoTo(nRecBE4))  
					   		
                    		
					   	// Prioridade: Data Iicio e Fim de Faturamento							
						If !Empty(BE4->BE4_DTFIMF) .And. ;
						    ((BD6->BD6_DATPRO > BE4->BE4_DTINIF) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTINIF .And. BD6->BD6_HORPRO >= BE4->BE4_HRINIF)) .And. ;
						    ((BD6->BD6_DATPRO < BE4->BE4_DTFIMF) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTFIMF .And. BD6->BD6_HORPRO <= BE4->BE4_HRFIMF))  
							 
							cDtHrInt := substr(dtos(BE4->BE4_DTINIF),1,4) + "/" +; 
						  	   	substr(dtos(BE4->BE4_DTINIF),5,2) + "/" + ;
							    substr(dtos(BE4->BE4_DTINIF),7,2)       + ;
		 						Substr(BE4->BE4_HRINIF,1,2)+":"+ ;
								Substr(BE4->BE4_HRINIF,3,2)+":"+ ;
							   	Iif(Len(ALLTRIM(BE4->BE4_HRINIF)) >5, Substr(BE4->BE4_HRINIF,5,2),"00")+cGNT   
							        
						    cDtHrSai := substr(dtos(BE4->BE4_DTFIMF),1,4) + "/" +;
				     			substr(dtos(BE4->BE4_DTFIMF),5,2) + "/" +;
						  		substr(dtos(BE4->BE4_DTFIMF),7,2)		  +;  
						  		Substr(BE4->BE4_HRFIMF,1,2)+":"+ ;
						   		Substr(BE4->BE4_HRFIMF,3,2)+":"+ ;
						   		Iif(Len(ALLTRIM(BE4->BE4_HRFIMF)) >5, Substr(BE4->BE4_HRFIMF,5,2),"00")+cGNT 
							   	  
						EndIf
							
					   	// Nao achei Data Inicio/Fim de Faturamento, uso Data de Internacao/Alta						
						If Empty(cDtHrInt) .And. Empty(cDtHrSai) .And. !Empty(BE4->BE4_DTALTA) .And. ; 
						    	((BD6->BD6_DATPRO > BE4->BE4_DATPRO) .Or. (BD6->BD6_DATPRO == BE4->BE4_DATPRO .And. BD6->BD6_HORPRO >= BE4->BE4_HORPRO)) .And. ;
							    ((BD6->BD6_DATPRO < BE4->BE4_DTALTA) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTALTA .And. BD6->BD6_HORPRO <= BE4->BE4_HRALTA))  
								       
						    cDtHrInt := substr(dtos(BE4->BE4_DATPRO),1,4) + "/" +; 
						  	substr(dtos(BE4->BE4_DATPRO),5,2) + "/" + ;
							substr(dtos(BE4->BE4_DATPRO),7,2)       + ;
							Substr(BE4->BE4_HORPRO,1,2)+":"+ ;
							Substr(BE4->BE4_HORPRO,3,2)+":"+ ;
							Iif(Len(ALLTRIM(BE4->BE4_HORPRO)) >5, Substr(BE4->BE4_HORPRO,5,2),"00")+cGNT   
	
						    	
						    cDtHrSai := substr(dtos(BE4->BE4_DTALTA),1,4) + "/" +; 
				     		substr(dtos(BE4->BE4_DTALTA),5,2) + "/" +;
							substr(dtos(BE4->BE4_DTALTA),7,2)		  +;
							Substr(BE4->BE4_HRALTA,1,2)+":"+ ;
							Substr(BE4->BE4_HRALTA,3,2)+":"+ ;
							Iif(Len(ALLTRIM(BE4->BE4_HRALTA)) >5, Substr(BE4->BE4_HRALTA,5,2),"00")+cGNT   
									
								
						EndIf
                    EndIf				
			    EndIf
			    RestArea(aAreaBE4)
			Else
				cDtHrInt := Space(21) 
				cDtHrSai := Space(21)
				xHorFim  := strtran(strtran(BD5->BD5_HORPRO,':',''),' ','')
                xHorFim  := substr(xHorFim,1,2) + ":"+ substr(xHorFim,3,2)
			EndIf	
			//0=Relacionado ao trabalho;1=Acidente de Transito;2=Outros Acidente;9=Nao Acidente
			   
		    BEA->(DbSetOrder(12))//BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
            If BEA->(DbSeek(xFilial("BEA")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
            	Do Case
			  		Case BEA->BEA_INDACI == "0" //1-Acidente do trabalho        
			   		    cIndAcid := "1"
				    Case BEA->BEA_INDACI == "1" //2-Acidente de transito
				        cIndAcid := "2"               
			  		Case BEA->BEA_INDACI == "2" //3-Acidente - outros   
			      		cIndAcid := "3"   
	       			Otherwise      				// 9-Não acidente
						cIndAcid := "9"
				EndCase            	 
            EndIf	
		Else
			
			// Grava a senha de Autorizacao			
			cNroAut := ''
			nRecBE4 := &(cAliCab+"->(Recno())")
			nOrdBE4 := &(cAliCab+"->(IndexOrd())")     
			cGuiSol := &(cAliCab+"->"+cAliCab+"_GUIINT")  
			
			If !empty(&(cAliCab+"->"+cAliCab+"_NRAOPE"))
				cNroAut := strzero(val(&(cAliCab+"->"+cAliCab+"_NRAOPE")),10)
			Else                                              // Botucatu pediu que buscasse no NRAEMP qdo NRAOPE estivesse vazio ??? AGS
				cNroAut := strzero(val(&(cAliCab+"->"+cAliCab+"_NRAEMP")),10)   // Rever este caso para os demais clientes ??? AGS
			Endif
			//tratamento para virada de versao... tem q considerar que guias podem ter sido importadas na 10 e estao gerando na 11	
			If !Empty(cGuiSol) .and. Empty(cNroAut)
				&(cAliCab+"->(DbSetOrder("+alltrim(str(1))+"))")
				&(cAliCab+"->(MsSeek('"+xFilial(cAliCab)+cGuiSol+"'))")		
				//pego o dado da guia orinal
				If ! empty(&(cAliCab+"->"+cAliCab+"_NRAOPE"))
					cNroAut := strzero(val(&(cAliCab+"->"+cAliCab+"_NRAOPE")),10)
				Else                                              // Botucatu pediu que buscasse no NRAEMP qdo NRAOPE estivesse vazio ??? AGS
					cNroAut := strzero(val(&(cAliCab+"->"+cAliCab+"_NRAEMP")),10)   // Rever este caso para os demais clientes ??? AGS
				Endif                                          
				&(cAliCab+"->(DbGoto("+alltrim(str(nRecBE4))+"))")
				&(cAliCab+"->(DbSetOrder("+alltrim(str(nOrdBE4))+"))")
			Endif
			If val(cNroAut) > 0
				cUniAut := cCodInt
				cCodExc := "C"
			Else
				cUniAut := "0000"
				cCodExc := "0"
			EndIf
			
			// Busca procedimento principal na Autorizacao	
			cChaAut := xFilial("BEJ") + BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
			cProPri := Space(8)
			
			BEJ->(MsSeek( cChaAut ))
			
			While  ! BEJ->(EOF()) .and. BEJ->(BEJ_FILIAL+BEJ_CODOPE+BEJ_ANOINT+BEJ_MESINT+BEJ_NUMINT)==cChaAut
				
				If BEJ->BEJ_PROPRI == "1"
					cProPri := BEJ->BEJ_CODPRO
					EXIT
				Endif
				
				BEJ->(DbSkip())
			Enddo
			
			// Posiciona a RDA	
			If BAU->(MsSeek( xFilial("BAU")+BE4->BE4_CODRDA ))
				cCGCHos := strzero(val(BAU->BAU_CPFCGC),14)
			Else
				cCGCHos := replicate("0",14)
			Endif

			cCGCHos := iif(BE4->BE4_REGINT=='3',replicate("0",14) ,cCGCHos)

			cUniHos := iif(BE4->BE4_REGINT=='3','0000',BE4->BE4_OPERDA)
			
			If nTipoCRDA == 1
				cCodHos := strzero(val(BE4->BE4_CODRDA),8)
			Else
				If Empty(BAU->BAU_CONREG)
					cCodHos := "00" + BAU->BAU_CODIGO
				Else
					cCodHos := "00" + StrZero(Val(BAU->BAU_CONREG),6)
				Endif
			Endif
			cCodHos := iif(BE4->BE4_REGINT=='3','00000000',cCodHos)
						
			cNomHos := PlRetponto(substr(BE4->BE4_NOMRDA+Space(60),1,60))
			cNomHos := iif(BE4->BE4_REGINT=='3',space(60),cNomHos)
			
			IF BE4->BE4_REGINT == '3'
				cTipAco := '  '
			else
				if BI4->(MsSeek( xFilial("BI4")+BE4->BE4_PADINT ))
					if BI4->BI4_CODEDI == "1" 
						cTipAco := "B "
					elseIf BI4->BI4_CODEDI  $ '2/3/4'
						cTipAco := "A "
					elseIf !Empty(BI4->BI4_CODEDI)
						cTipAco := BI4->BI4_CODEDI
					endif	
				endif

				if Empty(cTipAco)
					aadd(aLog2,{"Tipo de Acomodação Inválido: " + alltrim(BE4->BE4_PADINT),"Chave BE4: ",BE4->(BE4_CODOPE+" "+BE4_CODLDP+" "+BE4_CODPEG+" "+BE4_NUMERO)})
					PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
				endIf 

			endif

			If AllTrim(cTipAco) == "A"
			   cFatMul := "0100"
			Else
			   cFatMul := "0200"
			Endif   
			
			xHorFim  := strtran(strtran(BE4->BE4_HORPRO,':',''),' ','')
            xHorFim  := substr(xHorFim,1,2) + ":"+ substr(xHorFim,3,2)            
				
            // Prioridade: Data Inicio e Fim de Faturamento								
			If !Empty(BE4->BE4_DTFIMF) .And. ;
			    ((BD6->BD6_DATPRO > BE4->BE4_DTINIF) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTINIF .And. BD6->BD6_HORPRO >= BE4->BE4_HRINIF)) .And. ;
			    ((BD6->BD6_DATPRO < BE4->BE4_DTFIMF) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTFIMF .And. BD6->BD6_HORPRO <= BE4->BE4_HRFIMF))  
				 
				cDtHrInt := substr(dtos(BE4->BE4_DTINIF),1,4) + "/" +; 
			 	   	substr(dtos(BE4->BE4_DTINIF),5,2) + "/" + ;
			    	substr(dtos(BE4->BE4_DTINIF),7,2)       + ;
		 			substr(BE4->BE4_HRINIF,1,2)+":"+ ;
					substr(BE4->BE4_HRINIF,3,2)+":"+ ;
			   		Iif(Len(ALLTRIM(BE4->BE4_HRINIF)) >5, substr(BE4->BE4_HRINIF,5,2),"00")+cGNT   
  		
			    cDtHrSai := substr(dtos(BE4->BE4_DTFIMF),1,4) + "/" +;
			  		substr(dtos(BE4->BE4_DTFIMF),5,2) + "/" +;
			  		substr(dtos(BE4->BE4_DTFIMF),7,2)		  +;  
			  		substr(BE4->BE4_HRFIMF,1,2)+":"+ ;
			   		substr(BE4->BE4_HRFIMF,3,2)+":"+ ;
			   		Iif(Len(ALLTRIM(BE4->BE4_HRFIMF)) >5, substr(BE4->BE4_HRFIMF,5,2),"00")+cGNT 			    	
			   	  
			EndIf

			// Nao achei Data Inicio/Fim de Faturamento, uso Data de Internacao/Alta 								
			If !Empty(BE4->BE4_DTALTA) .And. ;  
			    ((BD6->BD6_DATPRO > BE4->BE4_DATPRO) .Or. (BD6->BD6_DATPRO == BE4->BE4_DATPRO .And. BD6->BD6_HORPRO >= BE4->BE4_HORPRO)) .And. ;
				((BD6->BD6_DATPRO < BE4->BE4_DTALTA) .Or. (BD6->BD6_DATPRO == BE4->BE4_DTALTA .And. BD6->BD6_HORPRO <= BE4->BE4_HRALTA))  
				       
			       	cDtHrInt := substr(dtos(BE4->BE4_DATPRO),1,4) + "/" +; 
			 		    substr(dtos(BE4->BE4_DATPRO),5,2) + "/" + ;
				   		substr(dtos(BE4->BE4_DATPRO),7,2)       + ;
				    	substr(BE4->BE4_HORPRO,1,2)+":"+ ;
				    	substr(BE4->BE4_HORPRO,3,2)+":"+ ;
				    	Iif(Len(ALLTRIM(BE4->BE4_HORPRO)) >5, substr(BE4->BE4_HORPRO,5,2),"00")+cGNT   
		    		
			   		cDtHrSai := substr(dtos(BE4->BE4_DTALTA),1,4) + "/" +; 
			 			substr(dtos(BE4->BE4_DTALTA),5,2) + "/" +;
			    		substr(dtos(BE4->BE4_DTALTA),7,2)		  +;
			    		substr(BE4->BE4_HRALTA,1,2)+":"+ ;
			    		substr(BE4->BE4_HRALTA,3,2)+":"+ ;
			    		Iif(Len(ALLTRIM(BE4->BE4_HRALTA)) >5, substr(BE4->BE4_HRALTA,5,2),"00")+cGNT   				
				
			EndIf
	    				            
			Do Case			    
			    Case BE4->BE4_INDACI == "0" //1-Acidente do trabalho        
			        cIndAcid := "1"
			    Case BE4->BE4_INDACI == "1" //2-Acidente de transito
			        cIndAcid := "2"               
			    Case BE4->BE4_INDACI == "2" //3-Acidente - outros   
			        cIndAcid := "3"                                   
				Otherwise					// 9-Não acidente
					cIndAcid := "9"
			EndCase
			
			BIY->(DbSetOrder(1))
			If BIY->(MsSeek(xFilial("BIY")+BE4->BE4_CODOPE+BE4->BE4_TIPALT))
				If  !Empty(BIY->BIY_MOTSAI)
					cTipSai := strzero(val(BIY->BIY_MOTSAI),2)
				Else
					cTipSai := If(empty(BE4->BE4_TIPALT),"11",strzero(val(BE4->BE4_TIPALT),2))
				Endif
			Else
				cTipSai := If(empty(BE4->BE4_TIPALT),"11",strzero(val(BE4->BE4_TIPALT),2))
			Endif

			If lPLS500EX
			   cTipInt := ExecBlock("PLS500EX",.F.,.F.,{ BE4->BE4_GRPINT, BE4->BE4_TIPINT })
			Else
				BQR->(dbSetOrder(1))
				If BQR->(MsSeek(xFilial("BQR")+BE4->(BE4_GRPINT+BE4_TIPINT)))
					cTipInt := AllTrim(BQR->BQR_CODEDI)
				Else
					cTipInt := " "
				EndIf		
			EndIf
                
			If ! cTipInt $ "1,2,3,6,7"
				aadd(aLog2,{"   Tipo Internacao invalida: " + cTipInt,"Chave BE4: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
				cTipInt := "0"
  			    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			Endif
			
			If BE4->BE4_TIPFAT == "4"
				cTP_FATURA := "1"
			ElseIf BE4->BE4_TIPFAT == "1"
				cTP_FATURA := "2"
			ElseIf BE4->BE4_TIPFAT == "2"
				cTP_FATURA := "3"
			ElseIf BE4->BE4_TIPFAT == "3"
				cTP_FATURA := "4"
			EndIf
			
			cCD_CIDOBT := left(BE4->BE4_CIDOBT,6)					
			cNR_DECOBT := left(BE4->BE4_NRDCOB,7)					
			cTP_OBTMULH:= strzero(val(BE4->BE4_OBTMUL),1)				      

			If cTipInt == "3"  // Internacao Obstetrica
				cTipNas	:= strzero(val(BE4->BE4_TIPNAS),2)
				If ! cTipNas $ "00,01,02,03,04,05,06,07,08,09,10,11,12"
		            aadd(aLog2,{"   Tipo Nascimento invalido: " + cTipNas,"Chave BE4: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			        PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			    Endif 
			    			
				cQtNasViv := BE4->BE4_NASVIV // Nascidos Vivos a Termo
				cQtNasMor := BE4->BE4_NASMOR // Nascidos Mortos
				cQtNasVPr := BE4->BE4_NASVPR // Nascidos Vivos Prematuros
				cQtObiPre := "0"  // Obito Neonatal precoce
				cQtObiTar := "0"  // Obito Neonatal Tardio
				cID_OBT1  := Space(1)				  
				cID_OBT2  := Space(1)				
				cID_OBT3  := Space(1)					
				cID_OBT4  := Space(1)				
				cID_OBT5  := Space(1)					
				cID_OBT6  := Space(1)				
				cID_OBT7  := Space(1)			
				cID_OBT8  := Space(1)						 
				cID_OBT9  := Space(1)						    									
				cNR_VIVO1	:= space(15)
				cNR_VIVO2	:= space(15)
				cNR_VIVO3  	:= space(15)
				cNR_VIVO4  	:= space(15)
				cNR_VIVO5  	:= space(15)	
				aNRDCNV 	:= StrTokArr( alltrim(BE4->BE4_NRDCNV), "," )	
				for nNV := 1 to len(aNRDCNV)
					&("cNR_VIVO" + cvaltochar(nNV)) := padr(alltrim(aNRDCNV[nNV]),15)
				next						
			Else
				cTipNas   := "00" // Tipo de Internacao Obstetrica
				cQtNasViv := BE4->BE4_NASVIV // Nascidos Vivos a Termo
			 	cQtNasMor := BE4->BE4_NASMOR // Nascidos Mortos
				cQtNasVPr := BE4->BE4_NASVPR // Nascidos Vivos Prematuros
				cQtObiPre := "0"  // Obito Neonatal precoce
				cQtObiTar := "0"  // Obito Neonatal Tardio
				cID_OBT1  := Space(1)				  
				cID_OBT2  := Space(1)				
				cID_OBT3  := Space(1)					
				cID_OBT4  := Space(1)				
				cID_OBT5  := Space(1)					
				cID_OBT6  := Space(1)				
				cID_OBT7  := Space(1)			
				cID_OBT8  := Space(1)						 
				cID_OBT9  := Space(1)									
				cNR_VIVO1  := space(15)						  
				cNR_VIVO2  := space(15)
				cNR_VIVO3  := space(15)
				cNR_VIVO4  := space(15)
				cNR_VIVO5  := space(15)							
			EndIf
				
					
		Endif
		
		If cTipGui == "A" .and. BD6->BD6_TIPGUI <> '05'
			cAliasCab := "BD5"
		Else
			cAliasCab := "BE4"
		EndIf

		cSgConsReq := PadR(&(cAliasCab + "->" + cAliasCab + "_SIGLA"), 12)
		cNrConsReq := PadR(&(cAliasCab + "->" + cAliasCab + "_REGSOL"), 15)
		cUFConsReq := PadR(&(cAliasCab + "->" + cAliasCab + "_ESTSOL"), 2)
		cNomeReq   := PlRetponto(PadR(&(cAliasCab + "->" + cAliasCab + "_NOMSOL"), 60))
		cSolicBase := &(cAliasCab + "->" + cAliasCab + "_ESTSOL")+&(cAliasCab + "->" + cAliasCab + "_REGSOL")+&(cAliasCab + "->" + cAliasCab + "_SIGLA")
		If ! Empty(cSolicBase)
		   If BB0->(MsSeek(xFilial("BB0")+cSolicBase))
			   cCNPJReq := StrZero(Val(BB0->BB0_CGC), 14, 0)
		   Else
   		       cCNPJReq := REPLICATE("0",14)
		   EndIf
		Else
		   cCNPJReq := REPLICATE("0",14)
		Endif   

		If &(cAliasCab + "->" + cAliasCab + "_ATERNA") == '1' .Or. (cAliasCab == 'BE4' .And. BE4->BE4_ATENRN == '1')
			cIDRN  := 'S'
		Else
	 		cIDRN  := 'N'
		EndIf

		cDatAut := iif(empty(dtos(BD6->BD6_DATPRO)),Dtos(&(cAliasCab + "->" + cAliasCab + "_DATPRO")),dtos(BD6->BD6_DATPRO))
		If cAliasCab == "BE4"
			cDatSol := cDatAut 
		Else
		    cDatSol := Dtos(&(cAliasCab + "->" + cAliasCab + "_DATSOL"))
		EndIf	   
		
		If Empty(cDatSol) .And. !Empty(cDatAut ) .And. &(cAliasCab + "->" + cAliasCab + "_TIPGUI") =="06"
			cDatSol:= cDatAut 
	    EndIf           
	    
		nRecBAU := BAU->(RecNo())
		nIndBAU := BAU->(IndexOrd())
        
        // Posiciona na BAU para buscar campos do prestador requisitante que estao vazios 
        
		BAU->(DbSetOrder(5))
		If BAU->(MsSeek(xFilial("BAU")+&(cAliasCab + "->" + cAliasCab + "_CDPFSO"), .F.))
		    
		    // SG_CONS_PROF_REQ  - Sigla do Conselho Profissional do prestador requisitante   
			if cSgConsReq $ "CRAS"
				cSgConsReq := PadR("CRESS", 12)
			elseif cSgConsReq $ "CRFA"
				cSgConsReq := PadR("CREFONO", 12)
			endif
			If ! Empty(cSgConsReq) .And. ! ( AllTrim(cSgConsReq) $ "COREN,CRESS,CRBM,CREFITO,CRF,CREFONO,CRM,CRN,CRO,CRP,OUT" )
			   	cSgConsReq := PadR(BAU->BAU_SIGLCR, 12)
	           	If ! Empty(cSgConsReq) .And. ! ( AllTrim(cSgConsReq) $ "COREN,CRESS,CRBM,CREFITO,CRF,CREFONO,CRM,CRN,CRO,CRP,OUT" )
			   	   cSgConsReq := PadR("OUT", 12)
			   	Endif
			Endif 
	
			If ! ( AllTrim(cSgConsReq) $ "COREN,CRESS,CRBM,CREFITO,CRF,CREFONO,CRM,CRN,CRO,CRP,OUT" )
			      cSgConsReq := PadR("OUT", 12)
			Endif
		    
		    // NR_CONS_PROF_REQ  - Número do Conselho Profissional do prestador requisitante			
			If empty(cNrConsReq) 
			   cNrConsReq := PadR(BAU->BAU_CONREG, 15)     
			   If Empty(cNrConsReq) .And. cTipNot <> "1"
					aAdd(aLog2, {"   Nr Conselho Solicitante em branco","Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			   EndIf
			Endif   
		    
		    // SG_UF_CONS_REQ  - Sigla da Unidade Federativa do Conselho Profissional do prest						
			If empty(cUFConsReq)
			   cUFConsReq := PadR(BAU->BAU_ESTCR, 2)
			   If Empty(cUFConsReq) .And. cTipNot <> "1"
					aAdd(aLog2, {"   UF Conselho Solicitante em branco","Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			   EndIf
			Endif   
		    
		    // NM_PREST_REQ  - Nome do prestador requisitante                                 
					
			If Empty(cNomeReq)
			   cNomeReq := PlRetponto(PadR(BAU->BAU_NOME, 60))
			   If Empty(cNomeReq) .And. cTipNot <> "1"
					aAdd(aLog2, {"   Nome Solicitante em branco","Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			   EndIf
			   
			   If cTipNot == "1" .And. ! Empty(cNomeReq)
			      cNomeReq := Space(60)
			   Endif   
			Endif   
		    
		    // NR_CNPJ_CPF_REQ  - Número do CNPJ ou do CPF do prestador requisitante          
					
			If Empty(cCNPJReq)
			   cCNPJReq := StrZero(Val(BAU->BAU_CPFCGC), 14)
			   If Empty(Val(cCNPJReq)) .And. cTipNot <> "1"
					aAdd(aLog2, {"   CPF/CGC Solicitante em branco","Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			   EndIf       
			   
			   If cTipNot == "1"
	   		      cCNPJReq := REPLICATE("0",14)
	   		   Endif   
			Endif   
		EndIf     
		
		// Verifico o CBOS do Prestador Solicitante 
		cCBOSSol := '000000'
		
		If cTipNot <> '1' //Tipo de Nota Consulta forca '000000'
			If !Empty(BD6->BD6_ESPSOL)
				If BAQ->(DbSeek(xFilial("BAQ")+PlsIntPad()+BD6->BD6_ESPSOL)) .And. !Empty(BAQ->BAQ_CBOS)     
					cCBOSSol := Substr(PLSDELIM(BAQ->BAQ_CBOS),1,6) 
				Else
					aAdd(aLog2, {"   CBOS Solicitante nao encontrado ou nao informado - Verificar Alias: BAQ"," Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
				    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
				EndIf  	
			Else
				BB0->(DbSetOrder(4))//BB0_FILIAL + BB0_ESTADO + BB0_NUMCR + BB0_CODSIG + BB0_CODOPE
				If BB0->(DbSeek(xFilial("BB0")+&(cAliasCab + "->" + cAliasCab + "_ESTSOL")+&(cAliasCab + "->" + cAliasCab + "_REGSOL")+&(cAliasCab + "->" + cAliasCab + "_SIGLA")))
					If BB0->BB0_VINC == '1' //1=Faz parte da Rede de Atendimento  
						aAreaBAU := BAU->(GetArea())
		            	BAU->(DbSetOrder(5))//BAU_FILIAL + BAU_CODBB0
		            	BAU->(DbSeek(xFilial("BAU")+BB0->BB0_CODIGO))
		            	
		            	BAX->(DbSetOrder(1))//BAX_FILIAL + BAX_CODIGO + BAX_CODINT + BAX_CODLOC + BAX_CODESP + BAX_CODSUB
		               	If BAX->(DbSeek(xFilial("BAX")+BAU->BAU_CODIGO))  
		            		While xFilial("BAX")+BAU->BAU_CODIGO == BAX->(BAX_FILIAL+BAX_CODIGO) .And. !BAX->(Eof())
								If BAX->BAX_ESPPRI == "1" 
									If BAQ->(DbSeek(xFilial("BAQ")+BAX->(BAX_CODINT+BAX_CODESP))) .And. !Empty(BAQ->BAQ_CBOS)
							    		cCBOSSol := Substr(PLSDELIM(BAQ->BAQ_CBOS),1,6)
						    			Exit
						    		Else
						    			cAliCrCBO := "BAQ"
						    		EndIf 
								Else
									cAliCrCBO := "BAX"
								EndIf  
								BAX->(DbSkip())
		                    EndDo
		            	Else
		            		cAliCrCBO := "BAX"
		            	EndIf  
		            	RestArea(aAreaBAU)	
					Else //2=Nao faz parte da Rede de Atendimento
		            	BQ1->(DbSetOrder(1))//BQ1_FILIAL + BQ1_CODIGO + BQ1_CODESP
		            	If BQ1->(DbSeek(xFilial("BQ1")+BB0->BB0_CODIGO))	
		            		BAQ->(DbSetOrder(1))//BAQ_FILIAL + BAQ_CODINT + BAQ_CODESP
							If BAQ->(DbSeek(xFilial("BAQ")+PlsIntPad()+BQ1->BQ1_CODESP))      
								cCBOSSol := Substr(PLSDELIM(BAQ->BAQ_CBOS),1,6)
							Else
								cAliCrCBO := "BAQ"
							EndIf  
		            	Else
		            		cAliCrCBO := "BQ1"
		            	EndIf
					EndIf  
					
					If Val(cCBOSSol) == 0
						aAdd(aLog2, {"   CBOS Solicitante nao encontrado - Verificar Alias: "+cAliCrCBO," Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
					    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			        EndIf
				EndIf
				BAU->(DbSetOrder(nIndBAU))
				BAU->(DbGoTo(nRecBAU)) 
			EndIf 
		EndIf	
		
		// Ponto de entrada para tratar o prestador solicitante		
		If lPLS50010
			aRetPto510 :=  ExecBlock("PLS50010",.F.,.F.,{cSgConsReq,cNrConsReq,cUFConsReq,cNomeReq,cCNPJReq})
			cSgConsReq  := PadR(aRetPto510[1],12)   
        	cNrConsReq  := PadR(aRetPto510[2],15)
        	cUFConsReq  := Padr(aRetPto510[3],02)
        	cNomeReq    := Padr(aRetPto510[4],60)
        	cCNPJReq    := Padr(aRetPto510[5],14)
		EndIf
		
		// Critica se um campo do prestador requisitante esta vazio		
		If cTipNot <> "1" .And. (Empty(cSgConsReq) .Or. Empty(cNrConsReq) .Or. Empty(cUFConsReq) .Or. Empty(cNomeReq) .Or. Empty(cCNPJReq) )
        	aAdd(aLog2, {"   Guia sem Prestador Solicitante","Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
		    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		EndIf
		
		
		// MOTIVO_ENCERRAM - Motivo de encerramento		
		cMotEncer := Space(2)
		If cAliasCab == "BE4"
			BIY->(DbSetOrder(1))//BIY_FILIAL + BIY_CODOPE + BIY_CODSAI
			If BIY->(DbSeek(xFilial("BIY")+PlsIntPad()+BE4->BE4_TIPALT))
				If !Empty(BIY->BIY_CODEDI)
					cMotEncer := BIY->BIY_CODEDI 
				Else   
					aAdd(aLog2, {"   Codigo EDI Motivo de Encerramento nao informado (BIY_CODEDI)"," Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			   		PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
				EndIf
			EndIf
		EndIf	
		//cTpAtend :=01  Remoção
		//cTpAtend :=02  Pequena Cirurgia
		//cTpAtend :=03  Terapias
		//cTpAtend :=04  Consultas
		//cTpAtend :=05  Exames
		//cTpAtend :=06  Atendimento Domicilar
		//cTpAtend :=07  SADT Internado  somente com diária associada e ID_AMBULA = "2" (não)
		//cTpAtend :=08  Quimioterapia
		//cTpAtend :=09  Radioterapia
		//cTpAtend :=10  TRS (Terapia Renal Substitutiva)
		//cTpAtend :=11  Pronto Socorro     
		//cTpAtend :=12  Ocupacional
		//cTpAtend :=13  Pequeno Atendimento (sutura, gesso e outros)
		cTpAtend := space(2)
		
		If cTipGui=="A"
			If cAliCab == "BD5"
				If BD5->BD5_TIPGUI == '01' .and. Empty(BD5->BD5_TIPATE)
					cTpAtend := "04"
				ElseIf !Empty(BD5->BD5_TIPATE) 
					cTpAtend := BD5->BD5_TIPATE
				ElseIf BD5->BD5_TIPGUI == '06'
				    cTpAtend := '07' //Honorario Individual assume o tipo Internacao
				Endif
			Else
			    cTpAtend := "05"
			Endif
		Endif  
		
		If cTipGui=="A" .and. Empty(cTpAtend)			
			aAdd(aLog2, {"   Tipo Nota Invalido - Não foi possível definir Tipo de Atendimento","Tipo Nota: " + cTipNot + " / Chave " + cAliasCab,BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		Endif    

		If !(cTipNot == '1' .Or. (cTipNot =='2' .And. cTpAtend == '04'))
			cTipCon := Space(1)	
		EndIf   
		
		If cTipNot $ "134"
			cTpAtend := Space(2)
		EndIf
		
		If !(cTipNot $ "2/3") 
			cCarAtend := Space(1)
		EndIf	
		
		// Regra Guia Principal para PTU 5.0		
		cGuiPri    := ""   
		lFindBE4GP := .F.
		
		If cTipGui == "A" 
			If !Empty(BD5->BD5_GUIINT)   
				aAreaBE4 := BE4->(GetArea())     
				
				// Primeiramente procuro uma guia de Resumo, se nao achar, procuro a             
				// guia de solicitacao de internacao                                        	
	   			
				BE4->(DbSetOrder(15))//BE4_FILIAL+BE4_GUIINT
				If BE4->(DbSeek(xFilial("BE4")+BD5->BD5_GUIINT)) 
					While xFilial("BE4")+BE4->BE4_GUIINT == BD5->(BD5_FILIAL+BD5_GUIINT) .And. !BE4->(Eof())
						If BD5->BD5_DATPRO >= BE4->BE4_DATPRO .And. ;
						  (BD5->BD5_DATPRO <= BE4->BE4_DTALTA .Or. Empty(BE4->BE4_DTALTA)) .And. BE4->BE4_TIPGUI == "05"
							lFindBE4GP := .T.
							Exit
						EndIf 
						BE4->(DbSkip())
					EndDo
				EndIf
				
				// Guia de solicitacao 	   			
				If !lFindBE4GP
					BE4->(DbSetOrder(1))
					If BE4->(DbSeek(xFilial("BE4")+BD5->BD5_GUIINT)) 
						While xFilial("BE4")+BE4->(BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO) == BD5->(BD5_FILIAL+BD5_GUIINT) .And. !BE4->(Eof())
							If BD5->BD5_DATPRO >= BE4->BE4_DATPRO .And. ;
							  (BD5->BD5_DATPRO <= BE4->BE4_DTALTA .Or. Empty(BE4->BE4_DTALTA)) .And. BE4->BE4_TIPGUI == "03"
								lFindBE4GP := .T.
								Exit
							EndIf 
							BE4->(DbSkip())
						EndDo
			 		EndIf
				EndIf

				If lFindBE4GP 
					if empty(val(cCBOSSol)) .and. cTipNot <> "1"
						cCodEsp := iif(!empty(BE4->BE4_ESPSOL),BE4->BE4_ESPSOL,BE4->BE4_CODESP)
						if !empty(cCodEsp) .and.  BAQ->(MsSeek( xFilial("BAQ")+BD6->BD6_OPERDA+cCodEsp))
							cCBOSSol := Substr(PLSDELIM(BAQ->BAQ_CBOS),1,6)
						endif
					endif

					If nTipoNota == 1           
						cGuiPri := Alltrim(BE4->(BE4_CODLDP+BE4_CODPEG+BE4_NUMERO))  
			    			
	   				ElseIf nTipoNota == 2 
					    
			    		// Caso o numero de impresso nao esteja preenchido, envia o numero da guia  
				     	 
				     	If Empty(BE4->BE4_NUMIMP)
						   	
			    		   	cGuiPri := Alltrim(BE4->(BE4_CODLDP+BE4_CODPEG+BE4_NUMERO))   
			    		   	
						Else
			               	cGuiPri :=  Iif(!Empty(BE4->BE4_NUMIMP),PadR(BE4->BE4_NUMIMP,20),Replicate("0",20))  
			            EndIf  
		 				
		 			Else  
		 				cGuiPri := Iif(!Empty(BE4->BE4_SENHA),PadR(BE4->BE4_SENHA,20),Replicate("0",20))    
		   			EndIf           
				EndIf
				RestArea(aAreaBE4)	  
			EndIf
		EndIf     

        If cTipGui == "A" .And. !Empty(BD5->BD5_GUIPRI) .And. Empty(cGuiPri) .And. !lFindBE4GP .And. Empty(BD5->BD5_GUIINT) 
        	cGuiPri:= PESQNUMIN(BD5->BD5_GUIPRI,"2")
        EndIf

		if BD6->BD6_TIPGUI == '05' .and. empty(cGuiPri)
			cGuiPri := BE4->BE4_GUIINT
		endif

		If Empty(cGuiPri)
			cGuiPri := Replicate("0",20)
		Endif		
		
		For iBD6 := 1 to len(aBD6)
			cDesPct:= ""
			cCodPct:= ""			
			cCodPoA := ""
			// Posiciona BD6	                                             
			
			BD6->(dbGoTo(aBD6[iBD6]))

			If cTipGui <> "A"   
				If cTipNas $ "03,04,05"
					If BD6->(BD6_CODPAD+BD6_CODPRO) $ "0145080038,0145080194,0231309054" // Cesariana com Histerectomia, Cesariana - feto unico ou multiplo
						cTipNas := "11"
					ElseIf BD6->(BD6_CODPAD+BD6_CODPRO) $ "0145080186,0145080100,0231309127,0231309135" // Parto (via baixa), Parto multiplo por via baixa
						cTipNas := "12"
					EndIf
				EndIf
			EndIf

			// Posiciona BR8	                                           
			If BR8->(MsSeek( xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO) ))
				cClasse := BR8->BR8_CLASSE
			Else
				cClasse := "000000"
			Endif
			
			// Verifica se tem codigo de Unidade de Medida                              
			
			cCodUnMed  := "000"
			BX6->(DbSetOrder(1)) //BX6_FILIAL+BX6_CODOPE+BX6_CODLDP+BX6_CODPEG+BX6_NUMERO+BX6_ORIMOV+BX6_SEQUEN+BX6_CODPAD+BX6_CODPRO      
			If BX6->(MsSeek(xFilial("BX6") + BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
				If !(empTy(BX6->BX6_CODUNM))
					cCodUnMed := alltrim(BX6->BX6_CODUNM)
				elseIf BR8->BR8_TPPROC $ "1/2/5/7"
					BA8->(DbSetOrder(1))//BA8_FILIAL+BA8_CODTAB+BA8_CDPADP+BA8_CODPRO
					If BA8->(DbSeek(xFilial("BA8")+BD6->(BD6_CODOPE+BD6_CODTAB+BD6_CODPAD+BD6_CODPRO))) .And. !Empty(BA8->BA8_UNMEDI)
			     		cCodUnMed  := Strzero(Val(BA8->BA8_UNMEDI),3)  
					EndIf
				EndIf
			elseIf BR8->BR8_TPPROC $ "1/2/5/7"
				BA8->(DbSetOrder(1))//BA8_FILIAL+BA8_CODTAB+BA8_CDPADP+BA8_CODPRO
				If BA8->(DbSeek(xFilial("BA8")+BD6->(BD6_CODOPE+BD6_CODTAB+BD6_CODPAD+BD6_CODPRO))) .And. !Empty(BA8->BA8_UNMEDI)
		     		cCodUnMed  := Strzero(Val(BA8->BA8_UNMEDI),3)  
				EndIf
			EndIf

			//Verifica Tabela TUNMM/TUSS
			BA8->(DbSetOrder(1))//BA8_FILIAL+BA8_CODTAB+BA8_CDPADP+BA8_CODPRO
			If ( BA8->(fieldPos("BA8_CODIFI")) > 0 .and. BA8->(DbSeek(xFilial("BA8")+BD6->(BD6_CODOPE+BD6_CODTAB+BD6_CODPAD+BD6_CODPRO))) )
				cTipCodifi  := alltrim(BA8->BA8_CODIFI)  
			EndIf	

			// CD_REF_MATERIAL_FAB                                                      
			
			cCodRefFab := Space(60)
			cCodRecPre := Replicate("0",10)
			If Alltrim(BD6->BD6_CODPRO) == cMatMedGen
				If !Empty(BD6->BD6_REFFED)
					cCodRefFab := Padr(BD6->BD6_REFFED,60)
				Else
					aadd(aLog2,{"   OPME Generico sem cod. referencia do material no fabricante: " + Alltrim(BR8->BR8_CODPSA),"Chave BD5: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			        PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
				EndIf			
			EndIf
			
			// Novos campos OPME versao 6.3                                              
			cIDPagForn := "0"
			cPagNomFor := Space(60)
			cDetRegAnv := Space(50)
			cNumNFForn := Space(20)      
			cCnpjFor   := Replicate("0",14)
			cRegAnvis := Space(15)

			If (BR8->BR8_TPPROC $ "56" .Or. Alltrim(BD6->BD6_CODPRO) == cMatMedGen )
		
				//Vou priorizar os dados informados na BX6
				BX6->(DbSetOrder(1))//BX6_FILIAL + BX6_CODOPE + BX6_CODLDP + BX6_CODPEG + BX6_NUMERO + BX6_ORIMOV + BX6_SEQUEN + BX6_CODPAD + BX6_CODPRO
				If BX6->(DbSeek(xFilial("BX6")+BD6->(BD6_CODOPE + BD6_CODLDP + BD6_CODPEG + BD6_NUMERO + BD6_ORIMOV + BD6_SEQUEN))) 
			    	
			    	If BR8->BR8_TPPROC $ "56" .And. ( Empty(BX6->BX6_PAGFOR) .And. Empty(BX6->BX6_NOMFOR) .And. Empty(BX6->BX6_CNPJFO) )			    	
			    		
			    		// Posiciona a RDA	                                             
						BAU->(DbSetOrder(1))
						If BAU->(MsSeek( xFilial("BAU")+BD6->BD6_CODRDA ))
				    		
				    		//ID_PAG_FORN
			    			cIDPagForn := "2"
				    		
				    		//NM_FORNECEDOR
				    		cPagNomFor := PlRetponto(substr(BAU->BAU_NOME+Space(60),1,60))
				    		
				    		//NR_CPF_CNPJ_FORNECEDOR
				    		cCnpjFor   := strzero(val(BAU->BAU_CPFCGC),14)
				    		
				    	EndIf
				    	
			    	Else
				    	//ID_PAG_FORN
				    	If !Empty(BX6->BX6_PAGFOR)
				    		cIDPagForn := BX6->BX6_PAGFOR
				    	EndIf  
	
				    	//NM_FORNECEDOR  
				    	If !Empty(BX6->BX6_NOMFOR)
				    		cPagNomFor := Substr(BX6->BX6_NOMFOR + Space(60),1,60)
				    	EndIf
				    	
				    	//NR_CPF_CNPJ_FORNECEDOR
				    	If !Empty(BX6->BX6_CNPJFO)
				    		cCnpjFor:= Strzero(Val(BX6->BX6_CNPJFO),14,0)
				    	EndIf
				    EndIf

			    	//DET_REG_ANVISA
			    	If !Empty(BX6->BX6_DREANV)
			    		cDetRegAnv := Substr(BX6->BX6_DREANV,1,50)
					Elseif BA8->(fieldPos('BA8_DETANV')) > 0 
			    		BA8->(DbSetOrder(4))//BA8_FILIAL+BA8_CODPRO+BA8_CODTAB
			   			If BA8->(msSeek(xFilial("BA8")+alltrim(BR8->BR8_CODPSA))) .And. !Empty(BA8->BA8_DETANV)
				  			cDetRegAnv := Padr(Substr(BA8->BA8_DETANV,1,50),50)                                                                            	
			   			EndIf   
			    	EndIf
			    
			    	//NR_NOTA_FISCAL_FORN 
			    	If !Empty(BX6->BX6_NNFFOR)
			    		cNumNFForn := Substr(BX6->BX6_NNFFOR,1,20)
			    	EndIf      
			    	
			    	//NR_REG_ANVISA
			    	If !Empty(BX6->BX6_REGANV)
			    		cRegAnvis := Substr(BX6->BX6_REGANV,1,15)
			    	Else
			    		BA8->(DbSetOrder(4))//BA8_FILIAL+BA8_CODPRO+BA8_CODTAB
			   			If BA8->(DbSeek(xFilial("BA8")+BR8->BR8_CODPSA)) .And. !Empty(BA8->BA8_RGANVI)
				  			cRegAnvis := Padr(Substr(BA8->BA8_RGANVI,1,15),15)                                                                            	
			   			EndIf   
			    	EndIf
			    
			    Else
			    
			    	If BR8->BR8_TPPROC $ "56"			    	
			    		
			    		// Posiciona a RDA	                                             
						BAU->(DbSetOrder(1))
						If BAU->(MsSeek( xFilial("BAU")+BD6->BD6_CODRDA ))
				    		
				    		//ID_PAG_FORN
			    			cIDPagForn := "2"
				    		
				    		//NM_FORNECEDOR
				    		cPagNomFor := PlRetponto(substr(BAU->BAU_NOME+Space(60),1,60))
				    		
				    		//NR_CPF_CNPJ_FORNECEDOR
				    		cCnpjFor   := strzero(val(BAU->BAU_CPFCGC),14)
				    		
				    	EndIf
				    	
			    	EndIf
			    		 
				EndIf	
			 
				//Verifico se o evento foi atrelado a uma NF, posso utilizar esses dados se nao informados na BX6 
				SF1->(DbSetOrder(1))//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO       
				If SF1->(DbSeek(Substr(BD6->BD6_NFE,1,len(SF1->F1_FILIAL)+len(SF1->F1_DOC)+len(SF1->F1_SERIE)+len(SF1->F1_FORNECE)+len(SF1->F1_LOJA))))
					If cIDPagForn == "0"
						cIDPagForn := "1" //1 - Pagamento ao fornecedor (compra feita pela Unimed)
					EndIf
					
					If Empty(cNumNFForn)	
						cNumNFForn := Padr(SF1->F1_DOC,20)
					EndIf  
																
				    SA2->(DbSetOrder(1))//A2_FILIAL+A2_COD_A2_LOJA
				    If SA2->(DbSeek(xFilial("SA2")+SF1->(F1_FORNECE+F1_LOJA)))
				    	If Empty(cPagNomFor)
				    		cPagNomFor := Substr(SA2->A2_NOME + Space(60),1,60)
				    	EndIf
				    	If Val(cCnpjFor) == 0
				    		cCnpjFor := Strzero(Val(SA2->A2_CGC),14,0)
				    	EndIf	
				    EndIf
				EndIf				

			   	if BR8->BR8_TPPROC == "5"
			   		If Empty(cDetRegAnv)
			    		aadd(aLog2,{"   Opme sem detentor do registro na Anvisa informado: " + Alltrim(BR8->BR8_CODPSA),"Chave BD5: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			    	EndIf 	    		 			    		 

		    		If Empty(cRegAnvis)
		    			aadd(aLog2,{"   Ortese/Protese sem registro ANVISA: " + Alltrim(BR8->BR8_CODPSA),"Chave BD5: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")	
			    	EndIf   

					// Seta logs				
			   		IF cIDPagForn == "0"
			   			aadd(aLog2,{"   Opme sem pagamento ao fornecedor informado: " + Alltrim(BR8->BR8_CODPSA),"Chave BD5: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			   		EndIf
					
					If Empty(cPagNomFor)
			   			aadd(aLog2,{"   Opme sem nome do fornecedor informado: " + Alltrim(BR8->BR8_CODPSA),"Chave BD5: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    	    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			   		EndIf 
					If Val(cCnpjFor) == 0
		    			aadd(aLog2,{"   Opme sem CNPJ do fornecedor da Nota Fiscal informado: " + Alltrim(BR8->BR8_CODPSA),"Chave BD5: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
		        	    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		    		EndIf 
	
					If Empty(cNumNFForn)
		    			aadd(aLog2,{"   Opme sem número da Nota Fiscal informado: " + Alltrim(BR8->BR8_CODPSA),"Chave BD5: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
		        	    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		    		EndIf
				endif		 
			EndIf
			
			If Empty((cAliasCab)->&(cAliasCab+"_GUIJUR")) .Or. (cAliasCab)->&(cAliasCab+"_GUIJUR") == '0'
				cGuiJur := "N"
			Else
				cGuiJur := "S"
			EndIf
			
			
			// Alimenta variaveis R504
			
			If cTipGui <> "A" .and. cAliasCab == "BE4"  .and. BD6->BD6_DATPRO < BE4->BE4_DATPRO
				dDatSer := BE4->BE4_DATPRO
			Else
				dDatSer := BD6->BD6_DATPRO
			Endif            
			
			cTipTab := BR8->BR8_TPPROC

			//Se BA8_CODIFI for vazio ou TUNMM, segue o processamento que era feito antes, como TUNMM	
			if ( empty(cTipCodifi) .or. cTipCodifi == "1" )
				Do Case
					Case cTipTab $ "0"
						cTipTab := "0"
					Case cTipTab $ "3|4"
						cTipTab := "1"
					Case cTipTab $ "1|5"
						cTipTab := "2"
					Case cTipTab $ "2"
						cTipTab := "3"
					Case cTipTab $ "6"
						cTipTab := "4"
					Otherwise
						cTipTab := "0"
				EndCase
			//Se TUSS ("2"), analisa BR8_TPPROC, para definir o que é Material ou Medicamento
			else
				Do Case
					Case cTipTab $ "1|5"  //1=Material;5=Ortese/Protese
						cTipTab := "5"
					Case cTipTab $ "2"  //2=Medicamento
						cTipTab := "6"
					Otherwise
						cTipTab := "5"
				EndCase	
			endif	

			If nTipEnv == 1 // Fechado
				Do Case
					Case cTipTab == "2" // Material
						cCodPsa := "90000021"  // codigo material fechado conforme manual ptu
					Case cTipTab == "3" // Medicamento
						cCodPsa := "90000013"   // codigo medicamento fechado conforme manual ptu
					Otherwise  
						lFounDePar := .F. //Reinicializa 
						
						// De-Para TISS - BTU      	                                             
						
						If lDeParaBTU  
						    cCodPct:= BR8->BR8_CODPSA
						    cDesPct:= BR8->BR8_DESCRI
							aRetBTU := PTUDePaBTU(nil,BD6->BD6_CODPRO,BD6->BD6_CODPAD,.F.,.T.)
							If len(aRetBTU) > 0
								cCodPsa := Alltrim(aRetBTU[2]) 
								lFounDePar := .T.
							EndIf  
						
		 				// De-Para B1M             	                                             
		   					
						Else   
							cCodPsa := PLDeParINT(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,@lFounDePar,"E") 	
						EndIf
						If !lFounDePar
							If ! empty(BR8->BR8_CODEDI)
								cCodPsa := strzero(val(BR8->BR8_CODEDI),8)
							Else
								cCodPsa := strzero(val(BD6->BD6_CODPRO),8)
							Endif
						EndIf	
				EndCase
			Else
				lFounDePar := .F. //Reinicializa     
				
				// De-Para TISS - BTU      	                                             
				
				If lDeParaBTU   
				    cCodPct:= BR8->BR8_CODPSA
				    cDesPct:= BR8->BR8_DESCRI
					aRetBTU := PTUDePaBTU(nil,BD6->BD6_CODPRO,BD6->BD6_CODPAD,.F.,.T.)
					If len(aRetBTU) > 0
						cCodPsa := Alltrim(aRetBTU[2]) 
						lFounDePar := .T.
					EndIf    
				
				// De-Para B1M           	  	                                             
					
				Else  
			   		cCodPsa := PLDeParINT(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,@lFounDePar) 		
				EndIf
				If !lFounDePar
					If ! empty(BR8->BR8_CODEDI)
						cCodPsa := strzero(val(BR8->BR8_CODEDI),8)
					Else
						cCodPsa := strzero(val(BD6->BD6_CODPRO),8)
					Endif
				EndIf	
			Endif
			
			If Int(BD6->BD6_QTDPRO) > 9999
				nQtdPsa := 9999
			Else
				nQtdPsa := BD6->BD6_QTDPRO
			Endif      
			
			
			If BD6->BD6_PROCCI == '1'
				Do Case
					Case BD6->BD6_TECUTI == "C"
						cTecUtil := '1'
					Case BD6->BD6_TECUTI == "V"
						cTecUtil := '2'
					Case BD6->BD6_TECUTI == "R"
						cTecUtil := '3'		
					Case Empty(BD6->BD6_TECUTI)	   
						cTecUtil := '1'	
				EndCase	
			Else
				cTecUtil := '0'
			EndIf
	
			cPacote := Iif (!Empty(BD6->BD6_CD_PAC) .Or. cTipTab == "4","S","N") 
			cNotPrg := replicate("0",11)
			
			cHorPsa := strzero(val(substr(BD6->BD6_HORPRO,1,2)),2) + ":" + strzero(val(substr(BD6->BD6_HORPRO,3,2)),2) + ":" + Iif(Len(BD6->BD6_HORPRO)>4,strzero(val(substr(BD6->BD6_HORPRO,5,2)),2),"00")
			
			// Verifica horario fim para urgencia/emergencia                            
			
			If cCarAtend == "2"
				If !Empty(BD6->BD6_HORFIM)
					cHorFim := strzero(val(substr(BD6->BD6_HORFIM,1,2)),2) + ":" + strzero(val(substr(BD6->BD6_HORFIM,3,2)),2) + ":" + Iif(Len(BD6->BD6_HORPRO)>4,strzero(val(substr(BD6->BD6_HORFIM,5,2)),2),"00")    
			    Else
			    	cHorFim := strzero(val(substr(xHorFim,1,2)),2) + ":" + strzero(val(substr(xHorFim,4,2)),2) + ":" + Iif(Len(BD6->BD6_HORPRO)>4,strzero(val(substr(xHorFim,5,2)),2),"00")    			
			    Endif
			    
        		// Ponto de entrada para tratativa de horario final                         
				
			    
			    If lPLS50011
					cHorFim := ExecBlock("PLS50011",.F.,.F.,{cHorFim,BD6->(Recno())})
           	  	EndIf 

			    If cHorFim == "00:00:00"  
			    	aadd(aLog2,{"   Necessario informar Hora Final, evento de Emergencia/Urgencia.","Chave BD6: ",BD6->(BD6_CODOPE+" "+BD6_CODLDP+" "+BD6_CODPEG+" "+BD6_NUMERO+" "+BD6_ORIMOV+" "+BD6_SEQUEN)})
					PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
				EndIf
			Else
				cHorFim := Space(8)
			EndIf	
			
			// Posiciona a BD4	                                             
			
			//AN0	
			//AN1	3A
			//AN2	3C
			//AN3	4C
			//AN4	6B
			//AN5	7C
			//AN6	9B
			//AN7	10C
			//AN8	12A
			cCodTab := alltrim(iif(!empty(BD6->BD6_CDTBRC),BD6->BD6_CDTBRC,BD6->BD6_CODTAB))
			If BD4->(Msseek( xFilial("BD4")+BD6->BD6_CODOPE+cCodTab+BD6->(BD6_CODPAD+BD6_CODPRO)+"PA" )) //Todas unidades iniciadas por PA
				xCodPoA := alltrim(BD4->BD4_PORMED)					

				Do Case
				Case xCodPoA == "3A"
					cCodPoA := "1"
				Case xCodPoA == "3C"
					cCodPoA := "2"
				Case xCodPoA == "4C"
					cCodPoA := "3"
				Case xCodPoA == "6B"
					cCodPoA := "4"
				Case xCodPoA == "7C"
					cCodPoA := "5"
				Case xCodPoA == "9B"
					cCodPoA := "6"
				Case xCodPoA == "10C"
					cCodPoA := "7"
				Case xCodPoA == "12A"
					cCodPoA := "8"
				Otherwise
					cCodPoA := "0"
				endcase

				if BKF->(fieldPos("BKF_CODEDI")) > 0 .and. cCodPoA == "0"
					cCodPoA := getBKF()	
				endif
				
			Else
				cCodPoA := " "
			Endif
			
			// Inicializa valores   		                                             
			
			nBD6    := noround(&(cCampoTOTPF),2)
			nBD7    := 0
			aReg504 := {}
			cRdaHm  := ""
			
			// Processa BD7 
			If BD7->(DbSeek((xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN))))
			
				While BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == (xFilial("BD6")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)) .and. ! BD7->(Eof())

					// Salta registros bloqueados
					If (BD7->BD7_BLOPAG == '1' .And. !BD6->BD6_MOTBPG $ '066-067-068') .or. (BD7->BD7_VLRTPF + BD7->BD7_VLRTAD <= 0)
						BD7->(dbSkip())
						Loop
					Endif 

					cViaBusca := iif(!empty(BD7->BD7_VIA), BD7->BD7_VIA, BD6->BD6_VIA)
					If cViaBusca >= '1'
						BGR->(DbSetOrder(1))
						If BGR->(MsSeek(xFilial("BGR")+PLSINTPAD()+cViaBusca))
							If !Empty(BGR->BGR_CODEDI)
								cViaAce := strzero(val(BGR->BGR_CODEDI),2)
							Else                                           
								//Se o sistema entrar aqui nesse if e o cadastro nao estiver da maneira abaixo, vai dar erro no validador.
								// 0 = Independe da via (100% HM)
								// 1 = Mesma via (50% HM)
								// 2 = Via diferente (70% HM)
								cViaAce := strzero(val(BGR->BGR_CODVIA),2)
							Endif
							cFatSer := strzero((BD6->BD6_PERHES)+100,3)
							If cFatSer == '000'
								cFatSer := '100'
							Endif
						Else              
							aadd(aLog2,{"   Via de acesso informada na guia não encontrada no cadastro.","Chave BD6: ",BD6->(BD6_CODOPE+" "+BD6_CODLDP+" "+BD6_CODPEG+" "+BD6_NUMERO+" "+BD6_ORIMOV+" "+BD6_SEQUEN)})
							PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
						Endif
            		Else
            			cViaAce := strzero(val(cViaBusca),2)
            			cFatSer := strzero(BD6->BD6_PERHES+100,3)
						If cFatSer == '000'
							cFatSer := '100'
						Endif
            		Endif

					aPacote := {0,0,{},""} //[1] valor real [2] valor cg [3] composicao aberta

					B43->(DbSetOrder(1))

					cFatUnd := ""
					If cPacote == 'S' .and. B43->(MsSeek(xFilial("B43")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN))) 
				        //alimento os itens do pacote
				        While !B43->(Eof()) .and. B43->(B43_FILIAL+B43_CODOPE+B43_CODLDP+B43_CODPEG+B43_NUMERO+B43_ORIMOV+B43_SEQUEN) == xFilial("B43")+BD7->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

							// De-Para TISS - BTU
						    If lDeParaBTU  
								aRetBTU := PTUDePaBTU(nil,B43->B43_CODPRO,B43->B43_CODPAD,.F.,.T.)
								If len(aRetBTU) > 0
									cCodItePac := Alltrim(aRetBTU[2]) 
								Else
									cCodItePac := B43->B43_CODPRO
								EndIf  

				  			// Verifica De/Para com a tabela B1M 
				          	Else  
								cRetB1M := PLDeParINT(B43->B43_CODPAD,B43->B43_CODPRO,BD6->BD6_DATPRO,@lFounDePar,"E") 
								IIf(lFounDePar,cCodItePac := cRetB1M,cCodItePac := B43->B43_CODPRO)								
							EndIf      

				          	aadd(aPacote[3],{B43->B43_CODPAD,cCodItePac,B43->B43_VALFIX,B43->B43_VALCH,B43->B43_PRINCI,B43->B43_TIPO,0,B43->B43_DESPRO})
				          	aPacote[1] += B43->B43_VALFIX
				          	aPacote[2] += B43->B43_VALCH
				          	aPacote[4] := B43->B43_NIVPAC
				          	B43->(DbSkip())
				        Enddo          
				        //calculo o percentual de cada item no valor total do pacote
				        nSomaPac := 0
				        For nI:=1 to Len(aPacote[3])
				        	aPacote[3][nI][7] := If(aPacote[3][nI][3] > 0,Round(aPacote[3][nI][3]/aPacote[1],Len(Str(aPacote[3][nI][3]/aPacote[1]))),;
				         	Round(aPacote[3][nI][4]/aPacote[2],Len(Str(aPacote[3][nI][4]/aPacote[2]))))
				         	nSomaPac += aPacote[3][nI][7]
				        Next                                           
				         	//trato o arredondamento
				        If nSomaPac <> 1 .and. nSomaPac > 0                           
				        	If nSomaPac > 1
				        		nDifPac := nSomaPac - 1  
				        		aPacote[3][nI-1][7] -= nDifPac
								nSomaPac -= nDifPac
				        	Else
				        		nDifPac := 1 - nSomaPac
				        		aPacote[3][nI-1][7] += nDifPac
				        		nSomaPac += nDifPac
				        	Endif
				        Endif
					Endif

					// Posiciona a RDA	                                             
					BAU->(DbSetOrder(1))
					BAU->(MsSeek( xFilial("BAU")+BD6->BD6_CODRDA )) //BAU->(MsSeek( xFilial("BAU")+BD7->BD7_CODRDA ))
					
					// Posiciona a Especialidade								
 					BB8->(DbSetOrder(1))
					If BB8->(MsSeek(xFilial("BB8")+BD7->BD7_CODRDA+BD6->BD6_OPERDA+BD6->BD6_CODLOC+BD6->BD6_LOCAL))
						cCNESExec   := IIf(!Empty(BB8->BB8_CNES),PadR(BB8->BB8_CNES, 7),"9999999")
						cCdMunExec := IIf(!Empty(BB8->BB8_CODMUN),BB8->BB8_CODMUN,"0000000")
					Else
						cCNESExec   := "9999999"
						cCdMunExec := IIF(!Empty(BAU->BAU_MUN),BAU->BAU_MUN,"0000000")
					EndIf
					cRda := BD6->BD6_CODRDA
					cEsp := BD6->BD6_CODESP
					cSgConsPr := PadR(BD7->BD7_SIGLA, 12)
					cNrConsPr := PadR(BD7->BD7_REGPRE, 15)
					cUFConsPr := PadR(BD7->BD7_ESTPRE, 2)
					cNmExec   := PlRetponto(padr(BD7->BD7_NOMPRE,60))
					If empty(cNmExec)   
            	        cNmExec   := PlRetponto(padr(BD7->BD7_NOMRDA,60))
            	    EndIf
					
					If !Empty(BD7->BD7_CDPFPR) 
						aAreaBB0 := BB0->(GetArea()) 
						BB0->(DbSetOrder(1))//BB0_FILIAL+BB0_CODIGO
						If BB0->(DbSeek(xFilial("BB0")+BD7->BD7_CDPFPR))
							If Empty(cNmExec)   
            	        		cNmExec   := PlRetponto(padr(BB0->BB0_NOME,60))
            	        	EndIf
            	        	If Empty(cSgConsPr)   
            	        		cSgConsPr := PadR(BB0->BB0_CODSIG, 12)
            	        	EndIf
            	        	If Empty(cNrConsPr)   
            	        		cNrConsPr := PadR(BB0->BB0_NUMCR, 15)
            	        	EndIf
            	        	If Empty(cUFConsPr)
            	        		cUFConsPr := PadR(BB0->BB0_ESTADO, 2)
            	        	EndIf
						Endif 
						RestArea(aAreaBB0)
					EndIf
					
					cTipPes := BAU->BAU_TIPPE
					cCGCPre := strzero(val(BAU->BAU_CPFCGC),14)
					cCgcExec 	:= PadL(AllTrim(BAU->BAU_CPFCGC),14,'0')
					cTpPeExec 	:= BAU->BAU_TIPPE
					if cSgConsPr $ "CRAS"
						cSgConsPr := PadR("CRESS", 12)
					elseif cSgConsPr $ "CRFA"
						cSgConsPr := PadR("CREFONO", 12)
					endif
					If ! Empty(cSgConsPr) .And. ! ( AllTrim(cSgConsPr) $ "COREN,CRESS,CRBM,CREFITO,CRF,CREFONO,CRM,CRN,CRO,CRP,OUT" )
   					   cSgConsPr := PadR(BAU->BAU_SIGLCR, 12)
            	       If ! Empty(cSgConsPr) .And. ! ( AllTrim(cSgConsPr) $ "COREN,CRESS,CRBM,CREFITO,CRF,CREFONO,CRM,CRN,CRO,CRP,OUT" )
					      cSgConsPr := PadR("OUT", 12)
					   Endif
					Endif 

					If ! ( AllTrim(cSgConsPr) $ "COREN,CRESS,CRBM,CREFITO,CRF,CREFONO,CRM,CRN,CRO,CRP,OUT" )
					      cSgConsPr := PadR("OUT", 12)
					Endif

					If empty(cNrConsPr)
					   cNrConsPr := PadR(BAU->BAU_CONREG, 15)
					Endif   

					If empty(cUFConsPr)
					   cUFConsPr := PadR(BAU->BAU_ESTCR, 2)
					Endif   

					If Empty(cEsp)
						cEsp := BD6->BD6_CODESP
					Endif

					If plsintpad() == "0024"  // somente botucatu - pois estava com a base de dados errada em funcao de importacao
						If BBF->(MsSeek(xFilial("BBF")+cRda+BD6->BD6_OPERDA+cEsp)) // verifica se a RDA tem a especialidade informada
							If BAQ->(MsSeek( xFilial("BAQ")+BD6->BD6_OPERDA+cEsp)) // busca o codigo da especialidade para PTU
								cCodEsp := strzero(val(BAQ->BAQ_INTERC),2)
							Else
								cCodEsp := replicate("0",2)
							Endif
						Else
							BBF->(MsSeek(xFilial("BBF")+cRda+BD6->BD6_OPERDA))      // busca a primeira especialidade da rda
							cEsp := substr(BBF->BBF_CODESP,5,3)
							If BAQ->(MsSeek( xFilial("BAQ")+BD6->BD6_OPERDA+cEsp))  // busca o codigo da especialidade para PTU
								cCodEsp := strzero(val(BAQ->BAQ_INTERC),2)
							Else
								cCodEsp := replicate("0",2)
							Endif
						Endif
					Else
						IF !Empty(BD6->BD6_ESPEDI)     
							cCodEsp := BD6->BD6_ESPEDI	 
						ElseIf  BAQ->(MsSeek( xFilial("BAQ")+BD6->BD6_OPERDA+cEsp))
							cCodEsp := strzero(val(BAQ->BAQ_INTERC),2)
						Else
							cCodEsp := replicate("0",2)
						Endif
					Endif

					// Monta campos baseados no BAU
					cNomPre := PlRetponto(substr(BAU->BAU_NOME+Space(60),1,60))				

					Do Case
						Case BAU->BAU_TIPPRE == "MED"
							cTipPre := "01"
						Case BAU->BAU_TIPPRE == "HOS"
							cTipPre := "02"
						Case BAU->BAU_TIPPRE == "LAB"
							cTipPre := "03"
						Case BAU->BAU_TIPPRE == "CLI"
							cTipPre := "04"
					   Case BAU->BAU_TIPPRE == "HOM" //HOME CARE - (atendimentos domiciliares)
						    cTipPre := "08"
						Case BAU->BAU_TIPPRE == "COO" //Cooperativa
							cTipPre := "09"
						Case BAU->BAU_TIPPRE <> "MED" .and. BAU->BAU_TIPPE == "F"
							cTipPre := "05"
						Otherwise
							cTipPre := "06"
					EndCase
					
					If cTipPre == "01" .And. BAQ->( Found() )
						cCBOSExec := Strzero(Val(PLSDELIM(BAQ->BAQ_CBOS)),6)
					Else
					    cCBOSExec := Strzero(0,6)
					EndIf
					
					// Ponto de entrada para tratar o executante					
					If lPLS50009
						aRetPto509 :=  ExecBlock("PLS50009",.F.,.F.,{cSgConsPr,cNrConsPr,cUFConsPr,cNmExec})
						cSgConsPr  := Padr(aRetPto509[1],12)
           		  		cNrConsPr  := Padr(aRetPto509[2],15)
           				cUFConsPr  := Padr(aRetPto509[3],02)
           				cNmExec    := Padr(aRetPto509[4],60)
         			EndIf 
         			
					// Ponto de entrada para tratar CBOS					
					If lPLS50006
						aRetPto506 := ExecBlock("PLS50006",.F.,.F.,{cCBOSSol,cCBOSExec,BD6->(Recno())})
						cCBOSSol   := Padr(aRetPto506[1],6)
           		  		cCBOSExec  := Padr(aRetPto506[2],6)
           		  		
				   		// Mesmo com PE, preciso forcar a regra do manual						
           		  		If cTipNot == "1"
							cCBOSSol := '000000'
						Endif
          			EndIf

					If BAU->BAU_COPCRE == "1"
						cRecPro := "S"
					Else
						cRecPro := IIF(BAU->BAU_RECPRO=="1","S","N")
					Endif

					// CNES e Codigo do Municipio
				    BB8->(DbSetOrder(1))
					If BB8->(MsSeek(xFilial("BB8")+BAU->BAU_CODIGO+BD6->BD6_OPERDA+BD6->BD6_CODLOC+BD6->BD6_LOCAL))
						cCNES   := IIf(!Empty(BB8->BB8_CNES),PadR(BB8->BB8_CNES, 7),"9999999")
						cCodMun := IIf(!Empty(BB8->BB8_CODMUN),BB8->BB8_CODMUN,"0000000")
					Else
						cCNES   := "9999999"
						cCodMun := IIF(!Empty(BAU->BAU_MUN),BAU->BAU_MUN,"0000000")
					EndIf
					
					If cCGCPre == "00000000000000"
						aadd(aLog2,{"   RDA sem cnpj: " + BAU->BAU_CODIGO,"",""})
					    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
					Endif
					If nTipoCRDA == 1
						cCodPre := "00" + BAU->BAU_CODIGO
					Else
						If Empty(BAU->BAU_CONREG)
							cCodPre := "00" + BAU->BAU_CODIGO
						Else
							cCodPre := "00" + StrZero(Val(BAU->BAU_CONREG),6)
						Endif
					Endif
					
					//a situacao abaixo atende Botucatu - analisar o caso para os demais clientes  AGS ??? 					
					If BAU->BAU_TIPPRE $ "MED,ANE"
						cCodAto := '1'
					Else
						cCodAto := '2'
					Endif
					cTpRedMin := PadR(BAU->BAU_TIPRED,1)
					cAltoCusto := IIf(BAU->BAU_ALTCUS == "1","S","N")
					
					// Busca prestador requisitante (CD_UNI_PRE_REQ e CD_PRE_REQ)					 
					cUniReq := replicate("0",4)   
					cPreReq := replicate("0",8)   
					aAreaBAU := BAU->(GetArea()) 
					BAU->(DbSetOrder(5))//BAU_FILIAL+BAU_CODBB0
					If !Empty(BD6->BD6_CDPFSOL) .And. BAU->(DbSeek(xFilial("BAU")+BD6->BD6_CDPFSOL)) 
						If nTipoCRDA == 1
					 		cPreReq := "00" + BAU->BAU_CODIGO
				   		Else
					  		If Empty(BAU->BAU_CONREG)
						  		cPreReq := "00" + BAU->BAU_CODIGO
					  		Else
						  		cPreReq := "00" + StrZero(Val(BAU->BAU_CONREG),6)
					   		Endif
				 		Endif
						cUniReq := BD6->BD6_OPEUSR
					EndIf
					RestArea(aAreaBAU)  					

					// Se BD7_CODTPA nao preenchido, procuro primeiro registro na BKX (priorizo o '0')					 
					cParBD7 := BD7->BD7_CODTPA

					If (Empty(cParBD7)) .Or. AllTrim(BD7->BD7_CODUNM) == "HM"
						If BKC->(DbSeek(xFilial("BKC")+BD7->BD7_CODUNM+PLSINTPAD()))
							cTipPar := Alltrim(BKC->BKC_CODPAR) 
						Else
							cTipPar :='0'
						Endif
					Else
						cTipPar :=IIF(LEN(cParBD7)>1,PLSAJPAR(cParBD7),Subs(cParBD7,1,1))
					Endif	

					If cTipPar == "9"
						cTipPar := "0"
					Endif
					
					// Tipo de nota Consulta, participacao passa a ser 0 = Não se aplica participação 					 
					If cTipNot == "1"
						cTipPar := "0"
					Endif 
					
					// Tipo de nota SADT, se nao preenchido forco zero e diferencio COP e FIL					 
					If cTipNot == "2"
						If !Empty(cParBD7) .And. (IIF(LEN(alltrim(cParBD7))>1,alltrim(cParBD7) <> '00',alltrim(cParBD7) <> '0')) .And. AllTrim(BD7->BD7_CODUNM) <> "HM"
							cTipPar :=IIF(LEN(cParBD7)>1,PLSAJPAR(cParBD7),Subs(cParBD7,1,1))
						Else
							If Empty(cTipPar)
								cTipPar := "0"
							Endif	
						Endif     

						/*If Alltrim(BD7->BD7_CODUNM) $ "COP,FIL"
							If empty(cRdaHm)
								nPosBD7 := BD7->(RecNo())
								If BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+"HM")))
									cRdaHm := BD7->BD7_CODRDA
								Endif
								BD7->(dbGoTo(nPosBD7))
							Endif
							If BD7->BD7_CODRDA <> cRdaHm
								cTipPar := "X"
							Endif
						Endif   */

					Endif                       
					IF BD7->BD7_FATMUL > 1
						cFatUnd := alltrim(STR(BD7->BD7_FATMUL*100)) 
					Else                
						cFatUnd := '100'
					Endif
					
					// Tipo de nota Internacao, forco taxas e diarias e diferencio COP e FIL					 
					If cTipNot == "3"
						If alltrim(BD7->BD7_CODUNM) $ "VDI,VTX"
							cTipPar := "H"
						EndIf	

						/*If Alltrim(BD7->BD7_CODUNM) $ "COP,FIL"
							If empty(cRdaHm)
								nPosBD7 := BD7->(RecNo())
								If BD7->(msSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+"HM")))
									cRdaHm := BD7->BD7_CODRDA
								Endif
								BD7->(dbGoTo(nPosBD7))
							Endif
							If BD7->BD7_CODRDA <> cRdaHm
								cTipPar := "X"
							Endif
						Endif*/

					Endif

					 If cOpeOriBTO == GetNewPar("MV_PLOPPEA","0999") .And. BAU->BAU_TIPPRE == GetNewPar("MV_PLSTPIN","OPE")  // corrido para quando for PEA pegar o mesmo codigo da operadora 
					 	cUniPre := padr(BAU->BAU_CODOPE,4)
					 Else
					 	cUniPre := padr(BD7->BD7_CODOPE,4)
					 Endif	

					// Calcula valores
					nVlrCob := 0
					nVlrPag := 0
					nVCoCob := 0
					nVFiCob := 0
					nTaxAdm := 0
					nTaxaCo := 0
					nTaxFil := 0

					cBD7PF  := strzero(noround(BD7->BD7_VLRTPF,2)*100,14,2)
					cBD7TAD := strzero(noround(BD7->BD7_VLRTAD,2)*100,14,2)

					// VL_PAGO_PREST - so e enviado de operadora do RS para RS
					aArea := GetArea()
					DbSelectArea("BA0")
					DbSetOrder(1)//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
					If lPjRaufi .And. BA0->(DbSeek(xFilial("BA0")+cUniOri)) .And. BA0->BA0_EST = "RS"
					    If BA0->(DbSeek(xFilial("BA0")+cUniDes)) .And. BA0->BA0_EST = "RS"
					        cBD7VPG := strzero(noround(BD7->BD7_VLRPAG,2)*100,14,2)
					        nBD7VPG := val(cBD7VPG) / 100
					    Else
					        nBD7VPG := 0 
					    EndIf   
					Else
					    nBD7VPG := 0 
				    EndIf
					RestArea(aArea)     

					nBD7PF  := val(cBD7PF)  / 100
					nBD7TAD := val(cBD7TAD) / 100

					nBD7PF  := nBD7PF-nBD7TAD

					If BD7->BD7_CODUNM $ "COP,COR"
						nVCoCob := noround(nBD7PF,2)
						nTaxaCo := noround(nBD7TAD,2)
					Else
						If BD7->BD7_CODUNM == "FIL"
							nVFiCob := noround(nBD7PF,2)
							nTaxFil := noround(nBD7TAD,2)
						Else
							nVlrCob := noround(nBD7PF,2)
   							If nTpMov <> "1"  
								nTaxAdm := noround(nBD7TAD,2)
							Else   
							   	nTaxAdm := 0
							   	nBD6 := nBD6 - noround(nBD7TAD,2)
							EndIf					
						Endif
					Endif
					nVlrPag := noround(nBD7VPG,2)

					// Ponto de Entrada para checar regras especificas	Federacao
					If lPLS500REG
						aRet := ExecBlock( "PLS500REG",.F.,.F. )
						If Len(aRet) > 0
						   For nI := 1 To Len(aRet)
							   AaDd(aLog2,{ aRet[nI,2],aRet[nI,3],aRet[nI,4] } )
						       PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
						   Next	   
						EndIf	
					EndIf

					// Monta vetor para registro R504
            		If lPLS50005 
        		         aRetPto505 := ExecBlock("PLS50005",.F.,.F.,{cCodEsp,cCodPsa,cTipPar,cTipTab,cPacote,cCodPoA})	
						 If ValType(aRetPto505) == "A" .And. Len(aRetPto505) >= 2
								cCodEsp := aRetPto505[1]
								cCodPsa := aRetPto505[2]
						 Endif
						 If ValType(aRetPto505) == "A" .And. Len(aRetPto505) >= 5
								cTipPar := aRetPto505[3]
								cTipTab := aRetPto505[4]
								cPacote := aRetPto505[5]
						 Endif   
						 If ValType(aRetPto505) == "A" .And. Len(aRetPto505) >= 11                                   
								nVlrCob := aRetPto505[6]
								nVCoCob := aRetPto505[7]
								nVFiCob := aRetPto505[8]
								nTaxAdm := If(nTpMov<>"1",aRetPto505[9],0)
								nTaxaCo := aRetPto505[10]
								nTaxFil := aRetPto505[11]
						  Endif
					Endif

					nPos := 0

					//troca de codigo AMB pata CBHPM....

						If nConvert == 2
							If Empty(dDataConv) .Or. dtos(BD7->BD7_DATPRO) >= dtos(dDataConv)
								BW0->(DbSetOrder(2))
								If BW0->(MsSeek(xFilial("BW0")+cTpTabCBH+cCodPsa))
									cCodPsa := Subs(Alltrim(BW0->BW0_CODPR1),1,8)
								Else
									BW0->(DbSetOrder(1))
									If BW0->(MsSeek(xFilial("BW0")+cTpTabCBH+cCodPsa))
										cCodPsa := Subs(Alltrim(BW0->BW0_CODPR2),1,8)
									Endif
								Endif
							Endif
						Endif

					If lAgrupa				

				  		// Implementacao criada para Sul Capixaba, define qual participacao           
				  		// aglutina o mesmo procedimento (mesmo com participacoes diferentes)           
 				  		// Para procedimentos cirurgicos, nunca ser agultinado                      

					    If !Empty(cPartAgrp)
					    	If BR8->BR8_TIPEVE <> "2"		
								nPos := aScan(aReg504,{|x| Alltrim(x[6])  == Alltrim(cCodPre) .and. ;
							                            Alltrim(x[11]) == Alltrim(cCodPsa) })        
							Else
								nPos := 0
							EndIf                            
						Else
							nPos := aScan(aReg504,{|x| Alltrim(x[6])  == Alltrim(cCodPre) .and. ;
							                            Alltrim(x[8])  == Alltrim(cTipPar) .and. ;
							                            Alltrim(x[11]) == Alltrim(cCodPsa) })     
						EndIf

						cCodUnmAnt:=BD7->BD7_CODUNM
					EndIf

					If nPos == 0 .or. Len(aPacote[3])>0
            		    If lPLS50004
						   For n50004 := 1 To Len(aPacote[3])
						   		//{CODPAD, CODPRO, Procedimento principal, Tipo do evento no pacote, controle de alteração}
								aadd(aPL50004, {aPacote[3][n50004][1], aPacote[3][n50004][2], aPacote[3][n50004][5], aPacote[3][n50004][6], 0})
						   next
						   abkp50004 := aclone(aPL50004)
        		           aRetPto504 := ExecBlock("PLS50004",.F.,.F.,{cCodEsp,cCodPsa,cTipPar,cTipTab,cPacote,cCodPoA})
							If Len(aPL50004) <> len(abkp50004)
								aPL50004 := aclone(abkp50004)
							endIf
							If ValType(aRetPto504) == "A" .And. Len(aRetPto504) >= 2
								cCodEsp := aRetPto504[1]
								cCodPsa := aRetPto504[2]
							Endif
							If ValType(aRetPto504) == "A" .And. Len(aRetPto504) >= 5
								cTipPar := aRetPto504[3]
								cTipTab := aRetPto504[4]
								cPacote := aRetPto504[5]
							Endif                        
							If ValType(aRetPto504) == "A" .And. Len(aRetPto504) >= 11                                   
								nVlrCob := aRetPto504[6]
								nVCoCob := aRetPto504[7]
								nVFiCob := aRetPto504[8]
								nTaxAdm := If(nTpMov<>"1",aRetPto505[9],0)
								nTaxaCo := aRetPto504[10]
								nTaxFil := aRetPto504[11]
							Endif
						Endif

						if nVlrCob > 0 .and. empty(val(cCBOSExec))
							cCodEsp := iif(!empty(BD7->BD7_ESPEXE),BD7->BD7_ESPEXE,BD6->BD6_ESPEXE)
							if !empty(cCodEsp) .and.  BAQ->(MsSeek( xFilial("BAQ")+BD6->BD6_OPERDA+cCodEsp))
								cCBOSExec := Substr(PLSDELIM(BAQ->BAQ_CBOS),1,6)
							endif
						endif

						/*if BR8->BR8_TPPROC <> "0" .or. (nVlrCob == 0 .and. BR8->BR8_TPPROC == "0")
							cTipPes := BAU->BAU_TIPPE
							cCGCPre := strzero(val(BAU->BAU_CPFCGC),14)
							cNmExec := PlRetponto(substr(BAU->BAU_NOME+Space(60),1,60))
						endif*/

						//Retirar o else quando a versão 11.3 entrar em vigor pra remover a duplicidade de código que precisou ocorrer aqui pra ter a versão anterior em uso até a vigência da nova
						//Na 11.3 os itens do apcote vão diferente e o código do pacote transita, isso inverte boa parte da lógica antiga de não enviar o apcote e enviar todos itens dele como eventos separados.
						If l500S .and. (empty(cDatAut) .or. cDatAut >= '20201201')
							// Posiciona no Registro para verificar a versao do layout... 						  

							nRecBR8   := BR8->(Recno())
							nOrdBR8   := BR8->(IndexOrd())          
							BR8->(DbSetOrder(3))  
							BR8->(MsSeek(xFilial("BR8")+cCodpSA))

							// Unidade de Medida - Conforme Tabela "S" - Anexo 01 do manual do Ptu 3.4  
							// indicado pelo campo na tabela padrao BR8_UNMENU-Unidade Medida Numerica  

							cUNMEDIDA := "00"

							// Posiciona no Registro para verificar a versao do layout
							DE1->(DbSetOrder(2))
							If DE1->(DbSeek(xFilial("DE1")+AllTrim(DE9->DE9_CODLAY)+" R501  014"))                                      
							cDeiRegra := StrTran(DE1->DE1_REGRA,'"',"") 
								If VAL(cDeiRegra) >= 12 // VERSAO DO LAYOUT MAIOR OU IGUAL A 10 VERIFICA SE O CAMPO EXISTE
									If Empty(BR8->BR8_UNMENU)
										cUNMEDIDA := "00"
									Else
										cUNMEDIDA := strzero(BR8->BR8_UNMENU,2)
										Endif
									Endif
								Endif		  
							BR8->(DbGoTo(nRecBR8))
							BR8->(DbSetOrder(nOrdBR8))


							// Verifica se ha um mesmo item da guia com o mesmo horario                 

							If len(aItensBD6) > 0 .And. aScan(aItensBD6,{|x| x[1] == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)}) == 0
								aItensBD6 := {}
							EndIf
							If len(aItensBD6) > 0
								If aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0
									While aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0 				                	
										cHorPsa := Substr(cHorPsa,1,6)+Strzero(Val(SubStr(cHorPsa,7,2)) + 1,2) 

										If SubStr(cHorPsa,7,2) == "60" 
											cHorPsa := SubStr(cHorPsa,1,3)+Strzero(Val(SubStr(cHorPsa,4,2)) + 1,2)+":00"
										EndIf

										If SubStr(cHorPsa,4,2) == "60" 
											cHorPsa := Strzero(Val(SubStr(cHorPsa,1,2)) + 1,2)+":00:00"
										EndIf
									EndDo  
								EndIf    
							EndIf	

							aAdd(aItensBD6,{BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),Alltrim(cCodPsa),cHorPsa})	

							// Incrementa array aR504			                
							aR504 := {}
							aadd(aR504,Space(8))						// 01 Sequencial
							aadd(aR504,Space(3))						// 02 Tipo de Registro
							aadd(aR504,cLote)							// 03 Lote
							aadd(aR504,Space(11))                       // 04 Reservado
							aadd(aR504,cUniPre)                         // 05 Unimed do Prestador
							aadd(aR504,cCodPre)                         // 06 Codigo do Prestador
							aadd(aR504,Space(40))                   	// 07 Reservado											
							aadd(aR504,Subs(cTipPar,1,1))               // 08 Participacao
							aadd(aR504,dtos(dDatSer))                   // 09 Data de Execucao
							aadd(aR504,cTipTab)                         // 10 Tipo de Tabela
							aadd(aR504,cCodPsa)                         // 11 Codigo do Servico
							If cTipTab $ "0/4"
								aadd(aR504,Strzero(Int(Round(nQtdPsa, 2)),4)+"0000") // 12 Quantidade 
							Else 
								cDecItem := cValToChar(nQtdPsa - Int(nQtdPsa)) 
								cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
								aadd(aR504,Strzero(int(nQtdPsa),4)+cDecItem)         // 12 Quantidade
							EndIf
							aadd(aR504,strzero(noround(nVlrCob,2)*100,14))        	// 13 Valor de Honorario
							aadd(aR504,strzero(noround(nVCoCob,2)*100,14))        	// 14 Valor de CO
							aadd(aR504,strzero(noround(nVFiCob,2)*100,14))	        // 15 Valor de Filme
							aadd(aR504,IF(Subs(cTipPar,1,1)=="A",cCodPoA," "))     	// 16 Codigo do Porte Anestesico
							aadd(aR504,cUniAut)                         // 17 Unimed Autorizadora
							aadd(aR504,space(9))						// 18 Reservado 							
							aadd(aR504,space(4))                    	// 19 Reservado 
							aadd(aR504,space(8))                    	// 20 Reservado													
							aadd(aR504,cViaAce)                         // 21 Via de Acesso
							aadd(aR504,If(nTpMov<>"1",strzero(noround(nTaxAdm,2)*100,14),strzero(0,14)))		// 22 Taxa de administracao do Servico
							aadd(aR504,strzero(noround(nTaxaCo,2)*100,14)) 		// 23 Taxa de administracao do CO
							aadd(aR504,strzero(noround(nTaxFil,2)*100,14)) 	    // 24 Taxa de administracao do Filme
							aadd(aR504,space(2))                         // 25 Codigo da especialidade				
							aadd(aR504,space(2))                        // 26 Reservado
							aadd(aR504,space(1))                        // 27 Reservado							
							aadd(aR504,cTipPes)                         // 28 Tipo de Pessoa
							aadd(aR504,cCGCPre)                         // 29 CNPJ, CGC ou CPF

							cPacote:= Iif (!Empty(BD6->BD6_CD_PAC),"S","N") 

							aadd(aR504, IIF(cTipTab == "4"," ",cPacote) )                         // 30 Pacote
							aadd(aR504,cCodAto)                         // 31 Codigo do Ato

							If !Empty(BD6->BD6_ESPEDI)  
								cNmExec   := PadR(BD6->BD6_NOMEDI, 60)   
								cSgConsPr := Padr(BD6->BD6_SIGEXE, 12) 								
								cNrConsPr := PadR(BD6->BD6_REGEXE, 15)
								cUFConsPr := BD6->BD6_ESTEXE 
								if cSgConsPr $ "CRAS"
									cSgConsPr := PadR("CRESS", 12)
								elseif cSgConsPr $ "CRFA"
									cSgConsPr := PadR("CREFONO", 12)
								endif
							EndIf														
							aadd(aR504,If(cFatUnd>'100',cFatUnd,'100')) // 32 Fator multiplicador  
							aadd(aR504,cNotPrg)                         // 33 Sequencial da nota para prorrogacao
							aadd(aR504,cHorPsa)			                // 34 Hora que foi realizado o servico
							aadd(aR504,Space(7))						// 35 RESERVADO
							aadd(aR504,Space(40))                   	// 36 Reservado
							aadd(aR504,cSgConsPr)						// 37 Sigla do Conselho Profissional do prestador do serviço.
							aadd(aR504,cNrConsPr)						// 38 Número do Conselho Profissional do prestador do serviço
							aadd(aR504,cUFConsPr)						// 39 Sigla da Unidade Federativa do Conselho Profissional do prestador do serviço.
							aadd(aR504,Space(2))						// 40 Reservado 
							aadd(aR504,Space(14))						// 41 Reservado
							aadd(aR504,Space(40))						// 42 Reservado
							aadd(aR504,Space(12))						// 43 Reservado
							aadd(aR504,Space(15))						// 44 Reservado
							aadd(aR504,Space(2))						// 45 Reservado
							aadd(aR504,Iif(cTpGuia=="04","S","N"))		// 46 ID-REEMBOLSO
							aadd(aR504,cNroAut)							// 47 Numero da Autorizacao
							aadd(aR504,If(nVlrPag<>0,strzero(noround(nVlrPag,2)*100,14),replicate("0",14)))     // 48 Valor pago ao prestador 

							//If Empty (BD6->BD6_CD_PAC)
							//	If lDeParaBTU 
							//		aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(cCodPct),1,8),replicate("0",8)))	// 49 CD_PACOTE  
							//	Else
							//		aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(BR8->BR8_CODPSA),1,8),replicate("0",8)))	// 49 CD_PACOTE  
							//	EndIf						 		
							//Else
							//	aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(BD6->BD6_CD_PAC),1,8),replicate("0",8))) // 49 CD_PACOTE
							//EndIF
							aadd(aR504,replicate("0",8)) // 49 CD_PACOTE

							aadd(aR504,Space(20))						// 50 Reservado
							aadd(aR504,cTiAutUnim)		   				// 51 Tipo de autorizaçõa

							If lDeParaBTU .And. !Empty(cDesPct)
								cDescBr8:= cDesPct   
							Else 
								If AllTrim(BD6->BD6_CODPRO) $ (cCodMedGen +';'+ cCodMatGen +';'+ cCodTaxGen +';'+ cCodOpmGen)
									cDescBr8:= BD6->BD6_DESPRO + Space(80)
								Else
									cDescBr8:= BR8->BR8_DESCRI 
								EndIf   						 		
							EndIf

							//Ponto de entrada para efetuar tratamento na descrição							
							If lPL500DESC
								cDescBr8 := ExecBlock("PL500DESC",.F.,.F.,{cDescBr8})
							Endif   

							aadd(aR504,Substr(cDescBr8,1,80))			// 52 Descrição do serviço				 	
							aadd(aR504,Space(1))						// 53 Reservado				 	
							aadd(aR504,cNota)                           // 54 Nro da nota de controle da Unimed    
							aadd(aR504,cHorFim)                         // 55 Hora que foi finalizado o servico
							aadd(aR504,iif(cFatUnd>'100','N',iif(cFatSer<>'100','S','N')))    // 56 Identificador de acréscimo de urgência/emergência
							aadd(aR504,cCBOSExec)                       // 57 Classificação Brasileira de Ocupações do profissional executante
							aadd(aR504,cTecUtil)                        // 58 Técnica utilizada para realização do procedimento   
							aadd(aR504,iif(empty(cDatAut),space(8),cDatAut))   // 59 Data da autorizacao
							aadd(aR504,iif(empty(cDatSol),space(8),cDatSol))   // 60 Data da solicitacao
							aadd(aR504,cCodUnMed)                   	// 61 Codigo da Unidade de Medida
							aadd(aR504,iif(BR8->BR8_TPPROC=='5',cRegAnvis,space(15))) // 62 Número de registro do material na ANVISA
							aadd(aR504,Space(7))                     	// 63 Reservado  						 	
							aadd(aR504,Space(30))                   	// 64 Reservado					 	
							aadd(aR504,iif(empty(cDatPagam),space(8),cDatPagam))// 65 Data do pagamento ao prestador
							aadd(aR504,iif(BR8->BR8_TPPROC=='5',cCnpjFor,replicate("0",14)))// 66 CNPJ do prestador
							aadd(aR504,cCodRecPre)              	    // 67 Código recebido do prestador
							aadd(aR504,cCodRefFab)                      // 68 Código de referência do material no fabricante		
							aadd(aR504,iif(BR8->BR8_TPPROC=='5',cIDPagForn,'0')) // 69 Indicador de pagamento direto ao fornecedor						 	
							aadd(aR504,Space(40))                   	// 70 Reservado	
							aadd(aR504,iif(BR8->BR8_TPPROC=='5',cDetRegAnv,space(50))) // 71 Obrigatório para OPME. Demais casos, preencher com brancos.
							aadd(aR504,iif(BR8->BR8_TPPROC=='5',cNumNFForn,space(20))) // 72 Regra: Obrigatório para ID_PAG_FORN=1						
							aadd(aR504,Space(1))  						// 73 Tipo de Rede conforme Manual do Intercâmbio Nacional								
							aadd(aR504,space(70))                   	// 74 Reservado
							aadd(aR504,cNmExec)							// 75 Nome do profissional executante.
							aadd(aR504,space(10))                   	// 76 Reservado			
							aadd(aR504,iif(BR8->BR8_TPPROC=='5',cPagNomFor ,space(60))) // 77 Nome do Fornecedor do material
							aadd(aR504,space(10))                   	// 78 Reservado	
 
							aadd(aR504,cAvisoIt)                  		// 79 Indicador de aviso RN 430
							aadd(aR504,StrZero(BD7->(RECNO()),20))		// 99 Recno do BD7 para gravar o BD7_SEQ500 ** SEMPRE DEIXAR POR ULTIMO ** 

							aadd(aReg504,aR504)
							nQtd_Ser += nQtdPsa

							// Monta matriz
							If Len(aPacote[3]) > 0
								nSlvVco := 0
								nSlvCco := 0
								nSlvFco := 0
								nSlvTad := 0   
								nSlvTco := 0        
								nSlvTfi := 0
								For nI:=1 To Len(aPacote[3])	

									nRecBR8   := BR8->(Recno())
									nOrdBR8   := BR8->(IndexOrd())          
									BR8->(MsSeek( xFilial("BR8")+aPacote[3][nI][1]+aPacote[3][nI][2] ))
									cTipTab := BR8->BR8_TPPROC
									If BR8->(fieldPos("BR8_TIPROL")) > 0
										cTipRol := BR8->BR8_TIPROL // 1-Honorarios 2-SADT
									Endif
									lZera := cTipTab == "5" .or. cTipRol == "1" .or. (BR8->(fieldPos("BR8_TIPROL")) == 0 .and. cTipTab == "0")
									// CTipTab = 5 (Ortese/Protese) / cTipRol = 1 (Honorarios) / Regra antida para sistemas sem o campo BR8_TIPROL	 
									If !lZera
										loop
									endIf
									BA8->(DbSetOrder(4))//BA8_FILIAL+BA8_CODPRO+BA8_CODTAB
									if cTipTab == '5' .and. BA8->(msSeek(xFilial("BA8")+alltrim(aPacote[3][nI][2])))			   			
										cDetRegAnv	:= iif(!empty(cDetRegAnv),cDetRegAnv,Padr(Substr(BA8->BA8_DETANV,1,50),50)  )
										cRegAnvis	:= iif(!empty(cRegAnvis	),cRegAnvis, Padr(Substr(BA8->BA8_RGANVI,1,15),15) )
									else
										cRegAnvis  := Space(15)
										cDetRegAnv := Space(50)
									endif

									Do Case
									Case cTipTab $ "0"
										cTipTab := "0"
									Case cTipTab $ "3|4"
										cTipTab := "1"
									Case cTipTab $ "1|5"
										cTipTab := "2"
									Case cTipTab $ "2"
										cTipTab := "3"
									Case cTipTab $ "6"
										cTipTab := "4"
									Otherwise
										cTipTab := "0"
									EndCase

									// Unidade de Medida - Conforme Tabela "S" - Anexo 01 do manual do Ptu 3.4  
									// indicado pelo campo na tabela padrao BR8_UNMENU-Unidade Medida Numerica  
									If Empty(BR8->BR8_UNMENU)
										cUNMEDIDA := "00"
									Else
										cUNMEDIDA := strzero(BR8->BR8_UNMENU,2)
									Endif				

									// Verifica se ha um mesmo item da guia com o mesmo horario                 
									If len(aItensBD6) > 0 .And. aScan(aItensBD6,{|x| x[1] == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)}) == 0
										aItensBD6 := {}
									EndIf

									If len(aItensBD6) > 0

										If aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0
											While aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0 

												cHorPsa := Substr(cHorPsa,1,6)+Strzero(Val(SubStr(cHorPsa,7,2)) + 1,2) 

												If SubStr(cHorPsa,7,2) == "60" 
													cHorPsa := SubStr(cHorPsa,1,3)+Strzero(Val(SubStr(cHorPsa,4,2)) + 1,2)+":00"
												EndIf

												If SubStr(cHorPsa,4,2) == "60" 
													cHorPsa := Strzero(Val(SubStr(cHorPsa,1,2)) + 1,2)+":00:00"
												EndIf
											EndDo  
										EndIf    
									EndIf	
									If Len(aPacote[3,nI]) > 0 .And. Len(aPacote[4])>0 .And. aPacote[4] $ "BLE,BLY,B42"   
										nQtdPsa:=VerQtdPac(aPacote[3,nI],aPacote,BD7->BD7_CODPAD,BD7->BD7_CODPRO,nQtdPsa,dTos(dDatSer)) * BD6->BD6_QTDPRO
									Endif       
		
									aAdd(aItensBD6,{BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),Alltrim(cCodPsa),cHorPsa})	

									// Incrementa array aR504                                                   

									aR504 := {}
									aadd(aR504,Space(8))						// 01 Sequencial
									aadd(aR504,Space(3))						// 02 Tipo de Registro
									aadd(aR504,cLote)							// 03 Lote
									aadd(aR504,Space(11))                      	// 04 Reservado
									aadd(aR504,cUniPre)                         // 05 Unimed do Prestador
									aadd(aR504,cCodPre)                         // 06 Codigo do Prestador							
									aadd(aR504,Space(40))                   	// 07 Reservado							
									aadd(aR504,Subs(cTipPar,1,1))               // 08 Participacao
									aadd(aR504,dtos(dDatSer))                   // 09 Data de Execucao
									aadd(aR504,cTipTab)                         // 10 Tipo de Tabela
									aadd(aR504,strzero(val(aPacote[3][nI][2]),8))                         // 11 Codigo do Servico

									If cTipTab $ "0/4"
										aadd(aR504,Strzero(Int(Round(nQtdPsa, 2)),4)+"0000") // 12 Quantidade
									Else 
										cDecItem := cValToChar(nQtdPsa - Int(nQtdPsa)) 
										cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
										aadd(aR504,Strzero(int(nQtdPsa),4)+cDecItem)         // 12 Quantidade
									EndIf								

									//A partir da versão 11.3 os valores são enviados no procedimento do pacote
									aadd(aR504,strzero(0,14)) 	// 13 Valor de Honorario
									aadd(aR504,strzero(0,14))	// 14 Valor de CO
									aadd(aR504,strzero(0,14)) 	// 15 Valor de Filme

									aadd(aR504,IF(Subs(cTipPar,1,1)=="A",cCodPoA," "))                         // 16 Codigo do Porte Anestesico
									aadd(aR504,cUniAut)                         // 17 Unimed Autorizadora
									aadd(aR504,space(9))						// 18 RESERVADO 								
									aadd(aR504,space(4))                        // 19 Reservado 
									aadd(aR504,space(8))                        // 20 Reservado								
									aadd(aR504,cViaAce)                         // 21 Via de Acesso
									aadd(aR504,strzero(0,14))  					// 22 Taxa de administracao do Servico
									aadd(aR504,strzero(0,14)) 					// 23 Taxa de administracao do CO
									aadd(aR504,strzero(0,14)) 	    			// 24 Taxa de administracao do Filme
									aadd(aR504,space(2))                       	// 25 Codigo da especialidade								
									aadd(aR504,space(2))                    	// 26 Reservado
									aadd(aR504,space(1))                    	// 27 Reservado								
									aadd(aR504,cTipPes)                         // 28 Tipo de Pessoa
									aadd(aR504,cCGCPre)                         // 29 CNPJ, CGC ou CPF
									aadd(aR504,"S")                         	// 30 Pacote
									aadd(aR504,cCodAto)                         // 31 Codigo do Ato                                              

									If !Empty(BD6->BD6_ESPEDI)  
										cNmExec   := PadR(BD6->BD6_NOMEDI, 60)   
										cSgConsPr := Padr(BD6->BD6_SIGEXE, 12) 								
										cNrConsPr := PadR(BD6->BD6_REGEXE, 15)
										cUFConsPr := BD6->BD6_ESTEXE 
									EndIf														
									aadd(aR504,If(cFatUnd>'100',cFatUnd,'100')) // 32 Fator multiplicador  
									aadd(aR504,cNotPrg)                         // 33 Sequencial da nota para prorrogacao
									aadd(aR504,cHorPsa)			                // 34 Hora que foi realizado o servico
									aadd(aR504,Space(7))						// 35 Reservado
									aadd(aR504,Space(40))                   	// 36 Reservado							
									aadd(aR504,cSgConsPr)						// 37 Sigla do Conselho Profissional do prestador do serviço.
									aadd(aR504,cNrConsPr)						// 38 Número do Conselho Profissional do prestador do serviço
									aadd(aR504,cUFConsPr)						// 39 Sigla da Unidade Federativa do Conselho Profissional do prestador do serviço.
									aadd(aR504,space(2))						// 40 Unidade de Medida - Conforme Tabela S Anexo 01
									aadd(aR504,Space(14))						// 41 Reservado
									aadd(aR504,Space(40))						// 42 Reservado
									aadd(aR504,Space(12))						// 43 Reservado
									aadd(aR504,Space(15))						// 44 Reservado
									aadd(aR504,Space(2))						// 45 Reservado
									aadd(aR504,Iif(cTpGuia=="04","S","N"))		// 46 ID-REEMBOLSO
									aadd(aR504,cNroAut)							// 47 Número da Autorização
									aadd(aR504,If(nVlrPag<>0,Strzero(noround(nVlrPag,2)*100,14),replicate("0",14))) // 48 Valor pago ao prestador

									If Empty(BD6->BD6_CD_PAC)    
										If lDeParaBTU 
											aadd(aR504,substr(alltrim(cCodPct)+space(8),1,8))	// 49 CD_PACOTE  
										Else
											aadd(aR504,substr(alltrim(BD6->BD6_CODPRO)+space(8),1,8))	// 49 CD_PACOTE  
										EndIf						 		
									Else
										aadd(aR504,substr(alltrim(BD6->BD6_CD_PAC)+space(8),1,8))	// 49 CD_PACOTE
									EndIf

									aadd(aR504,Space(20))							// 50 Reservado .
									aadd(aR504,cTiAutUnim)		   					// 51 Tipo de autorizaçõa								 	

									cDescBr8:= BR8->BR8_DESCRI  + Space(80) 

									//Ponto de entrada para efetuar tratamento na descriçõa.
									If lPL500DESC
										cDescBr8 := ExecBlock("PL500DESC",.F.,.F.,{cDescBr8})
									Endif   
		
									aadd(aR504,Substr(cDescBr8,1,80))			// 52 DS_SERVIÇO		
									aadd(aR504,Space(1))						// 53 Reservado		
									aadd(aR504,cNota)                           // 54 Nro da nota de controle da Unimed 
									aadd(aR504,cHorFim)                         // 55 Hora que foi finalizado o servico
									aadd(aR504,iif(cFatUnd>'100','N',iif(cFatSer<>'100','S','N')))    // 56 Identificador de acréscimo de urgência/emergência
									aadd(aR504,cCBOSExec)                       // 57 Classificação Brasileira de Ocupações do profissional executante
									aadd(aR504,cTecUtil)                        // 58 Técnica utilizada para realização do procedimento   
									aadd(aR504,iif(empty(cDatAut),space(8),cDatAut))                     	// 59 Data da autorizacao
									aadd(aR504,iif(empty(cDatSol),space(8),cDatSol))  // 60 Data da solicitacao
									aadd(aR504,cCodUnMed)                       // 61 Codigo da Unidade de Medida
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cRegAnvis,space(15))) // 62 Número de registro do material na ANVISA
									aadd(aR504,Space(7))                     	// 63 Reservado  						 	
									aadd(aR504,Space(30))                   	// 64 Reservado					 	
									aadd(aR504,iif(empty(cDatPagam),space(8),cDatPagam))// 65 Data do pagamento ao prestador
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cCnpjFor,replicate("0",14)))// 66 CNPJ do prestador
									aadd(aR504,cCodRecPre)              	    // 67 Código recebido do prestador
									aadd(aR504,cCodRefFab)                      // 68 Código de referência do material no fabricante		
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cIDPagForn,'0')) // 69 Indicador de pagamento direto ao fornecedor						 	
									aadd(aR504,Space(40))                   	// 70 Reservado	
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cDetRegAnv,space(50))) // 71 Obrigatório para OPME. Demais casos, preencher com brancos.
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cNumNFForn,space(20))) // 72 Regra: Obrigatório para ID_PAG_FORN=1						
									aadd(aR504,Space(1))  						// 73 Reservado							 	
									aadd(aR504,space(70))                   	// 74 Reservado
									aadd(aR504,cNmExec)							// 75 Nome do profissional executante.
									aadd(aR504,space(10))                   	// 76 Reservado			
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cPagNomFor ,space(60))) // 77 Nome do Fornecedor do material
									aadd(aR504,space(10))                   // 78 Reservado	

									aadd(aR504,cAvisoIt)                  		// 79 Indicador de aviso RN 430									
									aadd(aR504,StrZero(BD7->(RECNO()),20))		// 99 Recno do BD7 para gravar o BD7_SEQ500 ** SEMPRE DEIXAR POR ULTIMO **  						 			 	

									aadd(aReg504,aR504)
									nQtd_Ser += nQtdPsa
								Next
								//trata questoes de arredondamento na abertura do pacote 
								nPos := Len(aReg504)
								BR8->(DbGoTo(nRecBR8))
								BR8->(DbSetOrder(nOrdBR8))
							endIf
						else

							If Len(aPacote[3]) > 0
								nSlvVco := 0
								nSlvCco := 0
								nSlvFco := 0
								nSlvTad := 0   
								nSlvTco := 0        
								nSlvTfi := 0
								For nI:=1 To Len(aPacote[3])	

									nRecBR8   := BR8->(Recno())
									nOrdBR8   := BR8->(IndexOrd())          
									BR8->(MsSeek( xFilial("BR8")+aPacote[3][nI][1]+aPacote[3][nI][2] ))
									cTipTab := BR8->BR8_TPPROC
									cParcAux := iif(BR8->BR8_TPPROC == '4','H',subs(cTipPar,1,1) )

									BA8->(DbSetOrder(4))//BA8_FILIAL+BA8_CODPRO+BA8_CODTAB
									if cTipTab == '5' .and. BA8->(msSeek(xFilial("BA8")+alltrim(aPacote[3][nI][2])))			   			
										cDetRegAnv	:= iif(!empty(cDetRegAnv),cDetRegAnv,Padr(Substr(BA8->BA8_DETANV,1,50),50)  )
										cRegAnvis	:= iif(!empty(cRegAnvis	),cRegAnvis, Padr(Substr(BA8->BA8_RGANVI,1,15),15) )
									else
										cRegAnvis  := Space(15)
										cDetRegAnv := Space(50)
									endif

									Do Case
									Case cTipTab $ "0"
										cTipTab := "0"
									Case cTipTab $ "3|4"
										cTipTab := "1"
									Case cTipTab $ "1|5"
										cTipTab := "2"
									Case cTipTab $ "2"
										cTipTab := "3"
									Case cTipTab $ "6"
										cTipTab := "4"
									Otherwise
										cTipTab := "0"
									EndCase

									// Unidade de Medida - Conforme Tabela "S" - Anexo 01 do manual do Ptu 3.4  
									// indicado pelo campo na tabela padrao BR8_UNMENU-Unidade Medida Numerica  

									If Empty(BR8->BR8_UNMENU)
										cUNMEDIDA := "00"
									Else
										cUNMEDIDA := strzero(BR8->BR8_UNMENU,2)
									Endif

									// Verifica se ha um mesmo item da guia com o mesmo horario
									If len(aItensBD6) > 0 .And. aScan(aItensBD6,{|x| x[1] == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)}) == 0
										aItensBD6 := {}
									EndIf

									If len(aItensBD6) > 0

										If aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0
											While aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0 

												cHorPsa := Substr(cHorPsa,1,6)+Strzero(Val(SubStr(cHorPsa,7,2)) + 1,2) 

												If SubStr(cHorPsa,7,2) == "60" 
													cHorPsa := SubStr(cHorPsa,1,3)+Strzero(Val(SubStr(cHorPsa,4,2)) + 1,2)+":00"
												EndIf

												If SubStr(cHorPsa,4,2) == "60" 
													cHorPsa := Strzero(Val(SubStr(cHorPsa,1,2)) + 1,2)+":00:00"
												EndIf
											EndDo  
										EndIf    
									EndIf	
									If Len(aPacote[3,nI]) > 0 .And. Len(aPacote[4])>0 .And. aPacote[4] $ "BLE,BLY,B42"   
										nQtdPsa:=VerQtdPac(aPacote[3,nI],aPacote,BD7->BD7_CODPAD,BD7->BD7_CODPRO,nQtdPsa,dTos(dDatSer)) * BD6->BD6_QTDPRO
									Endif       
		
									aAdd(aItensBD6,{BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),Alltrim(cCodPsa),cHorPsa})	

									// Incrementa array aR504                                                   
									
									aR504 := {}
									aadd(aR504,Space(8))						// 01 Sequencial
									aadd(aR504,Space(3))						// 02 Tipo de Registro
									aadd(aR504,cLote)							// 03 Lote
									aadd(aR504,Space(11))                      	// 04 Reservado
									aadd(aR504,cUniPre)                         // 05 Unimed do Prestador
									aadd(aR504,cCodPre)                         // 06 Codigo do Prestador							
									aadd(aR504,Space(40))                   	// 07 Reservado							
									aadd(aR504,cParcAux)// 08 Participacao
									aadd(aR504,dtos(dDatSer))                   // 09 Data de Execucao
									aadd(aR504,cTipTab)                         // 10 Tipo de Tabela
									aadd(aR504,strzero(val(aPacote[3][nI][2]),8))                         // 11 Codigo do Servico

									If cTipTab $ "0/4"
										aadd(aR504,Strzero(Int(Round(nQtdPsa, 2)),4)+"0000") // 12 Quantidade
									Else 
										cDecItem := cValToChar(nQtdPsa - Int(nQtdPsa)) 
										cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
										aadd(aR504,Strzero(int(nQtdPsa),4)+cDecItem)         // 12 Quantidade
									EndIf

									If !(empty(aPL50004))
										
										nValItem := noround(nVlrCob*aPacote[3][nI][7],2) + noround(nVCoCob*aPacote[3][nI][7],2)

										//Exames são gerados como CO, serviços/consultas são gerados como Honorário
										If aPL50004[nI][5] == 1
											aadd(aR504,strzero(noround(0,2)*100,14))        // 13 Valor de Honorario
											aadd(aR504,strzero(noround(nValItem,2)*100,14)) // 14 Valor de CO
										elseif aPL50004[nI][5] == 2
											aadd(aR504,strzero(noround(nValItem,2)*100,14)) // 13 Valor de Honorario
											aadd(aR504,strzero(noround(0,2)*100,14))        // 14 Valor de CO
										else
											aadd(aR504,strzero(noround(noround(nVlrCob*aPacote[3][nI][7],2),2)*100,14)) // 13 Valor de Honorario
											aadd(aR504,strzero(noround(noround(nVCoCob*aPacote[3][nI][7],2),2)*100,14)) // 14 Valor de CO
										endIf
									else
										aadd(aR504,strzero(noround(noround(nVlrCob*aPacote[3][nI][7],2),2)*100,14)) // 13 Valor de Honorario
										aadd(aR504,strzero(noround(noround(nVCoCob*aPacote[3][nI][7],2),2)*100,14)) // 14 Valor de CO
									endIf
									
									nSlvVco += noround(nVlrCob*aPacote[3][nI][7],2)
									nSlvCco += noround(nVCoCob*aPacote[3][nI][7],2)

									aadd(aR504,strzero(noround(nVFiCob*aPacote[3][nI][7],2)*100,14))	        // 15 Valor de Filme
									nSlvFco += noround(nVFiCob*aPacote[3][nI][7],2)

									aadd(aR504,IF(Subs(cTipPar,1,1)=="A",cCodPoA," "))                         // 16 Codigo do Porte Anestesico
									aadd(aR504,cUniAut)                         // 17 Unimed Autorizadora
									aadd(aR504,space(9))						// 18 RESERVADO 								
									aadd(aR504,space(4))                        // 19 Reservado 
									aadd(aR504,space(8))                        // 20 Reservado								
									aadd(aR504,cViaAce)                         // 21 Via de Acesso

									aadd(aR504,If(nTpMov<>"1",strzero(noround(nTaxAdm*aPacote[3][nI][7],2)*100,14),strzero(0,14)))  		// 22 Taxa de administracao do Servico						
									nSlvTad += noround(nTaxAdm*aPacote[3][nI][7],2)

									aadd(aR504,If(nTpMov<>"1",strzero(noround(nTaxaCo*aPacote[3][nI][7],2)*100,14),strzero(0,14))) 		// 23 Taxa de administracao do CO
									nSlvTco += noround(nTaxaCo*aPacote[3][nI][7],2)

									aadd(aR504,If(nTpMov<>"1",strzero(noround(nTaxFil*aPacote[3][nI][7],2)*100,14),strzero(0,14))) 	    // 24 Taxa de administracao do Filme
									nSlvTfi += noround(nTaxFil*aPacote[3][nI][7],2)

									aadd(aR504,space(2))                         // 25 Codigo da especialidade	
						
									aadd(aR504,space(2))                    	// 26 Reservado
									aadd(aR504,space(1))                    	// 27 Reservado								
									aadd(aR504,cTipPes)                         // 28 Tipo de Pessoa
									aadd(aR504,cCGCPre)                         // 29 CNPJ, CGC ou CPF
									aadd(aR504,cPacote)                         // 30 Pacote
									aadd(aR504,cCodAto)                         // 31 Codigo do Ato                                              

									If !Empty(BD6->BD6_ESPEDI)  
										cNmExec   := PadR(BD6->BD6_NOMEDI, 60)   
										cSgConsPr := Padr(BD6->BD6_SIGEXE, 12) 								
										cNrConsPr := PadR(BD6->BD6_REGEXE, 15)
										cUFConsPr := BD6->BD6_ESTEXE 
									EndIf														
									aadd(aR504,If(cFatUnd>'100',cFatUnd,'100')) // 32 Fator multiplicador  
									aadd(aR504,cNotPrg)                         // 33 Sequencial da nota para prorrogacao
									aadd(aR504,cHorPsa)			                // 34 Hora que foi realizado o servico
									aadd(aR504,Space(7))						// 35 Reservado
									aadd(aR504,Space(40))                   	// 36 Reservado							
									aadd(aR504,cSgConsPr)						// 37 Sigla do Conselho Profissional do prestador do serviço.
									aadd(aR504,cNrConsPr)						// 38 Número do Conselho Profissional do prestador do serviço
									aadd(aR504,cUFConsPr)						// 39 Sigla da Unidade Federativa do Conselho Profissional do prestador do serviço.
									aadd(aR504,space(2))						// 40 Unidade de Medida - Conforme Tabela S Anexo 01
									aadd(aR504,Space(14))						// 41 Reservado
									aadd(aR504,Space(40))						// 42 Reservado
									aadd(aR504,Space(12))						// 43 Reservado
									aadd(aR504,Space(15))						// 44 Reservado
									aadd(aR504,Space(2))						// 45 Reservado
									aadd(aR504,Iif(cTpGuia=="04","S","N"))		// 46 ID-REEMBOLSO
									aadd(aR504,cNroAut)							// 47 Número da Autorização
									aadd(aR504,If(nVlrPag<>0,Strzero(noround(nVlrPag,2)*100,14),replicate("0",14))) // 48 Valor pago ao prestador

									If Empty(BD6->BD6_CD_PAC)    
										If lDeParaBTU 
											aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(cCodPct),1,8),replicate("0",8)))	// 49 CD_PACOTE  
										Else
											aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(BD6->BD6_CODPRO),1,8),replicate("0",8)))	// 49 CD_PACOTE  
										EndIf						 		
									Else
										aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(BD6->BD6_CD_PAC),1,8),replicate("0",8)))	// 49 CD_PACOTE
									EndIf

									aadd(aR504,Space(20))							// 50 Reservado .
									aadd(aR504,cTiAutUnim)		   					// 51 Tipo de autorizaçõa								 	

									If lDeParaBTU .And. !Empty(cDesPct)
										cDescBr8:= cDesPct + Space(80)
									Else
										If AllTrim(BD6->BD6_CODPRO) $ (cCodMedGen +';'+ cCodMatGen +';'+ cCodTaxGen +';'+ cCodOpmGen)
											cDescBr8:= BD6->BD6_DESPRO + Space(80)
										Else
											cDescBr8:= aPacote[3][nI][8] + Space(80) //BR8->BR8_DESCRI 
										EndIf 					 		
									EndIf	

									//Ponto de entrada para efetuar tratamento na descriçõa.
									If lPL500DESC
										cDescBr8 := ExecBlock("PL500DESC",.F.,.F.,{cDescBr8})
									Endif   
		
									aadd(aR504,Substr(cDescBr8,1,80))			// 52 DS_SERVIÇO		
									aadd(aR504,Space(1))						// 53 Reservado		
									aadd(aR504,cNota)                           // 54 Nro da nota de controle da Unimed 
									aadd(aR504,cHorFim)                         // 55 Hora que foi finalizado o servico
									aadd(aR504,iif(cFatUnd>'100','N',iif(cFatSer<>'100','S','N')))    // 56 Identificador de acréscimo de urgência/emergência
									aadd(aR504,cCBOSExec)                       // 57 Classificação Brasileira de Ocupações do profissional executante
									aadd(aR504,cTecUtil)                        // 58 Técnica utilizada para realização do procedimento   
									aadd(aR504,iif(empty(cDatAut),space(8),cDatAut))                     	// 59 Data da autorizacao
									aadd(aR504,iif(empty(cDatSol),space(8),cDatSol))  // 60 Data da solicitacao
									aadd(aR504,cCodUnMed)                       // 61 Codigo da Unidade de Medida
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cRegAnvis,space(15))) // 62 Número de registro do material na ANVISA
									aadd(aR504,Space(7))                     	// 63 Reservado  						 	
									aadd(aR504,Space(30))                   	// 64 Reservado					 	
									aadd(aR504,iif(empty(cDatPagam),space(8),cDatPagam))// 65 Data do pagamento ao prestador
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cCnpjFor,replicate("0",14)))// 66 CNPJ do prestador
									aadd(aR504,cCodRecPre)              	    // 67 Código recebido do prestador
									aadd(aR504,cCodRefFab)                      // 68 Código de referência do material no fabricante		
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cIDPagForn,'0')) // 69 Indicador de pagamento direto ao fornecedor						 	
									aadd(aR504,Space(40))                   	// 70 Reservado	
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cDetRegAnv,space(50))) // 71 Obrigatório para OPME. Demais casos, preencher com brancos.
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cNumNFForn,space(20))) // 72 Regra: Obrigatório para ID_PAG_FORN=1						
									aadd(aR504,Space(1))  						// 73 Tipo de Rede conforme Manual do Intercâmbio Nacional								
									aadd(aR504,space(70))                   	// 74 Reservado
									aadd(aR504,cNmExec)							// 75 Nome do profissional executante.
									aadd(aR504,space(10))                   	// 76 Reservado			
									aadd(aR504,iif(BR8->BR8_TPPROC=='5',cPagNomFor ,space(60))) // 77 Nome do Fornecedor do material
									aadd(aR504,space(10))                   // 78 Reservado	

									aadd(aR504,cAvisoIt)                  		// 79 Indicador de aviso RN 430									
									aadd(aR504,StrZero(BD7->(RECNO()),20))		// 99 Recno do BD7 para gravar o BD7_SEQ500 ** SEMPRE DEIXAR POR ULTIMO **  						 			 	

									aadd(aReg504,aR504)
									nQtd_Ser += nQtdPsa
								Next
								//trata questoes de arredondamento na abertura do pacote                
								nPos := Len(aReg504)
								If noround(nVlrCob,2) <> nSlvVco 
									nDifPac := noround(nVlrCob,2) - nSlvVco 
									aReg504[nPos,13] := strzero(val(aReg504[nPos,13]) + (noround(nDifPac,2)*100),14)        // 13 Valor de Honorario     
								Endif

								If noround(nVCoCob,2) <> nSlvCco
									nDifPac := noround(nVCoCob,2) - nSlvCco
									aReg504[nPos,14] := strzero(val(aReg504[nPos,14]) + (noround(nDifPac,2)*100),14)        // 14 Valor de CO     
								Endif

								If noround(nVFiCob,2) <> nSlvFco
									nDifPac := noround(nVFiCob,2) - nSlvFco
									aReg504[nPos,15] := strzero(val(aReg504[nPos,15]) + (noround(nDifPac,2)*100),14)	        // 15 Valor de Filme     
								Endif

								If nTpMov<>"1" .AND. noround(nTaxAdm,2) <> nSlvTad           
									nDifPac := noround(nTaxAdm,2) - nSlvTad 
									aReg504[nPos,22] := strzero(val(aReg504[nPos,22]) + (noround(nDifPac,2)*100),14)  		// 22 Taxa de administracao do Servico 
								Endif

								If noround(nTaxaCo,2) <> nSlvTco       
									nDifPac := noround(nTaxaCo,2) - nSlvTco
									aReg504[nPos,23] := strzero(val(aReg504[nPos,23]) + (noround(nDifPac,2)*100),14) 		// 23 Taxa de administracao do CO 
								Endif

								If noround(nTaxFil,2) <> nSlvTfi	   
									nDifPac := noround(nTaxFil,2) - nSlvTfi
									aReg504[nPos,24] := strzero(val(aReg504[nPos,24]) + (noround(nDifPac,2)*100),14) 	    // 24 Taxa de administracao do Filme
								Endif

								BR8->(DbGoTo(nRecBR8))
								BR8->(DbSetOrder(nOrdBR8))

							Else

								// Posiciona no Registro para verificar a versao do layout... 						  

								nRecBR8   := BR8->(Recno())
								nOrdBR8   := BR8->(IndexOrd())          
								BR8->(DbSetOrder(3))  
								BR8->(MsSeek(xFilial("BR8")+cCodpSA))

								// Unidade de Medida - Conforme Tabela "S" - Anexo 01 do manual do Ptu 3.4  
								// indicado pelo campo na tabela padrao BR8_UNMENU-Unidade Medida Numerica  

								cUNMEDIDA := "00"

								// Posiciona no Registro para verificar a versao do layout
								DE1->(DbSetOrder(2))
								If DE1->(DbSeek(xFilial("DE1")+AllTrim(DE9->DE9_CODLAY)+" R501  014"))                                      
								cDeiRegra := StrTran(DE1->DE1_REGRA,'"',"") 
									If VAL(cDeiRegra) >= 12 // VERSAO DO LAYOUT MAIOR OU IGUAL A 10 VERIFICA SE O CAMPO EXISTE
										If Empty(BR8->BR8_UNMENU)
											cUNMEDIDA := "00"
										Else
											cUNMEDIDA := strzero(BR8->BR8_UNMENU,2)
											Endif
										Endif
									Endif		  
								BR8->(DbGoTo(nRecBR8))
								BR8->(DbSetOrder(nOrdBR8))


								// Verifica se ha um mesmo item da guia com o mesmo horario                 

								If len(aItensBD6) > 0 .And. aScan(aItensBD6,{|x| x[1] == BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)}) == 0
									aItensBD6 := {}
								EndIf
								If len(aItensBD6) > 0
									If aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0
										While aScan(aItensBD6,{|x|Alltrim(x[2]) == Alltrim(cCodPsa) .And. x[3] == cHorPsa}) > 0 				                	
											cHorPsa := Substr(cHorPsa,1,6)+Strzero(Val(SubStr(cHorPsa,7,2)) + 1,2) 

											If SubStr(cHorPsa,7,2) == "60" 
												cHorPsa := SubStr(cHorPsa,1,3)+Strzero(Val(SubStr(cHorPsa,4,2)) + 1,2)+":00"
											EndIf

											If SubStr(cHorPsa,4,2) == "60" 
												cHorPsa := Strzero(Val(SubStr(cHorPsa,1,2)) + 1,2)+":00:00"
											EndIf
										EndDo  
									EndIf    
								EndIf	
		
								aAdd(aItensBD6,{BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),Alltrim(cCodPsa),cHorPsa})	

								// Incrementa array aR504			                
								aR504 := {}
								aadd(aR504,Space(8))						// 01 Sequencial
								aadd(aR504,Space(3))						// 02 Tipo de Registro
								aadd(aR504,cLote)							// 03 Lote
								aadd(aR504,Space(11))                       // 04 Reservado
								aadd(aR504,cUniPre)                         // 05 Unimed do Prestador
								aadd(aR504,cCodPre)                         // 06 Codigo do Prestador
								aadd(aR504,Space(40))                   	// 07 Reservado											
								aadd(aR504,Subs(cTipPar,1,1))               // 08 Participacao
								aadd(aR504,dtos(dDatSer))                   // 09 Data de Execucao
								aadd(aR504,cTipTab)                         // 10 Tipo de Tabela
								aadd(aR504,cCodPsa)                         // 11 Codigo do Servico
								If cTipTab $ "0/4"
									aadd(aR504,Strzero(Int(Round(nQtdPsa, 2)),4)+"0000") // 12 Quantidade
								Else 
									cDecItem := cValToChar(nQtdPsa - Int(nQtdPsa)) 
									cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
									aadd(aR504,Strzero(int(nQtdPsa),4)+cDecItem)         // 12 Quantidade
								EndIf
								aadd(aR504,strzero(noround(nVlrCob,2)*100,14))        	// 13 Valor de Honorario
								aadd(aR504,strzero(noround(nVCoCob,2)*100,14))        	// 14 Valor de CO
								aadd(aR504,strzero(noround(nVFiCob,2)*100,14))	        // 15 Valor de Filme
								aadd(aR504,IF(Subs(cTipPar,1,1)=="A",cCodPoA," "))     	// 16 Codigo do Porte Anestesico
								aadd(aR504,cUniAut)                         // 17 Unimed Autorizadora
								aadd(aR504,space(9))						// 18 Reservado 							
								aadd(aR504,space(4))                    	// 19 Reservado 
								aadd(aR504,space(8))                    	// 20 Reservado													
								aadd(aR504,cViaAce)                         // 21 Via de Acesso
								aadd(aR504,If(nTpMov<>"1",strzero(noround(nTaxAdm,2)*100,14),strzero(0,14)))		// 22 Taxa de administracao do Servico
								aadd(aR504,strzero(noround(nTaxaCo,2)*100,14)) 		// 23 Taxa de administracao do CO
								aadd(aR504,strzero(noround(nTaxFil,2)*100,14)) 	    // 24 Taxa de administracao do Filme

								aadd(aR504,space(2))                         // 25 Codigo da especialidade	
			
								aadd(aR504,space(2))                        // 26 Reservado
								aadd(aR504,space(1))                        // 27 Reservado							
								aadd(aR504,cTipPes)                         // 28 Tipo de Pessoa
								aadd(aR504,cCGCPre)                         // 29 CNPJ, CGC ou CPF

								cPacote:=Iif (!Empty(BD6->BD6_CD_PAC),"S","N") 

								aadd(aR504,cPacote)                         // 30 Pacote
								aadd(aR504,cCodAto)                         // 31 Codigo do Ato

								If !Empty(BD6->BD6_ESPEDI)  
									cNmExec   := PadR(BD6->BD6_NOMEDI, 60)   
									cSgConsPr := Padr(BD6->BD6_SIGEXE, 12) 								
									cNrConsPr := PadR(BD6->BD6_REGEXE, 15)
									cUFConsPr := BD6->BD6_ESTEXE 
								EndIf														
								aadd(aR504,If(cFatUnd>'100',cFatUnd,'100')) // 32 Fator multiplicador  
								aadd(aR504,cNotPrg)                         // 33 Sequencial da nota para prorrogacao
								aadd(aR504,cHorPsa)			                // 34 Hora que foi realizado o servico
								aadd(aR504,Space(7))						// 35 RESERVADO
								aadd(aR504,Space(40))                   	// 36 Reservado
								aadd(aR504,cSgConsPr)						// 37 Sigla do Conselho Profissional do prestador do serviço.
								aadd(aR504,cNrConsPr)						// 38 Número do Conselho Profissional do prestador do serviço
								aadd(aR504,cUFConsPr)						// 39 Sigla da Unidade Federativa do Conselho Profissional do prestador do serviço.
								aadd(aR504,Space(2))						// 40 Reservado 
								aadd(aR504,Space(14))						// 41 Reservado
								aadd(aR504,Space(40))						// 42 Reservado
								aadd(aR504,Space(12))						// 43 Reservado
								aadd(aR504,Space(15))						// 44 Reservado
								aadd(aR504,Space(2))						// 45 Reservado
								aadd(aR504,Iif(cTpGuia=="04","S","N"))		// 46 ID-REEMBOLSO
								aadd(aR504,cNroAut)							// 47 Numero da Autorizacao
								aadd(aR504,If(nVlrPag<>0,strzero(noround(nVlrPag,2)*100,14),replicate("0",14)))     // 48 Valor pago ao prestador 

								If Empty (BD6->BD6_CD_PAC)
									If lDeParaBTU 
										aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(cCodPct),1,8),replicate("0",8)))	// 49 CD_PACOTE  
									Else
										aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(BR8->BR8_CODPSA),1,8),replicate("0",8)))	// 49 CD_PACOTE  
									EndIf						 		
								Else
									aadd(aR504,Iif(cPacote=="S",Substr(Alltrim(BD6->BD6_CD_PAC),1,8),replicate("0",8))) // 49 CD_PACOTE
								EndIF

								aadd(aR504,Space(20))						// 50 Reservado
								aadd(aR504,cTiAutUnim)		   				// 51 Tipo de autorizaçõa

								If lDeParaBTU .And. !Empty(cDesPct)
									cDescBr8:= cDesPct   
								Else 
									If AllTrim(BD6->BD6_CODPRO) $ (cCodMedGen +';'+ cCodMatGen +';'+ cCodTaxGen +';'+ cCodOpmGen)
										cDescBr8:= BD6->BD6_DESPRO + Space(80)
									Else
										cDescBr8:= BR8->BR8_DESCRI 
									EndIf   						 		
								EndIf

								//Ponto de entrada para efetuar tratamento na descrição							
								If lPL500DESC
									cDescBr8 := ExecBlock("PL500DESC",.F.,.F.,{cDescBr8})
								Endif   

								aadd(aR504,Substr(cDescBr8,1,80))			// 52 Descrição do serviço				 	
								aadd(aR504,Space(1))						// 53 Reservado				 	
								aadd(aR504,cNota)                           // 54 Nro da nota de controle da Unimed    
								aadd(aR504,cHorFim)                         // 55 Hora que foi finalizado o servico
								aadd(aR504,iif(cFatUnd>'100','N',iif(cFatSer<>'100','S','N')))    // 56 Identificador de acréscimo de urgência/emergência
								aadd(aR504,cCBOSExec)                       // 57 Classificação Brasileira de Ocupações do profissional executante
								aadd(aR504,cTecUtil)                        // 58 Técnica utilizada para realização do procedimento   
								aadd(aR504,iif(empty(cDatAut),space(8),cDatAut))   // 59 Data da autorizacao
								aadd(aR504,iif(empty(cDatSol),space(8),cDatSol))   // 60 Data da solicitacao
								aadd(aR504,cCodUnMed)                   	// 61 Codigo da Unidade de Medida
								aadd(aR504,iif(BR8->BR8_TPPROC=='5',cRegAnvis,space(15))) // 62 Número de registro do material na ANVISA
								aadd(aR504,Space(7))                     	// 63 Reservado  						 	
								aadd(aR504,Space(30))                   	// 64 Reservado					 	
								aadd(aR504,iif(empty(cDatPagam),space(8),cDatPagam))// 65 Data do pagamento ao prestador
								aadd(aR504,iif(BR8->BR8_TPPROC=='5',cCnpjFor,replicate("0",14)))// 66 CNPJ do prestador
								aadd(aR504,cCodRecPre)              	    // 67 Código recebido do prestador
								aadd(aR504,cCodRefFab)                      // 68 Código de referência do material no fabricante		
								aadd(aR504,iif(BR8->BR8_TPPROC=='5',cIDPagForn,'0')) // 69 Indicador de pagamento direto ao fornecedor						 	
								aadd(aR504,Space(40))                   	// 70 Reservado	
								aadd(aR504,iif(BR8->BR8_TPPROC=='5',cDetRegAnv,space(50))) // 71 Obrigatório para OPME. Demais casos, preencher com brancos.
								aadd(aR504,iif(BR8->BR8_TPPROC=='5',cNumNFForn,space(20))) // 72 Regra: Obrigatório para ID_PAG_FORN=1						
								aadd(aR504,Space(1))  						// 73 Tipo de Rede conforme Manual do Intercâmbio Nacional								
								aadd(aR504,space(70))                   	// 74 Reservado
								aadd(aR504,cNmExec)							// 75 Nome do profissional executante.
								aadd(aR504,space(10))                   	// 76 Reservado			
								aadd(aR504,iif(BR8->BR8_TPPROC=='5',cPagNomFor ,space(60))) // 77 Nome do Fornecedor do material
								aadd(aR504,space(10))                   // 78 Reservado	

								aadd(aR504,cAvisoIt)                  		// 79 Indicador de aviso RN 430
								aadd(aR504,StrZero(BD7->(RECNO()),20))		// 99 Recno do BD7 para gravar o BD7_SEQ500 ** SEMPRE DEIXAR POR ULTIMO ** 

								aadd(aReg504,aR504)
								nQtd_Ser += nQtdPsa
							Endif

						endIf

					Else
						If !Empty(cPartAgrp)
							aReg504[nPos,8] := cPartAgrp                    // 08 Participacao 
						EndIf
						aReg504[nPos,13] := strzero(val(aReg504[nPos,13]) + (noround(nVlrCob,2)*100),14)        // 13 Valor de Honorario
						aReg504[nPos,14] := strzero(val(aReg504[nPos,14]) + (noround(nVCoCob,2)*100),14)        // 14 Valor de CO
						aReg504[nPos,15] := strzero(val(aReg504[nPos,15]) + (noround(nVFiCob,2)*100),14)	    // 15 Valor de Filme
						aReg504[nPos,22] := strzero(val(aReg504[nPos,22]) + (noround(nTaxAdm,2)*100),14)  		// 22 Taxa de administracao do Servico
						aReg504[nPos,23] := strzero(val(aReg504[nPos,23]) + (noround(nTaxaCo,2)*100),14) 		// 23 Taxa de administracao do CO
						aReg504[nPos,24] := strzero(val(aReg504[nPos,24]) + (noround(nTaxFil,2)*100),14) 	    // 24 Taxa de administracao do Filme
						aReg504[nPos,48] := strzero(val(aReg504[nPos,48]) + (noround(nVlrPag,2)*100),14) 	    // 24 Valor pago ao prestador 
					Endif

					// Totaliza valores para validacao	 do arquivo...
					nTotFat  += nVlrCob
					nTotFat  += nVCoCob
					nTotFat  += nVFiCob
					nTotFat  += If(nTpMov<>"1",nTaxAdm,0)
					nTotFat  += nTaxaCo
					nTotFat  += nTaxFil
					nvalor	 := nTotFat  
					nTot_Ser += noround(nVlrCob,2) 
					nBD7     += (nVlrCob+nVCoCob+nVFiCob+nTaxAdm+nTaxaCo+nTaxFil)

					BD7->(DbSkip())
				Enddo
			EndIf
			
			// Verifica se os valores bateram			
			nDif := round(nBD6,2) - round(nBD7,2)
			If nDif <> 0
				aadd(aLog2,{"   Diferenca entre BD6 e BD7",;
				"BD6: " + alltrim(transform(nbd6,"@E 999,999.99")) + "   BD7: " + alltrim(transform(nBD7,"@E 999,999.99")),;
				"Chave BD7: " + BD6->(BD6_CODOPE+" "+BD6_CODLDP+" "+BD6_CODPEG+" "+BD6_NUMERO+" "+BD6_ORIMOV+" "+BD6_SEQUEN)})
   			    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			Endif
			
			// Processa vetor com registros R504			
			For i := 1 to len(aReg504)
				If nTipEnv == 1 .and. cCodPsa $ "90000021#90000013"
					nPos := aScan(aMatMed,{|x| x[1] == aReg504[i,5]+aReg504[i,6] .and. x[8] == aReg504[i,11] })
					If nPos == 0
						aadd( aMatMed,{ (aReg504[i][05]+aReg504[i][06]),;
						aReg504[i][01]+;
						aReg504[i][02]+;
						aReg504[i][03]+;
						aReg504[i][04]+;
						aReg504[i][05]+;
						aReg504[i][06]+;
						aReg504[i][07]+;
						aReg504[i][08]+;
						aReg504[i][09]+;
						aReg504[i][10]+;
						aReg504[i][11],;
						aReg504[i][12],;
						aReg504[i][13],;
						aReg504[i][14]+;
						aReg504[i][15]+;
						aReg504[i][16]+;
						aReg504[i][17]+;
						aReg504[i][18]+;
						aReg504[i][19]+;
						aReg504[i][20]+;
						aReg504[i][21],;
						aReg504[i][22],;
						aReg504[i][23]+;
						aReg504[i][24]+;
						aReg504[i][25]+;
						aReg504[i][26]+;
						aReg504[i][27]+;
						aReg504[i][28]+;
						aReg504[i][29]+;
						aReg504[i][30]+;
						aReg504[i][31]+;
						aReg504[i][32]+;
						aReg504[i][33]+;
						aReg504[i][34]+;
						aReg504[i][35]+;
						aReg504[i][36]+;
						aReg504[i][37]+;
						aReg504[i][38]+;
						aReg504[i][39]+;
						aReg504[i][40]+;
						aReg504[i][41]+;
						aReg504[i][42]+;
						aReg504[i][43]+;
						aReg504[i][44]+;
						aReg504[i][45]+;
						aReg504[i][46]+;
						aReg504[i][47]+;
						aReg504[i][48]+;
						aReg504[i][49]+;
						aReg504[i][50]+;
						aReg504[i][51]+;
						aReg504[i][52]+;
						aReg504[i][53]+;
						aReg504[i][54]+;
						aReg504[i][55]+;
						aReg504[i][56]+;
						aReg504[i][57]+;
						aReg504[i][58]+;
						aReg504[i][59]+;
						aReg504[i][60]+;
						aReg504[i][61]+;
						aReg504[i][62]+;
						aReg504[i][63]+;
						aReg504[i][64]+;
						aReg504[i][65]+;
						aReg504[i][66]+;
						aReg504[i][67]+; 
						aReg504[i][68]+;
						aReg504[i][69]+;
						aReg504[i][70]+;
						aReg504[i][71]+;
						aReg504[i][72]+;
						aReg504[i][73]+;
						aReg504[i][74]+;
						aReg504[i][75]+;
						aReg504[i][76]+;
						aReg504[i][77],;
						aReg504[i][11],;
						aReg504[i][Len(aReg504[i])]})  
					Else
						aMatMed[nPos][3] := strzero(val(aMatMed[nPos][3]) + val(aReg504[i][12]),8)
						aMatMed[nPos][4] := strzero(val(aMatMed[nPos][4]) + val(aReg504[i][13]),14)
						aMatMed[nPos][6] := strzero(val(aMatMed[nPos][6]) + val(aReg504[i][22]),14)
					Endif
				Else
					
					// Grava R504 do arquivo temporario			
					If nDif <> 0
						Do Case
							Case val(aReg504[i][13]) > 0 .and. (val(aReg504[i][13]) + (nDif * 100) > 0)
								aReg504[i][13] := strzero(val(aReg504[i][13]) + (nDif * 100),14)
								nTot_Ser        += nDif
								nTotFat         += nDif
								nDif            := 0
							Case val(aReg504[i][14]) > 0 .and. (val(aReg504[i][14]) + (nDif * 100) > 0)
								aReg504[i][14] := strzero(val(aReg504[i][14]) + (nDif * 100),14)
								nTotFat         += nDif
								nDif            := 0
							Case val(aReg504[i][15]) > 0 .and. (val(aReg504[i][15]) + (nDif * 100) > 0)
								aReg504[i][15] := strzero(val(aReg504[i][15]) + (nDif * 100),14)
								nTotFat         += nDif
								nDif            := 0
						EndCase
					Endif
					cR504 := ""
					For ii := 1 to len(aReg504[i])						
						cR504 += aReg504[i][ii]
					Next
					R04->(Reclock("R04",.T.))
       				R04->Chave  	:= (cChaNot+"504")
					R04->R504 		:= cR504 
					R04->R504R 		:= aReg504[I,Len(aReg504[I])] 
					R04->(MsUnlock())
					nQtd_504++
					
					If substr(cCodPsa,1,2) $ "80,90"
						If val(aReg504[i][13]) > nMaiMat
							nMaiMat := val(aReg504[i][13])
							nRecMat := R04->(RecNo())
						Endif
					Else
						If val(aReg504[i][13]) > nMaiOut
							nMaiOut := val(aReg504[i][13])
							nRecOut := R04->(RecNo())
						Endif
					Endif
					
				Endif
			Next
		Next
		If cTipNas $ "03,04,05"
			cTipNas := "00"
		EndIf
		
		// Grava R504 do arquivo temporario
		For nPos := 1 to len(aMatMed)
			R04->(Reclock("R04",.T.))
		    R04->Chave := (cChaNot+"504")
			R04->R504  := (aMatMed[nPos][2]+aMatMed[nPos][3]+aMatMed[nPos][4]+aMatMed[nPos][5]+aMatMed[nPos][6]+aMatMed[nPos][7])  
			//If Len(aMatMed[nPos]) > 14 .And. VAL(aMatMed[nPos][15]) > 0
			//	R04->R504R := aMatMed[nPos][15]
			//Else 
				R04->R504R := aMatMed[nPos][9]
			//EndIf
			R04->(MsUnlock())
			nQtd_504++
			If val(aMatMed[nPos][3]) > nMaiMat
				nMaiMat := val(aMatMed[nPos][3])
				nRecMat := R04->(RecNo())
			Endif
		Next
		aMatMed  := {}
		
 	    If lPLS50002
           aRetPto502 := ExecBlock("PLS50002",.F.,.F.,{cCodCid})
           If ValType(aRetPto502) == "A" .And. Len(aRetPto502) >= 1
               cCodCid := aRetPto502[1]
          Endif   
        Endif   
		
		// Verifica se tem algum registro para esta guia		
        If Len(aReg504) == 0
            Loop
        Endif
		
		// Alimenta variavel cR502
		cR502 := Space(8)							// 01 Sequencial
		cR502 += Space(3)							// 02 Tipo de Registro
		cR502 += cLote								// 03 Nro do Lote
		cR502 += Space(11)							// 04 Reservado
	   	cR502 += space(1)    				    	// 05 Reservado
		cR502 += cCodInt							// 06 Codigo da Unimed
		cR502 += space(3)          					// 07 Reservado
		cR502 += (cCodEmp+cMatric+cTipReg+cDigito) 	// 08 Identificacao do Beneficiario
		cR502 += cNomUsr							// 09 Nome
		cR502 += cDtaAte    						// 10 Data de Atendimento
		cR502 += cCodExc							// 11 Codigo da Excessao
		cR502 += space(1)							// 12 Tipo de carater de atendimento - TISS (Novo dominio de valores - 3=pre-natal;4=referencia;5=Urgencia)
		cR502 += Space(2)							// 13 Reservado
		cR502 += cCodCid							// 14 Cid
		cR502 += replicate(" ",14)					// 15 Reservado
		cR502 += cTipPac							// 16 Tipo de Paciente
		cR502 += space(1)							// 17 Reservado
		cR502 += cTpAtend							// 18 Tipo de Atendimento - TISS
		cR502 += Space(11)							// 19 Reservado
		cR502 += cNota                              // 20 Nro da Nota 
		cR502 += padR(cGuiPri,20)                   // 21 Nro Nota Guia Principal  
		cR502 += cDtHrInt                           // 22 Data da internação hospitalar (data inicio faturamento)
		cR502 += cDtHrSai                           // 23 Data da alta (data fim de faturamento)    
      	cR502 += Space(8)                           // 24 Data da ultima autorizacao (Nao tratado no sistema)
       	cR502 += cTipNot                            // 25 Tipo de nota conforme Guias TISS de cobrança   
       	cR502 += cIdNotPri                          // 26 Indicador de Nota Principal, sinalizando que pode ser referenciada 
       	cR502 += cVerTISS                           // 27 Número de versão da TISS que o prestador enviou a cobrança   
       	cR502 += cPrsGuiTis                         // 28 Número da Guia TISS do Prestador 
       	cR502 += cGuiPrTIS                          // 29 Número da Guia TISS Principal  
       	cR502 += Space(20)                          // 30 Número da Guia TISS atribuído pela Operadora 
       	cR502 += cIndAcid                           // 31 Tipo de indicador de acidente.   
       	cR502 += cMotEncer                          // 32 Motivo de encerramento          
       	If cTipNot == "1"
			cR502 += StrZero(0,14)					// 33 Número do CNPJ ou do CPF do prestador requisitante. - TISS
			cR502 += Space(40)						// 34 Nome do prestador requisitante - TISS
			cR502 += Space(12)						// 35 Sigla do Conselho Profissional do prestador requisitante - TISS
			cR502 += Space(15)						// 36 Numero do Conselho Profissional do prestador requisitante - TISS
			cR502 += Space(2)						// 37 Sigla da Unidade Federativa do Conselho Profissional do prestador requisitante - TISS
		Else
			cR502 += cCNPJReq						// 33 Numero do CNPJ ou do CPF do prestador requisitante - TISS			
			cR502 += Space(40)						// 34 Reservado			
			cR502 += cSgConsReq						// 35 Sigla do Conselho Profissional do prestador requisitante - TISS
			cR502 += cNrConsReq						// 36 Numero do Conselho Profissional do prestador requisitante - TISS
			cR502 += cUFConsReq						// 37 Sigla da Unidade Federativa do Conselho Profissional do prestador requisitante - TISS
       	EndIf
		cR502 += cCBOSSol                           // 38 Classificação Brasileira de Ocupações do profissional requisitante  
		
		// Nota Glosada no AJIUS nao implementada ainda, sera alinhada com clientes
		cR502 += Space(11)			     	 		// 39 Reservado   
		cR502 += Space(11)			     	   		// 40 Reservado			      
		cR502 += StrZero(0,8)			     		// 41 Número do lote glosado no Ajius
		cR502 += Space(20)   			     		// 42 Número da nota glosada no Ajius 		
 		cR502 += cDatProtoc                         // 43 Data do protocolo do prestador
		cR502 += cIDRN                              // 44 Indicador de atendimento ao recém-nato
		cR502 += StrZero(0,20)                      // 45 Número do documento 1 Glosado no Ajius
		cR502 += StrZero(0,20)                      // 46 Número do documento 2 Glosado no Ajius
		cR502 += cCarAtend                     		// 47 Tipo de caráter do atendimento
	   	cR502 += cTipCon                      		// 48 Tipo de Consulta		
		cR502 += cGuiJur                   			// 49 Liminar Judicial
	   	cR502 += cTpPeExec                    		// 50 Tipo pessoa contratado executante
	   	cR502 += cCgcExec                    		// 51 CPF/CNPJ contratado executante
	   	cR502 += cCNESExec                    		// 52 CNES contratado executante
	   	cR502 += cCdMunExec                   		// 53 Código Municipio contratado executante

		If cTipNot == "1"
			cR502 += Space(60)					// 54 Nome do prestador requisitante - TISS
		Else
			cR502 += cNomeReq 					// 54 Nome do prestador requisitante - TISS
		EndIf
		cR502 += space(10) 						// 55 Reservado

		cR502 += cTpRedMin							// 56 Tipo de Rede
		cR502 += cAvisoGu							// 57 Indicador de Aviso
		cR502 += cIdHab								// 58 Beneficiario continuado
		cR502 += cLotB5S							// 59 Número do Lote do prestador 
		cR502 += cDtEnv								// 60 Data de Conhecimento do aviso

		cR502 += cNomPre						// 61 Nome do Prestador
		cR502 += space(10)						// 62 Reservado

		cR502 += cTipPre							// 63 Tipo de Prestador
		cR502 += cRecPro							// 64 Prestador Próprio ou contratado
		cR502 += cCD_CIDOBT							// 65 CID		
		
		// Alimenta variavel cR503...
		If cTipGui == "A"
			cR503 := Space(259)
		Else
			If lPLS50003
				ExecBlock("PLS50003",.F.,.F.)
			Endif
			
			cR503 := Space(8)						// 01 Sequencial
			cR503 += Space(3)						// 02 Tipo de Registro
			cR503 += cLote							// 03 Nro do Lote
			cR503 += Space(11)						// 04 Reservado
			cR503 += cUniHos						// 05 Unimed do Hospital
			cR503 += cCodHos						// 06 Codigo do Hospital
			cR503 += Space(25)						// 07 Reservado			
			cR503 += cTipAco						// 08 Tipo de Acomodacao
			cR503 += Space(21)                      // 09 Reservado
			cR503 += Space(21)                      // 10 Reservado
			cR503 += cFatMul			            // 11 Fator Multiplicador			
			cR503 += Space(1)						// 12 Reservado
			cR503 += Space(2)						// 13 Reservado
			cR503 += cCGCHos						// 14 CGC do Prestador
			cR503 += cTipInt						// 15 Tipo de Internacao
        	
        	If !cTipNas $ "00,01,02,03,04,05,06,07,08,09,10,11,12"
        	    cTipNas := "00"
        	Endif

        	cR503 += space(2)						// 16 Reservado 

			cR503 += space(17)					// 17 Tipo de faturamento da conta hospitalar.
			cR503 += cTP_FATURA					// 18 Tipo de faturamento da conta hospitalar.

			cR503 += space(6)								// 19 Reservado
			cR503 += space(7)								// 20 Reservado
			cR503 += cNR_VIVO1								// 21 Número da declaração de nascimento.
			cR503 += cNR_VIVO2								// 22 Número da declaração de nascimento.
			cR503 += cNR_VIVO3								// 23 Número da declaração de nascimento.
			cR503 += cNR_VIVO4								// 24 Número da declaração de nascimento.
			cR503 += cNR_VIVO5								// 25 Número da declaração de nascimento.
			cR503 += space(1)				    			// 26 Reservado

			If !Empty(cCD_CIDOBT) .And. Empty(cNR_DECOBT)
				aadd(aLog2,{" Numero da declaracao de obito - Obrigatorio se campo CD_CID_OBITO preenchido: " + cTipNas,"Chave BE4: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)})
			    PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
			    cR503 +=  Space(17)	 							// 27 Número da declaração de óbito.
		    Else
			    cR503 +=  Padr(cNR_DECOBT,17)					// 27 Número da declaração de óbito.
		    Endif
		        
		    If Val(cQtObiPre)>0 .Or. Val(cQtObiTar)>0
		    	cR503 += cCD_CIDOBT // CD_CID_OBITO_1          // 28 Número do Código Internacional da Doença.        
		    Else
		    	cR503 += Space(6) // CD_CID_OBITO_1            // 28 Número do Código Internacional da Doença. 
		    EndIf                 
		    
		    cR503 += Space(6) // CD_CID_OBITO_2                // 29 Número do Código Internacional da Doença.              
		    cR503 += Space(6) // CD_CID_OBITO_3                // 30 Número do Código Internacional da Doença. 
		    cR503 += Space(6) // CD_CID_OBITO_4                // 31 Número do Código Internacional da Doença. 
		    cR503 += Space(6) // CD_CID_OBITO_5		           // 32 Número do Código Internacional da Doença.                                    
		
		    If Val(cQtObiPre)>0 .Or. Val(cQtObiTar)>0
		    	cR503 += Padr(cNR_DECOBT,17) // NR_DECLARA_OBITO_1 // 33 Número da declaração de óbito do RN.                  
		    Else
		    	cR503 += Space(17) // NR_DECLARA_OBITO_1           // 33 Número da declaração de óbito do RN.
		    EndIf                 
							    
   		    cR503 += Space(17) // NR_DECLARA_OBITO_2        	// 34 Número da declaração de óbito do RN.                 
		    cR503 += Space(17) // NR_DECLARA_OBITO_3        	// 35 Número da declaração de óbito do RN.
		    cR503 += Space(17) // NR_DECLARA_OBITO_4        	// 36 Número da declaração de óbito do RN.
		    cR503 += Space(17) // NR_DECLARA_OBITO_5    	   	// 37 Número da declaração de óbito do RN.    
		    cR503 += cNota                                     	// 38 Número da nota de controle da Unimed      
		    cR503 += cTpRegInt                                 	// 39 Regime de Internação
		    cR503 += cNomMedAud                                	// 40 Nome do médico que auditou a conta hospitalar na executora 
		    cR503 += cRegMedAud                                	// 41 Número do CRM do médico que auditou a conta hospitalar na executora   
		    cR503 += cNomEnfAud                                	// 42 Nome do enfermeiro que auditou a conta hospitalar na executora
		    cR503 += cRegEnfAud                                	// 43 Número do COREN do enfermeiro que auditou a conta hospitalar na executora
		    cR503 += cUFMedAud                                 	// 44 Código da Unidade Federativa do CRM do médico que auditou a conta hospitalar na executora
		    cR503 += cUFEnfAud                                 	// 45 Código da Unidade Federativa do COREN do enfermeiro que auditou a conta hospitalar na executora		   

			cR503 += cNomHos								// 46 Nome do Hospital
							
			nQtd_503++
		Endif
		
		// Grava R502 do arquivo temporario		
		R02->(Reclock("R02",.T.))
	    R02->Chave := (cChaNot+"502")
		R02->R502  := cR502
		R02->(MsUnlock())
		nQtd_502++
		If cCodExc <> "0"
			nNot_Exc++
		Endif		
		
		// Grava R503 do arquivo temporario
		R03->(Reclock("R03",.T.))
	    R03->Chave := (cChaNot+"503")
		R03->R503  := cR503
		R03->(MsUnlock())		
		
		If cAliCab == "BE4"
			cChvBZC:= &(cAliCab+"->"+cAliCab+"_FILIAL")+&(cAliCab+"->"+cAliCab+"_CODOPE")+&(cAliCab+"->"+cAliCab+"_CODLDP")+&(cAliCab+"->"+cAliCab+"_CODPEG")+&(cAliCab+"->"+cAliCab+"_NUMERO")
		Else
			cChvBZC:= &(cAliCab+"->"+cAliCab+"_FILIAL")+&(cAliCab+"->"+cAliCab+"_OPEMOV")+&(cAliCab+"->"+cAliCab+"_CODLDP")+&(cAliCab+"->"+cAliCab+"_CODPEG")+&(cAliCab+"->"+cAliCab+"_NUMERO")
		EndIf	
		cIndCli :=alltrim(&(cAliCab+"->"+cAliCab+"_INDCLI")) + alltrim(&(cAliCab+"->"+cAliCab+"_INDCL2"))

		if cTipGui == 'I' .and. empty(cIndCli)
			aAreaBE4 := BE4->(GetArea())
			If BE4->(DbSeek(xFilial("BE4")+BE4->BE4_GUIINT))  
				cIndCli := alltrim(BE4->BE4_INDCLI) +  alltrim(" " + BE4->BE4_INDCL2)
			EndIf
			RestArea(aAreaBE4)	
		endif

		BZC->(DbSetOrder(1))
		If BZC->(MsSeek(xFilial("BZC")+cChvBZC))
			cIndObs := alltrim(BZC->BZC_OBSNO1)+ alltrim(BZC->BZC_OBSNO2)
			cIndJus := alltrim(BZC->BZC_JUSTE1)+ alltrim(BZC->BZC_JUSTE2)+ alltrim(BZC->BZC_JUSTE3)+ alltrim(BZC->BZC_JUSTE4)
			cIndEsp := alltrim(BZC->BZC_ESMAT1)+ alltrim(BZC->BZC_ESMAT2)+ alltrim(BZC->BZC_ESMAT3)+ alltrim(BZC->BZC_ESMAT4)
		EndIf	

		If alltrim(cTpAtend) $ '02/03/08/09/10' 
			If Empty(cIndCli)
				cR505 := Space(8)						    // 01 Sequencial
				cR505 += Space(3)						    // 02 Tipo de Registro
				cR505 += cLote							    // 03 Nro do Lote
				cR505 += Space(11)		    			    // 04 Reservado
				cR505 += '1'						        // 05 Tipo de registro
				cR505 += padr("INDICACAO NAO INFORMADA",100)// 06 Descrição do complemento da nota.			
				cR505 += cNota                              // 07 Nro da Nota 
				cR505 += Space(500)                         // 08 Especificação do material solicitado
				
				R05->(Reclock("R05",.T.))
			    R05->Chave := (cChaNot+"505")
				R05->R505  := cR505
				R05->(MsUnlock())
				nQTD_505++
			EndIf	
		EndIf

		If !Empty (cIndCli)
			cTpReg := '1'
			While !Empty(PlRetponto(cIndCli))
				cR505 := Space(8)						  // 01 Sequencial
				cR505 += Space(3)						  // 02 Tipo de Registro
				cR505 += cLote							  // 03 Nro do Lote
				cR505 += Space(11)		    			  // 04 Reservado
				cR505 += cTpReg						      // 05 Tipo de registro
				cR505 += padr(subs(PlRetponto(cIndCli),1,100),100)	// 06 Descrição do complemento da nota.			
				cR505 += cNota                            // 07 Nro da Nota 
				cR505 += Space(500)                       // 08 Especificação do material solicitado
				
				R05->(Reclock("R05",.T.))
			    R05->Chave := (cChaNot+"505")
				R05->R505  := cR505
				R05->(MsUnlock())
				nQTD_505++
				cIndCli := subs(cIndCli,101,Len(alltrim(&(cAliCab+"->"+cAliCab+"_INDCLI"))+alltrim(&(cAliCab+"->"+cAliCab+"_INDCL2"))))// vai ate o tamanho dos campos 
			Enddo
		EndIf

		If !Empty (cIndObs)
			cTpReg := '2'
			While !Empty(PlRetponto(cIndObs))
				cR505 := Space(8)						  // 01 Sequencial
				cR505 += Space(3)						  // 02 Tipo de Registro
				cR505 += cLote							  // 03 Nro do Lote
				cR505 += Space(11)		    			  // 04 Reservado
				cR505 += cTpReg						      // 05 Tipo de registro
				cR505 += padr(subs(PlRetponto(cIndObs),1,100),100)	// 06 Descrição do complemento da nota.			
				cR505 += cNota                            // 07 Nro da Nota 
				cR505 += Space(500)                       // 08 Especificação do material solicitado
				
				R05->(Reclock("R05",.T.))
			    R05->Chave := (cChaNot+"505")
				R05->R505  := cR505
				R05->(MsUnlock())
				nQTD_505++
				cIndObs := subs(cIndObs,101,LEN(alltrim(BZC->BZC_OBSNO1+BZC->BZC_OBSNO2)))// vai ate o tamanho dos campos 
			Enddo
		EndIf

		If !Empty (cIndJus)
			cTpReg := '3'
			While !Empty(PlRetponto(cIndJus))
				cR505 := Space(8)						  // 01 Sequencial
				cR505 += Space(3)						  // 02 Tipo de Registro
				cR505 += cLote							  // 03 Nro do Lote
				cR505 += Space(11)		    			  // 04 Reservado
				cR505 += cTpReg						      // 05 Tipo de registro
				cR505 += padr(subs(PlRetponto(cIndJus),1,100),100)	// 06 Descrição do complemento da nota.			
				cR505 += cNota                            // 07 Nro da Nota 
				cR505 += Space(500)                       // 08 Especificação do material solicitado
				
				R05->(Reclock("R05",.T.))
			    R05->Chave := (cChaNot+"505")
				R05->R505  := cR505
				R05->(MsUnlock())
				nQTD_505++
				cIndJus := subs(cIndJus,101,LEN(alltrim(BZC->BZC_JUSTE1+BZC->BZC_JUSTE2+BZC->BZC_JUSTE3+BZC->BZC_JUSTE4)))
			Enddo
		EndIf

		If !Empty (cIndEsp)
			cTpReg := '4'
			While !Empty(PlRetponto(cIndEsp))
				cR505 := Space(8)						  // 01 Sequencial
				cR505 += Space(3)						  // 02 Tipo de Registro
				cR505 += cLote							  // 03 Nro do Lote
				cR505 += Space(11)		    			  // 04 Reservado
				cR505 += cTpReg						      // 05 Tipo de registro
				cR505 += padr(subs(PlRetponto(cIndEsp),1,100),100)	// 06 Descrição do complemento da nota.			
				cR505 += cNota                            // 07 Nro da Nota 
				cR505 += Space(500)                       // 08 Especificação do material solicitado
				
				R05->(Reclock("R05",.T.))
			    R05->Chave := (cChaNot+"505")
				R05->R505  := cR505
				R05->(MsUnlock())
				nQTD_505++
				cIndEsp := subs(cIndEsp,101,LEN(alltrim(BZC->BZC_ESMAT1+BZC->BZC_ESMAT2+BZC->BZC_ESMAT3+BZC->BZC_ESMAT4)))
			Enddo
		EndIf				
		
	Enddo
	
	If lR506
		cR506 := Space(8)						    // 01 Sequencial
		cR506 += Space(3)						    // 02 Tipo de Registro
		cR506 += cNumDocNFE     				    // 03 Numero da nota fiscal eletronica do documento
		cR506 += cLinkNFE			                // 04 Link para Nota Fiscal Eletronica do documento
		
		R06->(Reclock("R06",.T.))
		R06->R506  := cR506
		R06->(MsUnlock())
	EndIf			
	
	// Coloca diferenca em mat/med	
	If GetNewPar("MV_PLATUER","1") == "1"
		If nTotFat <> nValor
			If nRecMat <>  0 .or. nRecOut <> 0
				If nRecMat <>  0
					R04->(dbGoTo(nRecMat))
				Else
					R04->(dbGoTo(nRecOut))
				Endif
				nDif := noround(noround(nValor * 100,0) - noround(nTotFat * 100,0),0)
				nVlr := val(substr(R04->R504,109,14))
				If (nVlr + nDif) >= 0
					nTotFat  += nDif / 100
					nTot_Ser += nDif / 100
					nVlr     += nDif
					R04->(Reclock("R04",.F.))   
					cR04 := R04->R504
					R04->R504  := substr(cR04,1,108) + strzero(nVlr,14) + substr(cR04,123,573)
					R04->(MsUnlock())
				Endif
			Endif
		Endif                               
	Elseif nTotFat <> nValor
		aadd(aLog1,{"Erro - diferenca encontrada","Oper: " + cOpeOriBTO+ "   Titulo: " + cPrefixoBTO + " " + cNumTitBTO,"Movimento:  "+ alltrim(transform(nTotFat,"@E 999,999,999.99")) + "   Fatura:  "+alltrim(transform(nValor,"@E 999,999,999.99"))})
   	    PlsLogFil(Space(03)+aLog1[Len(aLog1),1]+Space(03)+aLog1[Len(aLog1),2]+Space(03)+aLog1[Len(aLog1),3],"LOG500.TXT")
   	    if( select( "R02" ) > 0 )
			oTempR02:delete()
		endIf
		
   	    if( select( "R03" ) > 0 )
			oTempR03:delete()
		endIf

   	    if( select( "R04" ) > 0 )
			oTempR04:delete()
		endIf

   	    if( select( "R05" ) > 0 )
			oTempR05:delete()
		endIf		
		
		if( select( "R06" ) > 0 )
			oTempR06:delete()
		endIf		
		
	   	if( select( "R08" ) > 0 )
			oTempR08:delete()
		endIf			 	            
		
		TMP->(DBCloseArea()) 
		If len(aLog1) > 0 .or. len(aLog2) > 0
			If len(aLog1) > 0
				For i := 1 to len(aLog1)
					aadd(aLog,aLog1[i])
				Next
			Endif
			If len(aLog2) > 0
				For i := 1 to len(aLog2)
					aadd(aLog,aLog2[i])
				Next
			Endif
			aadd(aLog,{"","",""})
		Endif
		MsgStop("O Arquivo não foi gerado devido a falhas de arredondamento.")
   	    Return
	Endif
	If nTotFat <> nValor
		aadd(aLog1,{"Erro - diferenca encontrada","Oper: " + cOpeOriBTO+ "   Titulo: " + cPrefixoBTO + " " + cNumTitBTO,"Movimento:  "+ alltrim(transform(nTotFat,"@E 999,999,999.99")) + "   Fatura:  "+alltrim(transform(nValor,"@E 999,999,999.99"))})
   	    PlsLogFil(Space(03)+aLog1[Len(aLog1),1]+Space(03)+aLog1[Len(aLog1),2]+Space(03)+aLog1[Len(aLog1),3],"LOG500.TXT")
	Endif 
	
	If Existblock("PL500FAT")	
		Execblock("PL500FAT",.f.,.f.,{})
	Endif         
	
	R02->(DbGoTop())	    
	If !R02->(EOF())
		PTULn("501",.T.)
		PlsPTU(PadR(cCodLay, 6),cArqNom,cDirNov,.F.)
		// Devido a separaçõa da medicina Assistencial da ocupacional do envio dos arquivos d
		aadd(aLog1,{"Arquivo gerado ","Oper: " + cOpeOriBTO + "   Titulo: " + cPrefixoBTO + " " + cNumTitBTO,"Movimento:  "+ alltrim(transform(nTotFat,"@E 999,999,999.99")) + "   Fatura:  "+alltrim(transform(nTotFat,"@E 999,999,999.99"))})
	    PlsLogFil(Space(03)+aLog1[Len(aLog1),1]+Space(03)+aLog1[Len(aLog1),2]+Space(03)+aLog1[Len(aLog1),3],"LOG500.TXT")
	Endif
	
	// Verifica se existe log de ocorrencias	
	If len(aLog1) > 0 .or. ;
		len(aLog2) > 0
		If len(aLog1) > 0
			For i := 1 to len(aLog1)
				aadd(aLog,aLog1[i])
			Next
		Endif
		If len(aLog2) > 0
			For i := 1 to len(aLog2)
				aadd(aLog,aLog2[i])
			Next
		Endif
		aadd(aLog,{"","",""})
	Endif
	
	if( select( "R02" ) > 0 )
		oTempR02:delete()
	endIf
	
	if( select( "R03" ) > 0 )
		oTempR03:delete()
	endIf
	
	if( select( "R04" ) > 0 )
		oTempR04:delete()
	endIf
	
	if( select( "R05" ) > 0 )
		oTempR05:delete()
	endIf
	
	if( select( "R06" ) > 0 )
		oTempR06:delete()
	endIf
	
	if( select( "R07" ) > 0 )
		oTempR07:delete()
	endIf
	
	if( select( "R08" ) > 0 )
		oTempR08:delete()
	endIf
	
Endif

TMP->(DBCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA500Enviado
Verifica se o arquivo ja foi enviado

@author  PLS TEAM
@version P12
@since   08/10/2004
/*/
//-------------------------------------------------------------------
Function PLSA500Enviado(cUnimed, cNumero, cInterc)

BTO->(DbGoTop())   
BTO->(DbSetOrder(1))

If  BTO->(MsSeek(xFilial("BTO")+cUnimed+cNumero+cInterc))
	BTO->(Reclock("BTO",.F.))
	BTO->BTO_ENV500 := "1"
	BTO->(MsUnlock())
Else
	MsgAlert("Erro ao marcar fatura como enviada. Fatura de Intercambio nao Encontrada! - "+cUnimed + cNumero)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRSCon
Retorna String para verificar se procedimento eh Consulta

@author  PLS TEAM
@version P12
@since   08/10/2004
/*/
//-------------------------------------------------------------------
Function PLSRSCon()

Local aConsultas := {AllTrim(GETMV("MV_PLSCDCO"))}
Local cRet1 := ""
Local cRet2 := ""
Local nFor  := 0
Local aRet  := {}

If ExistBlock("PLSISCON")
	aRet := ExecBlock("PLSISCON",.F.,.F.)
	For nFor := 1 To Len(aRet)
		aadd(aConsultas,aRet[nFor])
	Next
Endif

For nFor := 1 To Len(aConsultas)
	cRet1 += Subs(aConsultas[nFor],1,2)+","
	cRet2 += AllTrim(Subs(aConsultas[nFor],3,16))+","
Next

Return({cRet1,cRet2})

Function ValR11()
Local lRetorno

    If R11->(Eof())
	   	lRetorno := .F.
    Else
	   	lRetorno := .T.
    Endif
    
Return lRetorno


//-------------------------------------------------------------------
/*/{Protheus.doc} GeraNumSeq504
Grava o codigo sequcncial da exportacao e para o tratamento do ptu a550 ajius 

@author  PLS TEAM
@version P12
@since   27/03/2012
/*/
//-------------------------------------------------------------------
Function GeraNumSeq504()  

Local cSeq	:= ""
Local nRec	:= 0  
Local cTexto:= Alltrim(R04->R504R)

cSeq	:= PTULN("R504")

nRec := Val(cTexto)

BD7->(DbGoTo(nRec))
BD7->(RecLock("BD7",.F.)) 
BD7->BD7_SEQ500:=cSeq
BD7->(MsUnlock())

return cSeq 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLQTA500TO
Trata o totalizador de eventos para gerar o R509

@author  PLS TEAM
@version P12
@since   16/11/2013
/*/
//-------------------------------------------------------------------
Function PLQTA500TO(nQtd)  
Local cRet     := ''    
Local cDecItem := ''

cDecItem := cValToChar(nQtd - Int(nQtd)) 
cDecItem := Padr(Substr(cDecItem,3,len(cDecItem)),4,"0")
cRet := Strzero(int(nQtd),7)+cDecItem							    
							    
Return(cRet) 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLDeParINT
Verifica a vigencia do De/Para CODEDI 

@author  PLS TEAM
@version P12
@since   03/06/2014
/*/
//-------------------------------------------------------------------
Function PLDeParINT(cCodPad,cCodPsa,dDatPro,lFind,cTpSeek) 
Local cRet      := cCodPsa  
Local aAreaBR8  := BR8->(GetArea())
Default cTpSeek := "E"
Default lFind   := .F.

// cTpSeek - "E" -> Envio (busca por CodPad+CodPsa)                      
//           "R" -> Recebimento (busca por CodEdi)                     
    
If cTpSeek == "E" 
	B1M->(DbSetOrder(1))//B1M_FILIAL+B1M_CODPAD+B1M_CODPSA	
	If B1M->(DbSeek(xFilial("B1M")+cCodPad+cCodPsa))
		While xFilial("B1M")+cCodPad+Alltrim(cCodPsa) == B1M->(B1M_FILIAL+B1M_CODPAD)+Alltrim(B1M->B1M_CODPSA) .And. !B1M->(Eof())
			If B1M->B1M_ATIVO == "1" .And. dDatPro >= B1M->B1M_DATINI .And. (Empty(B1M->B1M_DATFIN) .Or. dDatPro <= B1M->B1M_DATFIN) 
				cRet := B1M->B1M_CODEDI
				lFind := .T.
				Exit
			EndIf	
			B1M->(DbSkip())
	    EndDo
	EndIf	
	If !lFind  
		BR8->(DbSetOrder(1))
		BR8->(DbSeek(xFilial("BR8")+cCodPad+cCodPsa))  
		If !Empty(BR8->BR8_CODEDI)
			cRet  := BR8->BR8_CODEDI 
			lFind := .T.
		EndIf
	EndIf	
ElseIf cTpSeek == "R"   
	B1M->(DbSetOrder(2))//B1M_FILIAL+B1M_CODEDI
	If B1M->(DbSeek(xFilial("B1M")+cCodPsa))
		While xFilial("B1M")+Alltrim(cCodPsa) == B1M->B1M_FILIAL+Alltrim(B1M->B1M_CODEDI) .And. !B1M->(Eof())
			If B1M->B1M_ATIVO == "1" .And. dDatPro >= B1M->B1M_DATINI .And. (Empty(B1M->B1M_DATFIN) .Or. dDatPro <= B1M->B1M_DATFIN) 
				cRet := B1M->B1M_CODPSA
				lFind := .T.
				Exit
			EndIf	
			B1M->(DbSkip())
	    EndDo
	EndIf
EndIf

RestArea(aAreaBR8)
Return(Alltrim (cRet))

//-------------------------------------------------------------------
/*/{Protheus.doc} PLDeParINT
Verifica o codigo da Operadora para saber se manda ou nao o IRRF no A500   Campo VL_IR 

@author  PLS TEAM
@version P12
@since   23/12/2014
/*/
//-------------------------------------------------------------------
Static Function VerifIRRF(cOutOP)  

Local   cTipUn   := ""
Local   cMinOp   := PLSINTPAD()
Local   cTipMUn  := ""
Local   lEnvIr   := .F.
Default cOutOP   := "" 

aAreaBA0 := BA0->(GetArea())
DbSelectArea("BA0")
DbSetOrder(1)//BA0_FILIAL+BA0_CODIDE+BA0_CODINT 

If	!Empty (cOutOP)
	If BA0->(DbSeek(xFilial("BA0")+cOutOP))
          
        // verifico em qual range esta a operadora que estou gerando o Lote.   	
		Do Case
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0600"
				cTipUn := "1"     //Singulares
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0601" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0650"
				cTipUn := "2"      //Seccionais
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0651" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0850"
				cTipUn := "3"      //Entidades Internacionais
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0851" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0949"
			    cTipUn := "4"      // Intrafederativas     
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0990"
			    cTipUn := "5"      // Interfederativas/Federação
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0991" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0998"
			    cTipUn := "6"      //Empresas do Complexo (Seguradora,UAS,etc.)
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT == "0999"
			    cTipUn := "7"      //Confederação Nacional
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1600"
			    cTipUn := "8"      //Singulares Unicred
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1990"
			    cTipUn := "9"      //Centrais Unicred
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT == "1999"
			    cTipUn := "10"      //Confederação Unicred
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "2001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "2999"
			    cTipUn := "11"      //Usimeds
					
			Otherwise
				cTipUn := "1"
			Endcase
		RestArea(aAreaBA0)    

	EndIf
Endif

If	!Empty (cMinOp)
	If BA0->(DbSeek(xFilial("BA0")+cMinOp))
          
        // verifico em qual range esta a minha operadora.   	
		Do Case
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0600"
				cTipMUn := "1"     //Singulares
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0601" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0650"
				cTipMUn := "2"      //Seccionais
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0651" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0850"
				cTipMUn := "3"      //Entidades Internacionais
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0851" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0949"
			    cTipMUn := "4"      // Intrafederativas     
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0990"
			    cTipMUn := "5"      // Interfederativas/Federação
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "0991" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "0998"
			    cTipMUn := "6"      //Empresas do Complexo (Seguradora,UAS,etc.)
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT == "0999"
			    cTipMUn := "7"      //Confederação Nacional
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1600"
			    cTipMUn := "8"      //Singulares Unicred
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "1950" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "1990"
			    cTipMUn := "9"      //Centrais Unicred
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT == "1999"
			    cTipMUn := "10"      //Confederação Unicred
			Case BA0->BA0_CODIDE+BA0->BA0_CODINT >= "2001" .And. BA0->BA0_CODIDE+BA0->BA0_CODINT <= "2999"
			    cTipMUn := "11"      //Usimeds
					
			Otherwise
				cTipMUn := "1"
			Endcase
		RestArea(aAreaBA0)    

	EndIf
Endif

If !Empty (cTipMUn) .And. !Empty (cTipUn)
	If cTipMUn <> cTipUn
		lEnvIr := .T. 
	Endif
Endif

return (lEnvIr)

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraR507 
Gera registro R507 - Reembolso

@author  TOTVS
@version P11
@since   01/10/15
/*/
//-------------------------------------------------------------------
Static Function GeraR507(cCodOpeBTO,cOpeOriBTO,cAnoIniBTO,cMesIniBTO,cPrefixoBTO,cNumTitBTO,dVencSE1,dEmisSE1,cArqNom,cDirNov,nTpMov) 
Local cR507      := ""  
Local cR508      := ""  
Local cAnoMesAnt := ""
Local aStru502   := {}
Local aStru503   := {}
Local aStru504   := {}
Local aStru505   := {}     
Local aStru506   := {}     
Local aStru507   := {} 
Local aStru508   := {} 
Local i          := 0
Local ii         := 0       
Local nTotFat    := 0
Local aR507      := {}
Local aR508      := {}
Local aReg507    := {} 
Local aReg508    := {}   
Local lFounDePar := .F.
Local lDeParaBTU := GetNewPar("MV_PLAJBTU","0") == "1"
Local cSql     	 := ""
Local cTipGui    := ""
Local cNota      := ""
Local cUniPre    := ""
Local cNot       := ""     
Local cNomUsr    := ""
Local cSexo      := ""
Local cDatNas    := ""
Local cIDRN      := ""
Local cDatPro    := ""
Local cDatReemb  := ""
Local cCarAtend  := "" 
Local cCNPJPre   := ""
Local cNomPrest  := ""  
Local cNomeProf  := ""
Local cSiglaCon  := ""
Local cNumConPro := ""
Local cUFConsPro := ""
Local cCodPsa    := ""
Local cQtdPsa    := ""   
Local cVlrDifenc := ""
Local cVlrSerCob := ""
Local cNumAut    := ""
Local cTipTab	 := ""
Local cTipPar	 := ""
Local cParBD7	 := ""
Local cNotaAnt	 := ""
local cTipCodifi := ""
            
private nQTD_502 := 0
private nQTD_503 := 0
private nQTD_504 := 0
private nQTD_505 := 0
private nQTD_507 := 0
private nQTD_508 := 0
private nNOT_EXC := 0
private nQTD_SER := 0
private nTOT_SER := 0
private nNOT_AMB := 0

private cUniDes  := ""
private cCompet  := ""  
private cNumDoc1 := ""
private cTipDoc1 := "1"
private cTipDoc2 := "0"
private dDatBas  := dDatabase  
private dDatVen  
private dDatEmi   

// Cria arquivo temporario 502
aadd(aStru502,{"Chave","C",022,0})
aadd(aStru502,{"R502" ,"C",589,0})
	
//--< Criação do objeto FWTemporaryTable >---
oTempR02 := FWTemporaryTable():New( "R02" )
oTempR02:SetFields( aStru502 )
oTempR02:AddIndex( "INDR02",{ "CHAVE" } )

if( select( "R02" ) > 0 )
	R02->( dbCloseArea() )
endIf

oTempR02:Create()
dbSelectArea( "R02" )
R02->( dbSetorder( 1 ) )
	

// Cria arquivo temporario 503
aadd(aStru503,{"Chave","C",022,0})
aadd(aStru503,{"R503" ,"C",579,0})
	
//--< Criação do objeto FWTemporaryTable >---
oTempR03 := FWTemporaryTable():New( "R03" )
oTempR03:SetFields( aStru503 )
oTempR03:AddIndex( "INDR03",{ "CHAVE" } )

if( select( "R03" ) > 0 )
	R03->( dbCloseArea() )
endIf

oTempR03:Create()
dbSelectArea( "R03" )
R03->( dbSetorder( 1 ) )
	

// Cria arquivo temporario 504
aadd(aStru504,{"Chave","C",022,0})
aadd(aStru504,{"R504" ,"C",1082,0})//Tamanho maximo do Layout + 20 Caracteres do RECNO
aadd(aStru504,{"R504R","C",020,0})

//--< Criação do objeto FWTemporaryTable >---
oTempR04 := FWTemporaryTable():New( "R04" )
oTempR04:SetFields( aStru504 )
oTempR04:AddIndex( "INDR04",{ "CHAVE" } )

if( select( "R04" ) > 0 )
	R04->( dbCloseArea() )
endIf

oTempR04:Create()
dbSelectArea( "R04" )
R04->( dbSetorder( 1 ) )

// Cria arquivo temporario 505
aadd(aStru505,{"Chave","C",022,0})
aadd(aStru505,{"R505" ,"C",151,0})
	
//--< Criação do objeto FWTemporaryTable >---
oTempR05 := FWTemporaryTable():New( "R05" )
oTempR05:SetFields( aStru505 )
oTempR05:AddIndex( "INDR05",{ "CHAVE" } )

if( select( "R05" ) > 0 )
	R05->( dbCloseArea() )
endIf

oTempR05:Create()

dbSelectArea( "R05" )
R05->( dbSetorder( 1 ) )

// Cria arquivo temporario 506
aadd(aStru506,{"Chave","C",022,0})
aadd(aStru506,{"R506" ,"C",151,0})
	
//--< Criação do objeto FWTemporaryTable >---
oTempR06 := FWTemporaryTable():New( "R06" )
oTempR06:SetFields( aStru506 )
oTempR06:AddIndex( "INDR06",{ "CHAVE" } )

if( select( "R06" ) > 0 )
	R06->( dbCloseArea() )
endIf

oTempR06:Create()

dbSelectArea( "R06" )
R06->( dbSetorder( 1 ) )

// Cria arquivo temporario 507
aadd(aStru507,{"Chave","C",022,0})
aadd(aStru507,{"R507" ,"C",226,0})  
aadd(aStru507,{"R507R","C",020,0})
	
//--< Criação do objeto FWTemporaryTable >---
oTempR07 := FWTemporaryTable():New( "R07" )
oTempR07:SetFields( aStru507 )
oTempR07:AddIndex( "INDR07",{ "CHAVE" } )

if( select( "R07" ) > 0 )
	R07->( dbCloseArea() )
endIf

oTempR07:Create()

dbSelectArea( "R07" )
R07->( dbSetorder( 1 ) )

//Cria arquivo temporario 508
aadd(aStru508,{"Chave","C",022,0})
aadd(aStru508,{"R508" ,"C",332,0})  
 	
//--< Criação do objeto FWTemporaryTable >---
oTempR08 := FWTemporaryTable():New( "R08" )
oTempR08:SetFields( aStru508 )
oTempR08:AddIndex( "INDR08",{ "CHAVE" } )

if( select( "R08" ) > 0 )
	R08->( dbCloseArea() )
endIf

oTempR08:Create()

dbSelectArea( "R08" )
R08->( dbSetorder( 1 ) )

// Variaveis 501
cUniDes    := cOpeOriBTO    
cCompet    := substr(cAnoMesAnt,3,2) + substr(cAnoMesAnt,5,2)
cAnoMesAnt := cAnoIniBTO+cMesIniBTO
cCompet    := substr(cAnoMesAnt,3,2) + substr(cAnoMesAnt,5,2)
dDatVen    := dVencSE1    
dDatEmi    := dEmisSE1  
cNumDoc1   := Padr(cPrefixoBTO+cNumTitBTO,20)  
cNumDoc2 := Space(20)
cTipDoc2 := "0"

BKC->(dbSetOrder(1))//BKC_FILIAL + BKC_CODIGO + BKC_CODOPE + BKC_CODPAR
BDR->(dbSetOrder(1))//BDR_FILIAL + BDR_CODOPE + BDR_CODTAD      
B44->(dbSetOrder(1))//B44_FILIAL + B44_OPEMOV + B44_ANOAUT + B44_MESAUT + B44_NUMAUT
BK6->(dbSetOrder(3))//BK6_FILIAL + BK6_CODIGO

// Monta query principal com os registro de intercambio Anestesista...
cSql := " SELECT BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN, BD6_VLRPAG, BD6_VLRBPR, BD5.R_E_C_N_O_ "
cSql += " FROM "+RetSqlName("BD6")+" BD6 "
cSql += " INNER JOIN "+RetSqlName("BD5")+" BD5 " 
cSql += " ON  BD5.BD5_FILIAL = BD6.BD6_FILIAL " 
cSql += " AND BD5.BD5_CODOPE = BD6.BD6_CODOPE " 
cSql += " AND BD5.BD5_CODLDP = BD6.BD6_CODLDP " 
cSql += " AND BD5.BD5_CODPEG = BD6.BD6_CODPEG " 
cSql += " AND BD5.BD5_NUMERO = BD6.BD6_NUMERO " 
cSql += " AND BD5.BD5_CODLDP = '"+GetNewPar("MV_PLSPREM","9000")+"' " 
cSql += " AND BD5.BD5_PRE507 = '"+BTO->BTO_PREFIX+"'" 
cSql += " AND BD5.BD5_NUM507 = '"+BTO->BTO_NUMTIT+"'" 
cSql += " AND BD5.BD5_PAR507 = '"+BTO->BTO_PARCEL+"'" 
cSql += " AND BD5.BD5_TIP507 = '"+BTO->BTO_TIPTIT+"'"   
cSql += " AND BD5.BD5_REEANE = '1' "
cSql += " AND BD5.BD5_ENV507 = '1' "
cSql += " AND BD5.D_E_L_E_T_ <> '*' "
cSql += " WHERE BD6_FILIAL = '"+xFilial("BD6")+"' "
cSql += " AND BD6_CODOPE = '"+PlsIntPad()+"' "
cSql += " AND BD6_BLOCPA <> '1' " 
cSql += " AND BD6.D_E_L_E_T_ <> '*' " 
cSql += " ORDER BY BD6_FILIAL, BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_ORIMOV, BD6_SEQUEN"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cSQL), "TMP", .F., .T.)      

TMP->(DbGoTop())

If TMP->(EOF())
	MsgInfo("Não foram encontrados registros para exportação. Contate o administrador do sistema.")
Endif

While !TMP->(EOF())
	
	// Rodo guias com evento de reembolso de anestesista	   
	aLog1 	   := {}
	aLog2 	   := {}
	cTipGui    := Space(1)
	cDatNas    := Space(8)
	cSexo      := Space(1)  
	cCarAtend  := Space(1) 
	cTipPes    := Space(1)   
	cCNPJPre   := Replicate("0",14)  
	lFounDePar := .F.
	cNomPrest  := Space(70)    
	lFounDePar := .F.    
	cNumAut    := Replicate("0",10)    
	
	// Posiciona BD6...	
	If !BD6->(MsSeek(xFilial("BD6")+TMP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		aadd(aLog2,{"   BD6 nao encontrado","Chave BD6: ",TMP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)})
		PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		TMP->(DbSkip())
		Loop
	Endif    
	
	// Posiciona BD5...	
	If !BD5->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_SITUAC)))
		aadd(aLog2,{"   BD5 nao encontrado","Chave BD6: ",TMP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)})
		PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		TMP->(DbSkip())
		Loop
	Endif        
	
	// Posiciona BD7...	
	If !BD7->(MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
		aadd(aLog2,{"   BD7 nao encontrado","Chave BD6: ",TMP->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)})
		PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		TMP->(DbSkip())
		Loop
	Endif    
	
	// Posiciona B44...	
	If !B44->(MsSeek(xFilial("B44")+BD5->(BD5_OPEMOV+BD5_ANOAUT+BD5_MESAUT+BD5_NUMAUT)))
		aadd(aLog2,{"   B44 nao encontrado","Chave B44: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)})
		PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		TMP->(DbSkip())
		Loop
	Endif     
	
	
	// Posiciona BK6...	
	If !BK6->(MsSeek(xFilial("BK6")+B44->B44_CODREF))
		aadd(aLog2,{"   BK6 nao encontrado","Chave B44: ",BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)})
		PlsLogFil(Space(03)+aLog2[Len(aLog2),1]+Space(03)+aLog2[Len(aLog2),2]+Space(03)+aLog2[Len(aLog2),3],"LOG500.TXT")
		TMP->(DbSkip())
		Loop
	Endif                              
	
	cNota    := Alltrim(BD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))     
	cDatPro  := Dtos(BD6->BD6_DATPRO)        
	
	// De-Para TISS - BTU	
	If lDeParaBTU  
		aRetBTU := PTUDePaBTU(nil,BD6->BD6_CODPRO,BD6->BD6_CODPAD,.F.,.T.)
		If len(aRetBTU) > 0
			cCodPsa := Alltrim(aRetBTU[2]) 
			lFounDePar := .T.
		EndIf  
	
	// De-Para B1M		
	Else  
		cCodPsa := PLDeParINT(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,@lFounDePar,"E") 	
	EndIf
	If !lFounDePar
		IIf(!Empty(BR8->BR8_CODEDI),cCodPsa := strzero(val(BR8->BR8_CODEDI),8),cCodPsa := strzero(val(BD6->BD6_CODPRO),8))
	EndIf	
							
	 
	If BD6->BD6_ORIMOV == "1" .And. BD5->(MsSeek(xFilial("BD5")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))//guia de servico/consulta
		cTipGui := "A" 
	ElseIf BE4->(MsSeek(xFilial("BE4")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO)))//guia de internacao
		cTipGui := "I"  
	EndIf	
	
	cNomPrest  := Substr(BK6->BK6_NOME + Space(70),1,70) 
	cCNPJPre   := StrZero(Val(BK6->BK6_CGC),14,0)  
	cSiglaCon  := Padr(B44->B44_SIGLA,12)
	cNumConPro := Padr(B44->B44_REGEXE,15)
	cUFConsPro := B44->B44_ESTEXE     
	cDatReemb  := Dtos(B44->B44_DATPAG)   
	cNomeProf  := Padr(B44->B44_NOMEXE + Space(70),70)
	
	IIf(B44->B44_TIPPRE == "MED",cTipPes := "F",cTipPes := "J")
		
	cVlrDifenc := Strzero((BD6->BD6_VLRPAG-BD6->BD6_VLRBPR)*100,14)
	cVlrSerCob := Strzero(BD6->BD6_VLRPAG * 100,14)  
	nTotFat    += BD6->BD6_VLRPAG-BD6->BD6_VLRBPR
					
	IIf(cTipGui == "A",cAliasCab := "BD5",cAliasCab := "BE4")
	
	If BDR->(MsSeek(xFilial("BDR")+PlsIntPad()+AllTrim(&(cAliasCab + "->" + cAliasCab + "_TIPADM"))))
		If !Empty(BDR->BDR_CODEDI) //Se estiver informado o campo BDR_CODEDI, o mesmo sera priorizado 
	    	cCarAtend := BDR->BDR_CODEDI 
	    Else
	    	If BDR->BDR_CARINT == "E" //Eletiva
				cCarAtend := "1"
			ElseIf BDR->BDR_CARINT == "U" //Urgencia/Emergencia
				cCarAtend := "2"
			EndIf 
		EndIf		
	EndIf
		
	If &(cAliasCab + "->" + cAliasCab + "_ATERNA") == '1' .Or. (cAliasCab == 'BE4' .And. BE4->BE4_ATENRN == '1')
		cIDRN  := "S"
	Else
		cIDRN  := "N"
	EndIf
			
	BA1->(DbSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1")+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG))) 
		IIF( !Empty(BA1->BA1_MATEDI),cMatAnt := BA1->BA1_MATEDI,cMatAnt := BD6->BD6_MATANT)
		cDatNas := Dtos(BA1->BA1_DATNAS)
		IIF(BA1->BA1_SEXO == "1",cSexo := "M",cSexo := "F")
	Endif  
	
	BAU->(DbSetOrder(1))//BAU_FILIAL + BAU_CODIGO
	If BAU->(DbSeek(xFilial("BAU")+ BD6->BD6_CODRDA))
		cTpRedMin := PadR(BAU->BAU_TIPRED,1)
	EndIf 
						
	cNomUsr := PlRetponto(substr(BD6->BD6_NOMUSR+Space(25),1,25))
			
	cLote   := subs(BD6->BD6_CODLDP,3,2)+strzero(val(BD6->BD6_CODPEG),6)
	cChaNot := cLote + strzero(val(BD6->BD6_NUMERO),11)
	                                                             
	cUniPre := padr(BD6->BD6_OPEUSR,4)      
	cNot    := Alltrim(BD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO))     
	
	
	// De-Para TISS - BTU	
	If lDeParaBTU  
		aRetBTU := PTUDePaBTU(nil,BD6->BD6_CODPRO,BD6->BD6_CODPAD,.F.,.T.)
		If len(aRetBTU) > 0
			cCodPsa := Alltrim(aRetBTU[2]) 
			lFounDePar := .T.
		EndIf  
	
	// De-Para B1M		
	Else   
		cCodPsa := PLDeParINT(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD6->BD6_DATPRO,@lFounDePar,"E") 	
	EndIf
	If !lFounDePar
		If ! empty(BR8->BR8_CODEDI)
			cCodPsa := strzero(val(BR8->BR8_CODEDI),10)
			cDesPsa := PadR(BR8->BR8_DESCRI,80)
		Else
			cCodPsa := strzero(val(BD6->BD6_CODPRO),10)
			cDesPsa := PadR(BD6->BD6_DESPRO,80)
		Endif
	EndIf	  
	
	//Verifica Tabela TUNMM/TUSS
	BA8->(DbSetOrder(1))//BA8_FILIAL+BA8_CODTAB+BA8_CDPADP+BA8_CODPRO
	If ( BD6->(fieldPos("BA8_CODIFI")) > 0 .and. BA8->(DbSeek(xFilial("BA8")+BD6->(BD6_CODOPE+BD6_CODTAB+BD6_CODPAD+BD6_CODPRO))) ) 
		cTipCodifi  := alltrim(BA8->BA8_CODIFI)  
	EndIf	

	cTipTab := BR8->BR8_TPPROC
	
	if ( empty(cTipCodifi) .or. cTipCodifi == "1" )
		Do Case
			Case cTipTab $ "0"
				cTipTab := "0"
			Case cTipTab $ "3|4"
				cTipTab := "1"
			Case cTipTab $ "1|5"
				cTipTab := "2"
			Case cTipTab $ "2"
				cTipTab := "3"
			Case cTipTab $ "6"
				cTipTab := "4"
			Otherwise
				cTipTab := "0"
		EndCase
	//Se TUSS ("2"), analisa BR8_TPPROC, para definir o que é Material ou Medicamento
	else
		Do Case
			Case cTipTab $ "1|5"  //1=Material;5=Ortese/Protese
				cTipTab := "5"
			Case cTipTab $ "2"  //2=Medicamento
				cTipTab := "6"
			Otherwise
				cTipTab := "5"
		EndCase	
	endif	
	
	//Se BD7_CODTPA nao preenchido, procuro primeiro registro na BKX (priorizo o '0')
	cParBD7 := BD7->BD7_CODTPA

	If Empty(cParBD7)        
		If BKC->(MsSeek(xFilial("BKC")+BD7->BD7_CODUNM+PLSINTPAD()))  
			cTipPar := Alltrim(BKC->BKC_CODPAR)  
		Else                        
			cTipPar :='0'          
		Endif                       
	Else                            
		cTipPar :=IIF(LEN(cParBD7)>1,PLSAJPAR(cParBD7),Subs(cParBD7,1,1))  
	EndIf
	
	cQtdPsa := Strzero(Int(Round(BD6->BD6_QTDPRO, 2)),4)+"0000"						
	
	// Alimenta array para geracao posterior do arquivo   	
	if cNota <> cNotaAnt
		aR507 := {}
		aadd(aR507,Space(8))							// 01 Sequencial
		aadd(aR507,Space(3))							// 02 Tipo de Registro
		aadd(aR507,cLote)								// 03 Número do lote de notas.   
		aadd(aR507,cNota)                           	// 04 Número da nota de controle da Unimed ou número identificação de reembolso
		aadd(aR507,SubStr(cMatAnt,1,4))                 // 05 Código da Unimed   
		aadd(aR507,SubStr(cMatAnt,5,15)) 				// 06 Código de Identificação do Beneficiário, incluindo o dígito verificador, sendo o código da Unimed colocado em campo à parte.
		aadd(aR507,cNomUsr)                         	// 07 Nome do Beneficiário.  
		aadd(aR507,cDatNas)                         	// 08 Data de nascimento          
		aadd(aR507,cSexo)                           	// 09 Sexo do Beneficiário.    
		aadd(aR507,cIDRN)								// 10 Indicador de atendimento ao recém-nato
		aadd(aR507,cDatReemb)                       	// 11 Data do reembolso ao beneficiário         
		aadd(aR507,cCarAtend)                       	// 12 Tipo de caráter do atendimento 
		aadd(aR507,cTipPes)                         	// 13 Tipo de pessoa (prestador)
		aadd(aR507,cCNPJPre)                        	// 14 Número do CNPJ ou do CPF do prestador   
		aadd(aR507,Space(40))                       	// 15 Reservado   
		aadd(aR507,'1')                       		  	// 16 Identificação de cobrança de reembolso ou Ressarcimento ao SUS	  
		aadd(aR507,cNomPrest)                       	// 17 Nome do prestador   
		aadd(aR507,'2')                       			// 18 Tipo de cobrança do reembolso 1-Parcial 2-Integral
		aadd(aR507,StrZero(BD7->(RECNO()),20))		  	// 99 Recno do BD7 para gravar o BD7_SEQ500 ** SEMPRE DEIXAR POR ULTIMO **     
		aadd(aReg507,aR507)
	endif
	
	aR508 := {}
	aadd(aR508,Space(8))							// 01 Sequencial
	aadd(aR508,Space(3))							// 02 Tipo de Registro
	aadd(aR508,cLote)								// 03 Número do lote de notas.   
	aadd(aR508,cNota)                           	// 04 Número da nota de controle da Unimed ou número identificação de reembolso
	aadd(aR508,cDatPro)                         	// 05 Data de execução do serviço.	
	aadd(aR508,Space(40))                       	// 06 Reservado.
	aadd(aR508,cSiglaCon)                       	// 07 Sigla do Conselho Profissional
	aadd(aR508,cNumConPro)                      	// 08 Número do Conselho Profissional do prestador
	aadd(aR508,cUFConsPro)                      	// 09 Sigla da Unidade Federativa do Conselho Profissional do prestador
	aadd(aR508,Subs(cTipPar,1,1) )                  // 10 Tipo de participação para reembolso
	aadd(aR508,cTipTab)                             // 11 Identifica o Tipo de Tabela utilizado no Serviço Médico.
	aadd(aR508,Space(8))                         	// 12 Reservado
	aadd(aR508,cQtdPsa)						 	  	// 13 Quantidade do serviço cobrada
	aadd(aR508,cVlrDifenc)                      	// 14 Valor da diferença do serviço cobrado
	aadd(aR508,cVlrSerCob)						  	// 15 Valor do serviço cobrado
	aadd(aR508,cNumAut)					  	  	  	// 16 Número da Autorização
	aadd(aR508,cDesPsa)					  	  	  	// 17 Descrição do Serviço
	aadd(aR508,cNomeProf)                       	// 18 Nome do profissional executante. 
	aadd(aR508,strzero(val(BD6->BD6_CODPRO),10))  	// 19 Código do Serviço.	
	
	aadd(aReg508,aR508)
	
	cNotaAnt := cNota
	
	TMP->(DbSkip())
EndDo

TMP->(dbCloseArea())   


// Cria arquivo temporario 507	 
For i := 1 to len(aReg507)   
	cR507 := "" 
	For ii := 1 to len(aReg507[i])  
		cR507 += aReg507[i][ii]
	Next 
		
	R07->(Reclock("R07",.T.))
	R07->Chave  := (cChaNot+"507")
	R07->R507 	:= cR507                                	
	R07->R507R 	:= aReg507[I,18]
	R07->(MsUnlock())
	nQtd_507++
Next
R07->(DbGoTop())	

//Cria arquivo temporario 508 
For i := 1 to len(aReg508)   
	cR508 := "" 
	For ii := 1 to len(aReg508[i])  
		cR508 += aReg508[i][ii]
	Next 
		
	R08->(Reclock("R08",.T.))
	R08->Chave  := (cChaNot+"508")
	R08->R508 	:= cR508                                	
	R08->(MsUnlock())
	nQtd_508++
Next
R08->(DbGoTop())	

// Gera o arquivo   
cCodOpeBTO  := BTO->BTO_CODOPE
cOpeOriBTO  := BTO->BTO_OPEORI

If !R07->(EOF())			
	PlsPTU(PadR(mv_par12, 6),cArqNom,cDirNov,.F.)         
	aadd(aLog1,{"Arquivo gerado ","Oper: " + cOpeOriBTO + "   Titulo: " + cPrefixoBTO + " " + cNumTitBTO,"Movimento:  "+ alltrim(transform(nTotFat,"@E 999,999,999.99")) + "   Fatura:  "+alltrim(transform(nTotFat,"@E 999,999,999.99"))})
    PlsLogFil(Space(03)+aLog1[Len(aLog1),1]+Space(03)+aLog1[Len(aLog1),2]+Space(03)+aLog1[Len(aLog1),3],"LOG500.TXT")
EndIf
             

// Mensagem de processamento 
If len(aLog1) > 0 .or. len(aLog2) > 0
	If len(aLog1) > 0
		For i := 1 to len(aLog1)
			aadd(aLog,aLog1[i])
		Next
	Endif
	If len(aLog2) > 0
		For i := 1 to len(aLog2)
			aadd(aLog,aLog2[i])
		Next
	Endif
	aadd(aLog,{"","",""})
Endif
		
if( select( "R02" ) > 0 )
	oTempR02:delete()
endIf

if( select( "R03" ) > 0 )
	oTempR03:delete()
endIf

if( select( "R04" ) > 0 )
	oTempR04:delete()
endIf

if( select( "R05" ) > 0 )
	oTempR05:delete()
endIf

if( select( "R06" ) > 0 )
	oTempR06:delete()
endIf

if( select( "R07" ) > 0 )
	oTempR07:delete()
endIf

if( select( "R08" ) > 0 )
	oTempR08:delete()
endIf
Return         

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraSeq507
Grava o codigo sequencial da exportacao e para o tratamento do ptu a550 ajius  

@author  Microsiga
@version P12
@since   26/06/2012
/*/
//-------------------------------------------------------------------
Function GeraSeq507()  

Local cSeq   := ""
Local nRec   := 0  
Local cTexto := Alltrim(R07->R507R)

cSeq := PTULN("R507")

nRec := Val(cTexto)

BD7->(DbGoTo(nRec))
BD7->(RecLock("BD7",.F.)) 
BD7->BD7_SEQ500 := cSeq
BD7->(MsUnlock())

Return cSeq

//-------------------------------------------------------------------
/*/{Protheus.doc} VerQtdPac
Verifico qual a quantidade para determinado item do pacote

@author  PLS TEAM
@version P12
@since   30/09/2016
/*/
//-------------------------------------------------------------------
Function VerQtdPac(aPacte,aPacChq,cBd7CdPd,cBd7CdPr,nQtdPac,dDatUtS)  

Local cSqlP	         := "" 
Local cAptePd        := ""
Local cAptePr		 := "" 
Local cB43ChNv       := "" 
Local cAliPct        := ""
Default nQtdPac      := 1
Default cBd7CdPr     := ""
Default cBd7CdPd     := ""
Default aPacte       := {} 
Default aPacChq      := {}   
Default dDatUtS      := dtos(dDatUtS)

If Len(aPacChq) >= 4 .And. Len(aPacte)>= 2
	cB43ChNv := aPacChq[4]
	cAptePd  := aPacte [1] 
	cAptePr  := aPacte [2]
EndIf    

If cB43ChNv == "BLE"
   cAliPct := "BLE" 
ElseIf cB43ChNv == "BLY"   
   cAliPct := "BLY"
ElseIf cB43ChNv == "B42"
   cAliPct := "B42"
Else
   cAliPct := ""  
   cB43ChNv:= ""
EndIf

   
If !empty(cAliPct) .And. !Empty (cB43ChNv) .And. !Empty (cBd7CdPd) .And. !Empty (cBd7CdPr) .And. !Empty (cAptePd) .And. !Empty (cAptePr) .And. (cAliPct)->(FieldPos(cAliPct+"_QTDPAC")) > 0  
	
	cSqlP := " SELECT " + cAliPct + "_QTDPAC," + cAliPct + "_VIGDE,  " + cAliPct + "_VIGATE  "
	cSqlP += "  FROM " + RetSqlName(cAliPct) 
	cSqlP += " WHERE " + cAliPct + "_FILIAL = '"+ xFilial(cAliPct) +  "' "
	cSqlP += "   AND "+ cAliPct +"_CODINT = '" + plsintpad() + "' "
	if cAliPct == "BLY"
		cSqlP += "   AND "+ cAliPct +"_CODRDA = '" + BD6->BD6_CODRDA + "' "
	endif
	cSqlP += "   AND "+ cAliPct +"_CODPAD = '" + cBd7CdPd + "' "
	cSqlP += "   AND "+ cAliPct +"_CODPRO = '" + cBd7CdPr + "' "
	cSqlP += "   AND "+ cAliPct +"_CPADOC = '" + cAptePd + "' "
	cSqlP += "   AND "+ cAliPct +"_CODOPC = '" + cAptePr + "' "
	cSqlP += "   AND "+ cAliPct +"_ATIVO <> ' 0 ' "
    cSqlP += "   AND ( '"+ dDatUtS + "' BETWEEN "+ cAliPct +"_VIGDE AND " + cAliPct + "_VIGATE OR "+ cAliPct +"_VIGATE ='') "
	cSqlP += "   AND D_E_L_E_T_ = '' "
	
	cSqlP := ChangeQuery(cSqlP)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSqlP),"TmpPtp",.T.,.F.)

	if !TmpPtp->( Eof() )	
		nQtdPac := &("TMPPTP->"+cAliPct+"_QTDPAC")		
	EndIf                             	
				
	TmpPtp->( dbClosearea() )
		            
	If nQtdPac = 0
		nQtdPac:= 1
	EndIf	     
EndIf

Return nQtdPac


//-------------------------------------------------------------------
/*/{Protheus.doc} PESQNUMIN 
Posiciono no local + Peg + Numero da guia através da autorizacao

@author  TOTVS
@version P11
@since   23/06/17
/*/
//-------------------------------------------------------------------
Function PESQNUMIN(cChave,cTipo) 
Local lValTd	:= Iif (Empty(cTipo), .T., .F.)
Local lAchou	:= .F.
Local aArea	:= BE4->(GetArea())
Local cRet		:= ""

If (cTipo == '1' .Or. lValTd)
	BE4->(DbSetOrder(1)) //BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
	If ( BE4->(DbSeek(xFilial("BE4")+cChave)) )
		cRet := (BE4->BE4_CODOPE + BE4->BE4_ANOINT + BE4->BE4_MESINT + BE4->BE4_NUMINT)
		lAchou := .T.
	Else
		cRet := cChave
	EndIf
EndIf

If (cTipo == '2' .Or. lValTd .And. !lAchou)
	BE4->(DbSetOrder(2)) //BE4_FILIAL, BE4_CODOPE, BE4_ANOINT, BE4_MESINT, BE4_NUMINT
	If ( BE4->(DbSeek(xFilial("BE4")+cChave)) )
		cRet := (BE4->BE4_CODOPE + BE4->BE4_CODLDP + BE4->BE4_CODPEG + BE4->BE4_NUMERO)
	Else
		cRet := cChave
	EndIf
EndIf	

RestArea(aArea)	

Return cRet	

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAJPAR 
Faco um De/Para das participações quando a participacao tiver com 2 digitos.

@author  TOTVS
@version P11
@since   31/08/17
/*/
//-------------------------------------------------------------------

Function PLSAJPAR(cPartic)

DEFAULT cPartic:= ""

If !Empty(cPartic)
	Do Case
		Case cPartic == "00"          //C = Cirurgião
			cPartic := "C"
		Case cPartic == "01"          //1º Auxiliar
			cPartic := "1"
		Case cPartic == "02"          //2º Auxiliar
			cPartic := "2"
		Case cPartic == "03"          //3ºAuxiliar
			cPartic := "3"
		Case cPartic == "04"          //4ºAuxiliar
			cPartic := "4"
		Case cPartic == "05"          //4ºAuxiliar
			cPartic := "4"
		Case cPartic == "06"          //Instrumentador - como nao tem o item no manual do PTU apenas ajusto o valor para uma posicao
			if "PA" $ BD7->BD7_CODUNM 
				cPartic := "A"
			else
				cPartic := Subs(cPartic,2,1)
			endif
		Case cPartic == "07"          //Auxiliar de Anestesista (30% do Anestesista)
			cPartic := "N"
		Case cPartic == "08"          //Consultor - como nao tem o item no manual do PTU apenas ajusto o valor para uma posicao 
			cPartic := Subs(cPartic,2,1)
		Case cPartic == "09"          //Perfusionista
			cPartic := "F"
		Case cPartic == "10"          //Pediatra na Sala de Parto
			cPartic := "P"			
		Case cPartic == "11"          //Auxiliar SADT - como nao tem o item no manual do PTU apenas mantenho o valor. este nao ajusto pois senao ficaria igual auxiliar
			cPartic := cPartic
		Case cPartic == "12"          //L = Clínico
			cPartic := "L"
		Case cPartic == "13"          //Intensivista
			cPartic := "I"

		Otherwise
			cPartic := cPartic
	Endcase
EndIf	        

// outras participacoes do manual de intercambio n precisam ser tradas aqui. (H, X e 0 )

return (cPartic)

//-------------------------------------------------------------------
/*/{Protheus.doc} getBKF 
Retorna o código EDI da BKF

@author  Lucas Nonato
@version P12
@since   12/02/2020
/*/
static function getBKF()
local cRet as char
local cSql as char

cSql := " SELECT BKF_CODEDI FROM " + RetSqlName("BKF")
cSql += " WHERE BKF_FILIAL = '" + xfilial("BKF") + "'"
cSql += " AND BKF_CODINT = '" + substr(BD4->BD4_CODTAB,1,4) + "'"
cSql += " AND BKF_CODTAB = '" + substr(BD4->BD4_CODTAB,5,3) + "'"
cSql += " AND BKF_SEQPOR = " + cvaltochar(BD4->BD4_VALREF)
cSql += " AND D_E_L_E_T_ = ' ' "
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbBKF",.F.,.T.)

if !TrbBKF->(eof())
	cRet := TrbBKF->BKF_CODEDI
endif

if empty(cRet)
	if BD4->BD4_VALREF <= 8
		cRet := substr(cvaltochar(BD4->BD4_VALREF),1,1)
	else
		cRet := "0"
	endif
endif

TrbBKF->(dbclosearea())

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSU500FIL 
Filtro 

@author  Lucas Nonato
@version P12
@since   13/02/2020
/*/
function PLSU500FIL(lF2)
local cPerg    	:= "PLSU05"
local cFiltro	:= ""
default lF2 	:= .f.

if Pergunte(cPerg,.T.)
	
	cUniOri   := mv_par01
	nTipEnv   := mv_par02
	nEnviar   := mv_par03
	cGrpIni   := mv_par04
	cGrpFim   := mv_par05
	nTipoNota := mv_par06
	nTipoCRDA := mv_par07
	nConvert  := mv_par08
	dDataConv := mv_par09
	cDirNov   := mv_par10	
	cTpTabCBH := mv_par11	
	lAgrupa   := (mv_par13 == 2)
	cCodLay   := mv_par12
	nTipoLote := mv_par14 

	TCSQLEXEC("UPDATE " + RetSqlName("BTO") + " SET BTO_OK = '  ' WHERE BTO_OK <> '  ' ")

	l500S := Iif(cCodLay >= "A500S",.T.,.F.) 

	If nConvert == 2			
		If Empty(cTpTabCBH)
			MsgStop("Para se converter para CBHPM deve-se informar o tipo de tabela a que se refere a tabela AMB.")
			return PLSU500FIL(lF2)
		Endif
	Endif

	// Cria filtro para Faturas...	
	Do Case
		Case nEnviar = 1
			cComFil := " AND BTO_ENV500 <> '1' "//NAO ENVIADO
		Case nEnviar = 2
			cComFil := " AND BTO_ENV500 = '1' "//ENVIADO
		Case nEnviar = 3
			cComFil := ""
		Otherwise
			cComFil := ""
	Endcase

	cFiltro := "@BTO_FILIAL = '" + xFilial("BTO") + "' AND BTO_STATUS = '1' AND BTO_CODOPE = '" + cUniOri + "' AND D_E_L_E_T_ <> '*' " + cComFil	
	cFiltro := cFiltro + " AND BTO_GRPOPE >= '" + cGrpIni + "' AND BTO_GRPOPE <= '" + cGrpFim + "' "

	If nTipoLote == 2 
		cFiltro := cFiltro + " AND BTO_REEANE = '1' "
	ElseIf nTipoLote <> 2
		cFiltro := cFiltro + " AND BTO_REEANE <> '1' "
	EndIf  

	if lF2
		oMBrw500:SetFilterDefault(cFiltro)
		oMBrw500:Refresh()
	endif

endif

return cFiltro
