#INCLUDE "Protheus.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA261.CH"

Static aStructRA4   := Nil
Static aStructSQ9	:= Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPEA261   ºAutor  ³Christiane Vieira   º Data ³  09/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta dos Treinamentos dos Funcionários                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE - GPEA260()                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA261()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef  ºAutor  ³Christiane Vieira   º Data ³  09/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Definicao do modelo de dados                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ModelDef()
Local oStructRA4 := Nil
Local oStructSQ9 := Nil
Local oModel     := Nil
Local oStructSRA := Nil

//---------------------------------------------------------------
//Monta a estrutura do formulario com base no dicionario de dados
//---------------------------------------------------------------
oStructSRA := FWFormStruct(1,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"})

//---------------------------------------------------------------
//Monta a estrutura do formulario com base no dicionario de dados
//---------------------------------------------------------------
oStructRA4 := FWFormStruct(1,"RA4")
oStructSQ9 := FWFormStruct(1,"SQ9")


//----------------------------
//Monta o modelo do formulario
//----------------------------
FWFormModelStruct():New()   
oModel:= MpFormModel():New("GPEA261", /*Pre-Validacao*/,  /*Pos-Validacao*/,  /*Commit*/, /*Cancel*/)
oModel:AddFields("GPEA261_MSRA", /*cOwner*/, oStructSRA , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

oModel:GetModel("GPEA261_MSRA"):SetOnlyView( .T. )
oModel:GetModel("GPEA261_MSRA"):SetOnlyQuery( .T. )

oModel:AddGrid("GPEA261_MRA4", "GPEA261_MSRA" /*cOwner*/, oStructRA4 , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,{|oGrid|CargaGrid("RA4",oGrid)}/*bLoad*/)
If aStructRA4 == Nil
	aStructRA4 := oStructRA4:GetFields()
EndIf

oModel:GetModel("GPEA261_MRA4"):SetOnlyView( .T. )
oModel:GetModel("GPEA261_MRA4"):SetOnlyQuery( .T. )

//Adiciona o Grid
oModel:AddGrid("GPEA261_MSQ9", "GPEA261_MSRA"/*cOwner*/, oStructSQ9 , /*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,{|oGrid|CargaGrid("SQ9",oGrid)}/*bLoad*/)
If aStructSQ9 == Nil
	aStructSQ9 := oStructSQ9:GetFields()
EndIf

oModel:GetModel( "GPEA261_MRA4" ):SetDescription( OemToAnsi( STR0001 ) ) //"Cursos Internos"
oModel:GetModel( "GPEA261_MSQ9" ):SetDescription( OemToAnsi( STR0002 ) ) //"Cursos Externos"

//oModel:GetModel("GPEA020_SRB"):SetUniqueLine({"SRB_CODPRO"})
oModel:SetRelation("GPEA261_MRA4",{{"RA4_FILIAL",'xFilial("RA4")'},{"RA4_MAT","RA_MAT"}},RA4->(IndexKey()))
oModel:SetRelation("GPEA261_MSQ9",{{"Q9_FILIAL",'xFilial("SQ9")'},{"Q9_MAT","RA_MAT"}},SQ9->(IndexKey()))

oModel:SetVldActivate( { |oModel| GPA261VldIni() } )

Return(oModel)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Christiane Vieira   º Data ³  09/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Definicao da tela                                 		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ViewDef()
Local nX 		:= 0
Local oModel     := FwLoadModel("GPEA261")
Local oStructSRA
Local oStructRA4
Local oStructSQ9
Local oView           


//--------------------------------------------------------------
//Montagem da interface via dicionario de dados
//--------------------------------------------------------------
oStructSRA := FWFormStruct(2,"SRA",{|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"})

oStructRA4 := FWFormStruct(2,"RA4")
For nX := 1 to Len(aStructRA4)
	If AllTrim(aStructRA4[nX,3]) $ "RA4_FILIAL*RA4_MAT*RA4_NOME*RA4_SINONI*RA4_DESCSI*RA4_ENTIDA*RA4_DESCEN*RA4_NOTA*RA4_DURACA*RA4_UNDURA*RA4_PRESEN*RA4_VALOR*RA4_HORAS*RA4_EFICAC*RA4_EFICSN*RA4_TIPO*RA4_NIVEL*RA4_STATUS*RA4_DTALT*RA4_CODCOM*RA4_CONTEU"
		oStructRA4:RemoveField(aStructRA4[nX,3])
	EndIf
Next nX

oStructSQ9 := FWFormStruct(2,"SQ9")                    
For nX := 1 to Len(aStructSQ9)
	If AllTrim(aStructSQ9[nX,3]) $ "Q9_FILIAL*Q9_MAT*Q9_PONTOS*Q9_CUSTOMS*Q9_ENTIDAD*Q9_ESCOLAR*Q9_NIVEL*Q9_STATUS*Q9_DURACAO*Q9_CODCONT*Q9_CONTEUD*Q9_DTALTER*Q9_VERSAO*Q9_CODCOM*Q9_COMENT*Q9_CODQUA*Q9_QUADESC*Q9_CODCERT*Q9_DATVENC"
		oStructSQ9:RemoveField(aStructSQ9[nX,3])
	EndIf
Next nX

//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
oView := FWFormView():New()

oView:SetModel(oModel)
//oView:AddField( "GPEA261_VSRA" , oStructSRA,"GPEA261_MSRA" )
oView:AddGrid(  "GPEA261_VRA4" , oStructRA4,"GPEA261_MRA4" )
oView:AddGrid(  "GPEA261_VSQ9" , oStructSQ9,"GPEA261_MSQ9" )

//oView:createHorizontalBox("FORMFIELD",10)
oView:createHorizontalBox("GRID"     ,50)
oView:createHorizontalBox("GRID1"    ,50)

//oView:SetOwnerView( "GPEA261_VSRA","FORMFIELD")
oView:SetOwnerView( "GPEA261_VRA4","GRID")
oView:SetOwnerView( "GPEA261_VSQ9","GRID1")                                  

// Liga a identificacao do componente
oView:EnableTitleView("GPEA261_VRA4", OemToAnsi( STR0001 )) //"Cursos Internos"
oView:EnableTitleView("GPEA261_VSQ9", OemToAnsi( STR0002 )) //"Cursos Externos

Return(oView)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CargaGrid  ºAutor  ³Christiane Vieira  º Data ³  09/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Efetua a carga dos treinamentos filtrados conforme RA1,SQT  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CargaGrid(cAlias,oGrid)
Local aRet 			:= {}
Local aRet2			:= {}
Local nX			:= 0
Local nPosAux		:= 0

aRet2 := FormLoadGrid(oGrid)

If cAlias == "RA4"
	nPosAux := oGrid:GetIdField("RA4_CURSO")
Else
	nPosAux := oGrid:GetIdField("Q9_CURSO")
EndIf

For nX:= 1 to Len(aRet2)
	(cAlias)->(MsGoto(aRet2[nX,1]))
	If cAlias == "RA4"
		RA1->(DbSeek(xFilial("RA1")+aRet2[nX,2,nPosAux]))
		If RA1->RA1_IMPRIM == "1"
			aAdd(aRet,aClone(aRet2[nX]))
		EndIf
	Else
		SQT->(DbSeek(xFilial("SQT")+aRet2[nX,2,nPosAux]))
		If SQT->QT_IMPRIME == "1"
			aAdd(aRet,aClone(aRet2[nX]))
		EndIf	
	EndIf
Next

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GPA261VldIniºAutor ³Christiane Vieira  º Data ³  09/10/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se existem dados a serem exibidos                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPA261VldIni()
Local lRet 		:= .T.
Local nCnt		:= 0
Local cQuery 	:= ""


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum dado no arquivo - RA4               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT COUNT(*) TOTAL "
	cQuery += " FROM "+	RetSqlName("RA4") + " RA4"
	cQuery += " INNER JOIN " + RetSqlName("SRA") + " ON "
	cQuery += " RA4_FILIAL = RA_FILIAL AND "
	cQuery += " RA4_MAT = RA_MAT "
	cQuery += " INNER JOIN " + RetSqlName("RA1") + " ON "
	cQuery += " RA4_CURSO = RA1_CURSO "
	cQuery += " WHERE RA4_MAT = '" + SRA->RA_MAT + "' AND "
	cQuery += " RA1_IMPRIM = '1' AND "
	cQuery += " RA4.D_E_L_E_T_ = ' ' "		
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRA4', .F., .T.)
	dbSelectArea("QRA4")
	nCnt := QRA4->TOTAL
	dbCloseArea()
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe algum dado no arquivo - SQ9               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT COUNT(*) TOTAL1 "
	cQuery += " FROM "+	RetSqlName("SQ9") + " SQ9"
	cQuery += " INNER JOIN " + RetSqlName("SRA") + " ON "
	cQuery += " Q9_FILIAL = RA_FILIAL AND "
	cQuery += " Q9_MAT = RA_MAT "
	cQuery += " INNER JOIN " + RetSqlName("SQT") + " ON "
	cQuery += " Q9_CURSO = QT_CURSO "
	cQuery += " WHERE Q9_MAT = '" + SRA->RA_MAT + "' AND "
	cQuery += " QT_IMPRIME = '1' AND "
	cQuery += " SQ9.D_E_L_E_T_ = ' ' "		
			
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QSQ9', .F., .T.)
	dbSelectArea("QSQ9")
	nCnt += QSQ9->TOTAL1
	dbCloseArea()	
	
	If nCnt == 0
		lRet := .F.
		Help(" ",1,"GP260VAZIO")
	Endif
Return lRet