#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "TopConn.ch"

Static cTitulo := "Histórico Integração API"
User Function VAFINI01()
	local aArea     := GetArea()
	Local cFunBkp   := ""
	Local aCombo 	:= {"Sim","Não"}
	Local aParamBox	:= {}
	
	Local cLoad     := ProcName(1) // Nome do perfil se caso for carregar
	Local lCanSave  := .T. // Salvar os dados informados nos parâmetros por perfil
	Local lUserSave := .T. // Configuração por usuário
	Local cQry 		:= ""
	Local nI 		
	Local aFiltro   
	Local cFiltro	:= ""

	Private oBtn	:= Array(3)
	Private oTfSay  := TFont():New('ARIAL',,22,,.T.)
	Private oTfTot  := TFont():New('ARIAL',,24,,.T.)
	Private oScTotal 	:= nil
	Private oSnTotal 	:= nil
	Private oScTitulo 	:= nil
	Private oSnTitulo 	:= nil
	Private aParametros	:= {}
	
	Private aGSE2, aGSE5, aGZE2
	Private cTabSE2, cTabZE2, cTabSE5
	Private cALoad 	:= GetNextAlias()
	Private cASE2 	:= GetNextAlias()
	Private cAZE2 	:= GetNextAlias()
	Private cASE5 	:= GetNextAlias()
    Private oSE2
    Private oZE2
    Private oSE5

	aAdd(aParamBox,{1 ,"EMISSAO DE" , dDataBase, "@D","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"EMISSAO ATE" , dDataBase, "@D","","","",50,.T.}) // Tipo caractere
	aAdd(aParamBox,{1 ,"STATUS [Separado por vírgula]",Space(100),"","","","",100,.F.}) // Tipo caractere

	if ParamBox(aParamBox,"Parâmetros...",@aParametros, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  cLoad, lCanSave, lUserSave )
		if Len(aFiltro := StrToKarr(AllTrim(aParametros[3]),',')) > 0
			For nI := 1 to Len(aFiltro)
				cFiltro += "'"+aFiltro[nI]+"'" + iif(nI<Len(aFiltro),',','')
			next 
		endif 

		cQry := " select *" + CRLF
		cQry += " from "+RetSqlName("SE2")+"  " + CRLF
		cQry += " WHERE D_E_L_E_T_ = '' " + CRLF
		cQry += " AND E2_EMISSAO BETWEEN '"+dToS(aParametros[1])+"' AND '"+dToS(aParametros[2])+"' " + CRLF
		
		if cFiltro != "" //.and. aParametros[4] == 1
			cQry += " AND  E2_XSTAPI IN ("+cFiltro+") " + CRLF
		else 
			cQry += " AND  E2_XSTAPI <> '  ' " + CRLF
		endif

		MpSysOpenQry(cQry, cALoad)
		
		if (cALoad)->(EOF())
			MsgInfo("Não há dados com os parâmetros informados!")
		else
			//TABELA SE2
			aCpos := {}
			aTitulos := {}

			GetFields("SE2",@aCpos,@aTitulos)
			aGSE2 := gerCpBrow(aCpos,aTitulos)

			If oSE2 <> Nil
            	oSE2:Delete()
            	oSE2  :=  Nil
       	 	Endif
			oSE2 := FWTemporaryTable():New(cASE2)
			oSE2:SetFields(aCpos)
			oSE2:AddIndex("1", {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"})
			oSE2:Create()
			cTabSE2  :=  oSE2:GetRealName()

			//TABELA SE5
			aCpos := {}
			aTitulos := {}
			GetFields("SE5",@aCpos,@aTitulos)
			aGSE5 := gerCpBrow(aCpos,aTitulos)
			If oSE5 <> Nil
            	oSE5:Delete()
            	oSE5  :=  Nil
       	 	Endif
			oSE5 := FWTemporaryTable():New(cASE5)
			oSE5:SetFields(aCpos)
			oSE5:AddIndex("1", {"E5_FILIAL","E5_PREFIXO","E5_NUMERO","E5_PARCELA","E5_TIPO","E5_CLIFOR","E5_LOJA","E5_SEQ"})
			oSE5:Create()
			cTabSE5  :=  oSE2:GetRealName()
			
			//TABELA ZE2
			aCpos := {}
			aTitulos := {}
			GetFields("ZE2",@aCpos,@aTitulos)
			aGZE2 := gerCpBrow(aCpos,aTitulos)
			If oZE2 <> Nil
            	oZE2:Delete()
            	oZE2  :=  Nil
       	 	Endif
			oZE2 := FWTemporaryTable():New(cAZE2)
			oZE2:SetFields(aCpos)
			oZE2:AddIndex("1", {"ZE2_FILIAL","ZE2_PREFIX","ZE2_NUM","ZE2_FORNEC","ZE2_LOJA","ZE2_PARCEL","ZE2_TIPO","ZE2_ITEM"})
			oZE2:Create()
			cTabSE5  :=  oSE2:GetRealName()

			cFunBkp := FunName()
			
			SetFunName("VAFINI01")
				FWExecView('Alterar', 'VAFINI01', MODEL_OPERATION_UPDATE,,{||.T.})
			SetFunName(cFunBkp)

		endif

	endif

	(cALoad)->(DbCloseArea())
	(cASE2)->(DbCloseArea())
	(cAZE2)->(DbCloseArea())
	(cASE5)->(DbCloseArea())

    RestArea(aArea)
Return

//Funcao para montar array com colunas para browse
Static Function gerCpBrow(aCampos,aTitulos)
    Local nI
    Local aBrow := {}
 
    For nI := 1 to Len(aCampos)
        aAdd(aBrow,{aTitulos[nI], aCampos[nI,1] ,aCampos[nI,2] ,aCampos[nI,3] ,aCampos[nI,4]})
    Next
Return aBrow

//Buscar campos da SX3 para cada tabela temporaria - SE2, SE5 e ZE2
Static Function GetFields(cTab,aCpos,aTitulos)
	Local aArea 	:= GetArea()
	Local cAlias 	:= GetNextAlias()
	Local cQry 		:= ""

	cQry := "SELECT * FROM "+RetSqlName("SX3")+" WHERE X3_ARQUIVO = '"+cTab+"' AND X3_CONTEXT <> 'V' AND D_E_L_E_T_ = '' ORDER BY 2"
	MpSysOpenQry(cQry,cAlias)

	if cTab == "SE2"
		aAdd(aCpos,{"LEG","C",50,00})
		aAdd(aTitulos,"")
		aAdd(aCpos,{"SEL","L",1,00})
		aAdd(aTitulos,"")
	elseif  cTab == "SE5"
		aAdd(aCpos,{"OK","L",1,00})
		aAdd(aTitulos,"")
	endif

	While !(cAlias)->(EOF())
		aAdd(aTitulos,AllTrim((cAlias)->X3_TITULO))

		aAdd(aCpos,{AllTrim((cAlias)->X3_CAMPO),;
					AllTrim((cAlias)->X3_TIPO),;
					(cAlias)->X3_TAMANHO,;
					(cAlias)->X3_DECIMAL})

		(cAlias)->(DbSkip())
	End
	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)
Return 

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Chamar API' 	   ACTION 'U_FI01CAP()'      OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Alterar'	 	   ACTION 'VIEWDEF.VAFINI01' OPERATION 4 ACCESS 0
Return aRotina

Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStField 		:= FWFormModelStruct():New()
	Local oStSE2 		:= FWFormModelStruct():New()
	Local oStZE2 		:= FWFormModelStruct():New()
	Local oStSE5 		:= FWFormModelStruct():New()
 	Local aCpSE5		:= {}
	Local aZE2Rel		:= {}
	Local aSE5Rel		:= {}
	Local bLSE2  		:=  {|oModel, lCopy| loadSE2(oModel, lCopy,"SE2")}
	Local bLZE2  		:=  {|oModel, lCopy| loadGrd(oModel, lCopy,"ZE2")}
    Local bLSE5  		:=  {|oModel, lCopy| loadGrd(oModel, lCopy,"SE5")}
	Local nI
	
	//VERIFICAR ISSO
	For nI := 1 to Len(aGSE2)
		aadd(aGSE2[nI],.F.)
    Next
	For nI := 1 to Len(aGSE5)
		aadd(aGSE5[nI],.F.)
    Next
	For nI := 1 to Len(aGZE2)
		aadd(aGZE2[nI],.F.)
    Next

    oStField:addTable("", {"C_STRING1"}, "Visualização", {|| ""})
    oStField:addField("String 01", "texto", "C_STRING1", "C", 15)

/* 	oStSE5:AddField('OK' , ' ', 'OK' , 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))
	oStSE2:AddField('LEG', ' ', 'LEG', 'C', 50, 0,  , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "BR_BRANCO"))
	oStSE2:AddField('SEL', ' ', 'SEL', 'L', 1, 0, {|| VldSel()} , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F."))
 */
	MntStrut(@oStSE2,cASE2,aGSE2)  
    MntStrut(@oStZE2,cAZE2,aGZE2)  
    MntStrut(@oStSE5,cASE5,aGSE5)

    oStSE2:AddTable(cASE2,, "Contas a Pagar"				,{|| oStSE2:GetRealName()})
    oStZE2:AddTable(cAZE2,, "Titulo Financeiro Integr. API" ,{|| oStZE2:GetRealName()})
    oStSE5:AddTable(cASE5,, "Movimentação Bancaria"			,{|| oStSE5:GetRealName()})  

	aCpSE5 := oStSE5:aFields
	For nI := 1 to Len(aCpSE5)
		if oStSE5:aFields[nI][03] != 'OK'
			oStSE5:aFields[nI][08] := {|| .F.}
			oStSE5:aFields[nI][10] := .F.
		endif
	next nI
    
    //Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('FINI01')
	
	oModel:AddFields('FAKEM',/*cOwner*/   ,oStField, /* <bPre > */, /* <bPost > */, {|| LoadFake()}/* <bLoad > */)
	oModel:AddGrid('SE2DETAIL',"FAKEM"    ,oStSE2,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,bLSE2/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('ZE2DETAIL','SE2DETAIL',oStZE2,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,bLZE2/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	oModel:AddGrid('SE5DETAIL','SE2DETAIL',oStSE5,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,bLSE5/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	
	oModel:GetModel('SE2DETAIL'):SetOptional(.T.)
	oModel:GetModel('ZE2DETAIL'):SetOptional(.T.)
	oModel:GetModel('SE5DETAIL'):SetOptional(.T.)

/* 	aadd(aZE2Rel, {'ZE2_FILIAL' ,'E2_FILIAL' })
	aadd(aZE2Rel, {'ZE2_PREFIX' ,'E2_PREFIXO'})
	aadd(aZE2Rel, {'ZE2_NUM'    ,'E2_NUM'    })
	aadd(aZE2Rel, {'ZE2_PARCEL' ,'E2_PARCELA'})
	aadd(aZE2Rel, {'ZE2_TIPO'   ,'E2_TIPO'   })
	aadd(aZE2Rel, {'ZE2_FORNEC' ,'E2_FORNECE'})
	aadd(aZE2Rel, {'ZE2_LOJA'   ,'E2_LOJA'   })

	aadd(aSE5Rel, {'E5_FILIAL'  ,'E2_FILIAL' })
	aadd(aSE5Rel, {'E5_PREFIXO' ,'E2_PREFIXO'})
	aadd(aSE5Rel, {'E5_NUMERO'  ,'E2_NUM'    })
	aadd(aSE5Rel, {'E5_PARCELA' ,'E2_PARCELA'})
	aadd(aSE5Rel, {'E5_TIPO'    ,'E2_TIPO'   })
	aadd(aSE5Rel, {'E5_CLIFOR'  ,'E2_FORNECE'})
	aadd(aSE5Rel, {'E5_LOJA'    ,'E2_LOJA'   })

    oModel:SetRelation('ZE2DETAIL', aZE2Rel, ZE2->(IndexKey(1)))
    
    oModel:SetRelation('SE5DETAIL', aSE5Rel, SE5->(IndexKey(7))) */
	
	oModel:SetPrimaryKey( {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO","E2_FORNECE","E2_LOJA"} )

	oModel:SetDescription(cTitulo)
	
	oModel:GetModel('SE2DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('ZE2DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('SE5DETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('SE2DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('ZE2DETAIL'):SetNoDeleteLine(.T.)
	oModel:GetModel('SE5DETAIL'):SetNoDeleteLine(.T.)

	oModel:GetModel('FAKEM'):SetDescription('Hide')
	oModel:GetModel('SE2DETAIL'):SetDescription('Titulos a Pagar')
	oModel:GetModel('ZE2DETAIL'):SetDescription('Log Integração')
	oModel:GetModel('SE5DETAIL'):SetDescription('Baixa de Titulos')

Return oModel
Static Function ViewDef()
	Local oView		    := Nil
	Local oModel	    := FWLoadModel("VAFINI01")
	Local oStField 		:= FWFormViewStruct():New()
	Local oStSE2 	    := FWFormViewStruct():New()
	Local oStZE2 	    := FWFormViewStruct():New()
	Local oStSE5 	    := FWFormViewStruct():New()
	Local nX
    Local aDadSE2  := {}
    Local aDadZE2  := {}
    Local aDadSE5  := {}
	
    oStField:addField("C_STRING1", "01" , "String 01", "texto", , "C" )

	For nX := 1 to Len(aGSE2)
        IF aGSE2[nX,3] = "C"
            cPict := "@!"
        ElseIF aGSE2[nX,3] = "N"
            cPict := "@E 9,999,999.99"
        Else
            cPict := ""
        EnDIF
        aADD(aDadSE2,{aGSE2[nX,2],StrZero(nX,2),aGSE2[nX,1],aGSE2[nX,3],cPict,.F.})
    Next
 
    For nX := 1 to Len(aGZE2)
        IF aGZE2[nX,3] = "C"
            cPict := "@!"
        ElseIF aGZE2[nX,3] = "N"
            cPict := "@E 9,999,999.99"
        Else
            cPict := ""
        EnDIF
        aADD(aDadZE2,{aGZE2[nX,2],StrZero(nX,2),aGZE2[nX,1],aGZE2[nX,3],cPict,.F.})
    Next
 
    For nX := 1 to Len(aGSE5)
         IF aGSE5[nX,3] = "C"
             cPict := "@!"
         ElseIF aGSE5[nX,3] = "N"
             cPict := "@E 9,999,999.99"
         Else
             cPict := ""
         EnDIF
        aADD(aDadSE5,{aGSE5[nX,2],StrZero(nX,2),aGSE5[nX,1],aGSE5[nX,3],cPict,.F.})
    Next

	//oStSE5:AddField( 'OK' ,'01','OK' ,'OK' ,, 'Check')
	
	//oStSE2:AddField( 'LEG','01','','',, 'C','@BMP',,'',.F.)
	//oStSE2:AddField( 'SEL','02','','',, 'Check')

	MntView(@oStSE2,aDadSE2)
    MntView(@oStZE2,aDadZE2)
    MntView(@oStSE5,aDadSE5)

	oStSE2:SetProperty("LEG"		, MVC_VIEW_ORDEM, "01")
	oStSE2:SetProperty("SEL"		, MVC_VIEW_ORDEM, "02")
	oStSE2:SetProperty("E2_FILIAL"	, MVC_VIEW_ORDEM, "03")
	oStSE2:SetProperty("E2_PREFIXO"	, MVC_VIEW_ORDEM, "04")
	oStSE2:SetProperty("E2_NUM"		, MVC_VIEW_ORDEM, "05")
	oStSE2:SetProperty("E2_PARCELA"	, MVC_VIEW_ORDEM, "06")
	oStSE2:SetProperty("E2_TIPO"	, MVC_VIEW_ORDEM, "07")
	oStSE2:SetProperty("E2_PORTADO"	, MVC_VIEW_ORDEM, "08")
	oStSE2:SetProperty("E2_FORNECE"	, MVC_VIEW_ORDEM, "09")
	oStSE2:SetProperty("E2_LOJA"	, MVC_VIEW_ORDEM, "10")
	oStSE2:SetProperty("E2_NOMFOR"	, MVC_VIEW_ORDEM, "11")
	oStSE2:SetProperty("E2_NATUREZ"	, MVC_VIEW_ORDEM, "12")
	oStSE2:SetProperty("E2_EMISSAO"	, MVC_VIEW_ORDEM, "13")
	oStSE2:SetProperty("E2_VENCTO"	, MVC_VIEW_ORDEM, "14")
	oStSE2:SetProperty("E2_VENCREA"	, MVC_VIEW_ORDEM, "15")
	oStSE2:SetProperty("E2_VALOR"	, MVC_VIEW_ORDEM, "16")
	oStSE2:SetProperty("E2_SALDO"	, MVC_VIEW_ORDEM, "17")
	oStSE2:SetProperty("E2_ISS"		, MVC_VIEW_ORDEM, "18")
	oStSE2:SetProperty("E2_IRRF"	, MVC_VIEW_ORDEM, "19")
	oStSE2:SetProperty("E2_NUMBCO"	, MVC_VIEW_ORDEM, "20")
	oStSE2:SetProperty("E2_INDICE"	, MVC_VIEW_ORDEM, "21")
	oStSE2:SetProperty("E2_BAIXA"	, MVC_VIEW_ORDEM, "22")
	oStSE2:SetProperty("E2_BCOPAG"	, MVC_VIEW_ORDEM, "23")
	oStSE2:SetProperty("E2_EMIS1"	, MVC_VIEW_ORDEM, "24")
	oStSE2:SetProperty("E2_HIST"	, MVC_VIEW_ORDEM, "25")

	oStSE5:SetProperty("OK"			,MVC_VIEW_ORDEM, "01")
	oStSE5:SetProperty("E5_FILIAL"	,MVC_VIEW_ORDEM, "02")
	oStSE5:SetProperty("E5_DATA"	,MVC_VIEW_ORDEM, "03")
	oStSE5:SetProperty("E5_TIPO"	,MVC_VIEW_ORDEM, "04")
	oStSE5:SetProperty("E5_MOEDA"	,MVC_VIEW_ORDEM, "05")
	oStSE5:SetProperty("E5_VALOR"	,MVC_VIEW_ORDEM, "06")
	oStSE5:SetProperty("E5_NATUREZ"	,MVC_VIEW_ORDEM, "07")
	oStSE5:SetProperty("E5_BANCO"	,MVC_VIEW_ORDEM, "08")
	oStSE5:SetProperty("E5_AGENCIA"	,MVC_VIEW_ORDEM, "09")
	oStSE5:SetProperty("E5_CONTA"	,MVC_VIEW_ORDEM, "10")
	oStSE5:SetProperty("E5_NUMCHEQ"	,MVC_VIEW_ORDEM, "11")
	oStSE5:SetProperty("E5_DOCUMEN"	,MVC_VIEW_ORDEM, "12")
	oStSE5:SetProperty("E5_VENCTO"	,MVC_VIEW_ORDEM, "13")
	oStSE5:SetProperty("E5_RECPAG"	,MVC_VIEW_ORDEM, "14")
	oStSE5:SetProperty("E5_BENEF"	,MVC_VIEW_ORDEM, "15")
	oStSE5:SetProperty("E5_HISTOR"	,MVC_VIEW_ORDEM, "16")
	oStSE5:SetProperty("E5_TIPODOC"	,MVC_VIEW_ORDEM, "17")
	oStSE5:SetProperty("E5_VLMOED2"	,MVC_VIEW_ORDEM, "18")
	oStSE5:SetProperty("E5_LA"		,MVC_VIEW_ORDEM, "19")
	oStSE5:SetProperty("E5_SITUACA"	,MVC_VIEW_ORDEM, "20")
	oStSE5:SetProperty("E5_LOTE"	,MVC_VIEW_ORDEM, "21")
	oStSE5:SetProperty("E5_PREFIXO"	,MVC_VIEW_ORDEM, "22")
	oStSE5:SetProperty("E5_NUMERO"	,MVC_VIEW_ORDEM, "23")
	oStSE5:SetProperty("E5_PARCELA"	,MVC_VIEW_ORDEM, "24")
	oStSE5:SetProperty("E5_CLIFOR"	,MVC_VIEW_ORDEM, "25")
	oStSE5:SetProperty("E5_LOJA"	,MVC_VIEW_ORDEM, "26")
	oStSE5:SetProperty("E5_DTDIGIT"	,MVC_VIEW_ORDEM, "27")
	oStSE5:SetProperty("E5_TIPOLAN"	,MVC_VIEW_ORDEM, "28")
	oStSE5:SetProperty("E5_DEBITO"	,MVC_VIEW_ORDEM, "29")
	oStSE5:SetProperty("E5_CREDITO"	,MVC_VIEW_ORDEM, "30")
	oStSE5:SetProperty("E5_MOTBX"	,MVC_VIEW_ORDEM, "31")
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField( 'CAB'       , oStField , 'FAKEM' )
	oView:AddGrid( 'VIEW_SE2'   , oStSE2 , 'SE2DETAIL' )
	oView:AddGrid( 'VIEW_ZE2'   , oStZE2 , 'ZE2DETAIL' )
	oView:AddGrid( 'VIEW_SE5'   , oStSE5 , 'SE5DETAIL' )
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BOX_HIDE'  , 0 )
	oView:CreateHorizontalBox('BOX_SE2'  , 50 )
	oView:CreateHorizontalBox('BOX_GRID' , 50 )
	
    oView:CreateVerticalBox( 'BOX_ZE2', 50, 'BOX_GRID' )
    oView:CreateVerticalBox( 'BOX_BTN', 5 , 'BOX_GRID' )
    oView:CreateVerticalBox( 'BOX_DIR', 45, 'BOX_GRID' )

	oView:CreateHorizontalBox('BOX_SE5' , 90, 'BOX_DIR' )
	oView:CreateHorizontalBox('BOX_TOT' , 10, 'BOX_DIR' )  

	oView:AddOtherObject("TOTAL" ,{|o1Panel,o1OtherObject| CalcTot(o1Panel,o1OtherObject)})
	oView:AddOtherObject("BUTTON",{|o1Panel,o1OtherObject| CriaBtn(o1Panel,o1OtherObject)})
	
	//Amarrando a view com as box
	oView:SetOwnerView('CAB'	    ,'BOX_HIDE' )
	oView:SetOwnerView('BUTTON'		,'BOX_BTN'  )
	oView:SetOwnerView('VIEW_SE2'	,'BOX_SE2'  )
	oView:SetOwnerView('VIEW_ZE2'	,'BOX_ZE2'  )
	oView:SetOwnerView('VIEW_SE5'	,'BOX_SE5'  )
	oView:SetOwnerView('TOTAL'		,'BOX_TOT'  )

	oView:EnableTitleView('BUTTON'  ,'_________________________')
	oView:EnableTitleView('VIEW_SE2','Titulos a Pagar' )
	oView:EnableTitleView('VIEW_ZE2','Log Integração'  )
	oView:EnableTitleView('VIEW_SE5','Baixa de Titulos')

	SetKey( VK_F5 , { || InverteSelecao() } )
Return oView

Static Function LoadFake()
Return {"Fake"}

Static Function LoadSE2(oModel,lCopy,cIdSub)
    Local aArea     := FwGetArea()
    Local oStruct   := oModel:GetStruct()
    Local aData     := {}
    Local nI 
    Local aAux		:= oStruct:GetFields()

	While !(cALoad)->(EOF())
		aAdd(aData,{{(cALoad)->R_E_C_N_O_},{}})
	
		For nI := 1 to Len(aAux)
			if !(aAux[nI][14])
				if aAux[nI][3] == 'LEG'
					if (cALoad)->E2_XSTAPI = 'OK'
						aAdd(aData[Len(aData)][2],"BR_VERDE")
					else
						aAdd(aData[Len(aData)][2],"BR_VERMELHO")
					endif
				elseif aAux[nI][4] == 'C' .OR. aAux[nI][4] == 'N'
					aAdd(aData[Len(aData)][2],(cALoad)->&(aAux[nI][3]))
				elseif aAux[nI][4] == 'D'
					aAdd(aData[Len(aData)][2],sToD((cALoad)->&(aAux[nI][3])))
				elseif aAux[nI][4] == 'L' .and. aAux[nI][3] == 'SEL'
					aAdd(aData[Len(aData)][2],.F.)
				endif
			else //CAMPO VIRTUAL
				if aAux[nI][4] == 'C'
					aAdd(aData[Len(aData)][2],"")
				elseif aAux[nI][4] == 'D'
					aAdd(aData[Len(aData)][2],cToD("//"))
				elseif aAux[nI][4] == 'N'
					aAdd(aData[Len(aData)][2],0)
				endif
			endif
		Next nI

		(cALoad)->(DbSkip())
	endDo

    FwRestArea(aArea)
Return aData

Static Function CriaBtn(o1Panel,o1OtherObject)
	Local nWidth  := o1Panel:NCLIENTWIDTH / 2
	Local nHeight := o1Panel:NHEIGHT / 2
	
	@(nHeight - 75),nWidth - 10 BTNBMP oBtn[1]  RESOURCE "LBOK"		SIZE 25,25 ACTION InverteSelecao() OF o1Panel
	@(nHeight - 25),nWidth - 10 BTNBMP oBtn[2]  RESOURCE "ENVIAR" 	SIZE 25,25 ACTION Enviar() OF o1Panel
	@(nHeight + 25),nWidth - 10 BTNBMP oBtn[3]  RESOURCE "PESQUISA" SIZE 25,25 ACTION Consultar() OF o1Panel

	oBtn[1]:cToolTip := "Inverter Seleção"
	oBtn[2]:cToolTip := "Enviar"
	oBtn[3]:cToolTip := "Consultar"

Return

Static Function CalcTot(o1Panel,o1OtherObject)
	Local nWidth  := 0
	Local nHeight := 5
	
	oScTotal 	:= TSay():New(nHeight ,nWidth     , {||''},o1Panel,,oTfSay,,,,.T.,CLR_BLACK,CLR_WHITE,200,30)
	oSnTotal := TSay():New(nHeight ,nWidth + 60, {||''},o1Panel,,oTfTot,,,,.T.,CLR_RED,CLR_WHITE,200,30)

	oScTitulo 	:= TSay():New(nHeight ,nWidth + 180    , {||''},o1Panel,,oTfSay,,,,.T.,CLR_BLACK,CLR_WHITE,200,30)
	oSnTitulo := TSay():New(nHeight ,nWidth + 275, {||''},o1Panel,,oTfTot,,,,.T.,CLR_RED,CLR_WHITE,200,30)

Return

Static Function VldSel()
	Local oModel := FwModelActivate()
	Local oMSe2	 := oModel:GetModel("SE2DETAIL")
	Local oView	 := FWViewActive()
	Local nI
	Local lRet 	 := .t.
	Local nSoma  := 0
	Local nTitulos := 0
	Local nTamGrid		:= oMSe2:Length()
	Local aSaveLines 	:= FWSaveRows()

	if oMSe2:GetValue("E2_XSTAPI") == 'OK'
				oModel:SetErrorMessage("","","","","Ação inválida", 'Titulo já foi pago', "É possível selecionar apenas titulos que não foram pagos")

		lRet := .F.
	else
		For nI := 1 to nTamGrid
			oMSe2:GoLine(nI)
			if oMSe2:GetValue("SEL")
				nSoma +=  oMSe2:GetValue("E2_VALOR")
				nTitulos++
			endif
		next nI

		if nSoma == 0
			oScTotal:SetText("")
			oSnTotal:SetText("")

			oScTitulo:SetText("")
			oSnTitulo:SetText("")
		else
			oScTotal:SetText("Total a Pagar: ")
			oSnTotal:SetText(AllTrim(Transform(nSoma,Alltrim(X3Picture("E2_VALOR")))))

			oScTitulo:SetText("Titulos selecionados: ")
			oSnTitulo:SetText(AllTrim(Str(nTitulos)))
		endif
	endif
	FWRestRows(aSaveLines)
	oView:refresh()
Return lRet

Static Function InverteSelecao()
	Local oModel := FwModelActivate()
	Local oMSe2	 := oModel:GetModel("SE2DETAIL")
	Local oView	 := FWViewActive()
	Local nI
	Local aSaveLines 	:= FWSaveRows()
	Local nSoma  		:= 0
	Local nTitulos 		:= 0
	Local nTamGrid		:= oMSe2:Length()
	
	For nI := 1 to nTamGrid
		oMSe2:GoLine(nI)
		//if oMSe2:GetValue("E2_XSTAPI") != 'OK'
			oMSe2:LoadValue("SEL",!oMSe2:GetValue("SEL"))
		//endif
	next nI
	
	For nI := 1 to nTamGrid
		oMSe2:GoLine(nI)
		if oMSe2:GetValue("SEL")
			nSoma +=  oMSe2:GetValue("E2_VALOR")
			nTitulos++
		endif
	next nI

	if nSoma == 0
		oScTotal:SetText("")
		oSnTotal:SetText("")

		oScTitulo:SetText("")
		oSnTitulo:SetText("")
	else
		oScTotal:SetText("Total a Pagar: ")
		oSnTotal:SetText(AllTrim(Transform(nSoma,Alltrim(X3Picture("E2_VALOR")))))

		oScTitulo:SetText("Titulos selecionados: ")
		oSnTitulo:SetText(AllTrim(Str(nTitulos)))
	endif

	FWRestRows(aSaveLines)
	oView:refresh()
Return 
Static Function Enviar()
	Local oModel 	:= FwModelActivate()
	Local oMdlSE5	:= oModel:GetModel("SE5DETAIL")
	Local nI
	Local cChave 	:= ""

	For nI := 1 To oMdlSE5:Length()
		oMdlSE5:Goline(nI)
		if oMdlSE5:GetValue("OK")
			cChave := FwxFilial("SE5") +;
					oMdlSE5:GetValue("E5_PREFIXO") +;
					oMdlSE5:GetValue("E5_PARCELA") +;
					oMdlSE5:GetValue("E5_TIPO") +;
					oMdlSE5:GetValue("E5_CLIFOR") +;
					oMdlSE5:GetValue("E5_LOJA")
		endif 
	Next nI 

Return

Static Function Consultar()
	Local oModel 	:= FwModelActivate()
	Local oMdlSE5	:= oModel:GetModel("SE5DETAIL")
	Local nI
	Local cChave 	:= ""

	For nI := 1 To oMdlSE5:Length()
		oMdlSE5:Goline(nI)
		if oMdlSE5:GetValue("OK")
			cChave := FwxFilial("SE5") +;
					oMdlSE5:GetValue("E5_PREFIXO") +;
					oMdlSE5:GetValue("E5_PARCELA") +;
					oMdlSE5:GetValue("E5_TIPO") +;
					oMdlSE5:GetValue("E5_CLIFOR") +;
					oMdlSE5:GetValue("E5_LOJA")
		endif 
	Next nI 
Return

Static Function criaButtonSel(oPanel,oOtherObject)
    TButton():New( 01, 10, "OK Todos",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
Return
Static Function MntStrut(oObj,cAlias, aCampos)
    Local nI
    Default aCampos := {}
 
    For nI := 1 to Len(aCampos)
        oObj:AddField(;
            aCampos[nI,1],;                                                                                  // [01]  C   Titulo do campo
            aCampos[nI,1],;                                                                                  // [02]  C   ToolTip do campo
            aCampos[nI,2],;                                                                                  // [03]  C   Id do Field
            aCampos[nI,3],;                                                                                  // [04]  C   Tipo do campo
            aCampos[nI,4],;                                                                                  // [05]  N   Tamanho do campo
            aCampos[nI,5],;                                                                                  // [06]  N   Decimal do campo
            Nil,;                                                                                            // [07]  B   Code-block de validação do campo
            Nil,;                                                                                            // [08]  B   Code-block de validação When do campo
            {},;                                                                                             // [09]  A   Lista de valores permitido do campo
            .F.,;                                                                                            // [10]  L   Indica se o campo tem preenchimento obrigatório
            FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,('"+cAlias+"')->"+aCampos[nI,2]+",'')" ),;   // [11]  B   Code-block de inicializacao do campo
            .T.,;                                                                                            // [12]  L   Indica se trata-se de um campo chave
            aCampos[nI,6],;                                                                                  // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            .F.;                                                                                             // [14]  L   Indica se o campo é virtual
        )
 
        IF aCampos[nI,6]
            oObj:SetProperty(aCampos[nI,2], MODEL_FIELD_WHEN, { || .f.})
            oObj:SetProperty(aCampos[nI,2], MODEL_FIELD_NOUPD,.T.)
        EndIF
    Next
Return

Static Function loadGrd(oSub,lCopy,cIdSub)
    //Local cAliasTab     := ""
    Local nI            := 0
    Local nRec          := 1
    Local aRet          := {}
    Local aData         := {}
    Local aAux         := {}
 
    aData  :=  oSub:GetStruct():GetFields()

	For nI  :=  1 to Len(aData)

		if aData[nI][4] == 'C'
			aAdd(aAux,"")
		elseif aData[nI][4] == 'D'
			aAdd(aAux,cToD("//"))
		elseif aData[nI][4] == 'N'
			aAdd(aAux,0)
		elseif aData[nI][4] == 'M'
			aAdd(aAux,"")
		elseif aData[nI][4] == 'L'
			aAdd(aAux,.F.)
		endif

	Next nI
		
	aAdd(aRet,{nRec,aClone(aAux)})
	aAux  :=  {}
	nRec++
             
Return(aRet)

Static Function MntView(oObj,aCampos)
    Local nX
 
    For nX := 1 to Len(aCampos)
        oObj:AddField(;
            aCampos[nX,1],;                  // [01]  C   Nome do Campo
            aCampos[nX,2],;                  // [02]  C   Ordem
            aCampos[nX,3],;                  // [03]  C   Titulo do campo
            aCampos[nX,3],;                  // [04]  C   Descricao do campo
            Nil,;                            // [05]  A   Array com Help
            aCampos[nX,4],;                  // [06]  C   Tipo do campo
            aCampos[nX,5],;                  // [07]  C   Picture
            Nil,;                            // [08]  B   Bloco de PictTre Var
            Nil,;                            // [09]  C   Consulta F3
            aCampos[nX,6],;                  // [10]  L   Indica se o campo é alteravel
            Nil,;                            // [11]  C   Pasta do campo
            Nil,;                            // [12]  C   Agrupamento do campo
            Nil,;                            // [13]  A   Lista de valores permitido do campo (Combo)
            Nil,;                            // [14]  N   Tamanho maximo da maior opção do combo
            Nil,;                            // [15]  C   Inicializador de Browse
            Nil,;                            // [16]  L   Indica se o campo é virtual
            Nil,;                            // [17]  C   Picture Variavel
            Nil;                             // [18]  L   Indica pulo de linha após o campo
        )
    Next
 
Return
