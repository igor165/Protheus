#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX540.CH"

#DEFINE _CRLF CHR(13)+CHR(10)
 
Static __cMarca       := GetMark()
Static __nColEdit


/*/{Protheus.doc} AGRX540BVB
//Abre o browse para mostrar os blocos que podem ser autorizados
@author carlos.augusto
@since 02/03/2018
@version 12.1.20
@type function
/*/
Function AGRX540BVB()
	Local oDlg		        := Nil
	Local aCoors	       	:= FWGetDialogSize( oMainWnd )
	Local nOpcA 	       	:= 0
	Local oModel			:= FwModelActive()
	Local aHeader	 := {}
	Local aCpFiltro  := {}
	Local nOperation := oModel:GetOperation()
	
	Private __cAliGr
	Private __oArqTmp
	
	//- Coordenadas da area total da Dialog
	oSize:= FWDefSize():New(.T.)
	oSize:AddObject("DLG",100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	//Cria a estrutura da temporaria
	CriaTT()
	
	//Insere dados na temporaria
	BuscaBlocos()

	DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4];
	TITLE STR0021 OF oMainWnd PIXEL //"Vínculo de Blocos na Autorização de Carregamento"
	
	//Cria as colunas do browse
	aHeader := CriaColunas()
	
	//Define as colunas na opcao filtrar
	aCpFiltro := CriaFiltro()

	oBrwBlc :=  FWBrowse():New()
	oBrwBlc:SetOwner(oDlg)
	oBrwBlc:SetDataTable(.T.)
	oBrwBlc:SetAlias(__cAliGr)
	oBrwBlc:SetProfileID('2')
	oBrwBlc:Acolumns:= {}
	oBrwBlc:AddMarkColumns({|| If((__cAliGr)->SELEC == __cMarca,'LBOK','LBNO')}, {  |oBrwBlc| AGRX540BUN(__cAliGr)},{ |oBrwBlc| AGRX540BTD(__cAliGr, @oBrwBlc) })
	oBrwBlc:setcolumns( aHeader )
	oBrwBlc:DisableReport()
	oBrwBlc:DisableConfig()
	oBrwBlc:SetFieldFilter( aCpFiltro ) // Seta os campos para o botão filtro
	oBrwBlc:SetUseFilter() // Ativa filtro
	
	If nOperation <> MODEL_OPERATION_VIEW .AND. nOperation <> MODEL_OPERATION_DELETE
		oBrwBlc:SetEditCell( .T. ,) // Permite edição na grid
		oBrwBlc:acolumns[__nColEdit]:SetEdit(.T.)
		oBrwBlc:acolumns[__nColEdit]:SetReadVar('QTFRAUT')
		oBrwBlc:acolumns[__nColEdit]:bValid := {|| IIF(ValidRes((__cAliGr)->QTFRAUT, (__cAliGr)->QTFRSEL, (__cAliGr)->FRDMAR),oBrwBlc:Refresh(),.F.)}
	EndIf
	oBrwBlc:SetPreEditCell( { || .T. } )
	oBrwBlc:Activate()
	oBrwBlc:Enable()
	oBrwBlc:Refresh(.T.)

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| nOpcA:= 1, ExecGrav(oDlg)},{|| nOpcA:= 2, ExecCancel(oDlg) })
	
Return 	


/*/{Protheus.doc} CriaTT
//Cria a tabela temporaria
@author carlos.augusto
@since 02/03/2018
@version 12.1.20
@type function
/*/
Static Function CriaTT()
	Local aStruct	:= {}
	
	aAdd(aStruct, { "SELEC"  , "C", 2, 0, , }) //Seleção
	AAdd(aStruct, {"FILORG"	 , "C", TamSX3("N83_FILORG")[1], TamSX3("N83_FILORG")[2]})
	AAdd(aStruct, {"SAFRA"   , "C", TamSX3("N83_SAFRA") [1], TamSX3("N83_SAFRA") [2]})
	AAdd(aStruct, {"BLOCO"   , "C", TamSX3("N83_BLOCO") [1], TamSX3("N83_BLOCO") [2]})
	AAdd(aStruct, {"CLAVIS " , "C", TamSX3("N8P_CLAVIS")[1], TamSX3("N8P_CLAVIS")[2]})
	AAdd(aStruct, {"QTFRAUT" , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"QTFRSEL" , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRAUT" , "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIAUT" , "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	AAdd(aStruct, {"PSBRSEL" , "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLISEL" , "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	AAdd(aStruct, {"FRDMAR" , "C", TamSX3("N83_FRDMAR")[1], TamSX3("N83_FRDMAR")[2]})
	
	__cAliGr := GetNextAlias()	
	__oArqTmp := AGRCRTPTB(__cAliGr, {aStruct, {{"","FILORG,SAFRA,BLOCO,CLAVIS"},{"","FILORG,BLOCO"}}})
	
Return


/*/{Protheus.doc} BuscaBlocos
//Busca os blocos da ie posicionada
@author carlos.augusto
@since 02/03/2018
@version undefined

@type function
/*/
Static Function BuscaBlocos()
	Local cQuery
	Local oModel	:= FwModelActive()
	Local oMldN8O	:= oModel:GetModel('AGRA540_N8O')
	Local oMldN8P	:= oModel:GetModel('AGRA540_N8P')	
	Local cAliasN83
	Local nX
	
	cQuery := "   SELECT N83_FILORG, N83_SAFRA, N83_CODCTR, N83_PSLIQU, N83_BLOCO, N83_TIPO, N83_QUANT, N83_PSBRUT, "
	cQuery += "    N83_FRDMAR FROM " + RetSqlName('N83') + " N83 "
	cQuery += "    WHERE N83_FILIAL = '" + xFilial("N83") + "'"
	cQuery += "      AND N83_FILORG = '" + cFilAnt + "'"
	cQuery += "      AND N83_CODINE = '" + oMldN8O:GetValue( "N8O_CODINE" ) + "'"
	cQuery += "      AND N83_ITEM = '" 	 + oMldN8O:GetValue( "N8O_IDENTR" ) + "'"  
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	cAliasN83 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN83, .F., .T.)
	If (cAliasN83)->(!EoF())
		While (cAliasN83)->(!EoF())
			RecLock(__cAliGr, .T.)
				(__cAliGr)->FILORG 	  :=  (cAliasN83)->N83_FILORG
				(__cAliGr)->SAFRA     :=  (cAliasN83)->N83_SAFRA
				(__cAliGr)->BLOCO     :=  (cAliasN83)->N83_BLOCO
				(__cAliGr)->CLAVIS    :=  (cAliasN83)->N83_TIPO
				(__cAliGr)->QTFRSEL   :=  (cAliasN83)->N83_QUANT
				(__cAliGr)->PSBRSEL   :=  (cAliasN83)->N83_PSBRUT
				(__cAliGr)->PSLISEL   :=  (cAliasN83)->N83_PSLIQU
				(__cAliGr)->PSBRAUT   :=  0
				(__cAliGr)->PSLIAUT   :=  0
				(__cAliGr)->FRDMAR   :=  (cAliasN83)->N83_FRDMAR
				For nX := 1 to oMldN8P:Length()
					oMldN8P:GoLine(nX)
					If .Not. oMldN8P:IsDeleted()
						//Autorizacao em operacao de ALTERA. Atualiza quantidade
						If oMldN8P:GetValue("N8P_ITEMAC")== oMldN8O:GetValue("N8O_ITEM").And. ;
						oMldN8P:GetValue("N8P_FILORG") == (cAliasN83)->N83_FILORG .And. ;
						oMldN8P:GetValue("N8P_SAFRA") == (cAliasN83)->N83_SAFRA .And. ;
						oMldN8P:GetValue("N8P_BLOCO") == (cAliasN83)->N83_BLOCO
							(__cAliGr)->QTFRAUT := oMldN8P:GetValue("N8P_QTDAUT")
							(__cAliGr)->PSBRAUT := oMldN8P:GetValue("N8P_PSBRUT")
							(__cAliGr)->PSLIAUT := oMldN8P:GetValue("N8P_PSLIQU")
							
							If oMldN8P:GetValue("N8P_QTDAUT") == (__cAliGr)->QTFRSEL
								(__cAliGr)->SELEC := __cMarca
							EndIf
							exit
						EndIf
					EndIf
				Next nX
			MsUnlock(__cAliGr)
			(cAliasN83)->(dbSkip())
		End
	EndIf
Return


/*/{Protheus.doc} CriaColunas
//Cria as colunas do browse
@author carlos.augusto
@since 02/03/2018
@version undefined
@type function
/*/
Static Function CriaColunas()
	Local aHeader := {}
	// Campos que serão mostrados na grid
	aAdd(aHeader, {STR0031,{||(__cAliGr)->FILORG}  , 'C' ,X3PICTURE("N83_FILORG")	, 1 ,TamSX3("N83_FILORG")[1] ,TamSX3("N83_FILORG")[2] ,.F.})//Filial Origem"
	aAdd(aHeader, {STR0009,{||(__cAliGr)->SAFRA}   , 'C' ,X3PICTURE("N83_SAFRA") 	, 1 ,TamSX3("N83_SAFRA") [1] ,TamSX3("N83_SAFRA") [2] ,.F.})//Safra
	aAdd(aHeader, {STR0010,{||(__cAliGr)->BLOCO}   , 'C' ,X3PICTURE("N83_BLOCO")	, 1 ,TamSX3("N83_BLOCO") [1] ,TamSX3("N83_BLOCO") [2] ,.F.})//Bloco
	aAdd(aHeader, {STR0032,{||(__cAliGr)->CLAVIS}  , 'C' ,X3PICTURE("N8P_CLAVIS")	, 1 ,TamSX3("N8P_CLAVIS")[1] ,TamSX3("N8P_CLAVIS")[2] ,.F.})//Class. Vis.
	aAdd(aHeader, {STR0033,{||(__cAliGr)->QTFRAUT} , 'N' ,X3PICTURE("N8P_QTDAUT")	, 1 ,TamSX3("N83_QUANT") [1] ,TamSX3("N83_QUANT") [2] ,.T.})//Qtd Autorizada"
	aAdd(aHeader, {STR0034,{||(__cAliGr)->QTFRSEL} , 'N' ,X3PICTURE("N83_QUANT")	, 1 ,TamSX3("N83_QUANT") [1] ,TamSX3("N83_QUANT") [2] ,.T.})//Qtd Selec IE"
	aAdd(aHeader, {STR0038,{||(__cAliGr)->PSBRAUT} , 'N' ,X3PICTURE("N83_PSBRUT")  , 1 ,TamSX3("N83_PSBRUT")[1] ,TamSX3("N83_PSBRUT")[2] ,.F.})//Peso Bruto Aut"
	aAdd(aHeader, {STR0039,{||(__cAliGr)->PSLIAUT} , 'N' ,X3PICTURE("N83_PSLIQU")	, 1 ,TamSX3("N83_PSLIQU")[1] ,TamSX3("N83_PSLIQU")[2] ,.F.})//Peso Líq Aut"
	aAdd(aHeader, {STR0035,{||(__cAliGr)->PSBRSEL} , 'N' ,X3PICTURE("N83_PSBRUT")  , 1 ,TamSX3("N83_PSBRUT")[1] ,TamSX3("N83_PSBRUT")[2] ,.F.})//Peso Bruto Selec IE"
	aAdd(aHeader, {STR0036,{||(__cAliGr)->PSLISEL} , 'N' ,X3PICTURE("N83_PSLIQU")	, 1 ,TamSX3("N83_PSLIQU")[1] ,TamSX3("N83_PSLIQU")[2] ,.F.})//Peso Líq Selec IE"
	aAdd(aHeader, {"Fard. Marc.",{||(__cAliGr)->FRDMAR}  , 'C' ,X3PICTURE("N83_FRDMAR")	, 1 ,TamSX3("N83_FRDMAR")[1] ,TamSX3("N83_FRDMAR")[2] ,.F.})//Fard. Marc.
	
	
	
	//Coluna que sera editavel
	__nColEdit := 6

Return aHeader


/*/{Protheus.doc} CriaFiltro
//Cria colunas da opcao criar filtro
@author carlos.augusto
@since 02/03/2018
@version undefined

@type function
/*/
Static Function CriaFiltro()
	Local aCpFiltro := {}
	
	// Campos para o botão de filtro
	AAdd(aCpFiltro, {"FILORG"	,STR0031,"C",TamSX3("N83_FILORG")[1],TamSX3("N83_FILORG")[2],X3PICTURE("N83_FILORG")}) 
	AAdd(aCpFiltro, {"SAFRA" 	,STR0009,"C",TamSX3("N83_SAFRA")[1] ,TamSX3("N83_SAFRA")[2] ,X3PICTURE("N83_SAFRA")}) 
	AAdd(aCpFiltro, {"BLOCO" 	,STR0010,"C",TamSX3("N83_BLOCO")[1] ,TamSX3("N83_BLOCO")[2] ,X3PICTURE("N83_BLOCO")}) 
	AAdd(aCpFiltro, {"CLAVIS"  	,STR0032,"C",TamSX3("N8P_CLAVIS")[1],TamSX3("N8P_CLAVIS")[2],X3PICTURE("N8P_CLAVIS")})
	AAdd(aCpFiltro, {"QTFRAUT"  ,STR0033,"N",TamSX3("N83_QUANT")[1] ,TamSX3("N83_QUANT")[2] ,X3PICTURE("N8P_QTDAUT")}) 
	AAdd(aCpFiltro, {"QTFRSEL"  ,STR0034,"N",TamSX3("N83_QUANT")[1] ,TamSX3("N83_QUANT")[2] ,X3PICTURE("N83_QUANT")})
	AAdd(aCpFiltro, {"PSBRAUT"	,STR0038,"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],X3PICTURE("N83_PSBRUT")}) 
	AAdd(aCpFiltro, {"PSLIAUT"	,STR0039,"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],X3PICTURE("N83_PSLIQU")}) 
	AAdd(aCpFiltro, {"PSBRSEL"	,STR0035,"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],X3PICTURE("N83_PSBRUT")}) 
	AAdd(aCpFiltro, {"PSLISEL"	,STR0036,"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],X3PICTURE("N83_PSLIQU")})
	AAdd(aCpFiltro, {"FRDMAR"  	,"Fard. Marc.","C",TamSX3("N83_FRDMAR")[1],TamSX3("N83_FRDMAR")[2],X3PICTURE("N83_FRDMAR")}) 

Return aCpFiltro

/*/{Protheus.doc} AGRX540BUN
//Marca um e insere total ou zero
@author carlos.augusto
@since 02/03/2018
@version undefined
@param __cAliGr, characters, descricao
@type function
/*/
Static Function AGRX540BUN(__cAliGr)

	If !(__cAliGr)->( Eof() )		
		If (__cAliGr)->SELEC = __cMarca
			RecLock(__cAliGr, .F.)
			(__cAliGr)->SELEC := ' '
			(__cAliGr)->QTFRAUT := 0
			(__cAliGr)->PSBRAUT :=  0
			(__cAliGr)->PSLIAUT :=  0
			MsUnlock(__cAliGr)
		Else
			RecLock(__cAliGr, .F.)
			(__cAliGr)->SELEC := __cMarca
			(__cAliGr)->QTFRAUT := (__cAliGr)->QTFRSEL
			(__cAliGr)->PSBRAUT := (__cAliGr)->PSBRSEL
			(__cAliGr)->PSLIAUT := (__cAliGr)->PSLISEL 
			MsUnlock(__cAliGr)
		EndIf
	EndIf	
Return .T.



/*/{Protheus.doc} AGRX540BTD
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 02/03/2018
@version undefined
@param __cAliGr, characters, descricao
@type function
/*/
Static Function AGRX540BTD(__cAliGr, oBrwBlc)
	Local aSaveLines := FWSaveRows()

	dbSelectArea(__cAliGr)
	(__cAliGr)->( dbGoTop() )
	While !(__cAliGr)->( Eof() )

		If (__cAliGr)->SELEC = __cMarca
			RecLock(__cAliGr, .F.)
			(__cAliGr)->SELEC := ' '
			(__cAliGr)->QTFRAUT := 0
			(__cAliGr)->PSBRAUT :=  0
			(__cAliGr)->PSLIAUT :=  0
			MsUnlock(__cAliGr)
		Else
			RecLock(__cAliGr, .F.)
			(__cAliGr)->SELEC := __cMarca
			(__cAliGr)->QTFRAUT := (__cAliGr)->QTFRSEL
			(__cAliGr)->PSBRAUT := (__cAliGr)->PSBRSEL
			(__cAliGr)->PSLIAUT := (__cAliGr)->PSLISEL 
			MsUnlock(__cAliGr)
		EndIf

		(__cAliGr)->( dbSkip() )
	EndDo

	(__cAliGr)->( dbGoTop() )
	oBrwBlc:Refresh()
	FwRestRows(aSaveLines)
Return


/*/{Protheus.doc} ValidRes
//Valida valor digitado
@author carlos.augusto
@since 02/03/2018
@version undefined
@param nAutorizar, numeric, descricao
@param nSelecIE, numeric, descricao
@type function
/*/
Static Function ValidRes(nAutorizar, nSelecIE, cFrdMar)
	Local lRet	:= .T.
	If nAutorizar > nSelecIE
		Help( , , STR0018, , STR0037, 1, 0 ) //"Atenção"###"Quantidade de fardos a Autorizar maior do que o selecionado na Instrução de Embarque."
		lRet := .F.
	EndIf
	If cFrdMar == "1"
		Help( , , STR0018, , "O bloco possui fardos pré-selecionados na Instrução de Embarque. Utilize a ação relacionada de seleção de fardos.", 1, 0 ) //"Atenção"###
		lRet := .F.	
	EndIf
	//Atualiza Peso
	If lRet
		(__cAliGr)->PSBRAUT := ((__cAliGr)->PSBRSEL  / (__cAliGr)->QTFRSEL) * nAutorizar
		(__cAliGr)->PSLIAUT := ((__cAliGr)->PSLISEL  / (__cAliGr)->QTFRSEL) * nAutorizar
	EndIf
Return lRet
	

/*/{Protheus.doc} ExecGrav
//Grava os dados da TT no modelo
@author carlos.augusto
@since 02/03/2018
@version undefined
@param oDlg, object, descricao
@type function
/*/
Static Function ExecGrav(oDlg)
	Local lRet 		:= .T.
	Local oModel	:= FwModelActive()
	Local oMldN8N 	:= oModel:GetModel('AGRA540_N8N')
	Local oMldN8O 	:= oModel:GetModel('AGRA540_N8O')
	Local oMldN8P 	:= oModel:GetModel('AGRA540_N8P')
	Local nX
	Local lAdiciona := .T.
	Local nPesoSomFr := 0
	
	dbSelectArea(__cAliGr)
	(__cAliGr)->( dbGoTop() )
	While !(__cAliGr)->( Eof() )
		lAdiciona := .T.
		
		For nX := 1 to oMldN8P:Length()
			oMldN8P:GoLine(nX)
			If .Not. oMldN8P:IsDeleted()

				//Autorizacao em operacao de ALTERA. Atualiza quantidade
				If oMldN8P:GetValue("N8P_ITEMAC")== oMldN8O:GetValue("N8O_ITEM").And. ;
				   oMldN8P:GetValue("N8P_FILORG")== (__cAliGr)->FILORG .And. ;
				   oMldN8P:GetValue("N8P_SAFRA") == (__cAliGr)->SAFRA  .And. ;
				   oMldN8P:GetValue("N8P_BLOCO") == (__cAliGr)->BLOCO
					oMldN8P:SetValue("N8P_QTDAUT", (__cAliGr)->QTFRAUT)
					oMldN8P:LoadValue("N8P_PSBRUT",(__cAliGr)->PSBRAUT)
					oMldN8P:LoadValue("N8P_PSLIQU",(__cAliGr)->PSLIAUT)

					oMldN8P:LoadValue("N8P_DATATU" ,  dDatabase)
					oMldN8P:LoadValue("N8P_HORATU" ,  Time()   )		
					
					lAdiciona := .F.								
				EndIf
			EndIf
		Next nX
		
		If lAdiciona
			oMldN8P:AddLine()
			oMldN8P:GoLine( nX ) //Comeco a contar a partir da ultima linha do modelo, o modelo existe em background
			oMldN8P:LoadValue("N8P_FILIAL",(__cAliGr)->FILORG)
			oMldN8P:LoadValue("N8P_CODAUT",oMldN8N:GetValue("N8N_CODIGO"))
			oMldN8P:LoadValue("N8P_ITEMAC",oMldN8O:GetValue("N8O_ITEM"))
			oMldN8P:LoadValue("N8P_SAFRA", (__cAliGr)->SAFRA)
			oMldN8P:LoadValue("N8P_BLOCO", (__cAliGr)->BLOCO)
			oMldN8P:LoadValue("N8P_QTDAUT",(__cAliGr)->QTFRAUT)
			
			oMldN8P:LoadValue("N8P_DATATU" ,  dDatabase)
			oMldN8P:LoadValue("N8P_HORATU" ,  Time()   )
			
			oMldN8P:LoadValue("N8P_PSBRUT",(__cAliGr)->PSBRAUT)
			oMldN8P:LoadValue("N8P_PSLIQU",(__cAliGr)->PSLIAUT)
			oMldN8P:LoadValue("N8P_CLAVIS",(__cAliGr)->CLAVIS)
			oMldN8P:LoadValue("N8P_FILORG",(__cAliGr)->FILORG)
				
		EndIf
		
		If (__cAliGr)->QTFRAUT > 0
			nPesoSomFr += ((__cAliGr)->PSLISEL  / (__cAliGr)->QTFRSEL) * (__cAliGr)->QTFRAUT
		EndIf

		(__cAliGr)->( dbSkip() )
	EndDo

	(__cAliGr)->( dbGoTop() )
		
	oMldN8O:SetValue("N8O_QTDBLC", nPesoSomFr)
	oMldN8O:SetValue("N8O_QTD", nPesoSomFr + oMldN8O:GetValue("N8O_QTDFAR"))
	
	If lRet .and. valType(oDlg) == 'O' //oDlg ativo, tratamento quando REST oDlg não existe
		oDlg:End()
	EndIf

Return 
	
	/*/{Protheus.doc} ExecCancel
//Cancelar - sem efetivação
@author carlos.augusto
@since 23/02/2018
@version undefined
@param oDlg, object, descricao
@type function
/*/
Static function ExecCancel(oDlg)
	oDlg:End()
Return
	

