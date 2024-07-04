#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA123.CH"

#define MB_YESNO                    4
#define MB_ICONHAND                 16
#define MB_ICONQUESTION             32
#define MB_ICONEXCLAMATION          48
#define MB_ICONASTERISK             64

//-------------------------------------------------------------------
/*/{Protheus.doc} FISA123
Emissão Automática de Nota Fiscal de Crédito Presumido

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function FISA123()

Local aArea		:= GetArea()
Local aAliasMrk	:= {}           //Array para o retorno da função F123QrySFT 
Local aColumns	:= {}           //Colunas do Browse            
Local oDlgMrk		:= Nil
Local nOpc      := 1

Private cAliasMrk	:= ""
Private cNFiscal	:= ""
Private cNFSerie	:= ""
Private cA100For	:= ""
Private cLoja		:= ""
Private cNomWiz	:=	"FIS123" + FWGrpCompany() + FWGETCODFILIAL
Private dDEmissao	:= dDataBase

If !AliasIndic("F0S")
	Help("",1,"Help","Help",STR0002,1,0) //Tabela F0S ainda não foi criada, rodar o update U_UPDSIGAFIS
	Return
EndIf

If Pergunte('FISA123',.T.,STR0007)

    aAliasMrk	:= F123QryMrk(mv_par04) //Retorna alias e as colunas para o preenchimento da FWMarkBrowse
    cAliasMrk	:= aAliasMrk[1] 			//Alias usado no browse
    aColumns  := aAliasMrk[2] 			//Colunas que serão exibidas no browse
    nOpc := IIf(Empty(mv_par04),1,mv_par04) // Operacao (Emissao de pre-nota/Emissao de documento)

    If !(cAliasMrk)->(Eof())
        oMrkBrowse:= FWMarkBrowse():New()
        oMrkBrowse:SetFieldMark("MARK")
        oMrkBrowse:SetOwner(oDlgMrk)
        oMrkBrowse:SetDataQuery(.F.)
        oMrkBrowse:SetDataTable(.T.)
        oMrkBrowse:SetAlias(cAliasMrk)
        oMrkBrowse:SetDescription(STR0001 + " - " + IIf(nOpc == 1, STR0028, STR0003)) //Emissão Automática de Nota Fiscal de Crédito Presumido
        oMrkBrowse:SetColumns(aColumns)
        oMrkBrowse:Activate()
    Else
        Help(" ",1,"RECNO")
    EndIf

Endif    

If !Empty(cAliasMrk)
    dbSelectArea(cAliasMrk)
    dbCloseArea()
    Ferase(cAliasMrk+GetDBExtension())
    Ferase(cAliasMrk+OrdBagExt())
    cAliasMrk := ""
Endif

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()

Local aRotina := {}
	
ADD OPTION aRotina TITLE "Emitir"	ACTION 'F123Proc(cAliasMrk)'	OPERATION 3 ACCESS 0 //Pré-nota/Emissão
ADD OPTION aRotina TITLE STR0009	ACTION 'FISA123WIZ(cNomWiz)'	OPERATION 9 ACCESS 0 //Parametros

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} F123Proc
Pre Nota credito

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function F123Proc(cAlias)

Local cMarca		:= oMark:Mark()
Local nTotSelNF	:= 0
Local nSelNF		:= 0
Local nTotNF		:= 1
Local nTotCrePre	:= 0
Local cMens		:= ""
Local nNroDocEmi	:= F123QryF0S() + 1  //nro de documentos a emitir
Local nEspMens	:= 0                    
Local nTamMens	:= TamSX3("FT_EMISSAO")[1] + TamSX3("FT_NFISCAL")[1] + TamSX3("FT_ESTADO")[1] + TamSX3("FT_CRPREPR")[1] + 4
Local aWizard		:= {}
Local cAliasF0S	:= ""
Local nPreEmi		:= mv_par04

//Localiza os parâmetros para gerar a NF
If !xMagLeWiz(cNomWiz, @aWizard, .T.)
	cMens += STR0029 + Chr(10) + Chr(13) //Verifique o Cadastro de Parâmetros
	MsgStop(STR0018+Chr(13)+cMens)
	Return
EndIf

//Posiciona nas tabelas conforme parametros
If F123PosTab(aWizard)
	//Espaço para mensagem
	nEspMens := IIf(Val(aWizard[1][5])==0,2000,Val(aWizard[1][5]))  
	//Verifica tamanho da mensagem na formula
	If !Empty(SF4->F4_FORMULA)
		dbSelectArea("SM4")
		dbSetOrder(1)
		MsSeek(xFilial("SM4")+SF4->F4_FORMULA)
		nTamMens += Len(&(SM4->M4_FORMULA))
	Endif
	If nTamMens > nEspMens
		MsgStop(STR0018+" "+STR0030)
		Return
	Endif	
	//Cria tabela temporária como as notas selecionadas para atualizar a F0S
	F123CriaTRB()
	(cAlias)->(dbGoTop())
	While !(cAlias)->(EOF())
		If oMark:IsMark(cMarca)
			nSelNF++
			nTotSelNF++
			If nPreEmi==1	//Pre-nota
				If nTotSelNF > Int(nEspMens/nTamMens)
					nTotNF++
					nNroDocEmi++
					nTotSelNF := 0
				Endif
				RecLock("TRB",.T.)
				TRB->TRB_DOCCRE	:=	"PRE"+StrZero(nNroDocEmi,TamSX3("F0S_DOCCRE")[1]-3)	 
				TRB->TRB_DOCSAI	:=	(cAlias)->FT_NFISCAL
				TRB->TRB_SERSAI	:=	(cAlias)->FT_SERIE
				TRB->TRB_ESPSAI	:=	(cAlias)->FT_ESPECIE
				TRB->TRB_CLISAI	:=	(cAlias)->FT_CLIEFOR
				TRB->TRB_LOJSAI	:=	(cAlias)->FT_LOJA
				TRB->TRB_UFSAI	:=	(cAlias)->FT_ESTADO
				TRB->TRB_EMISAI	:=	(cAlias)->FT_EMISSAO
				TRB->TRB_CRESAI	:=	(cAlias)->FT_CRPREPR
				TRB->(MsUnLock())
				nTotCrePre 		+= (cAlias)->FT_CRPREPR
			Else 			//Emissão		
				RecLock("TRB",.T.)
				TRB->TRB_DOCCRE	:=	(cAlias)->F0S_DOCCRE	 
				TRB->TRB_CRESAI	:=	(cAlias)->F0S_CRESAI
				TRB->(MsUnLock())
				nTotNF		:= nSelNF
				nTotCrePre	+= (cAlias)->F0S_CRESAI
			Endif	 
		EndIf
		(cAlias)->(dbSkip())
	Enddo

	If nSelNF > 0
		cMens	:= 	STR0010 + AllTrim(Str(nSelNF)) + Chr(10) + Chr(13) +;
					STR0011 + AllTrim(Str(nTotNF)) + Chr(10) + Chr(13) +;
					STR0012 + AllTrim(Transform(nTotCrePre,"@e 99,999,999,999.99")) + Chr(10) + Chr(13)+;
					Chr(10) + Chr(13) + STR0013
		If MsgYesNo(cMens,STR0001)
			If nPreEmi==1	//Pre-nota
				MsgRun(STR0028+" - "+STR0020, STR0021,	{|| F123GraPreNF(nPreEmi)})
			Else	
				MsgRun(STR0020, STR0021,	{|| F123ExAu103(nPreEmi)})
			Endif
			oMrkBrowse:GetOwner():End()
		Endif
	Else
		MsgAlert(STR0014)
	Endif
	
	dbSelectArea("TRB")
	dbCloseArea()
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Grava pre-nota

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function F123GraPreNF(nPreEmi)
Local cMens	:= ""

dbSelectArea("TRB")
TRB->(DbGoTop())		
While !TRB->(EOF())
	nNroDocEmi	:= TRB->TRB_DOCCRE		 
	While !TRB->(EOF()) .AND. TRB->TRB_DOCCRE==nNroDocEmi		 
		//Grava a pre-nota na tabela F0S 
		F123GraF0S(nNroDocEmi,"",SA2->A2_COD,SA2->A2_LOJA,"","","",nPreEmi)
		TRB->(DbSkip())
	Enddo	
Enddo

If !Empty(cMens)
	MsgAlert(cMens)	
Endif	

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Chama a rotina automática do mata103
Atualiza a tabela F0S

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function F123ExAu103(nPreEmi)

Local aCabec		:= {}
Local aItens		:= {}
Local aLinha		:= {}
Local nTotNF		:= 0
Local cMens		:= ""
Local cMVEspecie	:= SuperGetMv("MV_ESPECIE")
Local cTipoNf		:= SuperGetMv("MV_TPNRNFS")
Local cNumNfGFE	:= ""

Private lMsErroAuto	:= .F.
Private lMsHelpAuto	:= .T.
Private cEspecie		:= "SPED"

ConOut(PadC(STR0001,80))

If !NfeNextDoc(@cNFiscal,@cNFSerie,@cNumNfGFE,cTipoNf,.T.)
	Return
Endif

ConOut("Inicio: "+Time())
dbSelectArea("TRB")
TRB->(DbGoTop())		
While !TRB->(EOF())
	aCabec		:= {}
	aItens		:= {}
	aLinha		:= {}
	nTotNF 	:= TRB->TRB_CRESAI
	//Atualiza a tabela F0S 
	F123GraF0S(cNFiscal,cNfSerie,SA2->A2_COD,SA2->A2_LOJA,cEspecie,cNfSerie,TRB->TRB_DOCCRE,nPreEmi)
	//Monta cabeçalho da NF	
	aadd(aCabec,{"F1_TIPO",		"N",				Nil})
	aadd(aCabec,{"F1_FORMUL",	"S",				Nil})
	aadd(aCabec,{"F1_DOC",		cNFiscal,			Nil})
	aadd(aCabec,{"F1_SERIE",		cNFSerie,			Nil})
	aadd(aCabec,{"F1_EMISSAO",	dDEmissao,			Nil})
	aadd(aCabec,{"F1_FORNECE",	SA2->A2_COD,		Nil})
	aadd(aCabec,{"F1_LOJA",		SA2->A2_LOJA,		Nil})
	aadd(aCabec,{"F1_ESPECIE",	cEspecie,			Nil})
	aadd(aCabec,{"F1_COND",		SE4->E4_CODIGO,	Nil})
	aadd(aCabec,{"F1_VALMERC",	nTotNF,			Nil})
	aadd(aCabec,{"F1_VALBRUT",	nTotNF,			Nil}) 
	aadd(aCabec,{"F1_MOEDA",		0,					Nil}) 
	aadd(aCabec,{"F1_TXMOEDA",	0,					Nil}) 
	aadd(aCabec,{"F1_STATUS",	"A",				Nil})
	//Monta o item da NF	
	aadd(aLinha,{"D1_COD",		SB1->B1_COD,		Nil})
	aadd(aLinha,{"D1_QUANT",		1,					Nil})
	aadd(aLinha,{"D1_VUNIT",		nTotNF,			Nil})
	aadd(aLinha,{"D1_TOTAL",		nTotNF,			Nil})
	aadd(aLinha,{"D1_TES",		SF4->F4_CODIGO,	Nil})
	aadd(aLinha,{"AUTDELETA",	"N",				Nil}) // Incluir sempre no último elemento do array de cada item
	aadd(aItens,aLinha)

	MATA103(aCabec,aItens,3) // inclusão
	
	If !lMsErroAuto
		ConOut("Incluido com sucesso! "+cNFiscal)
		cMens	+= STR0017 + cNFiscal + Chr(10) + Chr(13)
		If !TRB->(EOF())
			NfeNextDoc(@cNFiscal,@cNFSerie,@cNumNfGFE,cTipoNf,.F.)
		Endif	
	Else
		MostraErro()
		ConOut("Erro na inclusao!")
	EndIf
	TRB->(DbSkip())
Enddo
ConOut("Fim : "+Time())

If !Empty(cMens)
	MsgAlert(cMens)	
Endif	

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Grava a tabela F0S (notas que fazem parte da nota de crédito presumido)

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function F123GraF0S(cDoc,cSer,cFor,cLoj,cEsp,cSDocCr,cChaveF0S,nPreEmi)
Local	aArea		:= GetArea()
Local	aRecFOS	:= {}
Local	nA			:= 1

dbSelectArea("F0S")

If nPreEmi==1	//Pre-nota
	If !DBSeek(xFilial("F0S")+cDoc+cSer+cFor+cLoj+DTOS(dDEmissao)+TRB->(TRB_DOCSAI+TRB_SERSAI+TRB_CLISAI+TRB_LOJSAI+DTOS(TRB_EMISAI)))
		RecLock("F0S",.T.)
		F0S_FILIAL	:=	xFilial("F0S")
		F0S_DOCCRE	:=	cDoc 
		F0S_SERCRE	:=	cSer
		F0S_ESPCRE	:=	cEsp
		F0S_FORCRE	:=	cFor
		F0S_LOJCRE	:=	cLoj
		F0S_SDOCCR	:=	cSDocCr 	
		F0S_EMICRE	:=	dDEmissao
		F0S_DOCSAI	:=	TRB->TRB_DOCSAI
		F0S_SERSAI	:=	TRB->TRB_SERSAI
		F0S_ESPSAI	:=	TRB->TRB_ESPSAI	
		F0S_CLISAI	:=	TRB->TRB_CLISAI
		F0S_LOJSAI	:=	TRB->TRB_LOJSAI
		F0S_EMISAI	:=	TRB->TRB_EMISAI
		F0S_UFSAI	:=	TRB->TRB_UFSAI
		F0S_CRESAI	:=	TRB->TRB_CRESAI
		F0S_SDOCSA	:=	TRB->TRB_SDOCSA 	
		F0S->(MsUnLock())
	Endif
Endif

If nPreEmi==2	//Emissão
	If DBSeek(xFilial("F0S")+cChaveF0S)
		While !F0S->(EOF()) .AND. F0S->F0S_DOCCRE==cChaveF0S
			AADD(aRecFOS,F0S->(RECNO()))
			F0S->(DbSkip())
		Enddo
		For nA:=1 to Len(aRecFOS)		
			F0S->(dbGoTo(aRecFOS[nA]))
			RecLock("F0S",.F.)
			F0S_DOCCRE	:=	cDoc 
			F0S_SERCRE	:=	cSer
			F0S_ESPCRE	:=	cEsp
			F0S_FORCRE	:=	cFor
			F0S_LOJCRE	:=	cLoj
			F0S_SDOCCR	:=	cSDocCr 	
			F0S_EMICRE	:=	dDEmissao
			F0S->(MsUnLock())
		Next	
	Endif
Endif

RestArea(aArea)
 													
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Cria tabela temporaria

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function F123CriaTRB()

Local aArea	:= GetArea()
Local aCampo	:=	{}
Local cArq		:=	""

aAdd(aCampo,{"TRB_DOCCRE","C",TamSX3("F0S_DOCCRE")[1],0})
aAdd(aCampo,{"TRB_DOCSAI","C",TamSX3("F0S_DOCSAI")[1],0})
aAdd(aCampo,{"TRB_SERSAI","C",TamSX3("F0S_SERSAI")[1],0})
aAdd(aCampo,{"TRB_ESPSAI","C",TamSX3("F0S_ESPSAI")[1],0})
aAdd(aCampo,{"TRB_CLISAI","C",TamSX3("F0S_CLISAI")[1],0})
aAdd(aCampo,{"TRB_LOJSAI","C",TamSX3("F0S_LOJSAI")[1],0})
aAdd(aCampo,{"TRB_EMISAI","D",TamSX3("F0S_EMISAI")[1],0})
aAdd(aCampo,{"TRB_UFSAI" ,"C",TamSX3("F0S_UFSAI")[1],0})
aAdd(aCampo,{"TRB_SDOCSA","C",TamSX3("F0S_SDOCSA")[1],0})
aAdd(aCampo,{"TRB_CRESAI","N",TamSX3("F0S_CRESAI")[1],TamSX3("F0S_CRESAI")[2]})

cArq := CriaTrab(aCampo)
DbUseArea(.T., __LocalDriver, cArq, "TRB")
IndRegua ("TRB", cArq, "TRB_DOCCRE+TRB_DOCSAI")

RestArea(aArea)
 													
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Próximo nr da nota fiscal

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Static Function NfeNextDoc(cNFiscal,cNfSerie,cNumNfGFE,cTipoNf,lTela)

Local aArea		:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())
Local lRetorno	:= .T.
Local lUsaNewKey	:= TamSX3("F1_SERIE")[1] == 14 // Verifica se o novo formato de gravacao do Id nos campos _SERIE esta em uso
Local cSerieId	:= IIf(lUsaNewKey,SerieNfId("SF1",4,"F1_SERIE",dDEmissao,cEspecie,cNfSerie),cNfSerie)

Private cNumero	:= ""
Private cSerie 	:= ""

If lTela
	lRetorno := Sx5NumNota(@cSerie,cTipoNf,,,,@cSerieId,dDEmissao) // O parametro cSerieId deve ser passado para funcao Sx5NumNota afim de tratar a existencia ou nao do mesmo numero na funcao VldSx5Num do MATXFUNA.PRX
	//Validacao da NF informada pelo usuario
	If lRetorno .And. cTipoNF <> "3"
		SF1->(dbSetOrder(1))
		If SF1->(MsSeek(xFilial("SF1")+PADR(cNumero,TamSx3("F1_DOC")[1])+SerieNfId("SF1",4,"F1_SERIE",dDEmissao,cEspecie,cSerie)+cA100For+cLoja,.F.))
			Help(" ",1,"EXISTNF")
			lRetorno	:= .F.
			cNumero	:= ""
			cSerie		:= ""
		EndIf
	EndIf
Else	
	cSerie := SerieNfId("SF1",4,"F1_SERIE",dDEmissao,cEspecie,cNFSerie)
Endif
If lRetorno
	If cTipoNf <> "3"
		cSerieId := IIf(lUsaNewKey,SerieNfId("SF1",4,"F1_SERIE",dDEmissao,cEspecie,cSerie),cSerie)
		If cTipoNf <> "2" 
			cNumero := NxtSX5Nota(cSerie, NIL, cTipoNf,,,, cSerieId)
		EndIf	
	EndIf
   cNFiscal:=cNumero
   cNFSerie:=cSerie
Else 
   cNFiscal:= CriaVar("F1_DOC",.F.)
   cNFSerie:= SerieNfId("SF1",5,"F1_SERIE")      
EndIf

RestArea(aAreaSF1)
RestArea(aArea)

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Monta Wizard

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function FISA123WIZ(cNomWiz)

Local	aTxtApre	:=	{}
Local	aPaineis	:=	{}
Local	cTitObj1	:=	""
Local	cTitObj2	:=	""
	
aAdd(aTxtApre, STR0008)	
aAdd(aTxtApre, "")	
aAdd(aTxtApre, STR0022)	
aAdd(aTxtApre, STR0008)	
//Painel 0
aAdd(aPaineis, {})
nPos	:=	Len(aPaineis)
aAdd(aPaineis[nPos], STR0023)
aAdd(aPaineis[nPos], STR0022)
aAdd(aPaineis[nPos], {})

aAdd(aPaineis[nPos][3],{1,STR0024,,,,,,})
aAdd(aPaineis[nPos][3],{1,STR0025,,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,TamSX3("A1_COD")[1],,,"FOR"})
aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,TamSX3("A1_LOJA")[1]}) 

aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})

aAdd(aPaineis[nPos][3],{1,STR0026,,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,TamSX3("B1_COD")[1],,,"SB1"}) 

aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})

aAdd(aPaineis[nPos][3],{1,STR0027,,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"@!", 1,,,,TamSX3("F4_CODIGO")[1],,,"SF4"}) 

aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})

aAdd(aPaineis[nPos][3],{1,STR0030,,,,,,})
aAdd(aPaineis[nPos][3], {0, "",,,,,,})
aAdd(aPaineis[nPos][3],{2, ,"@e 99999", 1,,,,5})

lRet := xMagWizard (aTxtApre, aPaineis, cNomWiz)
	
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} 
Posiciona as tabelas

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7

/*/
//-------------------------------------------------------------------
Function F123PosTab(aWizard)

Local lSA2		:= .F.
Local lSE4		:= .F.
Local lSB1		:= .F.
Local lSF4		:= .F.
Local cMens	:= ""

//Verificar a existência do fornecedor
dbSelectArea("SA2")
dbSetOrder(1)
lSA2 := SA2->(MsSeek(xFilial("SA2")+aWizard[1][1]+aWizard[1][2])) 
//Verificar a existência do condição de pagamento
dbSelectArea("SE4")
dbSetOrder(1)
lSE4 := SE4->(MsSeek(xFilial("SE4")+SA2->A2_COND)) 
//Verificar a existência do produto
dbSelectArea("SB1")
dbSetOrder(1)
lSB1 := SB1->(MsSeek(xFilial("SB1")+aWizard[1][3])) 
//Verificar a existência do tes
dbSelectArea("SF4")
dbSetOrder(1)
lSF4 := SF4->(MsSeek(xFilial("SF4")+aWizard[1][4])) 

If !lSA2 
	cMens += "Cadastro de Fornecedor" + Chr(10) + Chr(13)
Endif	
If !lSE4 
	cMens += "Cadastro de Condição de Pagamento" + Chr(10) + Chr(13)
Endif	
If !lSB1
	cMens += "Cadastro de Produto" + Chr(10) + Chr(13)
Endif	
If !lSF4
	cMens += "Cadastro de TES" + Chr(10) + Chr(13)
Endif
If cMens<>""
	MsgAlert(STR0018+Chr(13)+Chr(10)+Chr(13)+Chr(10)+cMens)
Endif

Return (lSA2 .And. lSE4 .And. lSB1 .And. lSF4) 

//-------------------------------------------------------------------
/*/{Protheus.doc} F123QryMrk
Selecao do dados

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function F123QryMrk(nOpc)

Local aArea		:= GetArea()            
Local cAliasTrb	:= GetNextAlias()        
Local aStructTrb	:= IIf(nOpc==1, SFT->(DbStruct()), F0S->(DbStruct()))
Local aColumns	:= {}
Local nX			:= 0                    
Local cTempTab	:= ""
Local aCampoGrid	:= IIf(nOpc==1,{"FT_EMISSAO","FT_NFISCAL","FT_SERIE","FT_CLIEFOR","FT_LOJA","FT_ESTADO","FT_CRPREPR"},{"F0S_FILIAL","F0S_DOCCRE","F0S_EMICRE","F0S_UFSAI","F0S_CRESAI"})
Local cDataIni	:= DTOS(mv_par01)
Local cDataFim	:= DTOS(mv_par02)
Local cUF			:= mv_par03

If nOpc==1 //Pre-nota
	
	BeginSQL Alias cAliasTrb
		COLUMN FT_EMISSAO AS DATE
	
		SELECT SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ESTADO,SFT.FT_EMISSAO,SFT.FT_ESPECIE,'  ' as MARK,Sum(SFT.FT_CRPREPR) as FT_CRPREPR  
		FROM %Table:SFT% SFT
		WHERE SFT.FT_FILIAL=%xFilial:SFT% AND SFT.FT_EMISSAO BETWEEN %Exp:cDataIni% AND %Exp:cDataFim% AND SFT.FT_ESTADO=%Exp:cUF% AND SFT.FT_CRPREPR>0 AND SUBSTRING(SFT.FT_CFOP,1,1)>='5' AND SFT.FT_DTCANC='' AND SFT.%NotDel% AND
		(SELECT COUNT(*) FROM %Table:F0S% 
		WHERE F0S_FILIAL=%xFilial:F0S% AND F0S_DOCSAI=SFT.FT_NFISCAL AND F0S_SERSAI=SFT.FT_SERIE AND F0S_CLISAI=SFT.FT_CLIEFOR AND F0S_LOJSAI=SFT.FT_LOJA AND F0S_UFSAI=SFT.FT_ESTADO AND D_E_L_E_T_='') = 0
		GROUP BY SFT.FT_FILIAL,SFT.FT_NFISCAL,SFT.FT_SERIE,SFT.FT_CLIEFOR,SFT.FT_LOJA,SFT.FT_ESTADO,SFT.FT_EMISSAO,SFT.FT_ESPECIE
		ORDER By SFT.FT_FILIAL,SFT.FT_EMISSAO,SFT.FT_NFISCAL
		
	EndSql

Else
	
	BeginSQL Alias cAliasTrb
		COLUMN F0S_EMICRE AS DATE
	
		SELECT F0S.F0S_FILIAL,F0S.F0S_DOCCRE,F0S.F0S_EMICRE,F0S.F0S_UFSAI,'  ' as MARK,Sum(F0S.F0S_CRESAI) as F0S_CRESAI
		FROM %Table:F0S% F0S  
		WHERE F0S.F0S_FILIAL=%xFilial:F0S% AND F0S.F0S_DOCCRE LIKE 'PRE%' AND F0S.F0S_EMICRE BETWEEN %Exp:cDataIni% AND %Exp:cDataFim% AND F0S.F0S_UFSAI=%Exp:cUF% AND F0S.%NotDel%
		GROUP BY F0S.F0S_FILIAL,F0S.F0S_DOCCRE,F0S.F0S_EMICRE,F0S.F0S_UFSAI
		ORDER By F0S.F0S_FILIAL,F0S.F0S_EMICRE,F0S.F0S_DOCCRE

	EndSql

Endif	
//Cria arquivo temporário
cTempTab := CriaTrab(aStructTrb,.T.)
Copy To &cTempTab

//Fecha query
If Select(cAliasTrb) > 0
    DbSelectArea(cAliasTrb)
    DbCloseArea()
EndIf

DbUseArea( .T.,,cTempTab,cTempTab, .T., .F. )  

For nX:=1 To Len(aStructTrb) 
    If !aStructTrb[nX][1]=="MARK" .And. Ascan(aCampoGrid,aStructTrb[nX][1])>0
        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||"+aStructTrb[nX][1]+"}") )
        aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructTrb[nX][1])) 
        aColumns[Len(aColumns)]:SetSize(aStructTrb[nX][3]) 
        aColumns[Len(aColumns)]:SetDecimal(aStructTrb[nX][4])
        aColumns[Len(aColumns)]:SetPicture(PesqPict(IIf(nOpc==1,"SFT","F0S"),aStructTrb[nX][1]))  
    EndIf     
Next nX 

Return({cTempTab,aColumns})

//-------------------------------------------------------------------
/*/{Protheus.doc} F123QryF0S
Selecao do dados

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function F123QryF0S()

Local cAliasF0S	:= GetNextAlias()
Local nNroDoc		:= 0        

BeginSQL Alias cAliasF0S

	SELECT COUNT(*) as F0S_NRO_DOC FROM %Table:F0S% 
	WHERE F0S_FILIAL=%xFilial:F0S% AND F0S_DOCCRE LIKE 'PRE%' AND D_E_L_E_T_=''
	
EndSql

//Fecha query
If Select(cAliasF0S) > 0
	DbSelectArea(cAliasF0S)
	nNroDoc := F0S_NRO_DOC
	DbCloseArea()
EndIf

Return nNroDoc

//-------------------------------------------------------------------
/*/{Protheus.doc} F123F0SDet
Selecao do dados do documento

@author Mauro A. Goncalves
@since 15/07/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function F123F0SDet(cAliasF0S,cDocPre)

cAliasF0S	:= GetNextAlias()

BeginSQL Alias cAliasF0S
	COLUMN F0S_EMICRE AS DATE
	COLUMN F0S_EMISAI AS DATE

	SELECT * FROM %Table:F0S% 
	WHERE F0S_FILIAL=%xFilial:F0S% AND F0S_DOCCRE=%Exp:cDocPre% AND D_E_L_E_T_=''
	
EndSql

Return cAliasF0S