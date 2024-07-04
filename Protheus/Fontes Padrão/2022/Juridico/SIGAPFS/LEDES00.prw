#INCLUDE "LEDES00.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} LEDES98
Geração de arquivos E-billing 2000 - XML.

@author SISJURI
@since 10/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function LEDES00(cFatura, cCodEsc, cMoeEbi, cNArq, cDArq, lAutomato)
Local oDlg        := Nil
Local oNArquivo   := Nil
Local oDArquivo   := Nil
Local oEscri      := Nil
Local oFatura     := Nil
Local oMoeda      := Nil
Local aButtons    :={}
Local cDArquivo   := GetSrvProfString("RootPath", "") + "\"
Local cNArquivo   := cEmpAnt + cFilAnt + __cUserId
Local oLayer      := FWLayer():New()
Local cEscri      := Space(TamSx3('NS7_COD')[1])
Local aRetArq     := {.T., ""}
Local cF3         := RetSXB()

Default cFatura   := ""
Default cCodesc   := ""
Default cNArq     := ""
Default cDArq     := ""
Default cMoeEbi   := ""
Default lAutomato := .F.

If lAutomato
	aRetArq := RunQuery(cFatura, cCodEsc, cMoeEbi, cNArq, cDArq, lAutomato)
Else
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010,0 TO 250,500 PIXEL //"Geração de Arquivo XML LEDES2000"

	oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar

	oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer

	oDlg:lEscClose := .F.

	oNArquivo := TJurPnlCampo():New(05,20,200,20, oLayer:GetColPanel( 'MainColl' ), STR0002,, {|| }, {|| cNArquivo := oNArquivo:GetValue() }, Space(50),,,) //"Nome do Arquivo:"
	oNArquivo:SetHelp(STR0026) //"Indique o nome do arquivo a ser gerado."
	oDArquivo := TJurPnlCampo():New(32,20,130,20, oLayer:GetColPanel( 'MainColl' ), STR0003,, {|| }, {|| cDArquivo := oDArquivo:GetValue() }, Space(100),,,) //"Informe o caminho"
	oDArquivo:SetHelp(STR0027) //"Indique o caminho para geração do arquivo."

	oEscri    := TJurPnlCampo():New(59,20,40,20,oLayer:GetColPanel( 'MainColl' ),STR0004,'NS7_COD',{|| },{|| cEscri := oEscri:GetValue()},,,, 'NS7')      //"Cod.Escrit.:"
	oEscri:SetValid( {|| Empty(oEscri:GetValue()) .Or. ExistCpo('NS7', oEscri:GetValue(), 1) .And. JEBillMoe(oEscri, oFatura, oMoeda) } )
	oEscri:SetHelp(STR0028) //"Código do escritório da fatura para a qual será gerado o arquivo e-billing."

	oFatura := TJurPnlCampo():New(59,90,60,20,oLayer:GetColPanel( 'MainColl' ),STR0005,'NXA_COD',{|| },{|| },,,, cF3) //"Fatura:"
	oFatura:SetValid( {|| Empty(oFatura:GetValue()) .Or. (ExistCpo('NXA', oEscri:GetValue() + oFatura:GetValue(), 1) .And. JEBillFatCanc(oEscri, oFatura) .And. JEBILLMOE(oEscri, oFatura, oMoeda)) } )
	oFatura:oCampo:bWhen   := {|| !Empty(oEscri:GetValue())}
	oFatura:SetHelp(STR0029) //"Código da fatura para a qual será gerado o arquivo e-billing."
	oFatura:Refresh()

	oMoeda := TJurPnlCampo():New(59,180,40,20, oLayer:GetColPanel( 'MainColl' ), STR0021, 'CTO_MOEDA',{|| },{|| },,,, 'CTO') //"Moeda E-billing:"		
	oMoeda:SetHelp(STR0030) //"Código da moeda com a qual será gerado o arquivo e-billing."
	oMoeda:SetValid( {|| Empty(oMoeda:GetValue()) .Or. ExistCpo('CTO', oMoeda:GetValue(), 1) } )

	oBtDir :=	TButton():New( 42,160,"...", oLayer:GetColPanel( 'MainColl' ), {||oDArquivo:SetValue(AllTrim(cGetFile("*.*", STR0008, 0,, .T., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE)))},10,10,,,, .T.)//"Selecione o Diretorio p/ gerar o Arquivo"

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| Iif(!Empty(oEscri:GetValue()) .And. !Empty(oFatura:GetValue()) .And. !Empty(oMoeda:GetValue()),;
													MsgRun( STR0009, STR0010, {|| aRetArq := RunQuery( oFatura:GetValue(), cEscri, oMoeda:GetValue(), oNArquivo:GetValue(), oDArquivo:GetValue(), lAutomato ) } ) ,Alert(STR0006,STR0007) )},{||oDlg:End()},,aButtons) //"Processando arquivo TXT"###"Aguarde..."
EndIf

Return (aRetArq)

//-------------------------------------------------------------------
/*/{Protheus.doc} RunQuery
Montagem das querys com campos dinâmicos.

@author SISJURI
@since 10/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RunQuery(cFatura, cCodEsc, cMoeEbi, cNArq, cDArq, lAutomato)
Local aArea           := GetArea()
Local cCodFatura      := ""
Local cCodEscrit      := ""
Local cQryPrin        := ""
Local cTrbPrin        := ""
Local cQryMatter      := ""
Local cTrbMatter      := ""
Local cQryTkSum       := ""
Local cTrbTkSum       := ""
Local cQryFee         := ""
Local cTrbFee         := ""
Local cQryExpens      := ""
Local cTrbExpens      := ""
Local cCodChv         := ""
Local nPercFat        := 0
Local nMTotDetFees    := 0
Local nMTotDetExp     := 0
Local nMNetFees       := 0
Local nMNetExp        := 0
Local nMTotalDue      := 0
Local nMAdjFees       := 0
Local nMInvPayTerms   := 0
Local nMInvGenDisc    := 0
Local nMInvTotDue     := 0
Local nTkCost         := 0

Local cMTotDetFees    := ""
Local cMTotDetExp     := ""
Local cMNetFees       := ""
Local cMNetExp        := ""
Local cMTotalDue      := ""
Local cMAdjFees       := ""
Local cExpRate        := ""

Local nFeeUnit        := 0
Local nFeeRate        := 0
Local nFeeBaseAmount  := 0
Local nFeeTotAmount   := 0
Local nExpRate        := 0
Local nValorH         := 0

Local cFeeUnit        := ""
Local cFeeRate        := ""
Local cFeeBaseAmount  := ""
Local cFeeTotAmount   := ""

Local nExpTotAmount  := 0
Local cExpTotAmount  := ""
Local lTemTS         := .F.
Local lTemDP         := .F.
Local aLog           := {}

Local cMoeFat        := ""
Local cMoeDesc       := ""
Local cDescri        := ""
Local nValor         := 0
Local aValor         := {}
Local aPerFat        := JGetPerFT(cFatura, cCodEsc)
Local aRet           := {.T., ""}
Local cClientePg     := ""
Local cLojaPg        := ""
Local aFatPag     := JurGetDados('NXA', 1, xFilial('NXA') + cCodEsc + cFatura, {'NXA_CMOEDA','NXA_CLIPG','NXA_LOJPG','NXA_CCLIEN','NXA_CLOJA' })

	If Len(aFatPag) > 0
		cMoeFat := aFatPag[1]
		cQryPrin := "SELECT NRX_COD FROM " + RetSQLName("NRX") 
		cQryPrin += " INNER JOIN " + RetSQLName("NUH") +" ON ( NRX_COD = NUH_CEMP AND NUH_LOJA = '" + aFatPag[3] + "') "
		cQryPrin += " WHERE NUH_COD  = '" + aFatPag[2] + "'"
		
		If Len(JurSQL(cQryPrin, 'NRX_COD')) > 0
			// Cliente Pagador
			cClientePg :=  aFatPag[2]
			cLojaPg    :=  aFatPag[3]
		else
			// Cliente da Fatura
			cClientePg :=  aFatPag[4]
			cLojaPg    :=  aFatPag[5]
		EndIf

		cQryPrin := ""
	EndIf

	cMoeEbi := Iif(Empty(cMoeEbi), cMoeFat, cMoeEbi)

	cCodFatura := cFatura
	cCodEscrit := cCodEsc

	cQryPrin := " SELECT ( NXA.NXA_VLFATH - NXA.NXA_VLDESC - NXA_IRRF - NXA_PIS - NXA_COFINS - NXA_CSLL - NXA_INSS - NXA_ISS ) + NXA.NXA_VLFATD AS INV_TOTAL_NET_DUE," 
	cQryPrin +=          " NXA.NXA_CESCR || NXA.NXA_COD AS ESCR_COD, "
	cQryPrin +=          " NXA.*, "
	cQryPrin +=          " NS7.*, "
	cQryPrin +=          " NUH.NUH_CLIEBI, "
	cQryPrin +=          " SU5.U5_CONTAT, "
	cQryPrin +=          " CTO.CTO_DESC, "
	cQryPrin +=          " RD0.RD0_NOME, "
	cQryPrin +=          " SYA.YA_DESCR, "
	cQryPrin +=          " NXA.R_E_C_N_O_ AS RECNO_NXA, "
	cQryPrin +=          " CC2.CC2_MUN "
	cQryPrin +=    " FROM  "+ RetSqlName("NXA") + " NXA "
	cQryPrin +=    " INNER JOIN "+RetSqlname("NUH")+" NUH  "
	cQryPrin +=         " ON ( NUH.NUH_FILIAL = '"+xFilial("NUH")+"'"
	cQryPrin +=              " AND NUH.NUH_COD = '" + cClientePg + "'"
	cQryPrin +=              " AND NUH.NUH_LOJA ='" + cLojaPg + "'"
	cQryPrin +=              " AND NUH.D_E_L_E_T_ = ' ')  "
	cQryPrin +=    " INNER JOIN "+RetSqlname("NRX")+" NRX  "
	cQryPrin +=         " on( NRX.NRX_FILIAL     = '"+xFilial("NRX")+"'"
	cQryPrin +=         " AND NRX.NRX_COD    = NUH.NUH_CEMP "
	cQryPrin +=         " AND NRX.D_E_L_E_T_ = ' ')  "
	cQryPrin +=    " LEFT join " + RetSqlName("SU5") + " SU5 "
	cQryPrin +=          " ON ( SU5.U5_FILIAL  = '" + xFilial("SU5") + "' "
	cQryPrin +=          " AND SU5.U5_CODCONT = NXA.NXA_CCONT "
	cQryPrin +=          " AND SU5.D_E_L_E_T_ = ' ' ) "
	cQryPrin +=    " LEFT join " + RetSqlName("NS7") + " NS7  "
	cQryPrin +=          " ON ( NS7.NS7_FILIAL = '" + xFilial("NS7") + "' "
	cQryPrin +=          " AND NS7.NS7_COD    = NXA.NXA_CESCR "
	cQryPrin +=          " AND NS7.D_E_L_E_T_ = ' ' ) "
	cQryPrin +=    " LEFT join " + RetSqlName("CC2") + " CC2  "
	cQryPrin +=          " ON ( CC2.CC2_FILIAL = '" + xFilial("CC2") + "' "
	cQryPrin +=          " AND CC2.CC2_CODMUN  = NS7.NS7_CMUNIC "
	cQryPrin +=          " AND CC2.CC2_EST = NS7.NS7_ESTADO "
	cQryPrin +=          " AND CC2.D_E_L_E_T_ = ' ') "
	cQryPrin +=    " LEFT join " + RetSqlName("SYA") + " SYA  "
	cQryPrin +=          " ON ( SYA.YA_FILIAL  = '" + xFilial("SYA") + "' "
	cQryPrin +=          " AND SYA.YA_CODGI   = NS7.NS7_CPAIS "
	cQryPrin +=          " AND SYA.D_E_L_E_T_ = ' ') "
	cQryPrin +=    " LEFT join " + RetSqlName("CTO") + " CTO  "
	cQryPrin +=          " ON ( CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQryPrin +=          " AND CTO.CTO_MOEDA  = NXA.NXA_CMOEDA "
	cQryPrin +=          " AND CTO.D_E_L_E_T_ = ' ') "
	cQryPrin +=    " LEFT join " + RetSqlName("RD0") + " RD0  "
	cQryPrin +=          " ON ( RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQryPrin +=          " AND NXA.NXA_CPART  = RD0.RD0_CODIGO "
	cQryPrin +=          " AND RD0.D_E_L_E_T_ = ' ') "
	cQryPrin +=    " where NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQryPrin +=      " AND NXA.NXA_COD    = '" + cFatura + "' "
	cQryPrin +=      " AND NXA.NXA_CESCR  = '" + cCodEsc + "' "
	cQryPrin +=      " AND NXA.D_E_L_E_T_ = ' ' "

	If Select("TRBPRIN")>0
		DbSelectArea("TRBPRIN")
		TRBPRIN->(DbCloseArea())
	EndIf

	cTRBPRIN := ChangeQuery(cQryPrin)
	cTRBPRIN := StrTran(cTRBPRIN,'#','')
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBPRIN ) ,"TRBPRIN", .T., .F.)

	aArqXml:={}
	DbSelectArea("TRBPRIN")
	If TRBPRIN->(!Eof())
		Aadd(aArqXml,"<?xml version='1.0' encoding='UTF-8' ?>")
		Aadd(aArqXml,"<!-- ledes2000 Abril 2009 -->")
		Aadd(aArqXml,"<!DOCTYPE ledesxml SYSTEM 'http://www.ledes.org/ledes2000.dtd'>")
		Aadd(aArqXml,"<ledesxml>")
		
		Do While TRBPRIN->(!Eof()) .And. aRet[1]
			cCodChv := TRBPRIN->NS7_COD
			
			Do While TRBPRIN->(!Eof()) .And. cCodChv == TRBPRIN->NS7_COD .And. aRet[1]
				
				Aadd(aArqXml,Space(3)+"<firm>")
				If !Empty(TRBPRIN->NS7_COD)
					Aadd(aArqXml,Space(6)+"<if_tax_id>"+Alltrim(TRBPRIN->NS7_COD)+"</if_tax_id>")//Obrigatorio
					Aadd(aArqXml,Space(6)+"<if_id>"+Alltrim(TRBPRIN->NS7_COD)+"</if_id>")        //Opcional
				EndIf
				If !Empty(TRBPRIN->NS7_NOME)
					Aadd(aArqXml,Space(6)+"<if_name>"+Alltrim(TRBPRIN->NS7_NOME)+"</if_name>")   //Obrigatorio
				EndIf
				//=========================================
				//OBRIGATORIO
				//=========================================
				Aadd(aArqXml,Space(6)+"<if_address>")
				Aadd(aArqXml,Space(9)+"<address_info>")
				If !Empty(TRBPRIN->NS7_END)
					Aadd(aArqXml,Space(12)+"<address_1>"+Alltrim(TRBPRIN->NS7_END)+"</address_1>")
				EndIf
				If !Empty(TRBPRIN->CC2_MUN)
					Aadd(aArqXml,Space(12)+"<city>"+Alltrim(TRBPRIN->CC2_MUN)+"</city>")
				EndIf
				If !Empty(TRBPRIN->NS7_ESTADO)
					Aadd(aArqXml,Space(12)+"<state_province>"+Alltrim(TRBPRIN->NS7_ESTADO)+"</state_province>")
				EndIf
				If !Empty(TRBPRIN->NS7_CEP)
					Aadd(aArqXml,Space(12)+"<zip_postal_code>"+Alltrim(TRBPRIN->NS7_CEP)+"</zip_postal_code>")
				EndIf
				If !Empty(TRBPRIN->NS7_TEL)
					Aadd(aArqXml,Space(12)+"<phone>"+Alltrim(TRBPRIN->NS7_TEL)+"</phone>")
					Aadd(aArqXml,Space(12)+"<fax>"+Alltrim(TRBPRIN->NS7_TEL)+"</fax>")
				EndIf
				Aadd(aArqXml,Space(9)+"</address_info>")
				Aadd(aArqXml,Space(6)+"</if_address>")
				//=========================================
				//OPCIONAL
				//=========================================
				Aadd(aArqXml,Space(6)+"<if_remit_address>")
				Aadd(aArqXml,Space(9)+"<address_info>")
				If !Empty(TRBPRIN->NS7_END)
					Aadd(aArqXml,Space(12)+"<address_1>"+Alltrim(TRBPRIN->NS7_END)+"</address_1>")
				EndIf
				If !Empty(TRBPRIN->CC2_MUN)
					Aadd(aArqXml,Space(12)+"<city>"+Alltrim(TRBPRIN->CC2_MUN)+"</city>")
				EndIf
				If !Empty(TRBPRIN->NS7_ESTADO)
					Aadd(aArqXml,Space(12)+"<state_province>"+Alltrim(TRBPRIN->NS7_ESTADO)+"</state_province>")
				EndIf
				If !Empty(TRBPRIN->NS7_CEP)
					Aadd(aArqXml,Space(12)+"<zip_postal_code>"+Alltrim(TRBPRIN->NS7_CEP)+"</zip_postal_code>")
				EndIf
				If !Empty(TRBPRIN->NS7_TEL)
					Aadd(aArqXml,Space(12)+"<phone>"+Alltrim(TRBPRIN->NS7_TEL)+"</phone>")
					Aadd(aArqXml,Space(12)+"<fax>"+Alltrim(TRBPRIN->NS7_TEL)+"</fax>")
				EndIf
				Aadd(aArqXml,Space(9)+"</address_info>")
				Aadd(aArqXml,Space(6)+"</if_remit_address>")
				//=========================================
				//OPCIONAL
				//=========================================
				If !Empty(TRBPRIN->NS7_CTNAC)
					Aadd(aArqXml,Space(6)+"<if_billing_contact_lname>"+ RetFLName(1, TRBPRIN->NS7_CTNAC)+"</if_billing_contact_lname>")
					Aadd(aArqXml,Space(6)+"<if_billing_contact_fname>"+RetFLName(2,TRBPRIN->NS7_CTNAC)+"</if_billing_contact_fname>")
				EndIf
				If !Empty(TRBPRIN->NXA_CPART)
					Aadd(aArqXml,Space(6)+"<if_billing_contact_id>"+Alltrim(TRBPRIN->NXA_CPART)+"</if_billing_contact_id>")
				EndIf
				If !Empty(TRBPRIN->NS7_TEL)
					Aadd(aArqXml,Space(6)+"<if_billing_contact_phone>"+Alltrim(TRBPRIN->NS7_TEL)+"</if_billing_contact_phone>")
					Aadd(aArqXml,Space(6)+"<if_billing_contact_fax>"+Alltrim(TRBPRIN->NS7_TEL)+"</if_billing_contact_fax>")
				EndIf
				If !Empty(TRBPRIN->NS7_EMAIL)
					Aadd(aArqXml,Space(6)+"<if_billing_contact_email>"+Alltrim(TRBPRIN->NS7_EMAIL)+"</if_billing_contact_email>")
				EndIf
				//=========================================
				//OBRIGATORIO
				//=========================================
				Aadd(aArqXml,Space(6)+"<source_app>SIGAPFS</source_app>")
				Aadd(aArqXml,Space(6)+"<app_version>"+GetRpoRelease()+"</app_version>")
				//=========================================
				//OPCIONAL-INCLUIR QDO POSSUI INFORMACAO
				//DEFINIDA PARA A TAG EXTEND
				//=========================================
				//Aadd(aArqXml,Space(6)+"<extend_header vendor='Examen' app='billview' sequence='0' date='20000301'>")
				//Aadd(aArqXml,Space(9)+"<extend_data>")
				//Aadd(aArqXml,Space(12)+"<ext_name> </ext_name>")
				//Aadd(aArqXml,Space(12)+"<ext_value> </ext_value>")
				//Aadd(aArqXml,Space(9)+"</extend_data>")
				//Aadd(aArqXml,Space(6)+"</extend_header>")
				//=========================================
				Aadd(aArqXml,Space(3)+"</firm>")
				
				Do While TRBPRIN->(!Eof()) .And. cCodChv == TRBPRIN->NS7_COD .And. aRet[1]
					
					Aadd(aArqXml,Space(3)+"<client>")
					If !Empty(TRBPRIN->NXA_CCLIEN+TRBPRIN->NXA_CLOJA) .Or. !Empty(TRBPRIN->NUH_CLIEBI)
						Aadd(aArqXml,Space(6)+"<cl_id>"+Alltrim(Iif(Empty(TRBPRIN->NUH_CLIEBI), TRBPRIN->NXA_CCLIEN+TRBPRIN->NXA_CLOJA, TRBPRIN->NUH_CLIEBI))+"</cl_id>") //Opcional
					EndIf
					If !Empty(TRBPRIN->NXA_RAZSOC)
						Aadd(aArqXml,Space(6)+"<cl_name>"+Alltrim(TRBPRIN->NXA_RAZSOC)+"</cl_name>")               //Obrigatorio
					EndIf
					//=========================================
					//OBRIGATORIO
					//=========================================
					Aadd(aArqXml,Space(9)+"<cl_address>")
					Aadd(aArqXml,Space(12)+"<address_info>")
					If !Empty(TRBPRIN->NXA_ENDENT)
						Aadd(aArqXml,Space(15)+"<address_1>"+Alltrim(TRBPRIN->NXA_ENDENT)+"</address_1>")
					EndIf
					If !Empty(TRBPRIN->CC2_MUN)
						Aadd(aArqXml,Space(15)+"<city>"+Alltrim(TRBPRIN->CC2_MUN)+"</city>")
					EndIf
					If !Empty(TRBPRIN->NS7_ESTADO)
						Aadd(aArqXml,Space(15)+"<state_province>"+Alltrim(TRBPRIN->NS7_ESTADO)+"</state_province>")
					EndIf
					If !Empty(TRBPRIN->NS7_CEP)
						Aadd(aArqXml,Space(15)+"<zip_postal_code>"+Alltrim(TRBPRIN->NS7_CEP)+"</zip_postal_code>")
					EndIf
					If !Empty(TRBPRIN->NS7_TEL)
						Aadd(aArqXml,Space(15)+"<phone>"+Alltrim(TRBPRIN->NS7_TEL)+"</phone>")
						Aadd(aArqXml,Space(15)+"<fax>"+Alltrim(TRBPRIN->NS7_TEL)+"</fax>")
					EndIf
					Aadd(aArqXml,Space(12)+"</address_info>")
					Aadd(aArqXml,Space(9)+"</cl_address>")
					//=========================================
					//OPCIONAL
					//=========================================
					If !Empty(TRBPRIN->NXA_EMAIL)
						Aadd(aArqXml,Space(6)+"<cl_email>"+Alltrim(TRBPRIN->NXA_EMAIL)+"</cl_email>")
					EndIf
					If !Empty(TRBPRIN->U5_CONTAT)
						Aadd(aArqXml,Space(6)+"<cl_contact_lname>"+RetFLName(1, TRBPRIN->U5_CONTAT)+"</cl_contact_lname>")
						Aadd(aArqXml,Space(6)+"<cl_contact_fname>"+RetFLName(2, TRBPRIN->U5_CONTAT)+"</cl_contact_fname>")
					EndIf
					If !Empty(TRBPRIN->NXA_CCLIEN+TRBPRIN->NXA_CLOJA)
						Aadd(aArqXml,Space(6)+"<cl_tax_id>"+Alltrim(TRBPRIN->NXA_CCLIEN+TRBPRIN->NXA_CLOJA)+"</cl_tax_id>")
					EndIf
					//=========================================
					Aadd(aArqXml,Space(9)+"<invoice>")
					If !Empty(TRBPRIN->NXA_COD)
						Aadd(aArqXml,Space(12)+"<inv_id>"+Alltrim(TRBPRIN->NXA_COD)+"</inv_id>")                              //Obrigatorio
					EndIf
					If !Empty(TRBPRIN->NXA_DTEMI)
						Aadd(aArqXml,Space(12)+"<inv_date>"+Alltrim(TRBPRIN->NXA_DTEMI)+"</inv_date>")                        //Obrigatorio
						Aadd(aArqXml,Space(12)+"<inv_due_date>"+Alltrim(TRBPRIN->NXA_DTEMI)+"</inv_due_date>")                //Opcional
					EndIf
					
					If cMoeEbi != cMoeFat
						cMoeDesc := JurGetDados('CTO',1,xFilial('CTO')+ cMoeEbi, 'CTO_DESC')
					Else
						cMoeDesc := (TRBPRIN->CTO_DESC)
					EndIf
					
					If !Empty(cMoeDesc)
						Aadd(aArqXml,Space(12)+"<inv_currency>"+Alltrim(cMoeDesc)+"</inv_currency>")                 //Opcional
					EndIf
					If !Empty(aPerFat)
						Aadd(aArqXml,Space(12)+"<inv_start_date>" + IIf(Len(aPerFat) > 1, Alltrim(DtoS(aPerFat[1])), aPerFat[1][1]) + "</inv_start_date>")                     //Obrigatorio
						Aadd(aArqXml,Space(12)+"<inv_end_date>" + IIf(Len(aPerFat) > 1, Alltrim(DtoS(aPerFat[2])), aPerFat[1][2]) + "</inv_end_date>")                         //Obrigatorio
					EndIf
					NXA->( dbGoTo( TRBPRIN->RECNO_NXA ) )
					cDescri := StrTran(NXA->NXA_TXTFAT, CRLF, " ")
					If !Empty(cDescri)
						Aadd(aArqXml,Space(12)+"<inv_desc>"+Alltrim(cDescri)+"</inv_desc>")                                  //Opcional
					EndIf
					
					dEmiFat :=  StoD(TRBPRIN->NXA_DTEMI) //JurGetDados('NXA',1,xFilial('NXA')+ cEscri + cFatura, 'NXA_DTEMI')
					
					nMInvPayTerms := TRBPRIN->NXA_VLDESC
					aValor := JA201FConv( cMoeEbi, cMoeFat, nMInvPayTerms, '8', dEmiFat, , , , cCodEsc, cFatura )
					If !Empty(aValor[4])
						IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
						aRet[1] := .F.
						Exit
					Else
						nMInvPayTerms := Round(aValor[1],2)
					EndIf
					
					nMInvTotDue   := TRBPRIN->INV_TOTAL_NET_DUE
					aValor := JA201FConv( cMoeEbi, cMoeFat, nMInvTotDue, '8', dEmiFat, , , , cCodEsc, cFatura )
					If !Empty(aValor[4])
						IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
						aRet[1] := .F.
						Exit
					Else
						nMInvTotDue := Round(aValor[1], 2)
					EndIf
					
					nMInvGenDisc  := TRBPRIN->(NXA_IRRF+NXA_PIS+NXA_COFINS+NXA_CSLL+NXA_INSS+NXA_ISS)
					aValor := JA201FConv( cMoeEbi, cMoeFat, nMInvGenDisc, '8', dEmiFat, , , , cCodEsc, cFatura )
					If !Empty(aValor[4])
						IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
						aRet[1] := .F.
						Exit
					Else
						nMInvGenDisc := Round(aValor[1],2)
					EndIf
					
					Aadd(aArqXml,Space(12)+"<inv_payment_terms>"+Alltrim(Str(nMInvPayTerms))+"</inv_payment_terms>")//Opcional
					Aadd(aArqXml,Space(12)+"<inv_generic_discount>"+Alltrim(Str(nMInvGenDisc))+"</inv_generic_discount>")//Opcional
					Aadd(aArqXml,Space(12)+"<inv_total_net_due>"+Alltrim(Str(nMInvTotDue))+"</inv_total_net_due>")//Obrigatorio
					
					cQryMatter := " SELECT NXC.NXC_CESCR||NXC.NXC_CFATUR AS ESCR_COD, " + CRLF
					cQryMatter += "        NXC.*, " + CRLF
					cQryMatter += "        NVE.NVE_TITULO, NVE.NVE_CPGEBI, NVE.NVE_MATTER, NVE.NVE_TITEBI, NT7.NT7_TITULO " + CRLF
					cQryMatter += "   FROM " + RetSqlname("NXC") + " NXC " + CRLF
					cQryMatter += "  INNER JOIN " + RetSqlname("NVE") + " NVE  " + CRLF
					cQryMatter += "     ON (NVE.NVE_FILIAL = '" + xFilial("NVE") + "' " + CRLF
					cQryMatter += "    AND  NXC.NXC_CCLIEN = NVE.NVE_CCLIEN " + CRLF
					cQryMatter += "    AND  NXC.NXC_CLOJA  = NVE.NVE_LCLIEN " + CRLF
					cQryMatter += "    AND  NXC.NXC_CCASO  = NVE.NVE_NUMCAS " + CRLF
					cQryMatter += "    AND  NVE.D_E_L_E_T_ = ' ') " + CRLF
					cQryMatter += "   LEFT OUTER JOIN " + RetSqlname("NT7") + " NT7  " + CRLF
					cQryMatter += "     ON (NT7.NT7_FILIAL = '" + xFilial("NT7") + "' " + CRLF
					cQryMatter += "    AND  NXC.NXC_CCLIEN = NT7.NT7_CCLIEN" + CRLF
					cQryMatter += "    AND  NXC.NXC_CLOJA  = NT7.NT7_CLOJA" + CRLF
					cQryMatter += "    AND  NXC.NXC_CCASO  = NT7.NT7_CCASO" + CRLF
					cQryMatter += "    AND  NT7.NT7_CIDIOM = '" + TRBPRIN->NXA_CIDIO + "' " + CRLF
					cQryMatter += "    AND  NT7.NT7_REV    = '1'" + CRLF
					cQryMatter += "    AND  NT7.D_E_L_E_T_ = ' ') " + CRLF
					cQryMatter += "  WHERE NXC.NXC_FILIAL = '" + xFilial("NXC") + "'  " + CRLF
					cQryMatter += "    AND NXC.NXC_CESCR  = '" + TRBPRIN->NXA_CESCR + "' " + CRLF
					cQryMatter += "    AND NXC.NXC_CFATUR = '" + TRBPRIN->NXA_COD + "' " + CRLF
					cQryMatter += "    AND NXC.D_E_L_E_T_ = ' ' " + CRLF
					
					If Select("TRBMATT")>0
						DbSelectArea("TRBMATT")
						TRBMATT->(DbCloseArea())
					EndIf
					
					cTRBMatter := ChangeQuery(cQryMatter)
					dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBMatter ), "TRBMATT", .T., .F.)
					
					//Percentual do pagador da fatura
					nPercFat := (TRBPRIN->NXA_PERFAT / 100)
					
					DbSelectArea("TRBMATT")
					TRBMATT->(dbGoTop())
					
					If TRBMATT->(!Eof())
						Aadd(aArqXml,Space(12)+"<matter>")
						
						Do While TRBMATT->(!Eof()) .And. aRet[1]
							If !Empty(TRBMATT->NVE_CPGEBI)
								Aadd(aArqXml,Space(15)+"<cl_matter_id>"+Alltrim(TRBMATT->NVE_CPGEBI)+"</cl_matter_id>")//Opcional
							EndIf
							If Empty(TRBMATT->NVE_MATTER)
								JurEbilLog(aLog, "<lf_matter_id>", STR0025 + TRBMATT->(NXC_CCLIEN+'/'+NXC_CLOJA+'/'+NXC_CCASO)+ CRLF + STR0022 +"<lf_matter_id>"+ STR0023 +'"'+ RetTitle('NVE_MATTER') +'"'+ STR0024 ) //#"A tag obrigatória " ## " referente ao campo "### " não foi prenchida!"
							EndIf
							Aadd(aArqXml,Space(15)+"<lf_matter_id>"+Alltrim(TRBMATT->NVE_MATTER)+"</lf_matter_id>")//Obrigatorio
							
							If !Empty(TRBMATT->NVE_TITEBI)
								Aadd(aArqXml,Space(15)+"<matter_name>"+Alltrim(TRBMATT->NVE_TITEBI)+"</matter_name>")//Obrigatorio
								Aadd(aArqXml,Space(15)+"<matter_desc>"+Alltrim(TRBMATT->NVE_TITEBI)+"</matter_desc>")//Opcional
							Else
								If !Empty(TRBMATT->NT7_TITULO)
									Aadd(aArqXml,Space(15)+"<matter_name>"+Alltrim(TRBMATT->NT7_TITULO)+"</matter_name>")//Obrigatorio
									Aadd(aArqXml,Space(15)+"<matter_desc>"+Alltrim(TRBMATT->NT7_TITULO)+"</matter_desc>")//Opcional
								Else
									Aadd(aArqXml,Space(15)+"<matter_name>"+Alltrim(TRBMATT->NVE_TITULO)+"</matter_name>")//Obrigatorio
									Aadd(aArqXml,Space(15)+"<matter_desc>"+Alltrim(TRBMATT->NVE_TITULO)+"</matter_desc>")//Opcional
								EndIf
							EndIf
							If !Empty(TRBPRIN->RD0_NOME)
								Aadd(aArqXml,Space(15)+"<lf_managing_contact_lname>"+RetFLName(1, TRBPRIN->RD0_NOME)+"</lf_managing_contact_lname>")//Obrigatorio
								Aadd(aArqXml,Space(15)+"<lf_managing_contact_fname>"+RetFLName(2, TRBPRIN->RD0_NOME)+"</lf_managing_contact_fname>")//Obrigatorio
							EndIf
							//Aadd(aArqXml,Space(15)+"<lf_contact_id></lf_contact_id>")//Opcional
							If !Empty(TRBPRIN->NS7_TEL)
								Aadd(aArqXml,Space(15)+"<lf_contact_phone>"+Alltrim(TRBPRIN->NS7_TEL)+"</lf_contact_phone>")//Opcional
							EndIf
							If !Empty(TRBPRIN->NS7_EMAIL)
								Aadd(aArqXml,Space(15)+"<lf_contact_email>"+Alltrim(TRBPRIN->NS7_EMAIL)+"</lf_contact_email>")//Opcional
							EndIf
							//Aadd(aArqXml,Space(15)+"<cl_matter_var_1> </cl_matter_var_1>")//Opcional
							//Aadd(aArqXml,Space(15)+"<cl_matter_var_2> </cl_matter_var_2>")//Opcional
							If !Empty(TRBPRIN->NS7_CTNAC)
								Aadd(aArqXml,Space(15)+"<cl_contact_lname>"+RetFLName(1,TRBPRIN->NS7_CTNAC)+"</cl_contact_lname>")//Obrigatorio
								Aadd(aArqXml,Space(15)+"<cl_contact_fname>"+RetFLName(2,TRBPRIN->NS7_CTNAC)+"</cl_contact_fname>")//Obrigatorio
							EndIf
							//Aadd(aArqXml,Space(15)+"<cl_contact_id> </cl_contact_id>") //Opcional
							If !Empty(TRBPRIN->NS7_TEL)
								Aadd(aArqXml,Space(15)+"<cl_contact_phone>"+Alltrim(TRBPRIN->NS7_TEL)+"</cl_contact_phone>")//Opcional
							EndIf
							If !Empty(TRBPRIN->NS7_EMAIL)
								Aadd(aArqXml,Space(15)+"<cl_contact_email>"+Alltrim(TRBPRIN->NS7_EMAIL)+"</cl_contact_email>")//Opcional
							EndIf
							
							nMTotDetFees := (TRBMATT->NXC_VLHFAT - TRBMATT->NXC_VLTAB)
							aValor := JA201FConv( cMoeEbi, cMoeFat, nMTotDetFees, '8', dEmiFat, , , , cCodEsc, cFatura )
							If !Empty(aValor[4])
								IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
								aRet[1] := .F.
								Exit
							Else
								nMTotDetFees := Round(aValor[1],2)
								cMTotDetFees := Alltrim(Str(nMTotDetFees))
							EndIf
							
							nMTotDetExp  := (TRBMATT->NXC_VLDESP + TRBMATT->NXC_VLTAB)
							aValor := JA201FConv( cMoeEbi, cMoeFat, nMTotDetExp, '8', dEmiFat, , , , cCodEsc, cFatura )
							If !Empty(aValor[4])
								IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
								aRet[1] := .F.
								Exit
							Else
								nMTotDetExp := Round(aValor[1],2)
								cMTotDetExp := Alltrim(Str(nMTotDetExp ))
							EndIf
							
							nMNetFees    := (TRBMATT->NXC_VLHFAT - TRBMATT->NXC_VLTAB)
							aValor := JA201FConv( cMoeEbi, cMoeFat, nMNetFees, '8', dEmiFat, , , , cCodEsc, cFatura )
							If !Empty(aValor[4])
								IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
								aRet[1] := .F.
								Exit
							Else
								nMNetFees := Round(aValor[1],2)
								cMNetFees := Alltrim(Str(nMNetFees   ))
							EndIf
							
							nMNetExp     := (TRBMATT->NXC_VLDESP + TRBMATT->NXC_VLTAB)
							aValor := JA201FConv( cMoeEbi, cMoeFat, nMNetExp, '8', dEmiFat, , , , cCodEsc, cFatura )
							If !Empty(aValor[4])
								IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
								aRet[1] := .F.
								Exit
							Else
								nMNetExp := Round(aValor[1],2)
								cMNetExp := Alltrim(Str(nMNetExp    ))
							EndIf
							
							nMAdjFees    := (TRBMATT->NXC_DRATF)
							aValor := JA201FConv( cMoeEbi, cMoeFat, nMAdjFees, '8', dEmiFat, , , , cCodEsc, cFatura )
							If !Empty(aValor[4])
								IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
								aRet[1] := .F.
								Exit
							Else
								nMAdjFees := Round(aValor[1],2)
								cMAdjFees := Alltrim(Str(nMAdjFees   ))
							EndIf

							nMTotalDue   := nMNetFees + nMNetExp
							aValor := JA201FConv( cMoeEbi, cMoeFat, nMTotalDue, '8', dEmiFat, , , , cCodEsc, cFatura )
							If !Empty(aValor[4])
								IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
								aRet[1] := .F.
								Exit
							Else
								nMTotalDue := Round(aValor[1],2)
								cMTotalDue := Alltrim(Str(nMTotalDue  ))
							EndIf
							
							//Aadd(aArqXml,Space(15)+"<eft_agreement_number> </eft_agreement_number>")//Opcional
							//Aadd(aArqXml,Space(15)+"<matter_billing_type>TM</matter_billing_type>")//Opcional
							Aadd(aArqXml,Space(15)+"<matter_final_bill>N</matter_final_bill>")//Obrigatorio
							Aadd(aArqXml,Space(15)+"<matter_total_detail_fees>"+cMTotDetFees+"</matter_total_detail_fees>")//Obrigatorio
							Aadd(aArqXml,Space(15)+"<matter_total_detail_exp>"+cMTotDetExp+"</matter_total_detail_exp>")//Obrigatorio
							//Aadd(aArqXml,Space(15)+"<matter_tax_on_fees>0.00</matter_adj_on_fees>")
							//Aadd(aArqXml,Space(15)+"<matter_tax_on_exp>0.00</matter_adj_on_exp>")
							Aadd(aArqXml,Space(15)+"<matter_adj_on_fees>"+cMAdjFees+"</matter_adj_on_fees>")//Obrigatorio
							Aadd(aArqXml,Space(15)+"<matter_adj_on_exp>0.00</matter_adj_on_exp>")//Obrigatorio
							//Aadd(aArqXml,Space(15)+"<matter_perc_shar_fees>0.00</matter_perc_shar_fees>")//Opcional
							//Aadd(aArqXml,Space(15)+"<matter_perc_shar_exp>0.00</matter_perc_shar_exp>")//Opcional
							Aadd(aArqXml,Space(15)+"<matter_net_fees>"+cMNetFees+"</matter_net_fees>")//Obrigatorio
							Aadd(aArqXml,Space(15)+"<matter_net_exp>"+cMNetExp+"</matter_net_exp>")//Obrigatorio
							Aadd(aArqXml,Space(15)+"<matter_total_due>"+cMTotalDue+"</matter_total_due>")//Obrigatorio
							
							cQryTkSum := " select NXD.NXD_CESCR||NXD.NXD_CFATUR as ESCR_COD, " + CRLF
							cQryTkSum += "        NXD.*, " + CRLF
							cQryTkSum += "        RD0.RD0_NOME, " + CRLF
							cQryTkSum += "        NS2.NS2_CCATE, " + CRLF
							cQryTkSum += "        NRV.NRV_CCATE, " + CRLF
							cQryTkSum += "        RD0.RD0_SIGLA, " + CRLF
							//cQryTkSum += "        round(( NXD.NXD_HFREV * ( NXA.NXA_PERFAT / 100 ) ) * NXD.NXD_VLHORA, 2) as TK_COST, " + CRLF
							cQryTkSum += "        NXA.NXA_PERFAT, " + CRLF
							cQryTkSum += "        NUH.NUH_CEMP, " + CRLF
							cQryTkSum += "        NUR.NUR_CCAT " + CRLF
							cQryTkSum += " from   "+RetSqlname("NXA")+" NXA  " + CRLF
							
							cQryTkSum += "        inner join "+RetSqlname("NXD")+" NXD " + CRLF
							cQryTkSum += "             on( NXD.NXD_FILIAL     = '"+xFilial("NXD")+"'" + CRLF
							cQryTkSum += "                 and NXD.NXD_CESCR  = NXA.NXA_CESCR" + CRLF
							cQryTkSum += "                 and NXD.NXD_CFATUR = NXA.NXA_COD" + CRLF
							
							cQryTkSum += "                 and NXD.NXD_CCLIEN = '" +TRBMATT->NXC_CCLIEN+ "'" + CRLF
							cQryTkSum += "                 and NXD.NXD_CLOJA  = '" +TRBMATT->NXC_CLOJA+ "'" + CRLF
							cQryTkSum += "                 and NXD.NXD_CCASO  = '" +TRBMATT->NXC_CCASO+ "'" + CRLF
							
							cQryTkSum += "                 and NXD.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryTkSum += "        inner join "+RetSqlname("RD0")+" RD0 " + CRLF
							cQryTkSum += "             on( RD0.RD0_FILIAL     = '"+xFilial("RD0")+"'" + CRLF
							cQryTkSum += "                 and RD0.RD0_CODIGO = NXD.NXD_CPART" + CRLF
							cQryTkSum += "                 and RD0.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryTkSum += "        inner join "+RetSqlname("NUR")+" NUR " + CRLF
							cQryTkSum += "             on( NUR.NUR_FILIAL     = '"+xFilial("NUR")+"'" + CRLF
							cQryTkSum += "                 and NUR.NUR_CPART  = NXD.NXD_CPART" + CRLF
							cQryTkSum += "                 and NUR.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryTkSum += "        inner join "+RetSqlname("NUH")+" NUH  " + CRLF
							cQryTkSum += "             on( NUH.NUH_FILIAL     = '"+xFilial("NUH")+"'" + CRLF
							cQryTkSum += "                 and NUH.NUH_COD    = '" +cClientePg+ "'"+ CRLF
							cQryTkSum += "                 and NUH.NUH_LOJA   = '" +cLojaPg+ "'"+ CRLF
							cQryTkSum += "                 and NUH.D_E_L_E_T_ = ' ')  " + CRLF
							
							cQryTkSum += "        left join "+RetSqlname("NRX")+" NRX  " + CRLF
							cQryTkSum += "             on( NRX.NRX_FILIAL     = '"+xFilial("NRX")+"'" + CRLF
							cQryTkSum += "                 and NRX.NRX_COD    = NUH.NUH_CEMP" + CRLF
							cQryTkSum += "                 and NRX.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryTkSum += "        left join "+RetSqlname("NS2")+" NS2 " + CRLF
							cQryTkSum += "             on( NS2.NS2_FILIAL     = '"+xFilial("NS2")+"'" + CRLF
							cQryTkSum += "                 and NS2.NS2_CCATEJ = NUR.NUR_CCAT" + CRLF
							cQryTkSum += "                 and NS2.NS2_CDOC   = NRX.NRX_CDOC" + CRLF
							cQryTkSum += "                 and NS2.D_E_L_E_T_ = ' ') " + CRLF
							
							cQryTkSum += "        left join "+RetSqlname("NRV")+" NRV " + CRLF
							cQryTkSum += "             on( NRV.NRV_FILIAL     = '"+xFilial("NRV")+"'" + CRLF
							cQryTkSum += "                 and NRV.NRV_CDOC   = NS2.NS2_CDOC" + CRLF
							cQryTkSum += "                 and NRV.NRV_COD    = NS2.NS2_CCATE" + CRLF
							cQryTkSum += "                 and NRV.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryTkSum += " where  NXA.NXA_FILIAL     = '"+xFilial("NXA")+"' " + CRLF
							cQryTkSum += "        and NXA.NXA_CESCR  = '"+TRBPRIN->NXA_CESCR+"' " + CRLF
							cQryTkSum += "        and NXA.NXA_COD    = '"+TRBPRIN->NXA_COD+"'" + CRLF
							cQryTkSum += "        and NXA.D_E_L_E_T_ = ' ' " + CRLF
							
							If Select("TRBTK")>0
								DbSelectArea("TRBTK")
								TRBTK->(DbCloseArea())
							EndIf
							
							cTRBTkSum := ChangeQuery(cQryTkSum)
							dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBTkSum ) ,"TRBTK", .T., .F.)
							
							DbSelectArea("TRBTK")
							TRBTK->(dbGoTop())
							If TRBTK->(!Eof())
								Do While TRBTK->(!Eof()) .And. aRet[1]
									//=========================================
									//OBRIGATORIO
									//=========================================
									Aadd(aArqXml,Space(15)+"<tk_sum>")
									If !Empty(TRBTK->NXD_CPART)
										Aadd(aArqXml,Space(18)+"<tk_id>"+Alltrim(TRBTK->NXD_CPART)+"</tk_id>")
									EndIf
									If !Empty(TRBTK->RD0_NOME)
										Aadd(aArqXml,Space(18)+"<tk_lname>"+RetFLName(1,TRBTK->RD0_NOME)+"</tk_lname>")
										Aadd(aArqXml,Space(18)+"<tk_fname>"+RetFLName(2,TRBTK->RD0_NOME)+"</tk_fname>")
									EndIf
									If !Empty(TRBTK->NRV_CCATE)
										Aadd(aArqXml,Space(18)+"<tk_level>"+Alltrim(TRBTK->NRV_CCATE)+"</tk_level>")
									EndIf
									
									nValor := (TRBTK->NXD_VLHORA)
									aValor := JA201FConv( cMoeEbi, (TRBTK->NXD_CMOEDT), nValor, '8', dEmiFat, , , , cCodEsc, cFatura )
									If !Empty(aValor[4])
										IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
										aRet[1] := .F.
										Exit
									Else
										nValor := Round(aValor[1],2)
									EndIf
									
									Aadd(aArqXml,Space(18)+"<tk_rate>"+Alltrim(Str(nValor))+"</tk_rate>")
									
									nTkHours := ((TRBTK->NXD_HFREV+TRBTK->NXD_HFCLI)* nPercFat)
									
									Aadd(aArqXml,Space(18)+"<tk_hours>"+Alltrim(Str(nTkHours))+"</tk_hours>")
									
									nTkCost := nTkHours * nValor
									
									Aadd(aArqXml,Space(18)+"<tk_cost>"+Alltrim(Str(nTkCost))+"</tk_cost>")
									Aadd(aArqXml,Space(15)+"</tk_sum>")
									
									TRBTK->(DbSkip())
								EndDo
							EndIf
							
							cQryFee := " select" + CRLF
							cQryFee += "     NUE.*, " + CRLF
							cQryFee += "     NS0.NS0_CATIV, " + CRLF
							cQryFee += "     NRZ.NRZ_CTAREF, " + CRLF
							cQryFee += "     NUHB.NUH_CEMP, " + CRLF
							cQryFee += "     NUR.NUR_CCAT, " + CRLF
							cQryFee += "     NRV.NRV_CCATE, " + CRLF
							cQryFee += "     RD0.RD0_SIGLA, " + CRLF
							cQryFee += "     NRY.NRY_CFASE,  " + CRLF
							cQryFee += "     NUE.R_E_C_N_O_ NUERECNO  " + CRLF
							
							cQryFee += " from" + CRLF
							cQryFee += "     "+RetSqlname("NW0")+" NW0 " + CRLF
							
							cQryFee += "     inner join "+RetSqlname("NUE")+" NUE " + CRLF
							cQryFee += "         on( NUE.NUE_FILIAL     = '"+xFilial("NUE")+"'" + CRLF
							cQryFee += "             and NUE.NUE_COD    = NW0.NW0_CTS" + CRLF
							cQryFee += "             and NUE.NUE_CCLIEN = '" +TRBMATT->NXC_CCLIEN+ "'" + CRLF
							cQryFee += "             and NUE.NUE_CLOJA  = '" +TRBMATT->NXC_CLOJA+ "'" + CRLF
							cQryFee += "             and NUE.NUE_CCASO  = '" +TRBMATT->NXC_CCASO+ "'" + CRLF
							cQryFee += "             and NUE.NUE_VALOR1 > 0" + CRLF
							cQryFee += "             and NUE.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryFee += "     inner join "+RetSqlname("NUR")+" NUR " + CRLF
							cQryFee += "         on( NUR.NUR_FILIAL     = '"+xFilial("NUR")+"'" + CRLF
							cQryFee += "             and NUR.NUR_CPART  = NUE.NUE_CPART2" + CRLF
							cQryFee += "             and NUR.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryFee += "     inner join "+RetSqlname("RD0")+" RD0 " + CRLF
							cQryFee += "         on( RD0.RD0_FILIAL     = '"+xFilial("RD0")+"'" + CRLF
							cQryFee += "             and RD0.RD0_CODIGO = NUR.NUR_CPART " + CRLF
							cQryFee += "             and RD0.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryFee +=     " left join " + RetSqlName("NUH") + " NUH " + CRLF
							cQryFee +=         " on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "'" + CRLF
							cQryFee +=             " and NUH.NUH_COD =  '" +cClientePg+ "'"+ CRLF
							cQryFee +=             " and NUH.NUH_LOJA = '" +cLojaPg+ "'"+ CRLF
							cQryFee +=             " and NUH.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryFee +=     " left join " + RetSqlName("NUH") + " NUHB  " + CRLF
							cQryFee +=         "  on( NUHB.NUH_FILIAL     = '" + xFilial("NUH") + "'" + CRLF
							cQryFee +=             "  and NUHB.NUH_COD    = NUE.NUE_CCLIEN " + CRLF
							cQryFee +=             "  and NUHB.NUH_LOJA   = NUE.NUE_CLOJA " + CRLF
							cQryFee +=             "  and NUHB.NUH_CEMP   = NUH.NUH_CEMP " + CRLF
							cQryFee +=             "  and NUHB.D_E_L_E_T_ = ' ' ) " + CRLF
							
							cQryFee += "     left join "+RetSqlname("NRX")+" NRX " + CRLF
							cQryFee += "         on( NRX.NRX_FILIAL     = '"+xFilial("NRX")+"'" + CRLF
							cQryFee += "             and NRX.NRX_COD    = NUH.NUH_CEMP" + CRLF
							cQryFee += "             and NRX.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryFee += "     left join "+RetSqlname("NS2")+" NS2 " + CRLF
							cQryFee += "             on( NS2.NS2_FILIAL     = '"+xFilial("NS2")+"'" + CRLF
							cQryFee += "                 and NS2.NS2_CCATEJ = NUR.NUR_CCAT" + CRLF
							cQryFee += "                 and NS2.NS2_CDOC   = NRX.NRX_CDOC" + CRLF
							cQryFee += "                 and NS2.D_E_L_E_T_ = ' ') " + CRLF
							
							cQryFee += "     left join "+RetSqlname("NRV")+" NRV " + CRLF
							cQryFee += "             on( NRV.NRV_FILIAL     = '"+xFilial("NRV")+"'" + CRLF
							cQryFee += "                 and NRV.NRV_CDOC   = NS2.NS2_CDOC" + CRLF
							cQryFee += "                 and NRV.NRV_COD    = NS2.NS2_CCATE" + CRLF
							cQryFee += "                 and NRV.D_E_L_E_T_ = ' ')" + CRLF
							
							cQryFee += "     left join "+RetSqlname("NS0")+" NS0 " + CRLF
							cQryFee += "         on( NS0.NS0_FILIAL     = '"+xFilial("NS0")+"'" + CRLF
							cQryFee += "             and NS0.NS0_CDOC   = NRX.NRX_CDOC" + CRLF
							cQryFee += "             and NS0.NS0_CATIV  = NUE.NUE_CTAREB" + CRLF
							cQryFee += "             and NS0.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryFee += "     left join "+RetSqlname("NRY")+" NRY " + CRLF
							cQryFee += "         on( NRY.NRY_FILIAL     = '"+xFilial("NRY")+"'" + CRLF
							cQryFee += "             and NRY.NRY_CDOC   = NRX.NRX_CDOC" + CRLF
							cQryFee += "             and NRY.NRY_CFASE  = NUE.NUE_CFASE" + CRLF
							cQryFee += "             and NRY.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryFee += "     left join "+RetSqlname("NRZ")+" NRZ " + CRLF
							cQryFee += "         on( NRZ.NRZ_FILIAL     = '"+xFilial("NRZ")+"'" + CRLF
							cQryFee += "             and NRZ.NRZ_CDOC   = NRX.NRX_CDOC" + CRLF
							cQryFee += "             and NRZ.NRZ_CTAREF = NUE.NUE_CTAREF" + CRLF
							cQryFee += "             and NRZ.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryFee += " where" + CRLF
							cQryFee += "     NW0.NW0_FILIAL     = '"+xFilial("NW0")+"'" + CRLF
							cQryFee += "     and NW0.NW0_CESCR  = '"+TRBPRIN->NXA_CESCR+"'" + CRLF
							cQryFee += "     and NW0.NW0_CFATUR = '"+TRBPRIN->NXA_COD+"' " + CRLF
							cQryFee += "     and NW0.D_E_L_E_T_ = ' ' " + CRLF
							cQryFee += " order by NUE.NUE_DATATS, NUE.NUE_COD " + CRLF
							
							If Select("TRBFEE")>0
								DbSelectArea("TRBFEE")
								TRBFEE->(DbCloseArea())
							EndIf
							
							cTRBFee := ChangeQuery(cQryFee)
							dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBFee ) ,"TRBFEE", .T., .F.)
							
							DbSelectArea("TRBFEE")
							TRBFEE->(dbGoTop())
							If TRBFEE->(!Eof())
								Do While TRBFEE->(!Eof()) .And. aRet[1]
									Aadd(aArqXml,Space(15)+"<fee>")
									If !Empty(TRBFEE->NUE_DATATS)
										Aadd(aArqXml,Space(18)+"<charge_date>"+Alltrim(TRBFEE->NUE_DATATS)+"</charge_date>")//Obrigatorio
									EndIf
									If !Empty(TRBFEE->NUE_CPART2)
										Aadd(aArqXml,Space(18)+"<tk_id>"+Alltrim(TRBFEE->NUE_CPART2)+"</tk_id>")//Obrigatorio
									EndIf
									
									NUE->( dbGoTo(TRBFEE->NUERECNO ))
									cDescri := StrTran(NUE->NUE_DESC, CRLF, " ")
									If !Empty(cDescri)
										Aadd(aArqXml,Space(18)+"<charge_desc>"+Alltrim(cDescri)+"</charge_desc>")//Obrigatorio
									EndIf
									
									If !Empty(TRBFEE->NUE_CTAREF)
										Aadd(aArqXml,Space(18)+"<acca_task>"+Alltrim(TRBFEE->NRZ_CTAREF)+"</acca_task>")//Opcional
									EndIf
									If !Empty(TRBFEE->NS0_CATIV)
										Aadd(aArqXml,Space(18)+"<acca_activity>"+Alltrim(TRBFEE->NS0_CATIV)+"</acca_activity>")//Opcional
									EndIf
									If !Empty(TRBFEE->NUE_CCLIEN+TRBFEE->NUE_CLOJA)
										Aadd(aArqXml,Space(18)+"<cl_code_1>"+Alltrim(TRBFEE->NUE_CCLIEN+TRBFEE->NUE_CLOJA)+"</cl_code_1>")//Opcional
										Aadd(aArqXml,Space(18)+"<cl_code_2>"+Alltrim(TRBFEE->NUE_CCLIEN+TRBFEE->NUE_CLOJA)+"</cl_code_2>")//Opcional
									EndIf
									
									nValor1 := TRBFEE->NUE_VALOR1
									aValor := JA201FConv( cMoeEbi, TRBFEE->NUE_CMOED1, nValor1, '8', dEmiFat, , , , cCodEsc, cFatura )
									If !Empty(aValor[4])
										IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
										aRet[1] := .F.
										Exit
									Else
										nValor1 := aValor[1]
									EndIf
									
									nValorH := TRBFEE->NUE_VALORH
									aValor := JA201FConv( cMoeEbi, TRBFEE->NUE_CMOED1, nValorH, '8', dEmiFat, , , , cCodEsc, cFatura )
									If !Empty(aValor[4])
										IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
										aRet[1] := .F.
										Exit
									Else
										nValorH := aValor[1]
									EndIf
									
									nFeeUnit       := TRBFEE->NUE_TEMPOR * nPercFat
									nFeeRate       := Round(nValorH,4)
									nFeeBaseAmount := Round(nValor1 * nPercFat,2)
									nFeeTotAmount  := nFeeBaseAmount
									
									cFeeUnit       := Alltrim(Str(nFeeUnit      ))
									cFeeUnit       := JURA144C1(2, 3, cFeeUnit)
									cFeeRate       := Alltrim(Str(nFeeRate      ))
									cFeeBaseAmount := Alltrim(Str(nFeeBaseAmount))
									cFeeTotAmount  := Alltrim(Str(nFeeTotAmount ))
									
									Aadd(aArqXml,Space(18)+"<charge_type>U</charge_type>")//Obrigatorio
									If !Empty(cFeeUnit)
										Aadd(aArqXml,Space(18)+"<units>"+cFeeUnit+"</units>")//Obrigatorio
									EndIf
									
									Aadd(aArqXml,Space(18)+"<rate>"+cFeeRate+"</rate>")//Obrigatorio
									Aadd(aArqXml,Space(18)+"<base_amount>"+cFeeBaseAmount+"</base_amount>")//Obrigatorio
									Aadd(aArqXml,Space(18)+"<total_amount>"+cFeeTotAmount+"</total_amount>")//Obrigatorio
									Aadd(aArqXml,Space(15)+"</fee>")
									
									aLog := LD98VlLanc(TRBFEE->NUE_COD, TRBFEE->NUE_CCLIEN, TRBFEE->NUE_CLOJA, TRBFEE->NUE_CCASO, TRBFEE->NUH_CEMP,;
										TRBFEE->NRV_CCATE , TRBFEE->NUR_CCAT, TRBFEE->RD0_SIGLA, TRBFEE->NRY_CFASE, TRBFEE->NRZ_CTAREF, TRBFEE->NS0_CATIV, "TS", aLog, "cEscEbi", "cEscrit" )
									
									lTemTS := .T.
									
									TRBFEE->(DbSkip())
								EndDo
							Else
								lTemTS := lTemTS .or. .F.
							EndIf

							cQryExpens := " select expenses.*" + CRLF
							cQryExpens += " from" + CRLF
							cQryExpens += "     (select" + CRLF
							cQryExpens += "         NVZ.NVZ_CESCR||NVZ.NVZ_CFATUR as escr_cod, " + CRLF
							cQryExpens += "         NVY.NVY_DATA as charge_date," + CRLF
							cQryExpens += "         NVY.NVY_CPART as tk_id," + CRLF
							cQryExpens += "         NS3.NS3_CDESP as acca_expense," + CRLF
							cQryExpens += "         NVY.NVY_CCLIEN||NVY.NVY_CLOJA as cl_code_1," + CRLF
							cQryExpens += "         NVY.NVY_CCLIEN||NVY.NVY_CLOJA as cl_code_2," + CRLF
							cQryExpens += "         NVY.NVY_QTD as units," + CRLF
							cQryExpens += "         NVY.NVY_VALOR as total_amount, " + CRLF
							//validação
							cQryExpens += "     	NVY.NVY_COD as Exp_Codigo, " + CRLF
							cQryExpens += "     	NVY.NVY_CCLIEN as Exp_Cliente, " + CRLF
							cQryExpens += "     	NVY.NVY_CLOJA as Exp_Loja, " + CRLF
							cQryExpens += "     	NVY.NVY_CCASO as Exp_Caso, " + CRLF
							cQryExpens += "     	NUH.NUH_CEMP as Exp_Empresa, " + CRLF
							cQryExpens += "         NS4.NS4_CDESPJ as Exp_Tipo, " + CRLF
							cQryExpens += "         'DP' as Exp_Lanc, " + CRLF
							cQryExpens += "         '1' as Ident, " + CRLF
							cQryExpens += "         NVY.R_E_C_N_O_ as XXXRECNO, " + CRLF
							cQryExpens += "     	NVY.NVY_CMOEDA as Exp_Moeda " + CRLF
							// Validação
							cQryExpens += "      from" + CRLF
							cQryExpens += "         " + RetSqlName("NXA") + " NXA " + CRLF
							cQryExpens += "         inner join " + RetSqlName("NVZ") + " NVZ " + CRLF
							cQryExpens += "             on( NVZ.NVZ_FILIAL     = '" + xFilial("NVZ") + "'" + CRLF
							cQryExpens += "                 and NVZ.NVZ_CESCR  = NXA.NXA_CESCR" + CRLF
							cQryExpens += "                 and NVZ.NVZ_CFATUR = NXA.NXA_COD  " + CRLF
							cQryExpens += "                 and NVZ.D_E_L_E_T_ = ' ' ) " + CRLF
							cQryExpens += "         inner join " + RetSqlName("NVY") + " NVY " + CRLF
							cQryExpens += "             on( NVY.NVY_FILIAL     = '" + xFilial("NVY") + "'" + CRLF
							cQryExpens += "                 and NVY.NVY_COD    = NVZ.NVZ_CDESP" + CRLF
							cQryExpens += "             	and NVY.NVY_CCLIEN = '" +TRBMATT->NXC_CCLIEN+ "'" + CRLF
							cQryExpens += "             	and NVY.NVY_CLOJA  = '" +TRBMATT->NXC_CLOJA+ "'" + CRLF
							cQryExpens += "             	and NVY.NVY_CCASO  = '" +TRBMATT->NXC_CCASO+ "'" + CRLF
							cQryExpens += "                 and NVY.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryExpens += "         inner join " + RetSqlName("NUH") + " NUH " + CRLF
							cQryExpens += "             on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "'" + CRLF
							cQryExpens += "                 and NUH.NUH_COD =  '" +cClientePg+ "'"+ CRLF
							cQryExpens += "                 and NUH.NUH_LOJA = '" +cLojaPg+ "'"+ CRLF
							cQryExpens += "                 and NUH.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryExpens += "         inner join " + RetSqlName("NRX") + " NRX " + CRLF
							cQryExpens += "             on( NRX.NRX_FILIAL     = '" + xFilial("NRX") + "'" + CRLF
							cQryExpens += "                 and NRX.NRX_COD    = NUH.NUH_CEMP" + CRLF
							cQryExpens += "                 and NRX.D_E_L_E_T_ = ' ' )" + CRLF
							cQryExpens += "          left join " + RetSqlName("NS4") + " NS4 " + CRLF
							cQryExpens += "             on( NS4.NS4_FILIAL     = '" + xFilial("NS4") + "'" + CRLF
							cQryExpens += "                 and NS4.NS4_CDOC   = NRX.NRX_CDOC " + CRLF
							cQryExpens += "                 and NS4.NS4_CDESPJ = NVY.NVY_CTPDSP" + CRLF
							cQryExpens += "                 and NS4.D_E_L_E_T_ = ' ' ) " + CRLF
							cQryExpens += "          left join " + RetSqlName("NS3") + " NS3 " + CRLF
							cQryExpens += "             on( NS3.NS3_FILIAL     = '" + xFilial("NS3") + "'" + CRLF
							cQryExpens += "                 and NS3.NS3_CDOC   = NS4.NS4_CDOC" + CRLF
							cQryExpens += "                 and NS3.NS3_COD    = NS4.NS4_CDESP " + CRLF
							cQryExpens += "                 and NS3.D_E_L_E_T_ = ' ' ) " + CRLF
							cQryExpens += "      where" + CRLF
							cQryExpens += "         NXA.NXA_FILIAL     = '" + xFilial("NXA") + "' " + CRLF
							cQryExpens += "         and NXA.NXA_CESCR  = '" + TRBPRIN->NXA_CESCR + "' " + CRLF
							cQryExpens += "         and NXA.NXA_COD    = '" + TRBPRIN->NXA_COD   + "' " + CRLF
							cQryExpens += "         and NXA.D_E_L_E_T_ = ' ' " + CRLF
							cQryExpens += " " + CRLF
							cQryExpens += "      union all" + CRLF
							cQryExpens += " " + CRLF
							cQryExpens += "      select" + CRLF
							cQryExpens += "         NW4.NW4_CESCR||NW4.NW4_CFATUR as escr_cod, " + CRLF
							cQryExpens += "         NV4.NV4_DTLANC as charge_date," + CRLF
							cQryExpens += "         NV4.NV4_CPART  as tk_id," + CRLF
							cQryExpens += "         NXN.NXN_CSRVTB as acca_expense," + CRLF
							cQryExpens += "         NV4.NV4_CCLIEN||NV4.NV4_CLOJA as cl_code_1," + CRLF
							cQryExpens += "         NV4.NV4_CCLIEN||NV4.NV4_CLOJA as cl_code_2," + CRLF
							cQryExpens += "         NV4.NV4_QUANT as units," + CRLF
							cQryExpens += "         NV4.NV4_VLHFAT as total_amount, " + CRLF
							//validação
							cQryExpens += "     	NV4.NV4_COD as Exp_Codigo, " + CRLF
							cQryExpens += "     	NV4.NV4_CCLIEN as Exp_Cliente, " + CRLF
							cQryExpens += "     	NV4.NV4_CLOJA as Exp_Loja, " + CRLF
							cQryExpens += "     	NV4.NV4_CCASO as Exp_Caso, " + CRLF
							cQryExpens += "     	NUH.NUH_CEMP as Exp_Empresa, " + CRLF
							cQryExpens += "         NXO.NXO_CSRVTJ as Exp_Tipo, " + CRLF
							cQryExpens += "         'TB' as Exp_Lanc, " + CRLF
							cQryExpens += "         '2' as Ident, " + CRLF
							cQryExpens += "         NV4.R_E_C_N_O_ as XXXRECNO, " + CRLF
							cQryExpens += "         NV4.NV4_CMOEH as Exp_Moeda " + CRLF
							// Validação
							cQryExpens += "      from" + CRLF
							cQryExpens += "         " + RetSqlName("NXA") + " NXA " + CRLF
							cQryExpens += "         inner join " + RetSqlName("NW4") + " NW4 " + CRLF
							cQryExpens += "             on( NW4.NW4_FILIAL     = '" + xFilial("NW4") + "'" + CRLF
							cQryExpens += "                 and NW4.NW4_CESCR  = NXA.NXA_CESCR" + CRLF
							cQryExpens += "                 and NW4.NW4_CFATUR = NXA.NXA_COD  " + CRLF
							cQryExpens += "                 and NW4.D_E_L_E_T_ = ' ' ) " + CRLF
							cQryExpens += "         inner join " + RetSqlName("NV4") + " NV4 " + CRLF
							cQryExpens += "             on( NV4.NV4_FILIAL     = '" + xFilial("NV4") + "'" + CRLF
							cQryExpens += "                 and NV4.NV4_COD    = NW4.NW4_CLTAB" + CRLF
							cQryExpens += "             	and NV4.NV4_CCLIEN = '" +TRBMATT->NXC_CCLIEN+ "'" + CRLF
							cQryExpens += "             	and NV4.NV4_CLOJA  = '" +TRBMATT->NXC_CLOJA+ "'" + CRLF
							cQryExpens += "             	and NV4.NV4_CCASO  = '" +TRBMATT->NXC_CCASO+ "'" + CRLF
							cQryExpens += "                 and NV4.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryExpens += "         inner join " + RetSqlName("NUH") + " NUH " + CRLF
							cQryExpens += "             on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "'" + CRLF
							cQryExpens += "                 and NUH.NUH_COD =  '" +cClientePg+ "'"+ CRLF
							cQryExpens += "                 and NUH.NUH_LOJA = '" +cLojaPg+ "'"+ CRLF
							cQryExpens += "                 and NUH.D_E_L_E_T_ = ' ' )" + CRLF
							
							cQryExpens += "         inner join " + RetSqlName("NRX") + " NRX " + CRLF
							cQryExpens += "             on( NRX.NRX_FILIAL     = '" + xFilial("NRX") + "'" + CRLF
							cQryExpens += "                 and NRX.NRX_COD    = NUH.NUH_CEMP" + CRLF
							cQryExpens += "                 and NRX.D_E_L_E_T_ = ' ' )" + CRLF
							cQryExpens += "         left join " + RetSqlName("NXO") + " NXO " + CRLF
							cQryExpens += "             on( NXO.NXO_FILIAL     = '" + xFilial("NXO") + "'" + CRLF
							cQryExpens += "                 and NXO.NXO_CDOC   = NRX.NRX_CDOC " + CRLF
							cQryExpens += "                 and NXO.NXO_CSRVTJ = NV4.NV4_CTPSRV" + CRLF
							cQryExpens += "                 and NXO.D_E_L_E_T_ = ' ' ) " + CRLF
							cQryExpens += "         left join " + RetSqlName("NXN") + " NXN " + CRLF
							cQryExpens += "             on( NXN.NXN_FILIAL     = '" + xFilial("NXN") + "'" + CRLF
							cQryExpens += "                 and NXN.NXN_CDOC   = NRX.NRX_CDOC" + CRLF
							cQryExpens += "                 and NXN.NXN_COD    = NXO.NXO_CSRVTB" + CRLF
							cQryExpens += "                 and NXN.D_E_L_E_T_ = ' ' ) " + CRLF
							cQryExpens += "      where" + CRLF
							cQryExpens += "         NXA.NXA_FILIAL     = '" + xFilial("NXA") + "' " + CRLF
							cQryExpens += "         and NXA.NXA_CESCR  = '" + TRBPRIN->NXA_CESCR + "' " + CRLF
							cQryExpens += "         and NXA.NXA_COD    = '" + TRBPRIN->NXA_COD   + "' " + CRLF
							cQryExpens += "         and NXA.D_E_L_E_T_ = ' '" + CRLF
							cQryExpens += "     )expenses" + CRLF
							cQryExpens += " order by " + CRLF
							cQryExpens += "     expenses.Ident ,expenses.charge_date, expenses.Exp_Codigo" + CRLF
							
							If Select("TRBEXP")>0
								DbSelectArea("TRBEXP")
								TRBEXP->(DbCloseArea())
							EndIf
							
							cTRBExpens := ChangeQuery(cQryExpens)
							dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBExpens ) ,"TRBEXP", .T., .F.)
							
							DbSelectArea("TRBEXP")
							TRBEXP->(dbGoTop())
							If TRBEXP->(!Eof())
								Do While TRBEXP->(!Eof()) .And. aRet[1]
									Aadd(aArqXml,Space(15)+"<expense>")
									
									If !Empty(TRBEXP->charge_date)
										Aadd(aArqXml,Space(18)+"<charge_date>"+Alltrim(TRBEXP->charge_date)+"</charge_date>")//Opcional
									EndIf
									
									If !Empty(TRBEXP->tk_id)
										Aadd(aArqXml,Space(18)+"<tk_id>"+Alltrim(TRBEXP->tk_id)+"</tk_id>")//Opcional
									EndIf
									
									If !Empty(Alltrim(TRBEXP->Ident))
										
										If Alltrim(TRBEXP->Ident) == '1'
											
											NVY->( dbGoTo(TRBEXP->XXXRECNO ))
											cDescri := StrTran(NVY->NVY_DESCRI, CRLF, " ")
											
										ElseIf Alltrim(TRBEXP->Ident) == '2'
											
											NV4->( dbGoTo(TRBEXP->XXXRECNO ))
											cDescri := StrTran(NV4->NV4_DESCRI, CRLF, " ")
											
										EndIf
										
										If !Empty(cDescri)
											Aadd(aArqXml,Space(18)+"<charge_desc>"+Alltrim(cDescri)+"</charge_desc>")//Obrigatorio
										EndIf
										
									EndIf
									//Aadd(aArqXml,Space(18)+"<acca_task> </acca_task>")//Opcional
									If !Empty(TRBEXP->acca_expense)
										Aadd(aArqXml,Space(18)+"<acca_expense>"+Alltrim(TRBEXP->acca_expense)+"</acca_expense>")//Opcional
									EndIf
									
									If !Empty(TRBEXP->cl_code_1)
										Aadd(aArqXml,Space(18)+"<cl_code_1>"+Alltrim(TRBEXP->cl_code_1)+"</cl_code_1>")//Opcional
									EndIf
									
									If !Empty(TRBEXP->cl_code_2)
										Aadd(aArqXml,Space(18)+"<cl_code_2>"+Alltrim(TRBEXP->cl_code_2)+"</cl_code_2>")//Opcional
									EndIf
									
									nExpTotAmount := (TRBEXP->total_amount) * nPercFat
									aValor := JA201FConv( cMoeEbi, TRBEXP->Exp_Moeda, nExpTotAmount, '8', dEmiFat, , , , cCodEsc, cFatura )
									If !Empty(aValor[4])
										IIF(lAutomato, aRet := {.F., aValor[4]}, Alert(aValor[4]))
										aRet[1] := .F.
										Exit
									Else
										nExpTotAmount := Round(aValor[1],2)
									EndIf
									
									nExpRate      := Round((nExpTotAmount / TRBEXP->units),2)
									
									cExpTotAmount := Alltrim(Str(nExpTotAmount))
									cExpRate := Alltrim(Str(nExpRate))
									
									Aadd(aArqXml,Space(18)+"<charge_type>U</charge_type>")//Obrigatorio
									Aadd(aArqXml,Space(18)+"<units>"+Alltrim(Str(TRBEXP->units))+"</units>")//Obrigatorio
									Aadd(aArqXml,Space(18)+"<rate>"+Alltrim(cExpRate)+"</rate>")//Obrigatorio
									Aadd(aArqXml,Space(18)+"<total_amount>"+Alltrim(cExpTotAmount)+"</total_amount>")//Obrigatorio
									Aadd(aArqXml,Space(15)+"</expense>")
									
									aLog := LD98VlLanc(TRBEXP->Exp_Codigo, TRBEXP->Exp_Cliente, TRBEXP->Exp_Loja, TRBEXP->Exp_Caso, TRBEXP->Exp_Empresa ,;
										"NValdCat", "NValdCat", "NValdCat", "NtemFase", "NtemTarefa", TRBEXP->Exp_Tipo, TRBEXP->Exp_Lanc, aLog, "cEscEbi", "cEscrit" )
									
									lTemDP := .T.
									
									TRBEXP->(DbSkip())
								EndDo
							Else
								lTemDP := lTemDP .Or. .F.
							EndIf
							
							Aadd(aArqXml,Space(12) + "</matter>")
							
							TRBMATT->(DbSkip())
						EndDo
					EndIf
					Aadd(aArqXml, Space(9)+"</invoice>")
					Aadd(aArqXml, Space(6)+"</client>")
					TRBPRIN->(DbSkip())
				EndDo
			EndDo
		EndDo
		
		If aRet[1]
			Aadd(aArqXml,"</ledesxml>")
			
			cFatura := "'" + cCodEsc + cFatura+"'"
			
			If (lTemDP .OR. lTemTS)
				aRet := GeraArq(cNArq, cDArq, aArqXml, alog, cFatura, lAutomato)
			Else
				IIF(lAutomato, aRet := {.F., STR0014}, Alert(STR0014)) //"Nao existem registros a serem processados."
			EndIf
		EndIf
		
	Else
		IIF(lAutomato, aRet := {.F., STR0014}, Alert(STR0014)) //"Nao existem registros a serem processados."
	EndIf

	If aRet[1] .And. FindFunction("JLDFlagFat")
		JLDFlagFat(NXA->(Recno()))
	EndIf

	RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarArq
Montagem e geração do arquivo XML.

@author SISJURI
@since 10/05/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static FUnction GeraArq(cNomArq, cCaminho, aArquivo, aLog, cFatura, lAutomato)
Local nX         := 0
Local nY         := 0
Local cDirDocs   := "\ARQUIVOXML\"
Local cPath      := GetSrvProfString("RootPath", "") + cDirDocs
Local cArquivo   := cEmpAnt + cFilAnt + __cUserId
Local cMemolog   := ""
Local aRet       := {.T., ""}

Default aArquivo := {}
Default cCaminho := ""
Default cNomArq  := ""

Makedir(cPath)

If Empty(cNomArq)
	cArquivo := Alltrim(cArquivo) + ".xml"
ElseIf At(".XML", Upper(cNomArq)) == 0
	cArquivo := Alltrim(cNomArq) + ".xml"
Else	
	cArquivo := Alltrim(cNomArq)
EndIf
If !Empty(cCaminho)
	cPath := Alltrim(cCaminho)
	If !ExistDir(cPath)
		If !lAutomato
			Help( ,, 'HELP',, STR0011, 1, 0) //'Caminho informado nao existe'
		Else
			aRet := {.F., STR0011} //'Caminho informado nao existe'
		EndIf
		Return aRet
	EndIf
EndIf

If File(cPath + cArquivo)
	If !lAutomato .And. !MsgYesNo(STR0012, STR0007)
		Return 
	Else
		FErase(cPath + cArquivo)
	EndIf
EndIf

nHandle := FCreate(cPath+cArquivo)
If nHandle == -1
	If !lAutomato
		MsgStop(STR0013) //"Arquivo Txt não pode ser gerado."
	Else
		aRet := {.F., STR0013} //"Arquivo Txt não pode ser gerado."
	EndIf
	Return aRet
EndIf  

For nX := 1 To Len(aArquivo)
	FWrite(nHandle, aArquivo[nX] + Chr(13) + Chr(10))
Next

FClose(nHandle)

If !lAutomato .Or. !IsBlind() // Não deve executar o comando CpyS2T quando for via automação
	CpyS2T(SubStr(cPath, AT(":\", cPath) + 2, Len(cPath) - AT(":\",cPath)) + Alltrim(cArquivo), cPath, .T.) // copia o arquivo do servidor para o remote
EndIf

For nX := 1 To Len(aLog)
	For nY := 1 To Len(aLog[nX])
		cMemolog += aLog[nX][nY][2] + CRLF
	Next nY
Next nX

If !Empty(cMemolog)
	cMemolog := STR0018 + AllTrim(cCaminho) + Alltrim(cArquivo) + STR0019 + cFatura + STR0020 + CRLF + CRLF + cMemolog //"O Arquivo " ## " da fatura " ### " foi gerado com as seguintes inconsistências:"
	If !lAutomato
		JurErrLog(cMemolog, STR0001) //"Geração de Arquivo Texto LEDES2000"
	Else
		aRet := {.T., cMemolog}
	EndIf
Else
	If !lAutomato
		MsgInfo(STR0017, STR0016) // "Arquivo Xml processado com sucesso" # "Arquivo Gerado".
	Else
		aRet := {.T., STR0016 + " - " + STR0017}
	EndIf
EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JurEbilLog
Função utilizada para incrementar o array de criticas da LD98VlLanc com as criticas 
especificas do o arquivo E-Billing do LEDES00 

@Params				- cTag - Tag do arquivo aonde ocorreu a critica 
@Params				- cCritica - Mensagem de critica 

@Retuns	 aLog		- Array com o Retorno do log 
					- [1][1] Identificador da critica Empresa E-billing
						 [2] Mensagem de critica
					- [2][1] Identificador da critica Categoria E-billing
					     [2] Mensagem de critica				
					- [3][1] Identificador da critica Fase E-billing
					     [2] Mensagem de critica
					- [4][1] Identificador da critica Tarefa E-billing
					     [2] Mensagem de critica		
					- [5][1] Identificador da critica Atividade; Tipo Despesa; Serviço Tabelado E-billing
					     [2] Mensagem de critica
					- [N][1] Tag da critica E-billing
					     [2] Mensagem de critica

@author Luciano Pereira dos Santos
@since 02/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurEbilLog(aLog, cTag, cCritica)
Local nI     := 0
Local lFind  := .F.
Local aAux   := {}

Default aLog := {}

If Empty(aLog)
	For nI := 1 To 6
		aAdd(aLog, {})
	Next nI
EndIf

aAux := aClone(aLog)

For nI := 1 To Len(aAux)
	If (aScan(aAux[nI], {|x|x[1] == cTag}) > 0)
		aAdd(aLog[nI], {cTag, cCritica}) 
		lFind := .T.
	EndIf
Next nI

If !lFind
	aAdd(aLog, {{cTag, cCritica}})
EndIf

Return aLog

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSXB
Retorna qual SXB a ser usado

@Return cRet		Codigo da Consulta Padrão

@author fabiana.silva
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSXB()
Local cRet     := "NXA1"
Local aAreaSXB := SXB->(GetArea())
Local nTamSXB  := Len(SXB->XB_ALIAS)

SXB->(DbSetOrder(1)) //XB_ALIAS

If 	SXB->(DbSeek(PadR("NXA2", nTamSXB)))
	cRet := "NXA2"
EndIf

RestArea(aAreaSXB)

Return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} RetFLName
Retorna o First ou o LastName
@param nOption  -   1 Last Name
					2 First Name

@Return cRet	 First ou LastName

@author fabiana.silva
@since 02/10/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetFLName(nOption, cNome)
Local nTamRD0LNm := 30 
Local nTamRD0FNm := 20
Local nPos := 0

cNome := AllTrim(cNome)

If nOption == 1
	If (nPos := Rat(" ", cNome) ) > 0
		cNome := Left( AllTrim( Right(cNome,  Len(cNome) - nPos ) ), nTamRD0LNm)
	Else
		cNome := ""
	EndIf
ElseIf nOption == 2
	If (nPos := At(" ", cNome)-1) > 0
		cNome := Left( AllTrim( Left(cNome,nPos) ), nTamRD0FNm)
	EndIf
EndIf

Return cNome
