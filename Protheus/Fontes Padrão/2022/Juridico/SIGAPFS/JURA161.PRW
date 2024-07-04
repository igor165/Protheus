#INCLUDE "JURA161.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"

Static oResumo
Static cMoeNac  := SuperGetMV( 'MV_JMOENAC',, '01' )
Static aCotac   := {} //Moeda, cotação

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA161
Rotina de consulta de dados de faturamento do Caso. 

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA161()
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Private oBrowse := Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0001 ) //"Resumo Casos"
	oBrowse:SetAlias( "NVE" )
	oBrowse:SetMenuDef( "JURA161" )  // Redefine o menu a ser utilizado                   
	oBrowse:SetLocate()
	If FindFunction("JurBrwRev")
		Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NVE", {"NVE_LCLIEN"}), )
	EndIf
	JurSetBSize( oBrowse )
	oBrowse:Activate()

	If oResumo != Nil
		oResumo:Destroy()
	EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA070", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0004, "JA161VCONS()"   , 0, 2, 0, NIL } ) // "Consulta Resumo"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Casos

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA161" )
Local oStructNVE := FWFormStruct( 2, "NVE" )

JurSetAgrp( 'NVE',, oStructNVE )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA161_NVE", oStructNVE, "NVEMASTER"  )
oView:CreateHorizontalBox( "NVEFIELDS", 100 )
oView:SetOwnerView( "JURA161_NVE", "NVEFIELDS" )

oView:SetDescription( STR0001 ) //"Resumo Casos"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Casos

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel        := NIL
Local oStructNVE    := FWFormStruct( 1, "NVE" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA161", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NVEMASTER", NIL, oStructNVE, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0005 ) // "Modelo de Dados de Casos"
oModel:GetModel( "NVEMASTER" ):SetDescription( STR0006 ) // "Dados de Casos"
JurSetRules( oModel, "NVEMASTER",, "NVE",,  )

Return oModel  

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161VCONS()
Valida se o usuário tem acesso a dados sensíveis ou pessoais 
e para efetuar a chamada da classe TJurCasoResumo e os SetValue dos campos de
Resumo e abas da tela de Resumo de Caso.

@author Jorge Martins
@since  15/07/2022
/*/
//-------------------------------------------------------------------
Function JA161VCONS()
Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	If lPDUserAc
		JA161CONS()
	Else
		MsgInfo(STR0015, STR0016) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161CONS()
Efetua a chamada da classe TJurCasoResumo e os SetValue dos campos de
Resumo e abas da tela de Resumo de Caso.

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA161CONS()
Local aHeaderTS   := {}
Local aHeaderDS   := {}
Local aHeaderTB   := {}
Local aHeaderCJ_M := {}
Local aHeaderCJ_D := {}
Local aHeaderPR   := {}
Local aHeaderFT   := {}
Local aHeaderCT   := {}

	If oResumo == Nil
		oResumo   := TJurCasoResumo():New() //Classe utilizada para criação da tela
	EndIf

	//oResumo:SetTimer()

	oResumo:SetRecno(NVE->(Recno()))

	//Header
	oResumo:SetValue("CCLIEN", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "CCLIEN") }) //Cliente
	oResumo:SetValue("LOJA",   {|oBj, nRecno| JA161CABEC(oBj, nRecno, "LOJA")   }) //Loja
	oResumo:SetValue("DCLIEN", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "DCLIEN") }) //Nome Cliente
	oResumo:SetValue("NUMCAS", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "NUMCAS") }) //Número do Caso
	oResumo:SetValue("TITULO", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "TITULO") }) //Título do Caso
	oResumo:SetValue("SIGLA1", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "SIGLA1") }) //Revisor
	oResumo:SetValue("DTENTR", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "DTENTR") }) //Data de entrada
	oResumo:SetValue("CTABH",  {|oBj, nRecno| JA161CABEC(oBj, nRecno, "CTABH")  }) //Cód Tab Hon
	oResumo:SetValue("DTABH",  {|oBj, nRecno| JA161CABEC(oBj, nRecno, "DTABH")  }) //Desc Tab Hon
	oResumo:SetValue("MOETABH",{|oBj, nRecno| JA161CABEC(oBj, nRecno, "MOETABH")}) //Moe Tab Hon
	oResumo:SetValue("CTABS",  {|oBj, nRecno| JA161CABEC(oBj, nRecno, "CTABS")  }) //Cód Tab Serviços
	oResumo:SetValue("DTABS",  {|oBj, nRecno| JA161CABEC(oBj, nRecno, "DTABS")  }) //Desc Tab Serviços
	oResumo:SetValue("MOETABS",{|oBj, nRecno| JA161CABEC(oBj, nRecno, "MOETABS")}) //Moe Tab Serviços
	oResumo:SetValue("CTABP",  {|oBj, nRecno| JA161CABEC(oBj, nRecno, "CTABP")  }) //Cód Tab Padrão
	oResumo:SetValue("DTABP",  {|oBj, nRecno| JA161CABEC(oBj, nRecno, "DTABP")  }) //Desc Tab Padrão
	oResumo:SetValue("MOETABP",{|oBj, nRecno| JA161CABEC(oBj, nRecno, "MOETABP")}) //Moe Tab Padrão
	oResumo:SetValue("MOEOFIC",{|oBj, nRecno| JA161CABEC(oBj, nRecno, "MOEOFIC")}) //Moe Oficial
	oResumo:SetValue("ENCHON", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "ENCHON") }) //Encerra Hon
	oResumo:SetValue("ENCDES", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "ENCDES") }) //Encerra Desp
	oResumo:SetValue("ENCTAB", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "ENCTAB") }) //Encerra Tab
	oResumo:SetValue("EXITO",  {|oBj, nRecno| JA161CABEC(oBj, nRecno, "EXITO")  }) //Possui Êxito 
	oResumo:SetValue("DESPAD", {|oBj, nRecno| JA161CABEC(oBj, nRecno, "DESPAD") }) //Desconto Caso

	//ConOut("Tempo gasto com Header: "+oResumo:GetTimer()+" segundos")
	//oResumo:SetTimer()

	//BODY

	//VALORES PENDENTES
	oResumo:SetValue("VP_TS_TC_VLR_T_L", {|oBj, nRecno| JVLPDTSTL(oBj, nRecno) }) //TS (Moeda da Tabela de Honorários do Caso) - "Valor - Tempo Lançado"  
	oResumo:SetValue("VP_TS_TC_VLR_T_R", {|oBj, nRecno| JVLPDTSTR(oBj, nRecno) }) //TS (Moeda da Tabela de Honorários do Caso) - "Valor - Tempo Revisado"  
	oResumo:SetValue("VP_TS_TP_VLR_T_L", {|oBj, nRecno| JVLPDTSPTL(oBj, nRecno) }) //TS (Tabela de Honorários Padrão) - "Valor - Tempo Lançado" 
	oResumo:SetValue("VP_TS_TP_VLR_T_R", {|oBj, nRecno| JVLPDTSPTR(oBj, nRecno) }) //TS (Tabela de Honorários Padrão) - "Valor - Tempo Revisado"  
	oResumo:SetValue("VP_DS_MO_VLR", {|oBj, nRecno| JVLPDDS(oBj, nRecno) }) //Desp na Moeda Oficial
	oResumo:SetValue("VP_TB_MO_VLRT", {|oBj, nRecno| JVLPDTBMOT(oBj, nRecno) }) //Tab na Moeda Oficial - Tabela
	oResumo:SetValue("VP_TB_MO_VLRF", {|oBj, nRecno| JVLPDTBMOF(oBj, nRecno) }) //Tab na Moeda Oficial - Fatu
	oResumo:SetValue("VP_TB_TC_VLRT", {|oBj, nRecno| JVLPDTBMCT(oBj, nRecno) }) //Tab na Tabela do Caso - Tabela
	oResumo:SetValue("VP_TB_TC_VLRF", {|oBj, nRecno| JVLPDTBMCF(oBj, nRecno) }) //Tab na Tabela do Caso - Fatu
	
	//VALORES FATURADOS
	oResumo:SetValue("VF_TS_MO_VLR", {|oBj, nRecno| JA161VFTTS(oBj, nRecno) }) //Valor TS na Moeda Oficial 
	oResumo:SetValue("VF_DS_MO_VLR", {|oBj, nRecno| JA161VFTDS(oBj, nRecno) }) //Valor Desp na Moeda Oficial 
	oResumo:SetValue("VF_TB_MO_VLR", {|oBj, nRecno| JA161VFTTB(oBj, nRecno) }) //Valor Tab na Moeda Oficial 
	oResumo:SetValue("VF_FX_MO_VLR", {|oBj, nRecno| JA161VFTFX(oBj, nRecno) }) //Valor Fixo na Moeda Oficial 	

	//VALORES EM WO
	//oResumo:SetValue("WO_TS_MO_VLR", {|oBj, nRecno| JVLWOTS(oBj, nRecno) }) //TS na Moeda Oficial
	oResumo:SetValue("WO_DS_MO_VLR", {|oBj, nRecno| JVLWODS(oBj, nRecno) }) //Desp na Moeda Oficial
	//oResumo:SetValue("WO_TB_MO_VLR", {|oBj, nRecno| JVLWOTBMO(oBj, nRecno) }) //Tab na Moeda Oficial
	//oResumo:SetValue("WO_FX_MO_VLR", {|oBj, nRecno| JVLRWOFX(oBj, nRecno) }) //Fixo na Moeda Oficial

	//ConOut("Tempo gasto com Body: "+oResumo:GetTimer()+" segundos")
	//oResumo:SetTimer()

	//BROWSES
	oResumo:SetLog(.F.) //Habilita log do SetTimer() para verificar os tempos dos Headers e dos Bodys
	oResumo:SetHeaders({"NT0", "NW2", "NX0", "NXA", "NUE", "NVY", "NV4"/*, "NX6"*/}) //Prepara todos os Headers

	//Contratos
	oResumo:SetValue("BROWSE_CJ_M", { {|oBj, nRecno| oResumo:GetHeaders("NT0") }, ; 
	                                  {|oBj, nRecno, oBrw| JQRYCont(oBj, nRecno, oBrw) }, ;
	                                  {|oBrw| JEXECVIEW(1,"NT0","JURA096",oBrw,GetCpoBrw(oBrw,"NT0_COD"),STR0013) } } )
    
	//Junções
	oResumo:SetValue("BROWSE_CJ_D", { {|oBj, nRecno| oResumo:GetHeaders("NW2") }, ;
	                                  {|oBj, nRecno, oBrw| JQRYJun(oBj, nRecno, oBrw) }, ;
	                                  {|oBrw| JEXECVIEW(1,"NW2","JURA056",oBrw,GetCpoBrw(oBrw,"NW2_COD"),STR0014) } } )	
    
	//Pré-faturas
	oResumo:SetValue("BROWSE_PR", { {|oBj, nRecno| oResumo:GetHeaders("NX0") }, ;
	                                {|oBj, nRecno, oBrw| JQRYPF(oBj, nRecno, oBrw) }, ;
	                                {|oBrw| JEXECVIEW(1,"NX0","JURA202",oBrw,GetCpoBrw(oBrw,"NX0_COD"),STR0012) } } )

	//Faturas
	oResumo:SetValue("BROWSE_FT", { {|oBj, nRecno| oResumo:GetHeaders("NXA") }, ;
	                                {|oBj, nRecno, oBrw| JQRYFAT(oBj, nRecno, oBrw) }, ;
	                                {|oBrw| JEXECVIEW(1,"NXA","JURA204",oBrw,GetCpoBrw(oBrw,"NXA_CESCR")+GetCpoBrw(oBrw,"NXA_COD"),STR0009) } } )
	
	//Time Sheets	
	oResumo:SetValue("BROWSE_TS", { {|oBj, nRecno| oResumo:GetHeaders("NUE") }, ;
	                                {|oBj, nRecno, oBrw| JQRYTS(oBj, nRecno, oBrw) }, ;
	                                {|oBrw| JEXECVIEW(1,"NUE","JURA144",oBrw,GetCpoBrw(oBrw,"NUE_COD"),STR0008) } } )

	//Despesas
	oResumo:SetValue("BROWSE_DS", { {|oBj, nRecno| oResumo:GetHeaders("NVY") }, ;
	                                {|oBj, nRecno, oBrw| JQRYDS(oBj, nRecno, oBrw)}, ;
	                                {|oBrw| JEXECVIEW(1,"NVY","JURA049",oBrw,GetCpoBrw(oBrw,"NVY_COD"),STR0010) } } )	
	
	//Tabelados
	oResumo:SetValue("BROWSE_TB", { {|oBj, nRecno| oResumo:GetHeaders("NV4") }, ;
	                                {|oBj, nRecno, oBrw| JQRYTB(oBj, nRecno, oBrw) }, ;
	                                {|oBrw| JEXECVIEW(1,"NV4","JURA027",oBrw,GetCpoBrw(oBrw,"NV4_COD"),STR0011) } } )

    //Cotações (Valores Pendentes)
	oResumo:SetValue("BROWSE_CT", { {|oBj, nRecno| oResumo:GetHeaders("NX6") }, ;
	                                {|oBj, nRecno, oBrw| aCotac }, } )

	//ConOut("Tempo gasto com Browse: "+oResumo:GetTimer()+" segundos")
	oResumo:Activate()
	oResumo:DeActivate()

Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} HeaderToStr()
Transforma o array com os campos do aHeader em uma variável caracter
para utilização nas querys.

@author Cristina Cintra
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function HeaderToStr(aHeader, cSeparate)
Local cCampos := ""
Local nI

Default cSeparate := ","

	For nI := 1 to Len(aHeader)
		If nI == 1
			cCampos += Alltrim(aHeader[nI][2])
		Else
			cCampos += cSeparate + Alltrim(aHeader[nI][2])
		EndIf
	Next

Return cCampos 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161CABEC()
Retorna o conteúdo dos campos do cabeçalho da tela de Resumo de Caso.

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA161CABEC(oResumo, nRecno, cCampo)
Local aArea     := GetArea()
Local cReturn   := ""
Local cAux      := ""
Local cAux2     := ""
	
	NVE->(dbGoTo(nRecno))

	Do Case
		Case cCampo == "CCLIEN"
			cReturn := NVE->NVE_CCLIEN
		
		Case cCampo == "LOJA"
			cReturn := NVE->NVE_LCLIEN		
		
		Case cCampo == "DCLIEN"
			cReturn :=	JurGetDados('SA1',1,xFilial('SA1')+NVE->NVE_CCLIEN+NVE->NVE_LCLIEN, 'A1_NOME' )
		
		Case cCampo == "NUMCAS" 
			cReturn := NVE->NVE_NUMCAS
		
		Case cCampo == "TITULO"
			cReturn := NVE->NVE_TITULO		
		
		Case cCampo == "SIGLA1"
			cReturn := JurGetDados('RD0',1,xFilial('RD0')+NVE->NVE_CPART1, 'RD0_SIGLA')		
		
		Case cCampo == "DTENTR"
			cReturn := NVE->NVE_DTENTR		
		
		Case cCampo == "CTABH"
			cReturn := NVE->NVE_CTABH	
		
		Case cCampo == "DTABH"
			cReturn := JurGetDados('NRF',1,xFilial("NRF")+NVE->NVE_CTABH,'NRF_DESC')
		
		Case cCampo == "MOETABH"
			cAux    := JurGetDados('NRF',1,xFilial("NRF")+NVE->NVE_CTABH,'NRF_MOEDA')
		
		Case cCampo == "CTABS"
			cReturn := NVE->NVE_CTABS
		
		Case cCampo == "DTABS"
			cReturn := JurGetDados("NRE",1,xFilial("NRE")+NVE->NVE_CTABS,'NRE_DESC')
					
		Case cCampo == "MOETABS"
			cAux    := JurGetDados('NRE',1,xFilial("NRE")+NVE->NVE_CTABS,'NRE_MOEDA')
		
		Case cCampo == "CTABP"
			cReturn := JA161NVP()
		
		Case cCampo == "DTABP"
			cAux    := JA161NVP()
			cReturn := JurGetDados('NRF',1,xFilial("NRF")+cAux,'NRF_DESC')
				
		Case cCampo == "MOETABP"
			cAux2   := JA161NVP()
			cAux    := JurGetDados('NRF',1,xFilial("NRF")+cAux2,'NRF_MOEDA')
		
		Case cCampo == "MOEOFIC"
			cAux    := SuperGetMV( 'MV_JMOENAC',, '01' )
		
		Case cCampo == "ENCHON"
			cReturn := NVE->NVE_ENCHON
		
		Case cCampo == "ENCDES"
			cReturn := NVE->NVE_ENCDES
					
		Case cCampo == "ENCTAB"
			cReturn := NVE->NVE_ENCTAB
		
		Case cCampo == "EXITO"
			cReturn := NVE->NVE_EXITO		
		
		Case cCampo == "DESPAD"
			cReturn := Str(NVE->NVE_DESPAD)
			
	EndCase
	
	If !Empty(cAux) .And. Empty(cReturn)  
		cReturn := JurGetDados('CTO',1,xFilial("CTO")+cAux,'CTO_SIMB')
	EndIf

	RestArea( aArea )
	
Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161NVP()
Função que retorna a tabela padrão de honorários do escritório (NVP).

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA161NVP()
Local cReturn := "" 
Local aReturn := {}
Local cQuery  := ""
Local cAnoMes := AnoMes(MsDate())

	cQuery := " SELECT NVP.NVP_CTABH TABPAD" + CRLF
	cQuery +=   " FROM "+RetSqlName("NVP")+" NVP "  + CRLF
	cQuery += " WHERE NVP.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += 	" AND NVP.NVP_FILIAL = '" + xFilial( "NVP" ) + "' " + CRLF
	cQuery +=   " AND ( '"+cAnoMes+"' BETWEEN NVP.NVP_AMINI AND NVP.NVP_AMFIM  " + CRLF
	cQuery += 		  " OR NVP.NVP_AMFIM = '' " + CRLF			
	cQuery +=        " )" 
				
	aReturn := JurSQL(cQuery, {"TABPAD"})
	
	If !Empty(aReturn) .And. ValType(aReturn[1][1]) == "C"
		cReturn := aReturn[1][1]
	EndIf
			
Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYTS()
Efetua a query dos Time Sheets a serem mostrados na aba Time Sheets 
do Resumo do Caso.

@author Cristina Cintra
@since 13/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYTS(oResumo, nRecno, oBrw)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryTS      := "" 
Local cCampos     := "" 
Local dDtIniTS    := oResumo:GetDtIniTs(.T.)
Local dDtFimTS    := oResumo:GetDtEndTs(.T.)
Local aTS         := {}

	cCampos := HeaderToStr(oBrw:aHeader)
	
	NVE->(dbGoTo(nRecno))
	
	cQryTS := "SELECT " + cCampos + " " + CRLF
	cQryTS += " FROM " + RetSqlName("NUE") +" NUE " + CRLF
	cQryTS += 	" WHERE NUE.NUE_FILIAL = '"+xFilial("NUE")+"' " + CRLF
	cQryTS +=   " AND NUE.NUE_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF 
	cQryTS +=   " AND NUE.NUE_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF 
	cQryTS +=   " AND NUE.NUE_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
	cQryTS +=   " AND NUE.NUE_DATATS >='"+dDtIniTS+"' " + CRLF
	cQryTS +=   " AND NUE.NUE_DATATS <='"+dDtFimTS+"' " + CRLF
	cQryTS +=   " AND NUE.D_E_L_E_T_ = ' ' "
	cQryTS += " ORDER BY " +  SQLOrder( NUE->( IndexKey( 1 ) ) )
	
	aTS := JurSQL(cQryTS, StrToArray(cCampos, ","))
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aTS 

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYDS()
Efetua a query das Despesas a serem mostradas na aba Despesas 
do Resumo do Caso.

@author Cristina Cintra
@since 13/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYDS(oResumo, nRecno, oBrw)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryDS      := ""
Local dDtIniDS    := oResumo:GetDtIniDs(.T.)
Local dDtFimDS    := oResumo:GetDtEndDs(.T.)
Local cCampos     := "" 
Local aDS         := {}

	cCampos := HeaderToStr(oBrw:aHeader)
	
	NVE->(dbGoTo(nRecno))
	
	cQryDS := "SELECT " + cCampos + " " + CRLF
	cQryDS += " FROM " + RetSqlName("NVY") +" NVY " + CRLF
	cQryDS += 	" WHERE NVY.NVY_FILIAL = '"+xFilial("NVY")+"' " + CRLF
	cQryDS +=   " AND NVY.NVY_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF 
	cQryDS +=   " AND NVY.NVY_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF 
	cQryDS +=   " AND NVY.NVY_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
	cQryDS +=   " AND NVY.NVY_DATA >='"+dDtIniDS+"' " + CRLF
	cQryDS +=   " AND NVY.NVY_DATA <='"+dDtFimDS+"' " + CRLF
	cQryDS +=   " AND NVY.D_E_L_E_T_ = ' ' "
	cQryDS += " ORDER BY " +  SQLOrder( NVY->( IndexKey( 1 ) ) )	
	
	aDS := JurSQL(cQryDS, StrToArray(cCampos, ","))
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aDS 

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYTB()
Efetua a query dos Tabelados a serem mostrados na aba Tabelados 
do Resumo do Caso.

@author Cristina Cintra
@since 13/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYTB(oResumo, nRecno, oBrw)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryTB      := ""
Local dDtIniTB    := oResumo:GetDtIniTb(.T.)
Local dDtFimTB    := oResumo:GetDtEndTb(.T.)
Local cCampos     := "" 
Local aTB         := {}

	cCampos := HeaderToStr(oBrw:aHeader)
	
	NVE->(dbGoTo(nRecno))
	
	cQryTB := "SELECT " + cCampos + " " + CRLF
	cQryTB += " FROM " + RetSqlName("NV4") +" NV4 " + CRLF
	cQryTB += 	" WHERE NV4.NV4_FILIAL = '"+xFilial("NV4")+"' " + CRLF
	cQryTB +=   " AND NV4.NV4_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF 
	cQryTB +=   " AND NV4.NV4_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF 
	cQryTB +=   " AND NV4.NV4_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
	cQryTB +=   " AND NV4.NV4_DTLANC >='"+dDtIniTB+"' " + CRLF
	cQryTB +=   " AND NV4.NV4_DTLANC <='"+dDtFimTB+"' " + CRLF
	cQryTB +=   " AND NV4.D_E_L_E_T_ = ' ' "
	cQryTB += " ORDER BY " +  SQLOrder( NV4->( IndexKey( 1 ) ) )
	
	aTB := JurSQL(cQryTB, StrToArray(cCampos, ","))
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aTB     

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYFAT()
Efetua a query das Faturas a serem mostradas na aba Faturas 
do Resumo do Caso.

@author Cristina Cintra
@since 16/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYFAT(oResumo, nRecno, oBrw)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryFat     := ""
Local cCampos     := "" 
Local aFT         := {}

	cCampos := HeaderToStr(oBrw:aHeader)
	
	NVE->(dbGoTo(nRecno))
	
	cQryFat := "SELECT " + cCampos + " " + CRLF
	cQryFat += " FROM " + RetSqlName("NXA") +" NXA, " + CRLF
	cQryFat += ""+ RetSQLName("NXC") +"  NXC " + CRLF
	cQryFat += " WHERE NXC.NXC_FILIAL = '" + xFilial('NXC') + "' " + CRLF
	cQryFat += " AND NXA.NXA_FILIAL = '" + xFilial('NXA') + "' " + CRLF
	cQryFat += " AND NXA.NXA_TIPO = 'FT' " + CRLF
	cQryFat += " AND NXC.NXC_CCLIEN = '" +NVE->NVE_CCLIEN+ "' " + CRLF
	cQryFat += " AND NXC.NXC_CLOJA  = '" +NVE->NVE_LCLIEN+ "' " + CRLF
	cQryFat += " AND NXC.NXC_CCASO  = '" +NVE->NVE_NUMCAS+ "' " + CRLF
	cQryFat += " AND NXC.NXC_CFATUR = NXA.NXA_COD" + CRLF
	cQryFat += " AND NXC.NXC_CESCR  = NXA.NXA_CESCR" + CRLF
	cQryFat += " AND NXA.D_E_L_E_T_ = ' ' " + CRLF
	cQryFat += " AND NXC.D_E_L_E_T_ = ' ' "
	cQryFat += " ORDER BY " +  SQLOrder( NXA->( IndexKey( 1 ) ) )
	
	aFT := JurSQL(cQryFat, StrToArray(cCampos, ","))
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aFT 

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYPF()
Efetua a query das Pré-faturas a serem mostradas na aba Pré-faturas 
do Resumo do Caso.

@author Cristina Cintra
@since 16/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYPF(oResumo, nRecno, oBrw)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local cQryPreFat := ""
Local cCampos    := ""
Local aPF        := {}

	cCampos := HeaderToStr(oBrw:aHeader)
	
	NVE->(dbGoTo(nRecno))
	
	cQryPreFat := "SELECT " + cCampos + " " + CRLF
	cQryPreFat += " FROM " + RetSqlName("NX0") +" NX0, " + CRLF
	cQryPreFat += ""+ RetSQLName("NX1") +"  NX1 " + CRLF
	cQryPreFat += " WHERE NX1.NX1_FILIAL = '" + xFilial('NX1') + "' " + CRLF
	cQryPreFat += " AND NX0.NX0_FILIAL = '" + xFilial('NX0') + "' " + CRLF
	cQryPreFat += " AND NX1.NX1_CCLIEN = '" +NVE->NVE_CCLIEN+ "' " + CRLF
	cQryPreFat += " AND NX1.NX1_CLOJA  = '" +NVE->NVE_LCLIEN+ "' " + CRLF
	cQryPreFat += " AND NX1.NX1_CCASO  = '" +NVE->NVE_NUMCAS+ "' " + CRLF
	cQryPreFat += " AND NX1.NX1_CPREFT = NX0.NX0_COD" + CRLF
	cQryPreFat += " AND NX0.NX0_SITUAC IN ('2','3','4','5','6','7','9','A','B') " + CRLF
	cQryPreFat += " AND NX0.D_E_L_E_T_ = ' ' " + CRLF
	cQryPreFat += " AND NX1.D_E_L_E_T_ = ' ' " 
	cQryPreFat += " ORDER BY " +  SQLOrder( NX0->( IndexKey( 1 ) ) )
	
	aPF := JurSQL(cQryPreFat, StrToArray(cCampos, ","))
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aPF 
  
//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYCont()
Efetua a query dos Contratos a serem mostrados na aba Contratos/Junções 
do Resumo do Caso.

@author Cristina Cintra
@since 16/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYCont(oResumo, nRecno, oBrw)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryContr  := "" 
Local cCampos    := ""
Local aCT        := {}

	If oBrw == Nil
		oBrw := oResumo:GetValue("BROWSE_CJ_M", 2)
	EndIf
	
	cCampos := HeaderToStr(oBrw:aHeader)
	
	NVE->(dbGoTo(nRecno))
	
	cQryContr += " SELECT " + cCampos + " " + CRLF
	cQryContr +=   " FROM " + RetSqlName("NT0") + " NT0 "+CRLF
	cQryContr +=          " INNER JOIN " + RetSqlName("NUT") + " NUT ON ( NUT.NUT_FILIAL = '" + xFilial("NUT") +"' AND "+CRLF
	cQryContr +=                                                         " NUT.NUT_CCONTR = NT0.NT0_COD AND "+CRLF
	cQryContr +=                                                         " NUT.NUT_CCLIEN = '"+ NVE->NVE_CCLIEN +"' AND "+CRLF
	cQryContr +=                                                         " NUT.NUT_CLOJA  = '"+ NVE->NVE_LCLIEN  +"' AND "+CRLF
	cQryContr +=                                                         " NUT.NUT_CCASO  = '"+ NVE->NVE_NUMCAS  +"' AND "+CRLF
	cQryContr +=                                                         " NUT.D_E_L_E_T_ = ' ' )" + CRLF
	cQryContr +=  " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "+CRLF
	cQryContr +=    " AND NT0.D_E_L_E_T_ = ' ' "
	cQryContr +=  " ORDER BY " +  SQLOrder( NT0->( IndexKey( 1 ) ) )
	
	aCT := JurSQL(cQryContr, StrToArray(cCampos, ","))
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aCT 

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYJun()
Efetua a query das Junções de Contrato a serem mostradas na aba 
Contratos/Junções do Resumo do Caso.

@author Cristina Cintra
@since 16/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYJun(oResumo, nRecno, oBrw)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryJunc    := ""
Local cCampos     := ""
Local cContr      := ""
Local aJC         := {}

	If oBrw == Nil
		oBrw := oResumo:GetValue("BROWSE_CJ_D", 2)
	EndIf

	cCampos := HeaderToStr(oBrw:aHeader)

	NVE->(dbGoTo(nRecno))

	oBrw_M := oResumo:GetValue("BROWSE_CJ_M", 2)
	cContr := GetCpoBrw(oBrw_M,"NT0_COD")
	
	If !Empty(cContr) 
		cQryJunc += " SELECT " + cCampos + " " + CRLF
		cQryJunc +=   " FROM " + RetSqlName("NW2") + " NW2 "+CRLF
		cQryJunc +=          " INNER JOIN " + RetSqlName("NUT") + " NUT ON ( NUT.NUT_FILIAL = '" + xFilial("NUT") +"' AND "+CRLF
		cQryJunc +=                                                         " NUT.NUT_CCONTR = '"+cContr+"' AND "+CRLF
		cQryJunc +=                                                         " NUT.NUT_CCLIEN = '"+ NVE->NVE_CCLIEN +"' AND "+CRLF
		cQryJunc +=                                                         " NUT.NUT_CLOJA  = '"+ NVE->NVE_LCLIEN +"' AND "+CRLF
		cQryJunc +=                                                         " NUT.NUT_CCASO  = '"+ NVE->NVE_NUMCAS +"' AND "+CRLF
		cQryJunc +=                                                         " NUT.D_E_L_E_T_ = ' ' )" + CRLF
		cQryJunc +=         " INNER JOIN "+RetSqlName('NW3')+" NW3 ON (NW3.NW3_FILIAL = '"+xFilial("NW3")+"' AND  " + CRLF
		cQryJunc +=                                                " NW3.NW3_CCONTR = '"+cContr+"' AND " + CRLF
		cQryJunc +=                                                " NW3.NW3_CJCONT = NW2.NW2_COD AND " + CRLF
		cQryJunc +=                                                " NW3.D_E_L_E_T_ = ' ') " + CRLF
		cQryJunc +=  " WHERE NW2.NW2_FILIAL = '" + xFilial("NW2") +"' "+CRLF
		cQryJunc +=    " AND NW2.D_E_L_E_T_ = ' ' "
		cQryJunc +=  " ORDER BY " +  SQLOrder( NW2->( IndexKey( 1 ) ) )		
		
		aJC := JurSQL(cQryJunc, StrToArray(cCampos, ","))
	EndIf

	RestArea(aAreaNVE)
	RestArea(aArea)

Return aJC

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYVFT()
Efetua a query dos campos de Valores Faturados do Resumo do Caso.

@ Param    cTipo  Indica o tipo de lançamento (TS, TB, DS ou FX)

@author Cristina Cintra
@since 11/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYVFT(cTipo, oResumo, nRecno)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryFat     := ""
Local aValFat     := {}
Local dDtIniTS    := oResumo:GetDtIniTs(.T.)
Local dDtFimTS    := oResumo:GetDtEndTs(.T.)
Local dDtIniDS    := oResumo:GetDtIniDs(.T.)
Local dDtFimDS    := oResumo:GetDtEndDs(.T.)
Local dDtIniTB    := oResumo:GetDtIniTb(.T.)
Local dDtFimTB    := oResumo:GetDtEndTb(.T.)
Local dDtIniFX    := oResumo:GetDtIniFx(.T.)
Local dDtFimFX    := oResumo:GetDtEndFx(.T.)

Default cTipo     := ""

	NVE->(dbGoTo(nRecno))
	
	cQryFat := "SELECT NXA_CESCR ESCR, NXA_COD CODFAT, NXA_CMOEDA MOEFAT, NXA_DTEMI DTEMI"
	If cTipo == "TS"
		cQryFat += ", NXC_VLTS VALOR " + CRLF
	ElseIf cTipo == "DS" 
		cQryFat += ", NXC_VLDESP VALOR " + CRLF
	ElseIf cTipo == "TB"
		cQryFat += ", NXC_VLTAB VALOR " + CRLF
	ElseIf cTipo == "FX"	
		cQryFat += ", NXC_VFIXO VALOR " + CRLF	
	EndIf
	cQryFat += " FROM " + RetSqlName("NXA") +" NXA, " + RetSqlName("NXC") +" NXC " + CRLF
	cQryFat += 	 " WHERE NXA.NXA_FILIAL = '"+xFilial("NXA")+"' " + CRLF
	cQryFat += 	 " AND NXC.NXC_FILIAL = '"+xFilial("NXC")+"' " + CRLF
	cQryFat +=   " AND NXA.NXA_FILIAL = NXC.NXC_FILIAL " + CRLF
	cQryFat += 	 " AND NXA.NXA_CESCR = NXC.NXC_CESCR " + CRLF
	cQryFat +=   " AND NXA.NXA_COD = NXC.NXC_CFATUR " + CRLF
	cQryFat +=   " AND NXC.NXC_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
	cQryFat +=   " AND NXC.NXC_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF
	cQryFat +=   " AND NXC.NXC_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
	cQryFat +=   " AND NXA.NXA_TIPO = 'FT' " + CRLF
	cQryFat +=   " AND NXA.NXA_SITUAC = '1' " + CRLF 
	If cTipo == "TS"
		cQryFat += " AND NXA.NXA_DTEMI >='"+dDtIniTS+"' " + CRLF
		cQryFat += " AND NXA.NXA_DTEMI <='"+dDtFimTS+"' " + CRLF
	ElseIf cTipo == "DS" 
		cQryFat += " AND NXA.NXA_DTEMI >='"+dDtIniDS+"' " + CRLF
		cQryFat += " AND NXA.NXA_DTEMI <='"+dDtFimDS+"' " + CRLF
	ElseIf cTipo == "TB"
		cQryFat += " AND NXA.NXA_DTEMI >='"+dDtIniTB+"' " + CRLF
		cQryFat += " AND NXA.NXA_DTEMI <='"+dDtFimTB+"' " + CRLF
	ElseIf cTipo == "FX"	
		cQryFat += " AND NXA.NXA_DTEMI >='"+dDtIniFX+"' " + CRLF
		cQryFat += " AND NXA.NXA_DTEMI <='"+dDtFimFX+"' " + CRLF
		cQryFat += " AND NXA.NXA_FATADC = '2' " + CRLF
	EndIf
	cQryFat +=     " AND NXA.D_E_L_E_T_ = ' ' " + CRLF
	cQryFat +=     " AND NXC.D_E_L_E_T_ = ' ' " + CRLF
	
	aValFat := JurSQL(cQryFat, {"ESCR","CODFAT", "MOEFAT","VALOR","DTEMI"})
	 
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aValFat 

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161VFTTS()
Efetua o cálculo do campo Time Sheet - Moeda Oficial de Valores 
Faturados do Resumo do Caso.

@author Cristina Cintra
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA161VFTTS(oResumo, nRecno)
Local cTipo      := "TS"
Local aVlFatTS   := {}
Local nVlFatTS   := 0 

	aVlFatTS := JQRYVFT(cTipo, oResumo, nRecno)
	nVlFatTS := JCalcVlFat(aVlFatTS, "NXA")

Return nVlFatTS

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161VFTFX()
Efetua o cálculo do campo Fixo - Moeda Oficial de Valores 
Faturados do Resumo do Caso.

@author Cristina Cintra
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA161VFTFX(oResumo, nRecno)
Local cTipo      := "FX" 
Local aVlFatFX   := {}
Local nVlFatFX   := 0 

	aVlFatFX := JQRYVFT(cTipo, oResumo, nRecno)
	nVlFatFX := JCalcVlFat(aVlFatFX, "NXA")

Return nVlFatFX

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161VFTDS()
Efetua o cálculo do campo Despesas - Moeda Oficial de Valores 
Faturados do Resumo do Caso.

@author Cristina Cintra
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------    
Static Function JA161VFTDS(oResumo, nRecno)
Local cTipo      := "DS" 
Local aVlFatDS   := {}
Local nVlFatDS   := 0 

	aVlFatDS := JQRYVFT(cTipo, oResumo, nRecno)
	nVlFatDS := JCalcVlFat(aVlFatDS, "NXA")

Return nVlFatDS

//-------------------------------------------------------------------
/*/{Protheus.doc} JA161VFTTB()
Efetua o cálculo do campo Tabelados - Moeda Oficial de Valores 
Faturados do Resumo do Caso.

@author Cristina Cintra
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA161VFTTB(oResumo, nRecno)
Local cTipo      := "TB" 
Local aVlFatTB   := {}
Local nVlFatTB   := 0 

	aVlFatTB := JQRYVFT(cTipo, oResumo, nRecno)
	nVlFatTB := JCalcVlFat(aVlFatTB, "NXA")

Return nVlFatTB

//-------------------------------------------------------------------
/*/{Protheus.doc} JCalcVlFat()
Efetua o cálculo dos campos de Valores Faturados do Resumo do Caso.

@author Cristina Cintra
@since 17/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCalcVlFat(aValores, cTabela)
Local aArea      := GetArea()
Local aRet       := {}
Local nValores   := 0 
Local nI

Default aValores := {}
Default cTabela  := ""

	If !Empty(aValores) .And. (ValType(aValores) == "A") .And. !Empty(cTabela) 
		For nI := 1 to Len(aValores)
			If Alltrim(aValores[nI][3]) == Alltrim(cMoeNac)
				nValores += aValores[nI][4] 	
			Else
		   		aRet := JA201FConv(Alltrim(cMoeNac), Alltrim(aValores[nI][3]), aValores[nI][4], '8',StoD(aValores[nI][5]),,,xFilial(("'"+cTabela+"'")), aValores[nI][1], Alltrim(aValores[nI][2]), '1' )		
				If !Empty(aRet) .And. Empty(aRet[4])		
		   	   		nValores += aRet[1]
		  		Else
		  			nValores += aValores[nI][4]	
		   	   	EndIf 
			EndIf
		Next
	EndIf
	
	RestArea(aArea)

Return nValores

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYVWOTS()
Efetua a query dos campos de TS em Valores WO do Resumo do Caso.

@author Cristina Cintra
@since 18/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYVWOTS(cTipo, oResumo, nRecno)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryWO      := ""
Local aValWO      := {}
Local dDtIniTS    := oResumo:GetDtIniTs(.T.)
Local dDtFimTS    := oResumo:GetDtEndTs(.T.)

Default cTipo     := ""

	NVE->(dbGoTo(nRecno))
	
	cQryWO := "SELECT NUF_DTEMI DTEMI, NUE_CMOEDA MOEDA, "
	If cTipo == "TEMPOL"
		cQryWO += "NUE_TEMPOL TEMPO, NUE_VALORH VALOR, NUE_CPART2 CPART, NUE_ANOMES ANOMES " + CRLF
	ElseIf cTipo == "TEMPOR" 
		cQryWO += "NUE_TEMPOR TEMPO, NUE_VALOR VALOR, NUE_CPART2 CPART, NUE_ANOMES ANOMES " + CRLF
	EndIf
	cQryWO += " FROM " + RetSqlName("NUE") +" NUE, " + RetSqlName("NW0") +" NW0, " + RetSqlName("NUF") +" NUF " + CRLF
	cQryWO += 	 " WHERE NUE.NUE_FILIAL = '"+xFilial("NUE")+"' " + CRLF
	cQryWO += 	 " AND NW0.NW0_FILIAL = '"+xFilial("NW0")+"' " + CRLF
	cQryWO += 	 " AND NUF.NUF_FILIAL = '"+xFilial("NUF")+"' " + CRLF
	cQryWO +=    " AND NUE.NUE_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
	cQryWO +=    " AND NUE.NUE_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF
	cQryWO +=    " AND NUE.NUE_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
	cQryWO += 	 " AND NUF.NUF_DTEMI >= '"+dDtIniTS+"' " + CRLF
	cQryWO += 	 " AND NUF.NUF_DTEMI <= '"+dDtFimTS+"' " + CRLF
	cQryWO += 	 " AND NW0.NW0_CTS = NUE.NUE_COD " + CRLF   
	cQryWO += 	 " AND NUF.NUF_COD = NW0.NW0_CWO " + CRLF
	cQryWO += 	 " AND NUF.NUF_SITUAC = '1' " + CRLF  
	cQryWO += 	 " AND NUE.NUE_SITUAC = '2' " + CRLF
	cQryWO += 	 " AND NW0.NW0_SITUAC = '3' " + CRLF
	cQryWO += 	 " AND NW0.NW0_CANC = '2' " + CRLF 
	cQryWO +=    " AND NUE.D_E_L_E_T_ = ' ' " + CRLF
	cQryWO +=    " AND NW0.D_E_L_E_T_ = ' ' " + CRLF 
	cQryWO +=    " AND NUF.D_E_L_E_T_ = ' ' " + CRLF 
	
	aValWO := JurSQL(cQryWO, {"DTEMI","MOEDA","TEMPO","VALOR","CPART","ANOMES"})
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aValWO

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLWOTS()
Efetua o cálculo do campo Time Sheet - Moeda Oficial dos Valores em WO 
do Resumo do Caso.

@author Cristina Cintra
@since 18/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLWOTS(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local cTipo      := "TEMPOR"
Local aVlWOTS    := {}
Local nVlWOTS    := 0 

	NVE->(dbGoTo(nRecno))
	
	aVlWOTS := JQRYVWOTS(cTipo, oResumo, nRecno)
	nVlWOTS := JCalcVlTS(aVlWOTS, cTipo, "NUE", cMoeNac,.F.,.F.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlWOTS

//-------------------------------------------------------------------
/*/{Protheus.doc} JCalcVlTS()
Efetua o cálculo dos campos de TS de Valores Pendentes do Resumo do Caso.

@author Cristina Cintra
@since 18/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCalcVlTS(aValores, cTipo, cTabela, cMoeTabH, lCotac, lPendentes)
Local aArea      := GetArea()
Local aRet       := {}
Local nValores   := 0 
Local nAux       := 0
Local cAux       := "" 
Local nPos       := 0 
Local lConverte  := .F.
Local nI

Default aValores    := {}  //"DTEMI","MOEDA","TEMPO","VALOR","CPART","ANOMES","PERC"
Default cTabela     := ""
Default cMoeTabH    := ""
Default cTipo       := ""
Default lPendentes  := .F. //Indica se a chamada é do cálculo de Valores Pendentes, pois neste caso a conversão é com a data do dia

	If !Empty(aValores) .And. (ValType(aValores) == "A") .And. !Empty(cTabela) .And. !Empty(cMoeTabH) .And. !Empty(cTipo) 
		For nI := 1 to Len(aValores)
			If cTipo == "TEMPOR"
				If aValores[nI][2] == cMoeTabH
					nValores += Iif(aValores[nI][7] == 0, aValores[nI][4], aValores[nI][4] * (aValores[nI][7] / 100) ) 
				Else
					lConverte := .T.
				EndIf 
			ElseIf cTipo == "TEMPOL"
	        	nAux := (aValores[nI][3] * Iif(aValores[nI][7] == 0, aValores[nI][4], aValores[nI][4] * (aValores[nI][7] / 100) ) )
	        	If aValores[nI][2] == cMoeTabH
					nValores += nAux 
				Else
					lConverte := .T.
				EndIf 
			EndIf	
			
			If lConverte  //JA201FConv(cMoeda1, cMoeda2, nVlOrig, cTpExec, dCotacao, cCodFImpr, cPreFt, cXFilial, cEscr, cFatura, cTipoConf )	
				If nAux <> 0
					If lPendentes
						aRet := JA201FConv(cMoeTabH, Alltrim(aValores[nI][2]), nAux, '1',Date())
					Else 
						aRet := JA201FConv(cMoeTabH, Alltrim(aValores[nI][2]), nAux, '1',StoD(aValores[nI][1]))						
					EndIf						
				Else
					If lPendentes
						aRet := JA201FConv(cMoeTabH, Alltrim(aValores[nI][2]), Iif(aValores[nI][7] == 0, aValores[nI][4], aValores[nI][4] * (aValores[nI][7] / 100) ), '1',Date())
					Else
						aRet := JA201FConv(cMoeTabH, Alltrim(aValores[nI][2]), Iif(aValores[nI][7] == 0, aValores[nI][4], aValores[nI][4] * (aValores[nI][7] / 100) ), '1',StoD(aValores[nI][1]))
					EndIf
				EndIf
				If !Empty(aRet) .And. Empty(aRet[4])		
		   	   		nValores += aRet[1]
		   	   		If lCotac //Pegar a cotação apenas quando a origem for Dados Pendentes, não WO
			   	   		cAux := JurGetDados('CTO',1,xFilial("CTO")+(Iif(cMoeTabH == cMoeNac, aValores[nI][2], cMoeTabH)),'CTO_SIMB')
			   	   		nPos := aScan(aCotac, { |x| x[1] == cAux .And. x[2] == Iif(aRet[3] <> 1, aRet[3], aRet[2]) })
			   	   		If nPos == 0
				   	   		Aadd(aCotac,{cAux, Iif(aRet[3] <> 1, aRet[3], aRet[2])})
				   	   	EndIf
					EndIf
		  		Else
					Iif(nAux <> 0, nValores += nAux, nValores += Iif(aValores[nI][7] == 0, aValores[nI][4], aValores[nI][4] * (aValores[nI][7] / 100) ))
		   	   	EndIf 
			EndIf
			lConverte  := .F.
		Next
	EndIf		
	
	RestArea(aArea)

Return nValores

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCpoBrw()
Busca o conteúdo de um campo da browse de acordo com a coluna passada.

@author Cristina Cintra
@since 19/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetCpoBrw(oBrw, cCol)
Local xRet
Local nCol := 0

Default cCol := ""

	If (nCol := aScan(oBrw:aHeader, {|x| AllTrim(x[2]) == AllTrim(cCol) } ) ) > 0

		If oBrw:At() > 0 .And. !Empty(oBrw:aCols)
			xRet := oBrw:aCols[oBrw:At()][nCol]
		EndIf
	EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JEXECVIEW()
Função para executar a visulização dos registros das browses via
FWExecView.

@author Cristina Cintra
@since 19/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JEXECVIEW(nAcao, cTabela, cRotina, oBrw, cKey, cMsg)
Local aArea     := GetArea()
Local aAreaTab  := GetArea(cTabela)
Local cTitulo   := STR0003 //"Visualizar"

Default cTabela := ""
Default cRotina := "" 
Default cKey    := ""
Default nAcao   := 1 //Visualizar
Default cMsg    := ""

If !Empty(cTabela) .And. !Empty(cRotina) .And. !Empty(cKey)

	(cTabela)->(DBSetOrder(1))

	If (cTabela)->(dbSeek(xFilial(cTabela)+cKey))
 		MsgRun(STR0007,cMsg,{|| FWExecView(STR0003, cRotina, nAcao,, { || lOk := .T., lOk }) }) //Carregando... //"Visualizar"			  		
	Endif

EndIf

RestArea(aAreaTab)
RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYVWOTD()
Efetua a query dos campos de Despesas e Tabelados em Valores WO do 
Resumo do Caso.

@author Cristina Cintra
@since 19/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYVWOTD(cTabPr, cTabFat, oResumo, nRecno)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryWO      := ""
Local aValWO      := {}
Local dDtIniDS    := oResumo:GetDtIniDs(.T.)
Local dDtFimDS    := oResumo:GetDtEndDs(.T.)
Local dDtIniTB    := oResumo:GetDtIniTb(.T.)
Local dDtFimTB    := oResumo:GetDtEndTb(.T.)

Default cTabPr    := ""
Default cTabFat   := ""

	If !Empty(cTabPr) .And. !Empty(cTabFat)

		NVE->(dbGoTo(nRecno))
		
		cQryWO := "SELECT NUF_DTEMI DTEMI, "
		
		If cTabPr == "NV4"
			cQryWO += "NV4_CMOEH MOEDA, NV4_VLHFAT VALOR, NV4_ANOMES ANOMES, NV4_CTPSRV TIPO, NV4_QUANT QTD, 0 PERC " + CRLF
			cQryWO += " FROM " + RetSqlName("NV4") +" NV4, " + RetSqlName("NW4") +" NW4, " + RetSqlName("NUF") +" NUF " + CRLF
		ElseIf cTabPr == "NVY"
			cQryWO += "NVY_CMOEDA MOEDA, CASE WHEN NVZ.NVZ_CFATUR = '' THEN NVY_VALOR ELSE NVY_VALOR * NXA.NXA_PERFAT/100 END VALOR, " + CRLF
			cQryWO += "NVY_ANOMES ANOMES, NVY_CTPDSP TIPO, NVY_QTD QTD, 0 PERC, " + CRLF
			cQryWO += "NVZ.NVZ_CFATUR,  " + CRLF
			cQryWO += "NXA.NXA_PERFAT,  " + CRLF
			cQryWO += "CASE WHEN NVZ.NVZ_CFATUR = '' THEN NVY_VALOR ELSE NVY_VALOR*NXA.NXA_PERFAT/100 END VALOR2 " + CRLF
			cQryWO += " FROM " + RetSqlName("NVY") +" NVY " 
			cQryWO += "INNER JOIN " + RetSqlName("NVZ") +" NVZ" + CRLF
			cQryWO += " ON NVZ.NVZ_FILIAL = '"+xFilial("NVZ")+"' " + CRLF
			cQryWO += "AND NVZ.NVZ_CDESP  = NVY.NVY_COD " + CRLF
			cQryWO += "AND NVZ.NVZ_SITUAC = '3' " + CRLF
			cQryWO += "AND NVZ.NVZ_CANC   = '2' " + CRLF
			cQryWO += "AND NVZ.D_E_L_E_T_ = ' ' " + CRLF
			cQryWO += "INNER JOIN "  + RetSqlName("NUF") + " NUF ON NUF.NUF_FILIAL = '"+xFilial("NUF")+"' " + CRLF
			cQryWO += "AND NUF.NUF_COD = NVZ.NVZ_CWO" + CRLF
			cQryWO += "AND NUF.D_E_L_E_T_ = ' '" + CRLF
			cQryWO += "AND NUF.NUF_DTEMI >= '"+dDtIniDS+"' " + CRLF
			cQryWO += "AND NUF.NUF_DTEMI <= '"+dDtFimDS+"' " + CRLF
			cQryWO += "AND NUF.NUF_SITUAC = '1' " + CRLF
			cQryWO += "LEFT JOIN "  + RetSqlName("NXA") + " NXA ON NXA.NXA_FILIAL = '"+xFilial("NXA")+"' " + CRLF
			cQryWO += "AND NXA.NXA_CESCR  = NVZ.NVZ_CESCR" + CRLF
			cQryWO += "AND NXA.NXA_COD    = NVZ.NVZ_CFATUR" + CRLF
			cQryWO += "AND NXA.D_E_L_E_T_ = ' ' " + CRLF
		EndIf
		If cTabPr == "NV4"
			cQryWO += 	 " WHERE "+cTabPr+"."+cTabPr+"_FILIAL = '"+xFilial(cTabPr)+"' " + CRLF
			cQryWO += 	 " AND "+cTabFat+"."+cTabFat+"_FILIAL = '"+xFilial(cTabFat)+"' " + CRLF
			cQryWO += 	 " AND NUF.NUF_FILIAL = '"+xFilial("NUF")+"' " + CRLF
			cQryWO +=    " AND "+cTabPr+"."+cTabPr+"_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
			cQryWO +=    " AND "+cTabPr+"."+cTabPr+"_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF
			cQryWO +=    " AND "+cTabPr+"."+cTabPr+"_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
			cQryWO += 	 " AND NUF.NUF_DTEMI >= '"+dDtIniTB+"' " + CRLF
			cQryWO += 	 " AND NUF.NUF_DTEMI <= '"+dDtFimTB+"' " + CRLF
        ElseIf cTabPr == "NVY"
 			cQryWO += 	 " WHERE NVY.NVY_FILIAL = '"+xFilial("NVY")+"' " + CRLF
			cQryWO += 	 " AND NVY.NVY_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
			cQryWO += 	 " AND NVY.NVY_CLOJA  = '"+NVE->NVE_LCLIEN+"' " + CRLF
			cQryWO += 	 " AND NVY.NVY_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
			cQryWO += 	 " AND NVY.NVY_SITUAC = '2' " + CRLF
			cQryWO +=	 " AND NVY.D_E_L_E_T_ = ' ' " + CRLF
        EndIf
		If cTabPr == "NV4"
	   		cQryWO += 	 " AND NW4.NW4_CLTAB = "+cTabPr+"."+cTabPr+"_COD " + CRLF 
			cQryWO += 	 " AND NUF.NUF_COD = "+cTabFat+"."+cTabFat+"_CWO " + CRLF
			cQryWO += 	 " AND NUF.NUF_SITUAC = '1' " + CRLF  
			cQryWO += 	 " AND "+cTabPr+"."+cTabPr+"_SITUAC = '2' " + CRLF
			cQryWO += 	 " AND "+cTabFat+"."+cTabFat+"_SITUAC = '3' " + CRLF
			cQryWO += 	 " AND "+cTabFat+"."+cTabFat+"_CANC = '2' " + CRLF 
			cQryWO +=    " AND "+cTabPr+".D_E_L_E_T_ = ' ' " + CRLF
			cQryWO +=    " AND "+cTabFat+".D_E_L_E_T_ = ' ' " + CRLF 
			cQryWO +=    " AND NUF.D_E_L_E_T_ = ' ' " + CRLF 
		EndIf
	EndIf
	
	aValWO := JurSQL(cQryWO, {"DTEMI","MOEDA","VALOR","ANOMES","TIPO","QTD","PERC"})
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aValWO  

//-------------------------------------------------------------------
/*/{Protheus.doc} JCalcVlTD()
Efetua o cálculo dos campos de Tabelados e Despesas dos Valores Pendentes 
do Resumo do Caso.

@author Cristina Cintra
@since 19/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCalcVlTD(aValores, lCotac, lPendentes, cMoeda)
Local aArea      := GetArea()
Local aRet       := {}
Local nValores   := 0
Local cAux       := "" 
Local nI

Default aValores    := {}  //{"DTEMI","MOEDA","VALOR","ANOMES","TIPO","QTD","PERC"}
Default lPendentes  := .F.
Default cMoeda      := cMoeNac

	If !Empty(aValores) .And. (ValType(aValores) == "A")
		For nI := 1 to Len(aValores)
        	If aValores[nI][2] == cMoeda
        		nValores += Iif(aValores[nI][7] == 0, aValores[nI][3], aValores[nI][3] * (aValores[nI][7] / 100) )
        	Else
        		//JA201FConv(cMoeda1, cMoeda2, nVlOrig, cTpExec, dCotacao, cCodFImpr, cPreFt, cXFilial, cEscr, cFatura, cTipoConf )
            	If lPendentes
	            	aRet := JA201FConv(cMoeda, aValores[nI][2], Iif(aValores[nI][7] == 0, aValores[nI][3], aValores[nI][3] * (aValores[nI][7] / 100) ), '1', Date())
	            Else
	           	aRet := JA201FConv(cMoeda, aValores[nI][2], Iif(aValores[nI][7] == 0, aValores[nI][3], aValores[nI][3] * (aValores[nI][7] / 100) ), '1', StoD(aValores[nI][1]))
	            EndIf
	            
            	If !Empty(aRet) .And. Empty(aRet[4])		
		   	   		nValores += aRet[1]
		   	   		If lCotac //Pegar a cotação apenas quando a origem for Dados Pendentes, não WO
			   	   		cAux := JurGetDados('CTO',1,xFilial("CTO")+Iif(aValores[nI][2] == cMoeNac, cMoeda, aValores[nI][2]),'CTO_SIMB')
			   	   		nPos := aScan(aCotac, { |x| x[1] == cAux .And. x[2] == Iif(aRet[3] <> 1, aRet[3], aRet[2]) })
			   	   		If nPos == 0
				   	   		Aadd(aCotac,{cAux, Iif(aRet[3] <> 1, aRet[3], aRet[2])})
				   	   	EndIf
					EndIf
		  		EndIf
			EndIf
			lConverte  := .F.
		Next
	EndIf		
	
	RestArea(aArea)

Return nValores  

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLWODS()
Efetua o cálculo do campo Despesa - Moeda Oficial dos Valores em WO 
do Resumo do Caso.

@author Cristina Cintra
@since 19/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLWODS(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlWODS    := {}
Local nVlWODS    := 0 

	NVE->(dbGoTo(nRecno))
	
	aVlWODS := JQRYVWOTD("NVY", "NVZ", oResumo, nRecno)
	nVlWODS := JCalcVlTD(aVlWODS,.F.,.F.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlWODS

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLWOTBMO()
Efetua o cálculo do campo Tabelado - Moeda Oficial dos Valores em WO 
do Resumo do Caso.

@author Cristina Cintra
@since 19/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLWOTBMO(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlWOTBMO  := {}
Local nVlWOTBMO  := 0 

	NVE->(dbGoTo(nRecno))
	
	aVlWOTBMO := JQRYVWOTD("NV4", "NW4", oResumo, nRecno)
	nVlWOTBMO := JCalcVlTD(aVlWOTBMO,.F.,.F.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlWOTBMO

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYVWOFX()
Efetua a query dos campos de Fixo em Valores WO do Resumo do Caso.

@author Cristina Cintra
@since 20/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYVWOFX(oResumo, nRecno)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryWO      := ""
Local aValWO      := {}
Local dDtIniFX    := oResumo:GetDtIniFx(.T.)
Local dDtFimFX    := oResumo:GetDtEndFx(.T.)

	NVE->(dbGoTo(nRecno))
		
	cQryWO := "SELECT NUF_DTEMI DTEMI, NT1_CMOEDA MOEDA, NT1_VALORA VALORA, NT1_VALORB VALORB  " + CRLF
	cQryWO += " FROM " + RetSqlName("NT1") +" NT1 " + CRLF
	cQryWO += " INNER JOIN " + RetSqlName("NUF") +" NUF ON (
	cQryWO +=                                             " NUF.NUF_FILIAL = '"+xFilial("NUF")+"' AND " + CRLF
	cQryWO +=                                             " NUF.NUF_DTEMI >= '"+dDtIniFX+"' AND " + CRLF 
	cQryWO +=                                             " NUF.NUF_DTEMI <= '"+dDtFimFX+"' AND " + CRLF 
	cQryWO +=                                             " NUF.NUF_SITUAC = '1' AND " + CRLF 
	cQryWO +=                                             " NUF.D_E_L_E_T_ = ' ' ) " + CRLF 	
	cQryWO += " INNER JOIN " + RetSqlName("NWE") +" NWE ON (
	cQryWO +=                                             " NWE.NWE_FILIAL = '"+xFilial("NWE")+"' AND " + CRLF
	cQryWO +=                                             " NWE.NWE_CFIXO = NT1.NT1_SEQUEN AND " + CRLF 
	cQryWO +=                                             " NWE.NWE_SITUAC = '3' AND " + CRLF 
	cQryWO +=                                             " NWE.NWE_CANC = '2' AND " + CRLF 
	cQryWO +=                                             " NWE.NWE_CWO = NUF.NUF_COD AND " + CRLF 
	cQryWO +=                                             " NWE.D_E_L_E_T_ = ' ' ) " + CRLF 
	cQryWO += 	 " WHERE NT1.NT1_FILIAL = '"+xFilial("NT1")+"' " + CRLF
	cQryWO += 	 " AND NT1.NT1_SITUAC = '2' " + CRLF
	cQryWO +=    " AND NT1.D_E_L_E_T_ = ' ' " + CRLF
	cQryWO +=    " AND NT1.NT1_CCONTR IN " + CRLF
	cQryWO +=                          " ( SELECT NUT_CCONTR FROM " + RetSqlName("NUT") +" NUT WHERE NUT.NUT_FILIAL = '"+xFilial("NUT")+"' AND " + CRLF 
	cQryWO +=                            " NUT.NUT_CCLIEN = '"+NVE->NVE_CCLIEN+"' AND " + CRLF 
	cQryWO +=                            " NUT.NUT_CLOJA  = '"+NVE->NVE_LCLIEN+"' AND " + CRLF 
	cQryWO +=                            " NUT.NUT_CCASO  = '"+NVE->NVE_NUMCAS+"' AND " + CRLF
	cQryWO +=                            " NUT.D_E_L_E_T_ = ' ') "

	aValWO := JurSQL(cQryWO, {"DTEMI","MOEDA","VALORA","VALORB"})
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aValWO

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLRWOFX()
Efetua o cálculo do campo Fixo - Moeda Oficial dos Valores em WO 
do Resumo do Caso.

@author Cristina Cintra
@since 20/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLRWOFX(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlWOFX    := {}
Local nVlWOFX    := 0 

	NVE->(dbGoTo(nRecno))
	
	aVlWOFX := JQRYVWOFX(oResumo, nRecno)
	nVlWOFX := JCalcVFXWO(aVlWOFX,.F.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlWOFX 

//-------------------------------------------------------------------
/*/{Protheus.doc} JCalcVFXWO()
Efetua o cálculo do campo de Fixo dos Valores em WO 
do Resumo do Caso.

@author Cristina Cintra
@since 20/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCalcVFXWO(aValores)
Local aArea      := GetArea()
Local aRet       := {}
Local nValores   := 0
Local nAux       := 0
Local lConverte  := .F. 
Local nI

Default aValores    := {}  //{"DTEMI","MOEDA","VALORA","VALORB"}

	If !Empty(aValores) .And. (ValType(aValores) == "A")
		For nI := 1 to Len(aValores)
        	If !(aValores[nI][2] == cMoeNac)
        		lConverte := .T.
        	EndIf
			
       		If !Empty(aValores[nI][3])  //Se o Valor Atual estiver preenchido utiliza ele, senão utiliza o Valor Base
        		nAux += aValores[nI][3]
        	Else        		
        		nAux += aValores[nI][4]
        	EndIf        		
        	
			If lConverte
        		//JA201FConv(cMoeda1, cMoeda2, nVlOrig, cTpExec, dCotacao, cCodFImpr, cPreFt, cXFilial, cEscr, cFatura, cTipoConf )
            	aRet := JA201FConv(cMoeNac, Alltrim(aValores[nI][2]), nAux, '1', StoD(aValores[nI][1]))
            	If !Empty(aRet) .And. Empty(aRet[4])		
		   	   		nValores += aRet[1]
		  		EndIf
			Else
				nValores += nAux		
			EndIf
		Next
	EndIf		
	
	RestArea(aArea)

Return nValores  

//-------------------------------------------------------------------
/*/{Protheus.doc} JClcVTSTP()
Efetua o cálculo dos campos de Valor - Tempo Lançado e Valor - Tempo 
Revisado na Tabela Honorários Padrão de Valores Pendentes do Resumo do 
Caso.

@author Cristina Cintra
@since 20/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JClcVTSTP(aValores, cTipo, cTabela, cTabPad, cMoeTabP)
Local aArea      := GetArea()
Local aRet       := {} 
Local nValores   := 0 
Local nAux       := 0
Local cAux       := "" 
Local lConverte  := .F.
Local nI

Default aValores    := {}  //"DTEMI","MOEDA","TEMPO","VALOR","CPART","ANOMES","PERC"
Default cTabela     := ""
Default cMoeTabP    := ""
Default cTipo       := ""

	If !Empty(aValores) .And. (ValType(aValores) == "A") .And. !Empty(cTabela) .And. !Empty(cMoeTabP) .And. !Empty(cTipo) 
       	
       	For nI := 1 to Len(aValores)
       		
			aRet := JCALCTSTP(aValores[nI][5], aValores[nI][6], cTabPad) //Retorna o Vl Hora de acordo com a Tab Padrão
	        If !Empty(aRet)
	        	nValorH := aRet[2]
	        	If aRet[1] <> cMoeTabP
	        		lConverte := .T. 
	        	EndIf 
			EndIf
			
			If nValorH <> 0
				nAux := ( Iif(aValores[nI][7] == 0, aValores[nI][3], aValores[nI][3] * (aValores[nI][7] / 100) ) * nValorH )        
		
				If lConverte  //JA201FConv(cMoeda1, cMoeda2, nVlOrig, cTpExec, dCotacao, cCodFImpr, cPreFt, cXFilial, cEscr, cFatura, cTipoConf )	
					aRet := JA201FConv(aRet[1], cMoeTabP, Iif(aValores[nI][7] == 0, aValores[nI][4], aValores[nI][4] * (aValores[nI][7] / 100) ), '1', StoD(aValores[nI][1]))						
					If !Empty(aRet) .And. Empty(aRet[4])		
				   		nValores += aRet[1]
			   	   		If lCotac //Pegar a cotação apenas quando a origem for Dados Pendentes, não WO
					   		cAux := JurGetDados('CTO',1,xFilial("CTO")+(Iif(cMoeTabP == cMoeNac, aRet[1], cMoeTabP)),'CTO_SIMB')
					   		nPos := aScan(aCotac, { |x| x[1] == cAux .And. x[2] == Iif(aRet[3] <> 1, aRet[3], aRet[2]) })
				   	   		If nPos == 0
					   	   		Aadd(aCotac,{cAux, Iif(aRet[3] <> 1, aRet[3], aRet[2])})
					   	   	EndIf
						EndIf
				   	EndIf 
				Else
					nValores += nAux
				EndIf
			EndIf
			lConverte  := .F.
		Next
	EndIf		
	
	RestArea(aArea)

Return nValores 

//-------------------------------------------------------------------
/*/{Protheus.doc} JCALCTSTP(cPart, cAnoMes, cTabHon)

Rotina que retorna o valor hora e a moeda do Time Sheet considerando o 
participante e a Tabela de Honorários passada no parâmetro.

@Return nRet   Valor Hora 

@author Cristina Cintra
@since 20/12/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JCALCTSTP(cPart, cAnoMes, cTabHon)
Local nValorH   := 0
Local cMoeda    := ""
Local nVlTemp   := 0
Local aRet      := {}
Local aArea     := GetArea()
Local cQry1     := ""
Local cQryNUE   := ""

Default cPart    	:= ""
Default cAnoMes     := ""
Default cTabHon     := ""

	If !Empty(cPart) .And. !Empty(cAnoMes) .And. !Empty(cTabHon)
	
		cQry1 := "SELECT NTU.NTU_VALORH, NTV.NTV_COD, NTV.NTV_CMOEDA "
		
		cQry1 += "FROM " + RetSqlName("NUS") + " NUS "   // histórico do participante
		
		cQry1 += "INNER JOIN " + RetSqlName("NTU") + " NTU "  // histórico de honorários por categoria
		cQry1 +=    "ON NTU.NTU_FILIAL = '" + xFilial("NTU") + "' "
		cQry1 +=   "AND NTU.NTU_CCAT = NUS.NUS_CCAT "
		cQry1 +=   "AND NTU.D_E_L_E_T_ = ' ' "
		
		cQry1 += "INNER JOIN " + RetSqlName("NTV") + " NTV "  // histórico da tabela de honorários
		cQry1 +=    "ON NTV.NTV_FILIAL = '" + xFilial("NTV") + "' "
		cQry1 +=   "AND NTV.NTV_COD = NTU.NTU_CHIST "
		cQry1 +=   "AND NTV.D_E_L_E_T_ = ' ' "
		
		cQry1 += "WHERE NUS.NUS_FILIAL = '" + xFilial("NUS") + "' "
		cQry1 +=   "AND (('"+cAnoMes+"' >= NTV.NTV_AMINI AND NTV.NTV_AMFIM = '"+Space(TamSx3('NTV_AMFIM')[1])+"') OR "
		cQry1 +=        "('"+cAnoMes+"' BETWEEN NTV.NTV_AMINI AND NTV.NTV_AMFIM)) "
		cQry1 +=   "AND (('"+cAnoMes+"' >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '"+Space(TamSx3('NUS_AMFIM')[1])+"') OR "
		cQry1 +=        "('"+cAnoMes+"' BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
		cQry1 +=   "AND NUS.NUS_CPART = '" + cPart + "' "
		cQry1 +=   "AND NTV.NTV_CTAB  = '" + cTabHon + "' "
		cQry1 +=   "AND NTU.NTU_CTAB  = '" + cTabHon + "' "
		cQry1 +=   "AND NUS.D_E_L_E_T_ = ' ' "
	
		cQryNUE := GetNextAlias()
		cQry1   := ChangeQuery( cQry1, .F.)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQry1 ), cQryNUE, .T., .F. )
		
		nValorH  := (cQryNUE)->NTU_VALORH
		cMoeda   := (cQryNUE)->NTV_CMOEDA
		
		While !(cQryNUE)->(EOF())
			
			nVlTemp := JurGetDados('NTT',2,xFilial('NTT')+cTabHon+(cQryNUE)->NTV_COD+cPart,'NTT_VALORH')
			
			If !Empty(nVlTemp) .and. nVlTemp != 0
				nValorH := nVlTemp
			EndIf
			
			aAdd(aRet,cMoeda)
			aAdd(aRet,nValorH)
		
			(cQryNUE)->(dbSkip())
			
		EndDo
	
		(cQryNUE)->( dbcloseArea() )
	
	EndIf

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JCalcVlTC
Calcula os valores de Honorários do Lançamento Tabelado com base no 
histórico da Tabela de Serviços do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JCalcVlTC(cCodHis, cCodSrv, nQuant)
Local aArea    := GetArea()
Local aAreaNTS := GetArea("NTS")
Local nHonQtd  := 0
Local nHonExt  := 0
Local nVlrHon  := 0

Default cCodHis := ""
Default cCodSrv := ""

	If !Empty(cCodHis) .And. !Empty(cCodSrv)
		NTS->(dbSetOrder(3))
		If NTS->(dbSeek(xFilial('NTS') + cCodHis + cCodSrv))
			If nQuant > 0
				nHonExt := nQuant - NTS->NTS_MAXSER
				nHonExt := IIf(nHonExt > 0, nHonExt, 0)
				nHonQtd := nQuant - nHonExt
				nVlrHon := NTS->NTS_VALORH + (NTS->NTS_ADISER * nHonExt)
		  	EndIf
		EndIf		  
	EndIf

	RestArea(aAreaNTS)
	RestArea(aArea)
	
Return nVlrHon

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTSTL()
Efetua o cálculo do campo Valor - Tempo Lançado dos Valores Pendentes
do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTSTL(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local cTipo      := "TEMPOL"
Local cMoeTabH   := ""  
Local aVlPdTSTL  := {}
Local nVlPdTSTL  := 0 

	NVE->(dbGoTo(nRecno))
	cMoeTabH := JurGetDados('NRF',1,xFilial("NRF")+NVE->NVE_CTABH,'NRF_MOEDA')  
	
	aVlPdTSTL := JQRYVPDTS(cTipo, oResumo, nRecno) //{"MOEDA","TEMPO","VALOR","CPART","ANOMES","PERC"}
	nVlPdTSTL := JCalcVlTS(aVlPdTSTL, cTipo, "NUE", cMoeTabH,.T.,.T.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlPdTSTL

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTSTR()
Efetua o cálculo do campo Valor - Tempo Revisado da Tabela do Caso dos 
Valores Pendentes do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTSTR(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local cTipo      := "TEMPOR"
Local cMoeTabH   := ""  
Local aVlPdTSTR  := {}
Local nVlPdTSTR  := 0 

	NVE->(dbGoTo(nRecno))
	cMoeTabH := JurGetDados('NRF',1,xFilial("NRF")+NVE->NVE_CTABH,'NRF_MOEDA')  
	
	aVlPdTSTR := JQRYVPDTS(cTipo, oResumo, nRecno) //{"MOEDA","TEMPO","VALOR","CPART","ANOMES","PERC"}
	nVlPdTSTR := JCalcVlTS(aVlPdTSTR, cTipo, "NUE", cMoeTabH,.T.,.T.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlPdTSTR

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYVPDTS()
Efetua a query dos campos de TS em Valores Pendentes do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYVPDTS(cTipo, oResumo, nRecno)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryPdTS    := ""
Local aValPdTS    := {}
Local dDtIniTS    := oResumo:GetDtIniTs(.T.)
Local dDtFimTS    := oResumo:GetDtEndTs(.T.)

Default cTipo     := ""

	NVE->(dbGoTo(nRecno))
	
	cQryPdTS := "SELECT '"+DtoS(Date())+"' DTEMI, NUE_CMOEDA MOEDA, "
	If cTipo == "TEMPOL"
		cQryPdTS += "NUE_TEMPOL TEMPO, NUE_VALORH VALOR, NUE_CPART2 CPART, NUE_ANOMES ANOMES, 0 PERC " + CRLF
	ElseIf cTipo == "TEMPOR" 
		cQryPdTS += "NUE_TEMPOR TEMPO, NUE_VALOR VALOR, NUE_CPART2 CPART, NUE_ANOMES ANOMES, 0 PERC " + CRLF
	EndIf
	cQryPdTS += " FROM " + RetSqlName("NUE") +" NUE " + CRLF
	cQryPdTS += 	 " WHERE NUE.NUE_FILIAL = '"+xFilial("NUE")+"' " + CRLF
	cQryPdTS +=   	 " AND NUE.NUE_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
	cQryPdTS +=    	 " AND NUE.NUE_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF
	cQryPdTS +=      " AND NUE.NUE_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
	cQryPdTS += 	 " AND NUE.NUE_DATATS >= '"+dDtIniTS+"' " + CRLF
	cQryPdTS += 	 " AND NUE.NUE_DATATS <= '"+dDtFimTS+"' " + CRLF
	cQryPdTS += 	 " AND NUE.NUE_SITUAC = '1' " + CRLF
	cQryPdTS +=      " AND NUE.D_E_L_E_T_ = ' ' " + CRLF
	
	cQryPdTS +=    " UNION "  + CRLF
		
	cQryPdTS += " SELECT DTEMI, MOEDA, TEMPO, VALOR, CPART, ANOMES, ( 100 - SUM(PERC) ) PERC "  + CRLF
	cQryPdTS += " FROM ( "   + CRLF
	
	cQryPdTS += " SELECT '"+DtoS(Date())+"' DTEMI, NUE_CMOEDA MOEDA, "
	
	If cTipo == "TEMPOL"
		cQryPdTS += " NUE_TEMPOL TEMPO, " + CRLF
	ElseIf cTipo == "TEMPOR" 
		cQryPdTS += " NUE_TEMPOR TEMPO, " + CRLF
	EndIf

	cQryPdTS += " NUE_VALORH VALOR, NUE_CPART2 CPART, NUE_ANOMES ANOMES, NXA.NXA_PERFAT PERC " + CRLF
	cQryPdTS += " FROM " + RetSqlName("NUE") +" NUE " + CRLF
	
	cQryPdTS += " INNER JOIN " + RetSqlName("NW0") +" NW0 " + CRLF
	cQryPdTS += " ON NW0.NW0_FILIAL = 	'"+xFilial("NW0")+"' " + CRLF
	cQryPdTS += " AND NW0.NW0_CTS  = NUE.NUE_COD " + CRLF
	cQryPdTS += " AND NW0.NW0_SITUAC IN ('2','3') " + CRLF
	cQryPdTS += " AND NW0.NW0_CANC = '2' " + CRLF
	cQryPdTS += " AND NW0.D_E_L_E_T_ = ' ' " + CRLF
		
	cQryPdTS += " LEFT JOIN " + RetSqlName("NXA") +" NXA " + CRLF
	cQryPdTS += " ON NXA.NXA_FILIAL  = 	'"+xFilial("NXA")+"' " + CRLF
	cQryPdTS += " AND NXA.NXA_CESCR  = NW0.NW0_CESCR " + CRLF
	cQryPdTS += " AND NXA.NXA_COD    = NW0.NW0_CFATUR " + CRLF
	cQryPdTS += " AND NXA.D_E_L_E_T_ = ' '	 " + CRLF
	
	cQryPdTS += " WHERE NUE.NUE_FILIAL = 	'"+xFilial("NUE")+"' " + CRLF
	cQryPdTS += " AND NUE.NUE_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
	cQryPdTS += " AND NUE.NUE_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF
	cQryPdTS += " AND NUE.NUE_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
	cQryPdTS += " AND NUE.NUE_DATATS >= '"+dDtIniTS+"' " + CRLF
	cQryPdTS += " AND NUE.NUE_DATATS <= '"+dDtFimTS+"' " + CRLF
	cQryPdTS += " AND NUE.NUE_SITUAC = '2'  " + CRLF
	cQryPdTS += " AND NUE.D_E_L_E_T_ = ' '  " + CRLF
	cQryPdTS += " ) A "  + CRLF
	cQryPdTS += " GROUP BY DTEMI, MOEDA, TEMPO, VALOR, CPART, ANOMES " + CRLF
	cQryPdTS += " HAVING ( 100 - SUM(PERC) ) > 0 "
	
	aValPdTS := JurSQL(cQryPdTS, {"DTEMI","MOEDA","TEMPO","VALOR","CPART","ANOMES","PERC"})
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aValPdTS

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTSPTL()
Efetua o cálculo do campo Valor - Tempo Lançado na Tabela Honorários 
Padrão dos Valores em WO do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTSPTL(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aAreaNRF   := GetArea("NRF")
Local cTipo      := "TEMPOL"
Local cTabPad    := ""  
Local cMoeTabP   := ""  
Local aVPDTSPTL  := {}
Local nVPDTSPTL  := 0 

	NVE->(dbGoTo(nRecno))
	cTabPad  := JA161NVP()
	
	If !Empty(cTabPad)
		cMoeTabP := JurGetDados('NRF',1,xFilial("NRF")+cTabPad,'NRF_MOEDA')
	
		aVPDTSPTL := JQRYVPDTS(cTipo, oResumo, nRecno)
		nVPDTSPTL := JClcVTSTP(aVPDTSPTL, cTipo, "NUE", cTabPad, cMoeTabP,.T.)
	EndIf

	RestArea(aAreaNRF)		
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVPDTSPTL 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTSPTR()
Efetua o cálculo do campo Valor - Tempo Revisado na Tabela Honorários 
Padrão dos Valores em WO do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTSPTR(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aAreaNRF   := GetArea("NRF")
Local cTipo      := "TEMPOR"
Local cTabPad    := ""  
Local cMoeTabP   := ""  
Local aVPDTSPTR  := {}
Local nVPDTSPTR  := 0 

	NVE->(dbGoTo(nRecno))
	cTabPad  := JA161NVP()
	
	If !Empty(cTabPad)
		cMoeTabP := JurGetDados('NRF',1,xFilial("NRF")+cTabPad,'NRF_MOEDA')
	
		aVPDTSPTR := JQRYVPDTS(cTipo, oResumo, nRecno)
		nVPDTSPTR := JClcVTSTP(aVPDTSPTR, cTipo, "NUE", cTabPad, cMoeTabP,.T.)
	EndIf

	RestArea(aAreaNRF)		
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVPDTSPTR

//-------------------------------------------------------------------
/*/{Protheus.doc} JQRYVPDTD()
Efetua a query dos campos de Despesas e Tabelados em Valores Pendentes 
do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JQRYVPDTD(cTabPr, cTipoTab, oResumo, nRecno)
Local aArea       := GetArea()
Local aAreaNVE    := GetArea("NVE")
Local cQryVal     := ""
Local aValPd      := {}
Local dDtIniDS    := oResumo:GetDtIniDs(.T.)

Local dDtFimDS    := oResumo:GetDtEndDs(.T.)
Local dDtIniTB    := oResumo:GetDtIniTb(.T.)
Local dDtFimTB    := oResumo:GetDtEndTb(.T.)
Local cTabFat     := iif(cTabPr == "NVY", "NVZ", "NW4") 

Default cTabPr    := ""
Default cTipoTab  := ""

	If !Empty(cTabPr)

		NVE->(dbGoTo(nRecno))
		
		cQryVal := "SELECT "
		If cTabPr == "NV4"
			If cTipoTab == "FAT" 
				cQryVal += " NV4_DTLANC DTEMI, NV4_CMOEH MOEDA, "+cTabPr+"_VLHFAT VALOR, NV4_ANOMES ANOMES, NV4_CTPSRV TIPO, NV4_QUANT QTD, 0 PERC " + CRLF  
			Else
				cQryVal += " NV4_DTLANC DTEMI, NV4_CMOEH MOEDA, "+cTabPr+"_VLHTAB VALOR, NV4_ANOMES ANOMES, NV4_CTPSRV TIPO, NV4_QUANT QTD, 0 PERC " + CRLF
			EndIf
			cQryVal += " FROM " + RetSqlName("NV4") +" NV4 " + CRLF
			
		ElseIf cTabPr == "NVY"
			cQryVal += "NVY_DATA DTEMI, NVY_CMOEDA MOEDA, NVY_VALOR VALOR, NVY_ANOMES ANOMES, NVY_CTPDSP TIPO, NVY_QTD QTD, 0 PERC " + CRLF
			cQryVal += " FROM " + RetSqlName("NVY") +" NVY " + CRLF
		EndIf

		cQryVal += 	 " WHERE "+cTabPr+"."+cTabPr+"_FILIAL = '"+xFilial(cTabPr)+"' " + CRLF
		cQryVal +=    " AND "+cTabPr+"."+cTabPr+"_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
		cQryVal +=    " AND "+cTabPr+"."+cTabPr+"_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF
		cQryVal +=    " AND "+cTabPr+"."+cTabPr+"_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
		
		If cTabPr == "NV4"
			cQryVal += 	 " AND NV4.NV4_DTCONC >= '"+dDtIniTB+"' " + CRLF
			cQryVal += 	 " AND NV4.NV4_DTCONC <= '"+dDtFimTB+"' " + CRLF
        ElseIf cTabPr == "NVY"
 			cQryVal += 	 " AND NVY.NVY_DATA >= '"+dDtIniDS+"' " + CRLF
			cQryVal += 	 " AND NVY.NVY_DATA <= '"+dDtFimDS+"' " + CRLF
        EndIf
        
		cQryVal += 	 " AND "+cTabPr+"."+cTabPr+"_SITUAC = '1' " + CRLF
		cQryVal +=    " AND "+cTabPr+".D_E_L_E_T_ = ' ' " + CRLF

		cQryVal +=    " UNION ALL "  + CRLF
		
		cQryVal += "SELECT "
		cQryVal += " DTEMI, MOEDA, VALOR, ANOMES, TIPO, QTD, ( 100 - SUM(PERC) ) PERC "  + CRLF
		cQryVal += " FROM ( SELECT  "  + CRLF
		
		If cTabPr == "NVY"
			cQryVal += " NVY_DATA DTEMI , NVY_CMOEDA MOEDA, NVY_VALOR VALOR, NVY_ANOMES ANOMES, NVY_CTPDSP TIPO, NVY_QTD QTD, NXA.NXA_PERFAT PERC " + CRLF
		ElseIf cTabPr == "NV4"
			If cTipoTab == "FAT"
				cQryVal += " NV4_DTLANC DTEMI, NV4_CMOEH MOEDA, "+cTabPr+"_VLHFAT VALOR, NV4_ANOMES ANOMES, NV4_CTPSRV TIPO, NV4_QUANT QTD, NXA.NXA_PERFAT PERC " + CRLF
			Else
				cQryVal += " NV4_DTLANC DTEMI, NV4_CMOEH MOEDA, "+cTabPr+"_VLHTAB VALOR, NV4_ANOMES ANOMES, NV4_CTPSRV TIPO, NV4_QUANT QTD, NXA.NXA_PERFAT PERC " + CRLF
			EndIf
		EndIf
			
		cQryVal += " FROM " + RetSqlName(cTabPr)+ " " +cTabPr + CRLF 
		cQryVal += " INNER JOIN " + RetSqlName(cTabFat) +" " +cTabFat+ CRLF
		cQryVal += " ON "+cTabFat+"."+cTabFat+"_FILIAL = '"+xFilial(cTabFat)+"' " + CRLF
		If cTabPr == "NVY"
			cQryVal += " AND NVZ.NVZ_CDESP = NVY.NVY_COD " + CRLF
		ElseIf cTabPr == "NV4"
			cQryVal += " AND NW4.NW4_CLTAB = NV4.NV4_COD " + CRLF
		EndIf
		cQryVal += " AND "+cTabFat+"."+cTabFat+"_SITUAC IN ('2','3') " + CRLF
		cQryVal += " AND "+cTabFat+"."+cTabFat+"_CANC = '2' " + CRLF
		cQryVal += " AND "+cTabFat+".D_E_L_E_T_ = ' ' " + CRLF

		cQryVal += " INNER JOIN " + RetSqlName("NXA") +" NXA "
		cQryVal += " ON NXA.NXA_FILIAL = '"+xFilial("NXA")+"' " + CRLF
		cQryVal += " AND NXA.NXA_CESCR  = "+cTabFat+"."+cTabFat+"_CESCR " + CRLF
		cQryVal += " AND NXA.NXA_COD    = "+cTabFat+"."+cTabFat+"_CFATUR " + CRLF
		cQryVal += " AND NXA.D_E_L_E_T_ = ' ' " + CRLF
		cQryVal += " WHERE "+cTabPr+"."+cTabPr+"_FILIAL = '"+xFilial(cTabPr)+"' " + CRLF
		cQryVal += " AND "+cTabPr+"."+cTabPr+"_CCLIEN = '"+NVE->NVE_CCLIEN+"' " + CRLF
		cQryVal += " AND "+cTabPr+"."+cTabPr+"_CLOJA = '"+NVE->NVE_LCLIEN+"' " + CRLF
		cQryVal += " AND "+cTabPr+"."+cTabPr+"_CCASO = '"+NVE->NVE_NUMCAS+"' " + CRLF
			
		If cTabPr == "NVY"
			cQryVal += " AND NVY.NVY_DATA >= '"+dDtIniDS+"' " + CRLF
			cQryVal += " AND NVY.NVY_DATA <= '"+dDtFimDS+"' " + CRLF
			 
		ElseIf cTabPr == "NV4"
			cQryVal += " AND NV4.NV4_DTCONC >= '"+dDtIniTB+"' " + CRLF
			cQryVal += " AND NV4.NV4_DTCONC <= '"+dDtFimTB+"' " + CRLF
		EndIf
		
		cQryVal += " AND "+cTabPr+"."+cTabPr+"_SITUAC = '2' " + CRLF
		cQryVal += " AND "+cTabPr+".D_E_L_E_T_ = ' ' " + CRLF
		cQryVal += " ) A " + CRLF
		cQryVal += " GROUP BY DTEMI, MOEDA, VALOR, ANOMES, TIPO, QTD " + CRLF
		cQryVal += " HAVING ( 100 - SUM(PERC) ) > 0 "
	EndIf
	
	aValPd := JurSQL(cQryVal, {"DTEMI","MOEDA","VALOR","ANOMES","TIPO","QTD","PERC"})
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return aValPd  

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDDS()
Efetua o cálculo do campo Despesa - Moeda Oficial dos Valores Pendentes
do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDDS(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlPDDS    := {}
Local nVlPDDS    := 0 

	NVE->(dbGoTo(nRecno))
	
	aVlPDDS := JQRYVPDTD("NVY","", oResumo, nRecno)
	nVlPDDS := JCalcVlTD(aVlPDDS,.T.,.T.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlPDDS

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTBMOT()
Efetua o cálculo do campo Tabelado - Moeda Oficial - Valor Tab dos Valores Pendentes
do Resumo do Caso.

@author Cristina Cintra
@since 02/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTBMOT(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlPDTBMOT := {}
Local nVlPDTBMOT := 0 

	NVE->(dbGoTo(nRecno))
	
	aVlPDTBMOT := JQRYVPDTD("NV4","TAB", oResumo, nRecno)
	nVlPDTBMOT := JCalcVlTD(aVlPDTBMOT,.T.,.T.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlPDTBMOT

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTBMOF()
Efetua o cálculo do campo Tabelado - Moeda Oficial - Valor Fatu dos Valores Pendentes
do Resumo do Caso.

@author Cristina Cintra
@since 02/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTBMOF(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlPDTBMOF := {}
Local nVlPDTBMOF := 0 

	NVE->(dbGoTo(nRecno))
	
	aVlPDTBMOF := JQRYVPDTD("NV4","FAT", oResumo, nRecno)
	nVlPDTBMOF := JCalcVlTD(aVlPDTBMOF,.T.,.T.)
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlPDTBMOF

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTBMCT()
Efetua o cálculo do campo Tabelado - Tab Caso - Valor Tab dos Valores Pendentes 
do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTBMCT(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlPDTBMCT := {}
Local nVlPDTBMCT := 0
Local cMoeTab    := ""

	NVE->(dbGoTo(nRecno))

	cMoeTab := JurGetDados('NRE',1,xFilial("NRE")+NVE->NVE_CTABS,'NRE_MOEDA')

	If !Empty(cMoeTab)		
		aVlPDTBMCT := JQRYVPDTD("NV4","TAB", oResumo, nRecno)
		nVlPDTBMCT := JCalcVlTD(aVlPDTBMCT,.T.,.T.,cMoeTab)
	EndIf
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlPDTBMCT

//-------------------------------------------------------------------
/*/{Protheus.doc} JVLPDTBMCF()
Efetua o cálculo do campo Tabelado - Tab Caso - Valor Fatu dos Valores Pendentes 
do Resumo do Caso.

@author Cristina Cintra
@since 02/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JVLPDTBMCF(oResumo, nRecno)
Local aArea      := GetArea()
Local aAreaNVE   := GetArea("NVE")
Local aVlPDTBMCF := {}
Local nVlPDTBMCF := 0
Local cMoeTab    := ""

	NVE->(dbGoTo(nRecno)) 
	
	cMoeTab := JurGetDados('NRE',1,xFilial("NRE")+NVE->NVE_CTABS,'NRE_MOEDA')

	If !Empty(cMoeTab)	
		aVlPDTBMCF := JQRYVPDTD("NV4","FAT", oResumo, nRecno)
		nVlPDTBMCF := JCalcVlTD(aVlPDTBMCF,.T.,.T.,cMoeTab)
	EndIf
	
	RestArea(aAreaNVE)
	RestArea(aArea)

Return nVlPDTBMCF
