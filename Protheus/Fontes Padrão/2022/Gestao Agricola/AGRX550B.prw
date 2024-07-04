#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX550.CH"

#DEFINE _CRLF CHR(13)+CHR(10)

Static __cAliGr
Static __oArqTmp
Static __cMarca       := GetMark()
Static __nColEdit



/*/{Protheus.doc} AGRX550BVB
//Blocos do Pre-Agendamento
@author carlos.augusto
@since 14/03/2018
@version undefined
@type function
/*/
Function AGRX550BVB()
	Local oDlg		        := Nil
	Local aCoors	       	:= FWGetDialogSize( oMainWnd )
	Local oModel			:= FwModelActive()
	Local lRet				:= .T.
	Local oMldN9E 			:= oModel:GetModel('AGRA550_N9E')
	
	Local aHeader	 := {}
	Local aCpFiltro  := {}
	Local nOperation := oModel:GetOperation()
	Local lGraos	 := Posicione("SB5",1,fwxFilial("SB5")+M->NJJ_CODPRO,"B5_TPCOMMO") != '2'
	
	Private _lInstEmb := .F. //Indica que os blocos sao da instrucao de embarque
	
	If lGraos
		//"Atencao"##"Opção disponível somente para produto algodão."
		Help( ,, STR0010,,STR0041, 1, 0,) 
		Return( .F. )
	EndIf
	
	If Empty(oMldN9E:GetValue( "N9E_CODINE" ))
		//A Instrução de Embarque não foi selecionada. Favor selecionar uma Instrução de Embarque em Itens do Pré-Romaneio.
		Help('' ,1,".AGRX55000001.", , ,1,0)
		Return .F.
	EndIf
	
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
	lRet := BuscaBlocos()

	If lRet
		DEFINE MSDIALOG oDlg FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4];
		TITLE STR0001 OF oMainWnd PIXEL //"Vínculo de Blocos no Pré-Agendamento"
		
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
			oBrwBlc:acolumns[__nColEdit]:SetReadVar('QTFRPRE')
			oBrwBlc:acolumns[__nColEdit]:bValid := {|| IIF(ValidRes((__cAliGr)->QTFRPRE, (__cAliGr)->QTFRAUT),oBrwBlc:Refresh(),.F.)}
		EndIf
		oBrwBlc:SetPreEditCell( { || .T. } )
		oBrwBlc:Activate()
		oBrwBlc:Enable()
		oBrwBlc:Refresh(.T.)
	
		ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,{|| ExecGrav(oDlg)},{|| ExecCancel(oDlg) })
	Else
		//Não foi encontrado nenhum bloco vinculado na Autorização de Carregamento informada. 
		//Por favor, verifique se foi informado blocos na opção 'Vincular Blocos' na Autorização de Carregamento.
		Help('' ,1,".AGRX55000002.", , ,1,0)
	EndIf
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
	AAdd(aStruct, {"SAFRA"   , "C", TamSX3("N8Q_SAFRA") [1], TamSX3("N8Q_SAFRA") [2]})
	AAdd(aStruct, {"BLOCO"   , "C", TamSX3("N8Q_BLOCO") [1], TamSX3("N8Q_BLOCO") [2]})
	AAdd(aStruct, {"CLAVIS " , "C", TamSX3("N8P_CLAVIS")[1], TamSX3("N8P_CLAVIS")[2]})
	AAdd(aStruct, {"QTFRPRE" , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"QTFRAUT" , "N", TamSX3("N83_QUANT") [1], TamSX3("N83_QUANT") [2]})
	AAdd(aStruct, {"PSBRPRE" , "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLIPRE" , "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	AAdd(aStruct, {"PSBRSEL" , "N", TamSX3("N83_PSBRUT")[1], TamSX3("N83_PSBRUT")[2]})
	AAdd(aStruct, {"PSLISEL" , "N", TamSX3("N83_PSLIQU")[1], TamSX3("N83_PSLIQU")[2]})
	
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
	Local oMldN9E	:= oModel:GetModel('AGRA550_N9E')
	Local oMldN8Q	:= oModel:GetModel('AGRA550_N8Q')
	Local cAliasN83
	Local nX
	Local lRet 		:= .F.
	Local lBlcAuto  := .F. //Informa que tem blocos na Autorizacao

	cQuery := "   SELECT N8P_FILORG, N8P_SAFRA, N8P_BLOCO, N8P_QTDAUT, N8P_CLAVIS, N8P_PSLIQU, N8P_PSBRUT "
	cQuery += "     FROM " + RetSqlName('N8P') + " N8P "
	cQuery += "    WHERE N8P_FILIAL = '" + xFilial("N8P") + "'"
	cQuery += "      AND N8P_FILORG = '" + cFilAnt + "'"
	cQuery += "      AND N8P_CODAUT = '" + oMldN9E:GetValue( "N9E_CODAUT" ) + "'"
	cQuery += "      AND N8P_ITEMAC = '" + oMldN9E:GetValue( "N9E_ITEMAC" ) + "'"  
	cQuery += "      AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	cAliasN83 := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN83, .F., .T.)
	If (cAliasN83)->(!EoF())
		lBlcAuto := .T.
		While (cAliasN83)->(!EoF())
			lRet := .T.
			RecLock(__cAliGr, .T.)
				(__cAliGr)->FILORG 	  :=  (cAliasN83)->N8P_FILORG
				(__cAliGr)->SAFRA     :=  (cAliasN83)->N8P_SAFRA
				(__cAliGr)->BLOCO     :=  (cAliasN83)->N8P_BLOCO
				(__cAliGr)->CLAVIS    :=  (cAliasN83)->N8P_CLAVIS
				(__cAliGr)->QTFRAUT   :=  (cAliasN83)->N8P_QTDAUT
				(__cAliGr)->PSBRSEL   :=  (cAliasN83)->N8P_PSBRUT
				(__cAliGr)->PSLISEL   :=  (cAliasN83)->N8P_PSLIQU
				(__cAliGr)->PSBRPRE   :=  0
				(__cAliGr)->PSLIPRE   :=  0

				For nX := 1 to oMldN8Q:Length()
					oMldN8Q:GoLine(nX)
					If .Not. oMldN8Q:IsDeleted()
						//Autorizacao em operacao de ALTERA. Atualiza quantidade
						If oMldN8Q:GetValue("N8Q_SEQUEN")== oMldN9E:GetValue("N9E_SEQUEN") .And. ;
						  oMldN8Q:GetValue("N8Q_FILORG") == (cAliasN83)->N8P_FILORG .And. ;
						  oMldN8Q:GetValue("N8Q_SAFRA")  == (cAliasN83)->N8P_SAFRA .And. ;
						  oMldN8Q:GetValue("N8Q_BLOCO")  == (cAliasN83)->N8P_BLOCO
							(__cAliGr)->QTFRPRE := oMldN8Q:GetValue("N8Q_QTDPRE")
							If oMldN8Q:GetValue("N8Q_QTDPRE") == (__cAliGr)->QTFRAUT
								(__cAliGr)->SELEC := __cMarca
								(__cAliGr)->PSBRPRE   :=  oMldN8Q:GetValue("N8Q_PSBRUT")
								(__cAliGr)->PSLIPRE   :=  oMldN8Q:GetValue("N8Q_PSLIQU")
							EndIf
							exit
						EndIf
					EndIf
				Next nX

			MsUnlock(__cAliGr)
			(cAliasN83)->(dbSkip())
		End
	EndIf
	
	If .Not. lBlcAuto
		cQuery := "   SELECT N83_FILORG, N83_SAFRA, N83_CODCTR, N83_PSLIQU, N83_BLOCO, N83_TIPO, N83_QUANT, N83_PSBRUT "
		cQuery += "     FROM " + RetSqlName('N83') + " N83 "
		cQuery += "    WHERE N83_FILIAL = '" + xFilial("N83") + "'"
		cQuery += "      AND N83_FILORG = '" + cFilAnt + "'"
		cQuery += "      AND N83_CODINE = '" + oMldN9E:GetValue( "N9E_CODINE" ) + "'"
		cQuery += "      AND N83_ITEM = '" 	 + oMldN9E:GetValue( "N9E_ITEM" ) + "'"  
		cQuery += "      AND D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		cAliasN83 := GetNextAlias()
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasN83, .F., .T.)
		If (cAliasN83)->(!EoF())
			While (cAliasN83)->(!EoF())
				lRet := .T.
				_lInstEmb := .T.
				RecLock(__cAliGr, .T.)
					(__cAliGr)->FILORG 	  :=  (cAliasN83)->N83_FILORG
					(__cAliGr)->SAFRA     :=  (cAliasN83)->N83_SAFRA
					(__cAliGr)->BLOCO     :=  (cAliasN83)->N83_BLOCO
					(__cAliGr)->CLAVIS    :=  (cAliasN83)->N83_TIPO
					(__cAliGr)->QTFRAUT   :=  (cAliasN83)->N83_QUANT
					(__cAliGr)->PSBRSEL   :=  (cAliasN83)->N83_PSBRUT
					(__cAliGr)->PSLISEL   :=  (cAliasN83)->N83_PSLIQU
					(__cAliGr)->PSBRPRE   :=  0
					(__cAliGr)->PSLIPRE   :=  0
					
					For nX := 1 to oMldN8Q:Length()
						oMldN8Q:GoLine(nX)
						If .Not. oMldN8Q:IsDeleted()
							//Autorizacao em operacao de ALTERA. Atualiza quantidade
							If oMldN8Q:GetValue("N8Q_SEQUEN")== oMldN9E:GetValue("N9E_SEQUEN").And. ;
							oMldN8Q:GetValue("N8Q_FILORG") == (cAliasN83)->N83_FILORG .And. ;
							oMldN8Q:GetValue("N8Q_SAFRA") == (cAliasN83)->N83_SAFRA .And. ;
							oMldN8Q:GetValue("N8Q_BLOCO") == (cAliasN83)->N83_BLOCO
								(__cAliGr)->QTFRPRE := oMldN8Q:GetValue("N8Q_QTDPRE")
								(__cAliGr)->PSBRPRE := oMldN8Q:GetValue("N8Q_PSBRUT")
								(__cAliGr)->PSLIPRE := oMldN8Q:GetValue("N8Q_PSLIQU")
								
								(__cAliGr)->SELEC := __cMarca
								exit
							EndIf
						EndIf
					Next nX
				MsUnlock(__cAliGr)
				(cAliasN83)->(dbSkip())
			End
		EndIf
	EndIf
	
	
	
Return lRet


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
	aAdd(aHeader, {STR0002,{||(__cAliGr)->FILORG}  , 'C' ,X3PICTURE("N83_FILORG")	, 1 ,TamSX3("N83_FILORG")[1] ,TamSX3("N83_FILORG")[2] ,.F.})//Filial Origem"
	aAdd(aHeader, {STR0003,{||(__cAliGr)->SAFRA}   , 'C' ,X3PICTURE("N83_SAFRA") 	, 1 ,TamSX3("N83_SAFRA") [1] ,TamSX3("N83_SAFRA") [2] ,.F.})//Safra
	aAdd(aHeader, {STR0004,{||(__cAliGr)->BLOCO}   , 'C' ,X3PICTURE("N83_BLOCO")	, 1 ,TamSX3("N83_BLOCO") [1] ,TamSX3("N83_BLOCO") [2] ,.F.})//Bloco
	aAdd(aHeader, {STR0005,{||(__cAliGr)->CLAVIS}  , 'C' ,X3PICTURE("N8P_CLAVIS")	, 1 ,TamSX3("N8P_CLAVIS")[1] ,TamSX3("N8P_CLAVIS")[2] ,.F.})//Class. Vis.
	aAdd(aHeader, {STR0006,{||(__cAliGr)->QTFRPRE} , 'N' ,X3PICTURE("N8P_QTDAUT")	, 1 ,TamSX3("N83_QUANT") [1] ,TamSX3("N83_QUANT") [2] ,.T.})//Qtd Autorizada"
	aAdd(aHeader, {IIF(_lInstEmb,STR0014,STR0007) ,{||(__cAliGr)->QTFRAUT} , 'N' ,X3PICTURE("N83_QUANT")	, 1 ,TamSX3("N83_QUANT") [1] ,TamSX3("N83_QUANT") [2] ,.T.})//Qtd Selec IE"
	aAdd(aHeader, {STR0012,{||(__cAliGr)->PSBRPRE} , 'N' ,X3PICTURE("N83_PSBRUT")  , 1 ,TamSX3("N83_PSBRUT")[1] ,TamSX3("N83_PSBRUT")[2] ,.F.})//Peso Bruto Agend
	aAdd(aHeader, {STR0013,{||(__cAliGr)->PSLIPRE} , 'N' ,X3PICTURE("N83_PSLIQU")	, 1 ,TamSX3("N83_PSLIQU")[1] ,TamSX3("N83_PSLIQU")[2] ,.F.})//  Peso Líq Agend
	aAdd(aHeader, {IIF(_lInstEmb,STR0016,STR0008),{||(__cAliGr)->PSBRSEL} , 'N' ,X3PICTURE("N83_PSBRUT")  , 1 ,TamSX3("N83_PSBRUT")[1] ,TamSX3("N83_PSBRUT")[2] ,.F.})//Peso Bruto Selec IE"
	aAdd(aHeader, {IIF(_lInstEmb,STR0015,STR0009),{||(__cAliGr)->PSLISEL} , 'N' ,X3PICTURE("N83_PSLIQU")	, 1 ,TamSX3("N83_PSLIQU")[1] ,TamSX3("N83_PSLIQU")[2] ,.F.})//Peso Líq Selec IE"
		
		
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
	AAdd(aCpFiltro, {"FILORG"	,STR0002,"C",TamSX3("N83_FILORG")[1],TamSX3("N83_FILORG")[2],X3PICTURE("N83_FILORG")}) 
	AAdd(aCpFiltro, {"SAFRA" 	,STR0003,"C",TamSX3("N83_SAFRA")[1] ,TamSX3("N83_SAFRA")[2] ,X3PICTURE("N83_SAFRA")}) 
	AAdd(aCpFiltro, {"BLOCO" 	,STR0004,"C",TamSX3("N83_BLOCO")[1] ,TamSX3("N83_BLOCO")[2] ,X3PICTURE("N83_BLOCO")}) 
	AAdd(aCpFiltro, {"CLAVIS"  	,STR0005,"C",TamSX3("N8P_CLAVIS")[1],TamSX3("N8P_CLAVIS")[2],X3PICTURE("N8P_CLAVIS")})
	AAdd(aCpFiltro, {"QTFRPRE"  ,STR0006,"N",TamSX3("N83_QUANT")[1] ,TamSX3("N83_QUANT")[2] ,X3PICTURE("N8P_QTDAUT")}) 
	AAdd(aCpFiltro, {"QTFRAUT"  ,IIF(_lInstEmb,STR0014,STR0007),"N",TamSX3("N83_QUANT")[1] ,TamSX3("N83_QUANT")[2] ,X3PICTURE("N83_QUANT")})
	AAdd(aCpFiltro, {"PSBRPRE"	,STR0012,"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],X3PICTURE("N83_PSBRUT")}) 
	AAdd(aCpFiltro, {"PSLIPRE"	,STR0013,"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],X3PICTURE("N83_PSLIQU")}) 
	AAdd(aCpFiltro, {"PSBRSEL"	,IIF(_lInstEmb,STR0016,STR0008),"N",TamSX3("N83_PSBRUT")[1],TamSX3("N83_PSBRUT")[2],X3PICTURE("N83_PSBRUT")}) 
	AAdd(aCpFiltro, {"PSLISEL"	,IIF(_lInstEmb,STR0015,STR0009),"N",TamSX3("N83_PSLIQU")[1],TamSX3("N83_PSLIQU")[2],X3PICTURE("N83_PSLIQU")}) 

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
			(__cAliGr)->QTFRPRE := 0
			(__cAliGr)->PSBRPRE := 0
			(__cAliGr)->PSLIPRE := 0
			MsUnlock(__cAliGr)
		Else
			RecLock(__cAliGr, .F.)
			(__cAliGr)->SELEC := __cMarca
			(__cAliGr)->QTFRPRE := (__cAliGr)->QTFRAUT
			(__cAliGr)->PSBRPRE := (__cAliGr)->PSBRSEL
			(__cAliGr)->PSLIPRE := (__cAliGr)->PSLISEL 
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
			(__cAliGr)->QTFRPRE := 0
			(__cAliGr)->PSBRPRE := 0
			(__cAliGr)->PSLIPRE := 0
			MsUnlock(__cAliGr)
		Else
			RecLock(__cAliGr, .F.)
			(__cAliGr)->SELEC := __cMarca
			(__cAliGr)->QTFRPRE := (__cAliGr)->QTFRAUT
			(__cAliGr)->PSBRPRE := (__cAliGr)->PSBRSEL
			(__cAliGr)->PSLIPRE := (__cAliGr)->PSLISEL 
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
Static Function ValidRes(nAutorizar, nSelecIE)
	Local lRet	:= .T.
	If nAutorizar > nSelecIE
		//"Quantidade de fardos Pré-Agendados maior do que o Autorizado." 
		//"Atenção"###"Quantidade de fardos a Autorizar maior do que o selecionado na Instrução de Embarque."
		Help( , , STR0010, , IIF(_lInstEmb,STR0017,STR0011) , 1, 0 ) 
		lRet := .F.
	EndIf
	//Atualiza Peso
	If lRet
		(__cAliGr)->PSBRPRE := ((__cAliGr)->PSBRSEL  / (__cAliGr)->QTFRAUT) * nAutorizar
		(__cAliGr)->PSLIPRE := ((__cAliGr)->PSLISEL  / (__cAliGr)->QTFRAUT) * nAutorizar
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
	Local oMldNJJ 	:= oModel:GetModel('AGRA550_NJJ')
	Local oMldN8Q 	:= oModel:GetModel('AGRA550_N8Q')
	Local oMldN9E 	:= oModel:GetModel('AGRA550_N9E')
	Local nX
	Local lAdiciona := .T.
	Local nPesoSomFr := 0
	
	dbSelectArea(__cAliGr)
	(__cAliGr)->( dbGoTop() )
	While !(__cAliGr)->( Eof() )
		lAdiciona := .T.
		
		For nX := 1 to oMldN8Q:Length()
			oMldN8Q:GoLine(nX)
			If .Not. oMldN8Q:IsDeleted()

				//Autorizacao em operacao de ALTERA. Atualiza quantidade
				If oMldN8Q:GetValue("N8Q_SEQUEN")== oMldN9E:GetValue("N9E_SEQUEN") .And. ;
				   oMldN8Q:GetValue("N8Q_FILORG")== (__cAliGr)->FILORG .And. ;
				   oMldN8Q:GetValue("N8Q_SAFRA") == (__cAliGr)->SAFRA  .And. ;
				   oMldN8Q:GetValue("N8Q_BLOCO") == (__cAliGr)->BLOCO
					oMldN8Q:SetValue("N8Q_QTDPRE", (__cAliGr)->QTFRPRE)
					oMldN8Q:LoadValue("N8Q_PSBRUT",(__cAliGr)->PSBRPRE)
					oMldN8Q:LoadValue("N8Q_PSLIQU",(__cAliGr)->PSLIPRE)
					lAdiciona := .F.
				EndIf
			EndIf
		Next nX
		
		If lAdiciona
			oMldN8Q:AddLine()
			oMldN8Q:GoLine( nX ) //Comeco a contar a partir da ultima linha do modelo, o modelo existe em background
			oMldN8Q:LoadValue("N8Q_FILIAL",(__cAliGr)->FILORG)
			oMldN8Q:LoadValue("N8Q_CODROM", oMldNJJ:GetValue("NJJ_CODROM"))
			oMldN8Q:LoadValue("N8Q_SEQUEN", oMldN9E:GetValue("N9E_SEQUEN"))
			oMldN8Q:LoadValue("N8Q_SAFRA", (__cAliGr)->SAFRA)
			oMldN8Q:LoadValue("N8Q_BLOCO", (__cAliGr)->BLOCO)
			oMldN8Q:LoadValue("N8Q_QTDPRE",(__cAliGr)->QTFRPRE)
			
			oMldN8Q:LoadValue("N8Q_PSBRUT",(__cAliGr)->PSBRPRE)
			oMldN8Q:LoadValue("N8Q_PSLIQU",(__cAliGr)->PSLIPRE)
			oMldN8Q:LoadValue("N8Q_CLAVIS",(__cAliGr)->CLAVIS)
			oMldN8Q:LoadValue("N8Q_FILORG",(__cAliGr)->FILORG)
				
		EndIf
		
		If (__cAliGr)->QTFRPRE > 0
			nPesoSomFr += ((__cAliGr)->QTFRPRE / (__cAliGr)->QTFRAUT) * (__cAliGr)->PSLIPRE
		EndIf

		(__cAliGr)->( dbSkip() )
	EndDo

	(__cAliGr)->( dbGoTop() )
		
	oMldN9E:SetValue("N9E_QTDAGD", nPesoSomFr)
	
	If lRet 
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
	

