#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH" 
#INCLUDE "TMSR650.CH"
#INCLUDE "FWPRINTSETUP.CH"

#DEFINE DMPAPER_A4 9
#DEFINE IMP_PDF    6

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSR650
Realiza a impressão de faturas
@type function
@author Rafael Souza
@version 12
@since 01/09/2016
@return Nil Não há retorno
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 30/05/2017 para
@obs adaptar a impressão de faturas quando o ERP integrado seja o Datasul
/*/
//-------------------------------------------------------------------------------------------------
User Function TMSR650()

	Local cTmsERP         	:= SuperGetMV("MV_TMSERP",,'0')	
	Local lPreFat   	  	:= iif(type("PARAMIXB") == "A" .And. Len(PARAMIXB) >= 1,PARAMIXB[1], .F.)
	Local aCposProtg      	:= {}
	Local aCpoAccess	  	:= {'A1_NOME'}
	Local cFilePrint      	:= "FAT" + cEmpAnt + "_" + cFilAnt + "_" + Dtos(MSDate()) + "_" + StrTran(Time(), ":", "")
	Local cStartPath		:= GetSrvProfString("Startpath","")

	Private nLin     := 0 //-- Variavel para controle de linha
	Private cPerg    := ""
	Private oPrint
	//-- Declaracao de variaveis para controle de formato de fonte
	Private oFont06  := TFont():New("Arial",06,06,,.F.,,,,.T.,.F.)
	Private oFont06N := TFont():New("Arial",06,06,,.T.,,,,.T.,.F.)
	Private oFont07  := TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)
	Private oFont07N := TFont():New("Arial",07,07,,.T.,,,,.T.,.F.)
	Private oFont08  := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)
	Private oFont08N := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)
	Private oFont08I := TFont():New("Arial",08,08,,.F.,,,,.T.,.F.,.T.)
	Private oFont09  := TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)
	Private oFont09N := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)
	Private oFont10  := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
	Private oFont10N := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
	Private oFontD   := TFont():New("Arial",  ,07,,.F.)
	Private oFont11  := TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)
	Private oFont11N := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)
	Private oFont12  := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
	Private oFont12n := TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)
	Private oFont14  := TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
	Private oFont14N := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)

	If ExistFunc('TMLGPDCpPr')
		aCposProtg := TMLGPDCpPr(aCpoAccess, "SA1")
		If ExistFunc('FWPDCanUse') .And. FWPDCanUse() .And. !Empty(aCposProtg)
			If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCposProtg )) < Len(aCposProtg)
				Help(" ",1,STR0058,,,5,11) //"LGPD - Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Para mais informações contate o Administrador do sistema !!"
				Return
			EndIf	
		EndIf
	EndIf
	
	If cTmsERP == '0' //-- ERP Protheus
		cPerg := "TMSR650"
	ElseIf cTmsERP == '1' //-- ERP Datasul
		cPerg := "TMSR650A"
	EndIf

	If !lPreFat
		If ! Pergunte(cPerg, .T.)
			Return
		EndIf
	Else
		// Para impressão quando for origem pre-fatura
		Pergunte(cPerg, .F.)
	EndIf
	
	oPrint := FWMSPrinter():New(cFilePrint,IMP_PDF,.F./*lAdjustToLegacy*/,cStartPath,.T./*lDisabeSetup*/,/*lTReport*/,,/*cPrinter*/,.F./*lServer*/,/*lPDFAsPNG*/,/*lRaw*/,.T./*lViewPDF*/,/*nQtdCopy*/)

	oPrint:SetResolution(72)
	oPrint:SetLandscape()
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetPortrait()
	
	FwMsgRun(, {|oSay| TMR650Proc(@oPrint) } , "Processando"  , "Gerando relatório..." ) //"Processando"  /  "Transmitindo documentos..."

	If ValType(oPrint) != 'O'
		MsgAlert(STR0001) //-- "Nao ha dados para imprimir com estes parametros."
	EndIf 

Return 

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMR650Proc
Monta o layout do relatório
@type function
@protected
@author Rafael Souza
@version 12
@since 01/09/2016
@param [oPrint] , Objeto, Objeto oPrint (TMSPrinter)
@return Nil Não há retorno
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 30/05/2017 para
@obs adaptar a impressão de faturas quando o ERP integrado seja o Datasul
/*/
//-------------------------------------------------------------------------------------------------
Static Function TMR650Proc(oPrint)

	Local cExtenso  := ""
	Local cAux      := ""
	Local cBanco    := ""
	Local nLinAux   := 0
	Local nVltotal  := 0
	Local nColAux   := 0
	Local nValICMS  := 0	
	Local lCont     := .T.
	Local cAliasFat := ""
	Local nValFat   := 0
	Local cNumFat   := ""
	Local dtEmiss   := Nil
	Local dtVenct   := Nil
	Local nDecres   := 0
	Local nAcresc   := 0
	Local nDescon   := 0
	Local cPortad   := ""
	Local cAgenci   := ""
	Local cCtaCor   := ""
	Local nValJur   := 0
	Local cNomCli   := ""
	Local cEndCli   := ""
	Local cCepCli   := ""
	Local cBaiCli   := ""
	Local cMunCli   := ""
	Local cEstCli   := ""
	Local cEndCob   := ""
	Local cBaiCob   := ""
	Local cCepCob   := ""
	Local cMunCob   := ""
	Local cEstCob   := ""
	Local cPessoa   := ""
	Local cCgcCli   := ""
	Local cInsCli   := ""
	Local cObs      := ""
	Local cTmsERP   := SuperGetMV("MV_TMSERP",,'0')
	Local cStartPath		:= GetSrvProfString("Startpath","")
	Local cLogoTp	:= cStartPath + "logofat" + cEmpAnt + ".BMP" //Insira o caminho do Logo da empresa logada, na variavel cLogoTp.
	Local lAdjustToLegacy := .F.
	Local nDecr   	:= 0 
	Local nAcr    	:= 0
    Local nMoeda    := 1
	
	//
	If	IsSrvUnix() .And. GetRemoteType() == 1
		cLogoTp := StrTran(cLogoTp,"/","\")
	Endif 

	If  !File(cLogoTp)
		cLogoTp    := cStartPath + "logofat.bmp"
	EndIf	
	
	If cTmsERP == '0' //-- ERP Protheus
		cAliasFat := "TRBSE1"
	ElseIf cTmsERP == '1' //-- ERP Datasul
		cAliasFat := "TRBDRT"
	EndIf

	//-- Monta Query da Fatura
	MntQryFat(cAliasFat)

	lAdjustToLegacy := .T.

	While (cAliasFat)->(! Eof())

		lCont   := .T.
		nValFat := 0
		cNumFat := ""
		dtEmiss := Nil
		dtVenct := Nil
		nDecres := 0
		nAcresc := 0
		nDescon := 0
		cPortad := ""
		cAgenci := ""
		cCtaCor := ""
		nValJur := 0
		cNomCli := ""
		cEndCli := ""
		cCepCli := ""
		cBaiCli := ""
		cMunCli := ""
		cEstCli := ""
		cEndCob := ""
		cBaiCob := ""
		cCepCob := ""
		cMunCob := ""
		cEstCob := ""
		cPessoa := ""
		cCgcCli := ""
		cInsCli := ""
		cObs    := ""
        nMoeda  := 1

		//-- [1] Verificações
		If cTmsERP == '0' //-- ERP Protheus

			If (cAliasFat)->E1_SALDO  = 0   .And.; //-- Saldo zerado
			   (cAliasFat)->E1_STATUS = "B" .And.; //-- Baixado
			   (cAliasFat)->E1_SITFAT = "3"        //-- Cancelado
			   lCont := .F.
			EndIf

		ElseIf cTmsERP == '1' //-- ERP Datasul

			If (cAliasFat)->DRT_STATUS = "3" .Or.; //-- Fatura parcialmente baixada
			   (cAliasFat)->DRT_STATUS = "4" .Or.; //-- Fatura totalmente baixada
			   (cAliasFat)->DRT_STATUS = "5" .Or.; //-- Fatura cancelada
			   (cAliasFat)->DRT_STATUS = "6"       //-- Fatura protestada
			   lCont := .F.
			EndIf
		EndIf

		If lCont

			//-- [2] Informações da fatura
			If cTmsERP == '0' //-- ERP Protheus

				nValFat := (cAliasFat)->E1_VALOR
				cNumFat := (cAliasFat)->E1_NUM
				dtEmiss := (cAliasFat)->E1_EMISSAO
				dtVenct := (cAliasFat)->E1_VENCREA
				nDecres := (cAliasFat)->E1_DECRESC
				nAcresc := (cAliasFat)->E1_ACRESC
				nDescon := (cAliasFat)->(E1_DECRESC + E1TOTABAT)
				cPortad := (cAliasFat)->E1_PORTADO
				cAgenci := ""
				cCtaCor := ""
				nValJur := (cAliasFat)->E1_JUROS
				cNomCli := (cAliasFat)->A1_NOME
				cEndCli := (cAliasFat)->A1_END
				cCepCli := (cAliasFat)->A1_CEP
				cBaiCli := (cAliasFat)->A1_BAIRRO
				cMunCli := (cAliasFat)->A1_MUN
				cEstCli := (cAliasFat)->A1_EST
				cEndCob := (cAliasFat)->A1_ENDCOB
				cBaiCob := (cAliasFat)->A1_BAIRROC
				cCepCob := (cAliasFat)->A1_CEPC
				cMunCob := (cAliasFat)->A1_MUNC
				cEstCob := (cAliasFat)->A1_ESTC
				cPessoa := (cAliasFat)->A1_PESSOA
				cCgcCli := (cAliasFat)->A1_CGC
				cInsCli := (cAliasFat)->A1_INSCR
                nMoeda  := (cAliasFat)->E1_MOEDA
				cObs    := AllTrim(MV_PAR10)

			ElseIf cTmsERP == '1' //-- ERP Datasul

				nValFat := (cAliasFat)->DRT_VALOR
				cNumFat := (cAliasFat)->DRT_NUM
				dtEmiss := (cAliasFat)->DRT_DTEMIS
				dtVenct := (cAliasFat)->DRT_DTVENC
				nDecres := (cAliasFat)->DRT_DECRES
				nAcresc := (cAliasFat)->DRT_ACRESC
				nDescon := (cAliasFat)->DRT_DECRES //-- O Datasul devolve apenas o valor de desconto por pagamento antecipado
				cPortad := (cAliasFat)->DRT_BANCO
				cAgenci := (cAliasFat)->DRT_AGENC
				cCtaCor := (cAliasFat)->DRT_CTACOR
				nValJur := 0 //-- O Datasul devolve apenas o valor de juros por dia de atraso
				cNomCli := (cAliasFat)->A1_NOME
				cEndCli := (cAliasFat)->A1_END
				cCepCli := (cAliasFat)->A1_CEP
				cBaiCli := (cAliasFat)->A1_BAIRRO
				cMunCli := (cAliasFat)->A1_MUN
				cEstCli := (cAliasFat)->A1_EST
				cEndCob := (cAliasFat)->A1_ENDCOB
				cBaiCob := (cAliasFat)->A1_BAIRROC
				cCepCob := (cAliasFat)->A1_CEPC
				cMunCob := (cAliasFat)->A1_MUNC
				cEstCob := (cAliasFat)->A1_ESTC
				cPessoa := (cAliasFat)->A1_PESSOA
				cCgcCli := (cAliasFat)->A1_CGC
				cInsCli := (cAliasFat)->A1_INSCR
				nMoeda  := (cAliasFat)->DRT_MOEDA
				cObs    := AllTrim(MV_PAR09)

			EndIf

			oPrint:StartPage()
			nLin:= 0003
			oPrint:Box( nLin+0014, 0015, nLin+0395, 0580 )
			oPrint:Box( nLin+0014, 0015, nLin+0058, 0120 )
			oPrint:Box( nLin+0014, 0120, nLin+0058, 0580 )
			
			oPrint:SayBitmap ( nLin+0015, 0016, cLogoTp , 0090, 0040,,.T. )
			oPrint:Say( nLin+0026, 0125, AllTrim(SM0->M0_NOMECOM) + " - " + Transform(AllTrim(SM0->M0_CGC),"@R 99.999.999/9999-99" ) + " - I.E.:" + AllTrim(SM0->M0_INSC)   ,oFont11N)
			oPrint:Say( nLin+0037, 0125, AllTrim(SM0->M0_ENDENT), oFont08)
			oPrint:Say( nLin+0037, 0300, " - " + AllTrim(SM0->M0_BAIRENT), oFont08)	
			oPrint:Say( nLin+0045, 0125, AllTrim(SM0->M0_CIDENT), oFont08)
			oPrint:Say( nLin+0045, 0300, " - " + AllTrim(SM0->M0_ESTENT) + STR0002 + AllTrim(SM0->M0_CEPENT), oFont08) //-- CEP
			
			oPrint:Say( nLin+0053, 0125, STR0003  ,oFont08) //-- "TELEFONE: "
			oPrint:Say( nLin+0053, 0190, Transform(AllTrim(SM0->M0_TEL),"@R (99) 999999999") ,oFont08)	
		
			oPrint:Box( nLin+0120, 0022, nLin+0065, 0575 ) //Quadro principal
			oPrint:Box( nLin+0120, 0022, nLin+0065, 0180 ) //Primeira divisão
			oPrint:Box( nLin+0120, 0022, nLin+0078, 0101 ) //Quadro valor
			oPrint:Box( nLin+0120, 0101, nLin+0078, 0180 ) //Quadro número
			oPrint:Box( nLin+0120, 0180, nLin+0078, 0259 ) //Quadro Valor
			oPrint:Box( nLin+0120, 0259, nLin+0078, 0338 ) //Quadro N da ordem
			oPrint:Box( nLin+0120, 0338, nLin+0078, 0417 ) //Quadro emissao
			oPrint:Box( nLin+0120, 0417, nLin+0065, 0496 ) //Quadro vencimento
			oPrint:Box( nLin+0160, 0496, nLin+0065, 0575 ) //Quadro selo
			oPrint:Box( nLin+0090, 0022, nLin+0090, 0496 ) //Segunda divisão
						
			oPrint:Say( nLin+0074, 0085, STR0004, oFont08N) //"FATURA"
			oPrint:Say( nLin+0074, 0275, STR0005, oFont08N) //"DUPLICATA"
			oPrint:Say( nLin+0086, 0050, STR0006, oFont08N) //"VALOR"
			oPrint:Say( nLin+0086, 0125, STR0007, oFont08N) //"NUMERO"
			oPrint:Say( nLin+0086, 0202, STR0006, oFont08N) //"VALOR"
			oPrint:Say( nLin+0086, 0275, STR0008, oFont08N) //"Nº Ordem"
			oPrint:Say( nLin+0086, 0360, STR0009, oFont08N) //"EMISSAO"	
			oPrint:Say( nLin+0078, 0425, STR0010, oFont08N) //"VENCIMENTO"
			
			oPrint:Say( nLin+0070, 0499, STR0011, oFont06N) //--"PARA USO DA "
			oPrint:Say( nLin+0080, 0499, STR0012, oFont06N) //--"INSTITUIÇÃO FINANCEIRA"
																
			oPrint:Say( nLin+0105, 0050, Transform(nValFat,"@E 999,999,999.99 "), oFont08)//VALOR
			oPrint:Say( nLin+0105, 0125, cNumFat, oFont08)//NUMERO
			oPrint:Say( nLin+0105, 0202, Transform(nValFat,"@E 999,999,999.99 "), oFont08)//VALOR
			oPrint:Say( nLin+0105, 0275, cNumFat, oFont08)//NUMERO
			oPrint:Say( nLin+0105, 0360, DTOC(StoD(dtEmiss)), oFont08)//EMISSAO
			oPrint:Say( nLin+0105, 0425, Transform(STOD(dtVenct),"@D"), oFont08)//DATA DE VENCIMENTO
		
			oPrint:Say( nLin+0130, 0125, STR0013, oFont06) //--"DESCONTO DE : "	
			oPrint:Say( nLin+0130, 0275, STR0014, oFont06) //--"VALOR LIQUIDO : "
			oPrint:Say( nLin+0140, 0125, STR0015, oFont06) //--"BANCO : "
			oPrint:Say( nLin+0140, 0275, STR0016, oFont06) //--"JUROS : "
			
			If cTmsERP == '1' //-- ERP Datasul
				oPrint:Say( nLin+0150, 0125, STR0056, oFont06) //--"AGENCIA : "
				oPrint:Say( nLin+0160, 0125, STR0057, oFont06) //--"CTA CORREN : "
			EndIf
			
			If cTmsERP == '0' //-- ERP Protheus
				nVltotal := nValFat - nDescon
			Else //-- ERP Datasul				
				nVltotal := nValFat 
				If nDescon > 0 
					nValFat := nValFat + nDescon
				ElseIf nAcresc > 0 
					nValFat := nValFat - nAcresc
				EndIf
			EndIf
			
			If !Empty(cPortad)
				cBanco := AllTrim(cPortad) + " / " + Posicione("SA6",1, xFilial("SA6")+cPortad , "A6_NOME")
			Else
				cBanco := ""
			EndIf
			
			PesqDoc(cAliasFat, @nDecr, @nAcr) //Query dos documentos no detalhe da fatura
			
			If nDecr > 0
				nDescon := nDescon + nDecr
			Endif
			
			If nAcr > 0
				nAcresc := nAcresc + nAcr
			EndIf
			
			oPrint:Say( nLin+0130, 0180, Transform(nDescon,"@E 999,999,999.99 "), oFont06N) //DESCONTO
			oPrint:Say( nLin+0130, 0350, Transform(nVltotal,"@E 999,999,999.99 "), oFont06N) //VALOR LIQUIDO
			oPrint:Say( nLin+0140, 0180, cBanco, oFont06N) //BANCO
			oPrint:Say( nLin+0140, 0350, Transform(nValJur,"@E 999,999,999.99 "), oFont06N) //JUROS
			
			If cTmsERP == '1' //-- ERP Datasul
				oPrint:Say( nLin+0150, 0180, cAgenci, oFont06N) //AGENCIA
				oPrint:Say( nLin+0160, 0180, cCtaCor, oFont06N) //CTA CORREN
			EndIf

			oPrint:Box( nLin+0300, 0101, nLin+0170, 0575 )//Quadro pagador
			
			oPrint:Say( nLin+0180, 0105, STR0017         , oFont08)
			oPrint:Say( nLin+0180, 0150, cNomCli         , oFont08N) //SACADO
			nLin += 10
			oPrint:Say( nLin+0180, 0105, STR0018         , oFont08)
			oPrint:Say( nLin+0180, 0150, Alltrim(cEndCli), oFont08N) //ENDERECO
			oPrint:Say( nLin+0180, 0500, STR0019         , oFont08)
			oPrint:Say( nLin+0180, 0520, AllTrim(cCepCli), oFont08N) //CEP

			oPrint:Say( nLin+0190, 0105, STR0020         , oFont08)
			oPrint:Say( nLin+0190, 0150, AllTrim(cBaiCli), oFont08N) //BAIRRO
			oPrint:Say( nLin+0190, 0300, STR0021         , oFont08)	
			oPrint:Say( nLin+0190, 0350, AllTrim(cMunCli), oFont08N) //MUNICIPIO
			oPrint:Say( nLin+0190, 0500, STR0022         , oFont08)
			oPrint:Say( nLin+0190, 0520, AllTrim(cEstCli), oFont08N) //SIGLA DO ESTADO
			oPrint:Say( nLin+0200, 0105, STR0023         , oFont08)
			oPrint:Say( nLin+0200, 0150, Alltrim(cEndCob), oFont08N) //PRACA PGTO
			oPrint:Say( nLin+0200, 0340, STR0024         , oFont08)
			oPrint:Say( nLin+0200, 0382, AllTrim(cBaiCob), oFont08N) //BAIR. COB	
			oPrint:Say( nLin+0200, 0500, STR0025         , oFont08)
			oPrint:Say( nLin+0200, 0537, Alltrim(cCepCob), oFont08N) //CEP COB
			oPrint:Say( nLin+0210, 0105, STR0026         , oFont08)	
			oPrint:Say( nLin+0210, 0150, AllTrim(cMunCob), oFont08N) //MUN COB
			oPrint:Say( nLin+0210, 0300, STR0027         , oFont08)
			oPrint:Say( nLin+0210, 0350, AllTrim(cEstCob), oFont08N) //UF COB	
			
			If cPessoa == "F"
				oPrint:Say( nLin+0220, 0105, STR0028, oFont08)	
				oPrint:Say( nLin+0220, 0150, Transform(AllTrim(cCgcCli),"@R 999.999.999-99" ), oFont08N) //CPF CLIENTE
			Else
				oPrint:Say( nLin+0220, 0105, STR0029, oFont08)
				oPrint:Say( nLin+0220, 0150, Transform(AllTrim(cCgcCli),"@R 99.999.999/9999-99" ), oFont08N) //CNPJ CLIENTE
			EndIf
			oPrint:Say( nLin+0220, 0300, STR0030, oFont08)
			oPrint:Say( nLin+0220, 0350, Alltrim(cInsCli), oFont08N) //INSCRICAO ESTADUAL
		
			oPrint:Box( nLin+0230, 0101, nLin+0280, 0575 ) //Quadro VALOR POR EXTENSO
			oPrint:Box( nLin+0230, 0180, nLin+0280, 0575 ) //Quadro TEXTO VALOR POR EXTENSO
			
			oPrint:Say( nLin+0255, 0120, STR0031	,oFont08N) //-- VALOR POR
			oPrint:Say( nLin+0265, 0120, STR0032	,oFont08N) //-- EXTENSO
			
			cExtenso  := Extenso(nVltotal,,nMoeda)
			If Len(cExtenso) <= 80
				oPrint:Say( nLin+0250, 200, cExtenso	,oFont08N)//Valor por Extenso
			Else //Quebra o texto em outra linha
				cAux := cExtenso
				nLinAux := nLin+0250
				While Len(cAux) > 0
					cAux := SubStr(cExtenso, 80)
					cExtenso := SubStr(cExtenso,1,79)
					oPrint:Say( nLinAux , 200, cExtenso	,oFont08N)//Valor por Extenso
					cExtenso := cAux
					nLinAux += 50
				EndDo
			EndIf

			oPrint:Box( nLin+0320, 0060, nLin+0170, 0061 )//linha de assinatura vertical
			oPrint:Say( nLin+0200, 0065, "A", oFont08N)
			oPrint:Say( nLin+0210, 0065, "S", oFont08N)
			oPrint:Say( nLin+0220, 0065, "S", oFont08N)
			oPrint:Say( nLin+0230, 0065, "I", oFont08N)
			oPrint:Say( nLin+0240, 0065, "N", oFont08N)
			oPrint:Say( nLin+0250, 0065, "A", oFont08N)
			oPrint:Say( nLin+0260, 0065, "T", oFont08N)
			oPrint:Say( nLin+0270, 0065, "U", oFont08N)
			oPrint:Say( nLin+0280, 0065, "R", oFont08N)
			oPrint:Say( nLin+0290, 0065, "A", oFont08N)
		
			oPrint:Say( nLin+0300, 0101, STR0033, oFont08)
			oPrint:Say( nLin+0310, 0101, STR0034 + AllTrim(SM0->M0_NOMECOM) + STR0035, oFont08) //-- " OU A SUA ORDEM NA PRAÇA E VENCIMENTO INDICADOS." 
			
			oPrint:Say( nLin+0340, 0101, STR0036, oFont08)  //--EM
			oPrint:Say( nLin+0343, 0120, STR0037, oFont14N) //--"___/___/___"
			oPrint:Say( nLin+0352, 0130, STR0038, oFont06)  //--"DATA DO ACEITE"
			
			oPrint:Box( nLin+0343, 0350,  nLin+0344, 0500) //linha de assinatura horizontal
			oPrint:Say( nLin+0352, 0380, STR0039, oFont06) //--"ASSINATURA DO SACADO"

			oPrint:Say( nLin+0370, 0050, STR0040, oFont08N) //--"OBS.: "
			oPrint:Say( nLin+0370, 0080, cObs, oFont08)
			
			nLin -= 10
			
			oPrint:Say( nLin+0400, 0005, Replicate("-", 360), oFont06)
			
			//Imprimi o quadro de detalhes box parte cima descrição
			oPrint:Box( nLin+0405, 0015, nLin+0420, 0071 )// 1 DT. Emissao
			oPrint:Box( nLin+0405, 0071, nLin+0420, 0128 )// 1 ORI/DES
			oPrint:Box( nLin+0405, 0128, nLin+0420, 0184 )// 1 DOCUMENTO
			oPrint:Box( nLin+0405, 0184, nLin+0420, 0241 )// 1 ICMS
			oPrint:Box( nLin+0405, 0241, nLin+0420, 0297 )// 1 VALOR
			
			oPrint:Box( nLin+0405, 0297, nLin+0420, 0354 )// 2 DT. Emissao
			oPrint:Box( nLin+0405, 0354, nLin+0420, 0410 )// 2 ORI/DES
			oPrint:Box( nLin+0405, 0410, nLin+0420, 0467 )// 2 DOCUMENTO
			oPrint:Box( nLin+0405, 0467, nLin+0420, 0523 )// 2 ICMS
			oPrint:Box( nLin+0405, 0523, nLin+0420, 0580 )// 2 VALOR
		
			oPrint:Say( nLin+0415, 0025, STR0009	,oFont08N) //--"EMISSÃO"
			oPrint:Say( nLin+0415, 0081, STR0041	,oFont08N) //--"FIL.ORI"
			oPrint:Say( nLin+0415, 0134, STR0042	,oFont08N) //--"DOCUMENTO"	
			oPrint:Say( nLin+0415, 0194, STR0043	,oFont08N) //--"IMPOSTO"
			oPrint:Say( nLin+0415, 0251, STR0006	,oFont08N) //--"VALOR"
		
			oPrint:Say( nLin+0415, 0307, STR0009	,oFont08N)//--"EMISSÃO"
			oPrint:Say( nLin+0415, 0364, STR0041	,oFont08N)//--"FIL.ORI"
			oPrint:Say( nLin+0415, 0417, STR0042    ,oFont08N)//--"DOCUMENTO"
			oPrint:Say( nLin+0415, 0477, STR0043	,oFont08N)//--"IMPOSTO"
			oPrint:Say( nLin+0415, 0533, STR0006	,oFont08N)//--"VALOR"
			
			nLinAux := 0435
			nColAux := 0025
			
			While TRBDT6->(!Eof())
				
				oPrint:Say( nLinAux, nColAux, Transform(STOD(TRBDT6->DT6_DATEMI),"@D")	,oFont08N,,,,2) //DT. EMISSAO
				nColAux += 0056
				oPrint:Say( nLinAux, nColAux, AllTrim(TRBDT6->DT6_FILORI),oFont08N,,,,2) //FIL. ORI
				nColAux += 0055
				oPrint:Say( nLinAux, nColAux, AllTrim(TRBDT6->DT6_DOC)	,oFont08N,,,,2) // DOCUMENTO
				nColAux += 0058
				oPrint:Say( nLinAux, nColAux, Transform(TRBDT6->DT6_VALIMP,"@E 999,999,999.99 ")	,oFont08N,,,,2) //IMPOSTO
				nColAux += 0057
				oPrint:Say( nLinAux, nColAux, Transform(TRBDT6->DT6_VALTOT,"@E 999,999,999.99 ")	,oFont08N,,,,2) //VALOR 
				nValICMS += TRBDT6->DT6_VALIMP
				//Muda a pagina e imprimi novamente o cabeçalho deste bloco
				If nLinAux >= 755 .And. nColAux == 526
					oPrint:EndPage()
					oPrint:StartPage()
					//Imprimi o cabeçalho novamente box parte cima descrição
					nLinAux := 20
					oPrint:Box( nLinAux, 0015, nLinAux+0015, 0071 )// 1 DT. Emissao
					oPrint:Box( nLinAux, 0071, nLinAux+0015, 0128 )// 1 FIL. ORI
					oPrint:Box( nLinAux, 0128, nLinAux+0015, 0184 )// 1 DOCUMENTO
					oPrint:Box( nLinAux, 0184, nLinAux+0015, 0241 )// 1 ICMS
					oPrint:Box( nLinAux, 0241, nLinAux+0015, 0297 )// 1 VALOR
					
					oPrint:Box( nLinAux, 0297, nLinAux+0015, 0354 )// 2 DT. Emissao
					oPrint:Box( nLinAux, 0354, nLinAux+0015, 0410 )// 2 FIL. ORI
					oPrint:Box( nLinAux, 0410, nLinAux+0015, 0467 )// 2 DOCUMENTO
					oPrint:Box( nLinAux, 0467, nLinAux+0015, 0523 )// 2 ICMS
					oPrint:Box( nLinAux, 0523, nLinAux+0015, 0580 )// 2 VALOR
					
					nLinAux += 10

					oPrint:Say( nLinAux, 0025, STR0009	,oFont08N)//--"EMISSÃO"
					oPrint:Say( nLinAux, 0081, STR0041	,oFont08N)//--"FIL.ORI"
					oPrint:Say( nLinAux, 0136, STR0042	,oFont08N)//--"DOCUMENTO"
					oPrint:Say( nLinAux, 0194, STR0043	,oFont08N)//--"IMPOSTO"
					oPrint:Say( nLinAux, 0251, STR0006	,oFont08N)//--"VALOR"
				
					oPrint:Say( nLinAux, 0307, STR0009	,oFont08N)
					oPrint:Say( nLinAux, 0364, STR0041	,oFont08N)
					oPrint:Say( nLinAux, 0418, STR0042	,oFont08N)
					oPrint:Say( nLinAux, 0477, STR0043	,oFont08N)
					oPrint:Say( nLinAux, 0533, STR0006	,oFont08N)

					nLinAux += 10
				EndIf
				If nColAux == 526
					nColAux := 0025
					nLinAux += 10
				Else
					nColAux := 0300
				EndIf
		
				TRBDT6->(dbSkip())
			EndDo
			nLinAux += 10
			//////////////////////////////////////////////////////////
			//Verifica o espaço que sobrou na folha para o rodapé
			//se não tiver espaço inicia uma nova folha
			If nLinAux > 700
				oPrint:EndPage()
				oPrint:StartPage()
				nLinAux := 20
			EndIf
			
			//RODAPE DA FATURA

			oPrint:Box( nLinAux, 0015, nLinAux+0030, 580 ) // 
			oPrint:Say( nLinAux+0035, 0005, Replicate("-", 360),oFont06) //pontilhado para corte
			oPrint:Say( nLinAux+0040,500, STR0049    ,oFont06)//--"Corte na linha Pontilhada" 
			oPrint:Box( nLinAux+0045, 0015, nLinAux+0160, 580 ) //BLOCO PRINCIPAL DO RODAPE
			oPrint:Box( nLinAux+0048, 0400, nLinAux+0158, 578 ) //BLOCO CARIMBO
			oPrint:Say( nLinAux+0055, 0470, STR0044	,oFont08)   //--"CARIMBO"
			
			nLinAux += 10
			oPrint:Say( nLinAux, 0020, STR0045	,oFont08)
			oPrint:Say( nLinAux, 0070, Transform(nValFat,"@E 999,999,999.99 ")	,oFont08N) //VALOR BRUTO
			
			oPrint:Say( nLinAux, 0140, STR0046	,oFont08)
			oPrint:Say( nLinAux, 0190, Transform(nDescon,"@E 999,999,999.99 ")	,oFont08N) //DESCONTO
			
			oPrint:Say( nLinAux, 0280, STR0047	,oFont08)
			oPrint:Say( nLinAux, 0330, Transform(nAcresc,"@E 999,999,999.99 ")	,oFont08N) //ACRESCIMO
			
			oPrint:Say( nLinAux, 0420, STR0016	,oFont08)
			oPrint:Say( nLinAux, 0470, Transform(nValJur,"@E 999,999,999.99 ")	,oFont08N) //JUROS	
			
			nLinAux += 17
			
			oPrint:Say( nLinAux, 0020, STR0004	,oFont08)
			oPrint:Say( nLinAux, 0090, AllTrim(cNumFat)		,oFont08N) //FATURA
		
			oPrint:Say( nLinAux, 0140, STR0010	,oFont08)
			oPrint:Say( nLinAux, 0220, Transform(STOD(dtVenct),"@D") 	,oFont08N) //VENCIMENTO
			
			oPrint:Say( nLinAux, 0280, STR0043	,oFont08)
			oPrint:Say( nLinAux, 0330, Transform(nValICMS,"@E 999,999,999.99 ")	,oFont08N) //IMPOSTO
			
			oPrint:Say( nLinAux, 0420, STR0048	,oFont08)
			oPrint:Say( nLinAux, 0470, Transform(nVltotal,"@E 999,999,999.99 ")		,oFont08N) //LIQUIDO		
			
			nLinAux += 30
			oPrint:Say( nLinAux, 070, STR0050  	,oFont12) //--"PROTOCOLO DE ENTREGA DE FATURA"
			nLinAux += 10
			oPrint:Say( nLinAux, 070, AllTrim(SM0->M0_NOMECOM)	,oFont12)
			
			nLinAux += 20
			oPrint:Say( nLinAux, 0020, STR0051	,oFont08N) //--CLIENTE
			oPrint:Say( nLinAux, 0070, AllTrim(cNomCli)	,oFont08)
			nLinAux += 10
			oPrint:Say( nLinAux, 0020, STR0018	,oFont08N) //--ENDERECO
			oPrint:Say( nLinAux, 0070, AllTrim(cEndCob)	,oFont08)	
			nLinAux += 10
			oPrint:Say( nLinAux, 0020, STR0004	,oFont08N) //--Fatura: 
			oPrint:Say( nLinAux, 0070, AllTrim(cNumFat)	,oFont08)
			oPrint:Say( nLinAux, 0140, STR0009	,oFont08N) //-- Emissao
			oPrint:Say( nLinAux, 0190, Transform(STOD(dtEmiss),"@D")	,oFont08)
			oPrint:Say( nLinAux, 0280, STR0055	,oFont08N)//-- Vencimento
			oPrint:Say( nLinAux, 0330, Transform(STOD(dtVenct),"@D")	,oFont08)
			nLinAux += 40
			oPrint:Say( nLinAux, 0020, STR0053	,oFont08N) //--"DATA RECEB.: ___/___/___"
			oPrint:Say( nLinAux, 0140, STR0054	,oFont08N)//--"RECEBIDO POR: ________________________"
			
			oPrint:EndPage()
			nVltotal := 0
			nValICMS := 0		

			//-- Atualiza o status da fatura
			AtzStaFat(cAliasFat)

		EndIf

		(cAliasFat)->(DbSkip())
	EndDo

	oPrint:Preview()

	(cAliasFat)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MntQryFat
Monta query para extração de dados da tabela de fatura
@type function
@protected
@author Rafael Souza
@version 12
@since 01/09/2016
@param [cAliasFat] , Caracter, Alias que terá os dados da(s) fatura(s)
@return Nil Não há retorno
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 30/05/2017 para
@obs adaptar a impressão de faturas quando o ERP integrado seja o Datasul
/*/
//-------------------------------------------------------------------------------------------------
Static Function MntQryFat(cAliasFat)

	Local cQuery  	:= ""
	Local cTmsERP 	:= SuperGetMV("MV_TMSERP",,'0')
	Local cPar08	:= MV_PAR08
	Local cPar09	:= MV_PAR09 

	Default cAliasFat := ""

	If ValType(cPar08) == "D"
		cPar08	:= DToS(cPar08)
	EndIf

	If ValType(cPar09) == "D"
		cPar09	:= DToS(cPar09)
	EndIf

	If cTmsERP == '0' //-- ERP Protheus

		cQuery	:= " SELECT E1_NUM   , E1_PREFIXO, E1_TIPO   , E1_EMISSAO, E1_VENCREA, E1_VALOR, " + CRLF
		cQuery  += "        E1_ACRESC, E1_DECRESC, E1_JUROS  , E1_VALLIQ , E1_PORTADO,E1_SALDO , " + CRLF
		cQuery  += "        E1_STATUS, E1_SITFAT , E1_MOEDA  , E1_FILDEB, E1_CLIENTE, E1_LOJA, (SELECT SUM(ABT.E1_VALOR) "         + CRLF 
		cQuery  += "                                  FROM " + RetSqlName("SE1") + " ABT "         + CRLF
		cQuery  += "                                  WHERE D_E_L_E_T_     = ' ' "                 + CRLF
		cQuery  += "	                                AND ABT.E1_FILIAL  = SE1.E1_FILIAL "       + CRLF
		cQuery  += "                                    AND ABT.E1_NUM     = SE1.E1_NUM "          + CRLF
		cQuery  += "                                    AND ABT.E1_PREFIXO = SE1.E1_PREFIXO "      + CRLF
		cQuery  += "                                    AND ABT.E1_TIPO    = 'AB-') E1TOTABAT  , " + CRLF
		cQuery	+= "        A1_NOME  , A1_END    , A1_BAIRRO , A1_CEP    , A1_MUN    , A1_EST  , " + CRLF
		cQuery	+= "        A1_ENDCOB, A1_CEPC   , A1_BAIRROC, A1_MUNC   , A1_ESTC   , A1_CGC  , " + CRLF
		cQuery 	+= "        A1_INSCR , A1_PESSOA "                                                 + CRLF

		cQuery	+= "   FROM " + RetSqlName("SE1") + " SE1 " + CRLF

		cQuery	+= "  INNER JOIN " + RetSqlName("SA1") + " SA1 "             + CRLF
		cQuery	+= "          ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "' " + CRLF
		cQuery	+= "         AND SA1.A1_COD     = SE1.E1_CLIENTE "           + CRLF
		cQuery	+= "         AND SA1.A1_LOJA    = SE1.E1_LOJA "              + CRLF
		cQuery	+= "         AND SA1.D_E_L_E_T_ = ' ' "                      + CRLF

		cQuery	+= "  WHERE SE1.E1_FILIAL  = '" + xFilial("SE1") +"' "                                     + CRLF
		cQuery	+= "    AND SE1.E1_PREFIXO = '" + MV_PAR01 +"'"                                            + CRLF
//		cQuery	+= "    AND SE1.E1_TIPO    = 'FT ' "                                                       + CRLF
		cQuery	+= "    AND SE1.E1_TIPO    <> 'IS-' "                                                      + CRLF
		cQuery	+= "    AND SE1.E1_NUM     BETWEEN '" + MV_PAR02       + "' AND '" + MV_PAR03       + "' " + CRLF
		cQuery	+= "    AND SA1.A1_COD     BETWEEN '" + MV_PAR04       + "' AND '" + MV_PAR06       + "' " + CRLF
		cQuery	+= "    AND SA1.A1_LOJA    BETWEEN '" + MV_PAR05       + "' AND '" + MV_PAR07       + "' " + CRLF
		
		cQuery	+= "    AND SE1.E1_EMISSAO BETWEEN '" + cPar08 + "' AND '" + cPar09 + "' " + CRLF
		
		cQuery	+= "    AND SE1.D_E_L_E_T_ = ' ' "                                                         + CRLF

	ElseIf cTmsERP == '1' //-- ERP Datasul

		cQuery	:= " SELECT DRT.DRT_NUM   , DRT.DRT_DTEMIS, DRT.DRT_DTVENC, DRT.DRT_VALOR , DRT.DRT_STATUS, DRT.DRT_VALJUR, " + CRLF
		cQuery  += "        DRT.DRT_VALDES, DRT.DRT_BANCO , DRT.DRT_AGENC , DRT.DRT_CTACOR, DRT.DRT_ACRESC, DRT.DRT_DECRES, " + CRLF
		cQuery	+= "        DRT.DRT_MOEDA , DRT.DRT_FILDEB, DRT.DRT_CLIFAT, DRT.DRT_LOJFAT, " + CRLF									
		cQuery	+= "        SA1.A1_NOME   , SA1.A1_END    , SA1.A1_BAIRRO , SA1.A1_CEP    , SA1.A1_MUN ,  "   + CRLF
		cQuery	+= "        SA1.A1_EST    , SA1.A1_ENDCOB , SA1.A1_CEPC   , SA1.A1_BAIRROC, SA1.A1_MUNC,  "   + CRLF
		cQuery 	+= "        SA1.A1_ESTC   , SA1.A1_CGC    , SA1.A1_INSCR  , SA1.A1_PESSOA "                   + CRLF

		cQuery	+= "   FROM " + RetSqlName("DRT") + " DRT " + CRLF

		cQuery	+= "  INNER JOIN " + RetSqlName("SA1") + " SA1 "             + CRLF
		cQuery	+= "          ON SA1.A1_FILIAL  = '" + xFilial("SA1") + "' " + CRLF
		cQuery	+= "         AND SA1.A1_COD     = DRT.DRT_CLIFAT "           + CRLF
		cQuery	+= "         AND SA1.A1_LOJA    = DRT.DRT_LOJFAT "           + CRLF
		cQuery	+= "         AND SA1.D_E_L_E_T_ = ' ' "                      + CRLF

		cQuery	+= "  WHERE DRT.DRT_FILIAL = '" + xFilial("DRT") +"' "                                     + CRLF
		cQuery	+= "    AND DRT.DRT_NUM    BETWEEN '" + MV_PAR01       + "' AND '" + MV_PAR02       + "' " + CRLF
		cQuery	+= "    AND DRT.DRT_CLIFAT BETWEEN '" + MV_PAR03       + "' AND '" + MV_PAR05       + "' " + CRLF
		cQuery	+= "    AND DRT.DRT_LOJFAT BETWEEN '" + MV_PAR04       + "' AND '" + MV_PAR06       + "' " + CRLF
		cQuery	+= "    AND DRT.DRT_DTEMIS BETWEEN '" + Dtos(MV_PAR07) + "' AND '" + cPar08 + "' " + CRLF
		cQuery	+= "    AND DRT.D_E_L_E_T_ = ' ' "                                                         + CRLF

	EndIf

	cQuery := ChangeQuery(cQuery)

	If Select(cAliasFat) > 0
		(cAliasFat)->(dbCloseArea())
	EndIf

	DbUseArea(.T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasFat, .T., .T.)

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PesqDoc
Query com os documentos referentes a fatura
@type function
@protected
@author Rafael Souza
@version 12
@since 01/09/2016
@param [cAliasFat] , Caracter, Alias que está posicionado na fatura
@return Nil Não há retorno
@obs Alterado por Guilherme Eduardo Bittencourt (guilherme.eduardo) em 30/05/2017 para
@obs adaptar a impressão de faturas quando o ERP integrado seja o Datasul
/*/
//-------------------------------------------------------------------------------------------------
Static Function PesqDoc(cAliasFat, nDecr, nAcr)
	
Local cQuery      := ""
Local cQryFrom    := ""
Local cPrefix     := ""
Local cNum        := ""
Local cTipo       := ""
Local cTmsERP     := SuperGetMV("MV_TMSERP",,'0')
Local cAliasQry   := GetNextAlias()
Local cIn         := ""
Local cAliasVal   := GetNextAlias()
Local cFilDeb	  := ""
Local cCliFat 	  := ""    
Local cLojFat     := ""   
Local aDocTms	  := {} 
	
Default nDecr    := 0
Default nAcr     := 0

If cTmsERP == '0' //-- ERP Protheus
	cPrefix := (cAliasFat)->E1_PREFIXO
	cNum    := (cAliasFat)->E1_NUM
	cTipo   := (cAliasFat)->E1_TIPO
	cFilDeb := (cAliasFat)->E1_FILDEB
	cCliFat := (cAliasFat)->E1_CLIENTE 
	cLojFat := (cAliasFat)->E1_LOJA	
ElseIf cTmsERP == '1' //-- ERP Datasul
	cPrefix := Space(TamSX3("E1_PREFIXO")[2])
	cNum    := (cAliasFat)->DRT_NUM
	cTipo   := Space(TamSX3("E1_TIPO")[2])
	cFilDeb := (cAliasFat)->DRT_FILDEB
	cCliFat := (cAliasFat)->DRT_CLIFAT 
	cLojFat := (cAliasFat)->DRT_LOJFAT 
EndIf

// Adicionada condição para buscar somente os documentos do tipo 2 e 5 na existencia de documentos de apoio da fatura.
cQuery   := " SELECT DT6_DOCTMS "                            + CRLF
cQryFrom := " FROM " + RetSqlName("DT6")                     + CRLF
cQryFrom += " WHERE D_E_L_E_T_ = ' ' "                       + CRLF
cQryFrom += "    AND DT6_FILIAL = '" + xFilial("DT6") + "' " + CRLF
cQryFrom += "    AND DT6_FILDEB = '" + cFilDeb + "' "
cQryFrom += "    AND DT6_CLIDEV = '" + cCliFat + "' " 
cQryFrom += "    AND DT6_LOJDEV = '" + cLojFat + "' " 
cQryFrom += "    AND DT6_PREFIX = '" + cPrefix + "' "        + CRLF
cQryFrom += "    AND DT6_NUM    = '" + cNum    + "' "        + CRLF
cQryFrom += "    AND DT6_TIPO   = '" + cTipo   + "' "        + CRLF
cQuery   += cQryFrom
cQuery   += "    AND DT6_DOCTMS IN ('1','2','5','6','7','8','9','A','D','E','F','G','J','K','L','M','P')        "        + CRLF
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())

    If aScan(aDocTms, {|x| x == (cAliasQry)->DT6_DOCTMS }) == 0
        AAdd(aDocTms, (cAliasQry)->DT6_DOCTMS)
        cIn += "'"+ (cAliasQry)->DT6_DOCTMS +"'"
        // Adiciona a ','
        If (cAliasQry)->(!Eof())
            cIn += ","
        EndIf
    EndIf
    (cAliasQry)->(dbSkip()) 
EndDo

(cAliasQry)->(dbCloseArea())
If !Empty(cIn)
    cIn := SubStr(cIn, 1,Len(cIn)-1)
EndIf

// Soma Acrescimo e Decrescimo na fatura
cQuery   := " SELECT SUM(DT6_DECRES) DT6_DECRES, SUM(DT6_ACRESC) DT6_ACRESC "  
cQuery += " FROM " + RetSqlName("DT6")                     + CRLF
cQuery += " WHERE D_E_L_E_T_ = ' ' "                       + CRLF
cQuery += "    AND DT6_FILIAL = '" + xFilial("DT6") + "' " + CRLF
cQuery += "    AND DT6_PREFIX = '" + cPrefix + "' "        + CRLF
cQuery += "    AND DT6_NUM    = '" + cNum    + "' "        + CRLF
cQuery += "    AND DT6_TIPO   = '" + cTipo   + "' "        + CRLF
   
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasVal, .F., .T.)
	
If !(cAliasVal)->(Eof())
	nDecr := (cAliasVal)->DT6_DECRES
	nAcr  := (cAliasVal)->DT6_ACRESC
EndIf
(cAliasVal)->(dbCloseArea())

cQuery := " SELECT DT6_DATEMI, "                           + CRLF
cQuery += "        DT6_FILORI, "                           + CRLF
cQuery += "        DT6_FILDES, "                           + CRLF
cQuery += " CASE WHEN DT6_NFELET = '' THEN DT6_DOC WHEN "  + CRLF        
cQuery += " DT6_NFELET <> '' THEN DT6_NFELET END DT6_DOC," + CRLF
cQuery += "        DT6_VALIMP, "                           + CRLF
cQuery += "        DT6_VALTOT, "                           + CRLF
cQuery += "        DT6_DOCTMS, "                           + CRLF
cQuery += "        DT6_SERIE   "                           + CRLF
cQuery += cQryFrom
If !Empty(cIn)
	cQuery   += "    AND DT6_DOCTMS IN ("+ cIn +")   "     + CRLF
EndIf

cQuery := ChangeQuery(cQuery)
	
If Select("TRBDT6") > 0
	TRBDT6->(dbCloseArea())
EndIf

DbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), "TRBDT6", .T., .T.)

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtzStaFat
Atualiza o status da fatura
@type function
@protected
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 30/05/2017
@param [cAliasFat], Caracter, Alias que está posicionado na fatura
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Static Function AtzStaFat(cAliasFat)
	
	Local aArea   := {}
	Local lRet    := .F.
	Local cTmsERP := SuperGetMV("MV_TMSERP",,'0')

	If cTmsERP == '0' //-- ERP Protheus
		
		aArea := SE1->(GetArea())

		SE1->(DbSetOrder(1)) //-- Prefixo + No.Titulo + Parcela + Tipo
		If SE1->(MsSeek(xFilial("SE1") + (cAliasFat)->E1_PREFIXO + (cAliasFat)->E1_NUM))
			RecLock("SE1", .F.)
			SE1->E1_SITFAT := StrZero(2, Len(SE1->E1_SITFAT)) //-- 2 - Fatura impressa
			SE1->(MsUnLock())
		EndIf

		RestArea(aArea)

	ElseIf cTmsERP == '1' //-- ERP Datasul

		aArea := DRT->(GetArea())

		DRT->(DbSetOrder(1))
		If DRT->(MsSeek(xFilial("DRT") + (cAliasFat)->DRT_NUM))
			RecLock("DRT", .F.)
			DRT->DRT_STATUS := "7" //-- 7 - Fatura impressa
			DRT->(MsUnLock())
		EndIf

		RestArea(aArea)

	EndIf

Return lRet
