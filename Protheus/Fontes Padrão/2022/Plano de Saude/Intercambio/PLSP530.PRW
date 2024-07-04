#INCLUDE "PROTHEUS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "PLSMCCR.CH"

#define lLinux IsSrvUnix()
#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF    
#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP530
Envia arquivo com glosas totais/baixa do envio

@author  Renan Sakai
@version P12
@since   09/01/2017
/*/
//-------------------------------------------------------------------
Function PLSP530(oObjXml,cRootNS,cNameSpace) 
Local aCab    := {}
Local cCodUniOri := ""
Local cCodUniDes := ""
Local cNumRegAns := ""
Local cTipGloBai := ""
Local cCodAviso  := ""
Local cNumLote   := ""
Local cNumGuia   := ""
Local cMatric    := ""
Local cCGC       := ""
Local dDatConhec

Local cRet      := ""
Local cHash     := ""
Default cRootNS    := ""
Default cNameSpace := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do processo                       				           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
cCodUniOri := PLRetTagW2(oObjXml,cRootNS,"cabecalhoTransacao\codigoUnimedOrigemMensagem",,4)
cCodUniDes := PLRetTagW2(oObjXml,cRootNS,"cabecalhoTransacao\codigoUnimedDestinoMensagem",,4)
cNumRegAns := PLRetTagW2(oObjXml,cRootNS,"cabecalhoTransacao\numeroRegistroANS")
	
cTipGloBai := PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\tipoGlosaBaixa")
cCodAviso  := PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\codigoUnimedAviso")
dDatConhec := Stod(PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\dataConhecimento","D"))
cNumLote   := PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\numeroLotePrestador")
cNumGuia   := PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\numeroGuiaTissPrestador")
cMatric    := PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\codigoUnimedBeneficiario",,4)
cMatric    += PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\identificacaoBeneficiario",,13)
cCGC       := PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\dadosPrestador\cpfPrestador")
If Empty(cCGC)
	cCGC   := PLRetTagW2(oObjXml,cRootNS,"dadosglosaoubaixa\dadosPrestador\cnpjPrestador")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faz processamento da guia                      				           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
PL300AtuGui(cCodUniOri,cCodUniDes,cNumRegAns,cTipGloBai,cCodAviso,dDatConhec,cNumLote,cNumGuia,cMatric,cCGC)	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta resposta                              				           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aCab := {"535",cCodUniOri,cCodUniDes,"01"}
//Cabecalho
cRet := PTSoapRes(cRet,'respostaAviso',.T.,.F.,aCab,@cHash,nil,.F.,"V1_00_00",.F.)

//cRet := PLMntTagPT(cRet,'statusGlosaBaixa',"S",nil,nil,nil,@cHash)	

cRet := PLMntTagPT(cRet,'statusGlosaBaixa',nil,.T.)
cRet := PLMntTagPT(cRet,'statusRetorno',"S",nil,nil,nil,@cHash)	
//cRet := PLMntTagPT(cRet,'codigoMensagemRetorno',"S",nil,nil,nil,@cHash)
cRet := PLMntTagPT(cRet,'statusGlosaBaixa',nil,nil,.T.)


// Corpo do arquivo
/*
cRet := PLMntTagPT(cRet,'numeroTransacaoPrestadora',aRet[1][06],nil,nil,nil,cHash)
cRet := PLMntTagPT(cRet,'dataGeracao',ajustaData(convDataXML(aRet[1][07])))
cRet := PLMntTagPT(cRet,'idUsuario',aRet[1][08])
		
cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,.T.)
cRet := PLMntTagPT(cRet,'codigoUnimed',cValtoChar(Val(aRet[1][09])) )
cRet := PLMntTagPT(cRet,'codigoIdentificacao',aRet[1][10] )
cRet := PLMntTagPT(cRet,'identificacaoBeneficiario',nil,nil,.T.)
		
cRet := PLMntTagPT(cRet,'numeroProtocolo',aRet[1][11])
cRet := PLMntTagPT(cRet,'idResposta',aRet[1][12])
cRet := PLMntTagPT(cRet,'mensagemLivre',aRet[1][13])
cRet := PLMntTagPT(cRet,'origemResposta',aRet[1][14])
cRet := PLMntTagPT(cRet,'numeroVersaoProtocolo',aRet[1][15])
*/
// Finaliza arquivo
cHash := Upper( MD5(cHash,2) ) 
cRet  := PTSoapRes(cRet,'respostaAviso',.F.,.T.,aCab,cHash,nil,.F.,"V1_00_00",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se o layout do arquivo de resposta esta Ok					   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
aRetVld := PTVldXmlLy(cRet,nil,"nc_Transacoes-V1_00_00.xsd","V1_00_00","a530")
If !aRetVld[1]
	cRet := aRetVld[2] 
EndIf

Return cRet	


//-------------------------------------------------------------------
/*/{Protheus.doc} PL300AtuGui
Atualiza ao receber o arquivo A530

@author  Renan Sakai	
@version P12
@since   09/01/2017
/*/
//-------------------------------------------------------------------
Static Function PL300AtuGui(cCodUniOri,cCodUniDes,cNumRegAns,cTipGloBai,cCodAviso,dDatConhec,cNumLote,cNumGuia,cMatric,cCGC)
local lRet 		:= .F.
local aCampos 	:= { }
local aTamSX3	:= TamSX3("B5T_NUMLOT") 
local nNumLot 	:= 0
local nNumGui 	:= 0
Local cTipoGuia	:= ""
Local cSql		:= ""
Local cRet		:= ""
	
nNumLot := aTamSX3[1]
aTamSX3	:= TamSX3("B5T_NMGPRE")
nNumGui	:= aTamSX3[1]

cNumLote := cNumLote + space(nNumLot - len(cNumLote))
cNumGuia := cNumGuia + space(nNumGui - len(cNumGuia))	

If cTipGloBai == "1"
	DbSelectArea("B5T")	
	B5T->(DbSetOrder(2)) //B5T_FILIAL+B5T_OPEHAB+B5T_NUMLOT+B5T_NMGPRE+B5T_MATRIC
	If B5T->(MsSeek(xFilial("B5T")+cCodUniOri+cNumLote+cNumGuia+cMatric))
		
		aadd( aCampos,{ "B5T_VLRGLO" , B5T->B5T_VLRTOT } )
		lRet := PL520GRGUI( 4, aCampos, 'MODEL_B5T', 'PLSP520B5T' )
		
	EndIf
ElseIf cTipGloBai == "2"
	cSql := " SELECT B2S_TIPGUI, B2S_STATUS, B5S_NUMLOT, B5S_CODOPE, B5S_CODLDP, B5S_CODPEG, B5S_NUMERO " 
	cSql += " FROM " + RetSqlName("B2S") + " B2S "
	
	cSql += " INNER JOIN " + RetSqlName("B5S") + " B5S "
	cSql += " 	ON  B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
	cSql += " 	AND B5S.B5S_NUMLOT = B2S.B2S_NUMLOT "
	cSql += " 	AND B5S.B5S_NUMGUI = '"+cNumGuia+"' "
	cSql += " 	AND B5S.D_E_L_E_T_ = ' ' "
	
	cSql += " WHERE B2S.B2S_FILIAL = '" + xFilial("B2S") + "' "
	cSql += " 	AND B2S.B2S_STATUS = '3' "
	cSql += " 	AND B2S.B2S_NUMLOT = '"+cNumLote+"' "
	cSql += " 	AND B2S.D_E_L_E_T_ = ' ' "
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbB5S",.F.,.T.)
	
	If !TrbB5S->(Eof())
		DBSelectarea("B5S")
		B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
		B5S->(MsSeek(xFilial("B5S")+TrbB5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
		aCampos := {}
		aAdd( aCampos,{ "B5S_GUICRI"	,"2"	} ) //0=Não Criticada;1=Criticada;2=Guia Expirada
		lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )					
	EndIf
		
	TrbB5S->(dbCloseArea())
EndIf

Return lRet
