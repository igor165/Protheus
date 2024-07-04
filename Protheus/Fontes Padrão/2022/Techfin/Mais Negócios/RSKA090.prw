#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RSKA090.CH"
#INCLUDE "RSKDefs.ch"

#DEFINE TYPE_MODEL	1
#DEFINE TYPE_VIEW	2

Static oAR4Temp := Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RSKA090    
Conciliação Financeira

@author Squad NT TechFin
@since  28/12/2020
/*/
//-----------------------------------------------------------------------------
Function RSKA090()
	Local aCoors 	:= FWGetDialogSize( oMainWnd )
	Local aFields	:= {}
	Local aColumns	:= {}
	Local oDlg		:= Nil
	Local oBrowse	:= Nil
	Local nColumn	:= 0

	oAR4Temp := RskTmpTable()

	DEFINE MSDIALOG oDlg Title STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL //"Conciliação Financeira"


	aAdd(aFields, {"AR4_FILIAL", STR0002, "C", FwSizeFilial(), "@!"})   		//"Filial"
	aAdd(aFields, {"AR4_IDPROC", STR0003, "C", TamSX3("AR4_IDPROC")[1], "@!"}) 	//"Processamento"
	aAdd(aFields, {"AR4_DTPROC", STR0004, "D", 8, ""})  						//"Data"
	aAdd(aFields, {"AR4_HRPROC", STR0005, "C", 8, "@!"})   						//"Hora"
	aAdd(aFields, {"AR4_TOTMOV", STR0075, "N", 5, "99999"})   					//"Movimentados"
	aAdd(aFields, {"AR4_TOTCRR", STR0076, "N", 5, "99999"})   					//"Correções"

	For nColumn := 1 To Len( aFields )
		AAdd( aColumns, FWBrwColumn():New() )
		aColumns[nColumn]:SetData(&( '{ || ' + aFields[nColumn][1] + ' }' ))
		aColumns[nColumn]:SetTitle( aFields[nColumn][2] )
		aColumns[nColumn]:SetType( aFields[nColumn][3] )
		aColumns[nColumn]:SetSize( aFields[nColumn][4])
		aColumns[nColumn]:SetPicture( aFields[nColumn][5] )
	Next nColumn

	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription(STR0006) //"Conciliação Financeira"
	oBrowse:SetOwner(oDlg)
	oBrowse:SetDataTable()
	oBrowse:SetAlias(oAR4Temp:GetAlias())
	oBrowse:SetColumns(aColumns)
	oBrowse:SetUseFilter()
	oBrowse:SetSeek()
	oBrowse:SetProfileID("RSKA090")
	oBrowse:AddButton(STR0007, { || FWExecView(STR0007,"RSKA090",MODEL_OPERATION_VIEW)  } ,, 2 ) //"Detalhes"
	oBrowse:AddButton(STR0078, { ||FWMsgRun(, {|| RskRepro()}, STR0085, STR0086) },,2) //"Reabrir Periodo" ### "Processando" ### "Processando dados aguarde..."
	oBrowse:Activate()

	ACTIVATE MSDIALOG oDlg CENTERED

	If oAR4Temp <> Nil
		oAR4Temp:Delete()
		FreeObj( oAR4Temp )
	EndIf

	FreeObj(oDlg)
	FreeObj(oBrowse)

	FwFreeArray(aCoors)
	FwFreeArray(aColumns)
	FwFreeArray(aColumns)

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskTmpTable
Criação da tabela temporaria com movimentos da conciliação financeira

@return oTmpTable , objeto, Tabela temporaria da conciliação financeira.

@author Squad NT TechFin
@since  28/12/2020
/*/
//--------------------------------------------------------------------------------------
Static Function RskTmpTable()
	Local oTmpTable := Nil
	Local cTmpAR4	:= GetNextAlias()
	Local cQryTemp	:= GetNextAlias()
	Local cQuery	:= ""
	Local aFields 	:= {}
	Local aRet 		:= {}

	aAdd(aFields,{"AR4_FILIAL","C",FwSizeFilial(),0})
	aAdd(aFields,{"AR4_IDPROC","C",TamSX3("AR4_IDPROC")[1],0})
	aAdd(aFields,{"AR4_DTPROC","D",8,0})
	aAdd(aFields,{"AR4_HRPROC","C",8,0})
	aAdd(aFields,{"AR4_TOTMOV","N",5,0})
	aAdd(aFields,{"AR4_TOTCRR","N",5,0})

	oTmpTable := FWTemporaryTable():New( cTmpAR4 )
	oTmpTable:SetFields( aFields )
	oTmpTable:AddIndex( "1", {"AR4_FILIAL","AR4_IDPROC"} )
	oTmpTable:AddIndex( "2", {"AR4_FILIAL","AR4_DTPROC", "AR4_HRPROC" } )
	oTmpTable:Create()

	cQuery := " SELECT DISTINCT AR4_FILIAL, AR4_IDPROC, "+;
		" SUM(CASE WHEN AR4_STATUS = '2' THEN 1 ELSE 0 END) AR4_TOTMOV, " +;
		" SUM(CASE WHEN AR4_STATUS = '3' THEN 1 ELSE 0 END) AR4_TOTCRR  " +;
		" FROM " + RetSqlName("AR4") +;
		" WHERE AR4_TIPMOV = '8' AND D_E_L_E_T_ = ' ' " +;
		" GROUP BY AR4_FILIAL, AR4_IDPROC "

	MpSysOpenQuery(cQuery,cQryTemp)

	While (cQryTemp)->(!Eof())
		aRet := RskDTimeProc( (cQryTemp)->AR4_IDPROC )
		RecLock(cTmpAR4, .T.)
		(cTmpAR4)->AR4_FILIAL	:= (cQryTemp)->AR4_FILIAL
		(cTmpAR4)->AR4_IDPROC 	:= (cQryTemp)->AR4_IDPROC
		(cTmpAR4)->AR4_DTPROC 	:= aRet[1]
		(cTmpAR4)->AR4_HRPROC 	:= aRet[2]
		(cTmpAR4)->AR4_TOTMOV 	:= (cQryTemp)->AR4_TOTMOV
		(cTmpAR4)->AR4_TOTCRR 	:= (cQryTemp)->AR4_TOTCRR
		MsUnLock()
		(cQryTemp)->(DBSkip())
	End

	(cQryTemp)->(DBCloseArea())

	FwFreeArray(aFields)
	FwFreeArray(aRet)

Return oTmpTable


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Conciliação Financeira

@return objeto, Modelo da conciliação financeira
@author Squad NT TechFin
@since  28/12/2020
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel        := Nil
	Local oStructZZ0    := Nil
	Local oStructZZ1    := Nil
	Local bLoadZZ0      := {| | Rsk90LbZZ0() }
	Local bLoadZZ1      := { |oMdlZZ1| Rsk90LdZZ1(oMdlZZ1) }

	oStructZZ0 := FWFormModelStruct():New()
	oStructZZ0:AddTable("ZZ0",{},STR0001) //"Conciliação Financeira"
	RskBuildStruct(oStructZZ0,"ZZ0",TYPE_MODEL)

	oStructZZ1 := FWFormModelStruct():New()
	oStructZZ1:AddTable("ZZ1",{},STR0008) //"Detalhes da Conciliação"
	RskBuildStruct(oStructZZ1,"ZZ1",TYPE_MODEL)

	oModel := MPFormModel():New( "RSKA090",,,,bLoadZZ0)
	oModel:AddFields("ZZ0MASTER",,oStructZZ0,,,bLoadZZ0)
	oModel:AddGrid("ZZ1DETAIL","ZZ0MASTER",oStructZZ1,,,,,bLoadZZ1)

	oModel:GetModel("ZZ0MASTER"):SetOnlyQuery(.T.)
	oModel:GetModel("ZZ1DETAIL"):SetOnlyQuery(.T.)

	oModel:GetModel("ZZ1DETAIL"):SetOptional(.T.)

	oModel:GetModel("ZZ1DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("ZZ1DETAIL"):SetNoInsertLine(.T.)

	oModel:SetDescription(STR0001) //"Conciliação Financeira"
	oModel:SetPrimaryKey({})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface Conciliação Financeira

@return objeto, Modelo da conciliação financeira
@author Squad NT TechFin
@since  28/12/2020
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef()

	Local oModel        := FWLoadModel( "RSKA090" )
	Local oStructZZ0    := FWFormViewStruct():New()
	Local oStructZZ1    := FWFormViewStruct():New()
	Local oView         := Nil

	RskBuildStruct(oStructZZ0,"ZZ0",TYPE_VIEW)
	RskBuildStruct(oStructZZ1,"ZZ1",TYPE_VIEW)

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "VIEW_ZZ0", oStructZZ0, "ZZ0MASTER" )
	oView:AddGrid( "VIEW_ZZ1", oStructZZ1, "ZZ1DETAIL" )
	oView:AddIncrementField( "VIEW_ZZ1", "ZZ1_ITEM" )

	oView:CreateHorizontalBox( "CONCILIATION", 15 )
	oView:EnableTitleView( "VIEW_ZZ0", STR0009 ) //"Conciliação"

	oView:CreateHorizontalBox( "DETAILCONC", 85 )
	oView:EnableTitleView( "VIEW_ZZ1", STR0008 ) //"Detalhes da Conciliação"

	oView:SetOwnerView( "VIEW_ZZ0", "CONCILIATION" )
	oView:SetOwnerView( "VIEW_ZZ1", "DETAILCONC" )

	oView:SetViewProperty( "VIEW_ZZ1","ENABLENEWGRID" )
	oView:SetViewProperty( "VIEW_ZZ1","GRIDFILTER" )
	oView:SetViewProperty( "VIEW_ZZ1","GRIDSEEK" )

Return oView

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskDTimeProc
Formata o id de processsamento em data / hora

@param cIdProc, caracter, Id de processamento

@return aRet , array, Array sendo [1] = data [2] = hora.

@author Squad NT TechFin
@since  28/12/2020
/*/
//--------------------------------------------------------------------------------------
Static Function RskDTimeProc(cIdProc)
	Local aRet := {}

	aAdd(aRet,sTod(SubStr(cIdProc,1,8)))
	aAdd(aRet,Substr(cIdProc,9,2) + ":" + Substr(cIdProc,11,2) + ":" + Substr(cIdProc,13,2))
Return aRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskDTimeProc
Função responsavel por criar a estrutura de dados do tipo MODEL / VIEW.

@param oStruct, objeto, Tipo de estrutura
@param cAliasTmp, caracter, Alias temporario
@param nType, numerico, Tipo de estrutura 1=Model 2=View

@author Squad NT TechFin
@since  28/12/2020
/*/
//-------------------------------------------------------------------------------------
Static Function RskBuildStruct(oStruct, cAliasTmp, nType)

	Local cPictVlr := GetSx3Cache("E1_VALOR","X3_PICTURE")

	If nType == TYPE_MODEL

		//----------------Estrutura para criação do campo-----------------------------
		// [01] C Titulo do campo
		// [02] C ToolTip do campo
		// [03] C identificador (ID) do Field
		// [04] C Tipo do campo
		// [05] N Tamanho do campo
		// [06] N Decimal do campo
		// [07] B Code-block de validação do campo
		// [08] B Code-block de validação When do campo
		// [09] A Lista de valores permitido do campo
		// [10] L Indica se o campo tem preenchimento obrigatório
		// [11] B Code-block de inicializacao do campo
		// [12] L Indica se trata de um campo chave
		// [13] L Indica se o campo pode receber valor em uma operação de update.
		// [14] L Indica se o campo é virtual

		// Conciliação
		If cAliasTmp == "ZZ0"

			//Filial
			oStruct:AddField(STR0010,STR0011,"ZZ0_FILIAL","C",FwSizeFilial(),0,,,,,,,,.T.)

			//Id. Proc.
			oStruct:AddField(STR0012,STR0013,"ZZ0_IDPROC","C",14,0,,,,,,,,.T.)

			//Data Proc.
			oStruct:AddField(STR0014,STR0015,"ZZ0_DTPROC","D",8,0,,,,,,,,.T.)

			//Hora Proc.
			oStruct:AddField(STR0016,STR0017,"ZZ0_HRPROC","C",8,0,,,,,,,,.T.)

			//Movimentados
			oStruct:AddField(STR0075,STR0075,"ZZ0_TOTMOV","N",5,0,,,,,,,,.T.)

			//Correções
			oStruct:AddField(STR0076,STR0076,"ZZ0_TOTCRR","N",5,0,,,,,,,,.T.)


		ElseIf cAliasTmp == "ZZ1"

			//Filial
			oStruct:AddField(STR0010,STR0011,"ZZ1_FILIAL","C",FwSizeFilial(),0,,,,,,,,.T.)

			//Id. Proc.
			oStruct:AddField(STR0012,STR0013,"ZZ1_IDPROC","C",14,0,,,,,,,,.T.)

			//Item
			oStruct:AddField(STR0018,STR0018,"ZZ1_ITEM","C",6,0,,,,,,,,.T.)

			//Banco
			oStruct:AddField(STR0019,STR0020,"ZZ1_BCOCOD","C",3,0,,,,,,,,.T.)

			//Agência
			oStruct:AddField(STR0021,STR0022,"ZZ1_BCOAGE","C",6,0,,,,,,,,.T.)

			//Conta Corrente
			oStruct:AddField(STR0023,STR0024,"ZZ1_BCOCTA","C",10,0,,,,,,,,.T.)

			//Tipo de evento
			oStruct:AddField(STR0025,STR0026,"ZZ1_EVENTO","C",10,0,,,,,,,,.T.)

			//Descrição
			oStruct:AddField(STR0027,STR0027,"ZZ1_EVTDSC","C",40,0,,,,,,,,.T.)

			//Documento
			aRet := TamSx3("AR1_DOC")
			oStruct:AddField(STR0028,STR0029,"ZZ1_NFDOC","C",aRet[1],aRet[2],,,,,,,,.T. )

			//Tipo de lançamento
			oStruct:AddField(STR0030,STR0031,"ZZ1_TPLANC","C",1,0,,,{STR0073,STR0074},,,,,.T.)

			//Parcela
			aRet := TamSx3("E1_PARCELA")
			oStruct:AddField(STR0032,STR0033,"ZZ1_PARCELA","C",aRet[1],aRet[2],,,,,,,,.T. )

			//Número de Parcelas
			oStruct:AddField(STR0034,STR0035,"ZZ1_NRPARC","C",3,0,,,,,,,,.T.)

			//Tipo de Transacao
			oStruct:AddField(STR0036,STR0037,"ZZ1_TPTRAN","C",1,0,,,,,,,,.T.)

			//Data do lançamento
			oStruct:AddField(STR0038,STR0039,"ZZ1_DTLANC","D",8,0,,,,,,,,.T.)

			//Valor principal da transação
			oStruct:AddField(STR0040,STR0041,"ZZ1_VLPTRA","N",14,2,,,,,,,,.T.)

			//Valor total da transação
			aRet := TamSx3("E1_VALOR")
			oStruct:AddField(STR0042,STR0043,"ZZ1_VLTTRA","N",aRet[1],aRet[2],,,,,,,,.T.)

			//Valor principal da parcela
			oStruct:AddField(STR0044,STR0045,"ZZ1_VLPPAR","N",aRet[1],aRet[2],,,,,,,,.T.)

			//Valor total da parcela
			oStruct:AddField(STR0046,STR0047,"ZZ1_VLTPAR","N",aRet[1],aRet[2],,,,,,,,.T.)

			//Data do vencimento original da parcela
			oStruct:AddField(STR0048,STR0049,"ZZ1_DTVPAR","D",8,0,,,,,,,,.T.)

			//Data do vencimento atual da parcela
			oStruct:AddField(STR0050,STR0051,"ZZ1_DTVAPA","D",8,0,,,,,,,,.T.)

			//Custo de antecipação da parcela
			oStruct:AddField(STR0052,STR0053,"ZZ1_CUSANT","N",aRet[1],aRet[2],,,,,,,,.T.)

			//Valor do lançamento
			oStruct:AddField(STR0054,STR0055,"ZZ1_VLRLAN","N",aRet[1],aRet[2],,,,,,,,.T.)

			//Status
			oStruct:AddField(STR0056,STR0056,"ZZ1_STATUS","C",1,0,,,{STR0068,STR0069,STR0070,STR0071,STR0072,STR0077},,,,,.T.) //{"1=Recepcionado","2=Movimentado","3=Corrigir","4=Cancelado","5=Agendado","6=Customizado"}

			//Observação
			oStruct:AddField(STR0056,STR0056,"ZZ1_OBSERV","M",10,0,,,,,,,,.T.)

		EndIf

	ElseIf nType == TYPE_VIEW

		//----------------Estrutura para criação do campo-----------------------------
		// [01] C Nome do Campo
		// [02] C Ordem
		// [03] C Titulo do campo
		// [04] C Descrição do campo
		// [05] A Array com Help
		// [06] C Tipo do campo
		// [07] C Picture
		// [08] B Bloco de Picture Var
		// [09] C Consulta F3
		// [10] L Indica se o campo é evitável
		// [11] C Pasta do campo
		// [12] C Agrupamento do campo
		// [13] A Lista de valores permitido do campo (Combo)
		// [14] N Tamanho Maximo da maior opção do combo
		// [15] C Inicializador de Browse
		// [16] L Indica se o campo é virtual
		// [17] C Picture Variável


		If cAliasTmp == "ZZ0"

			//Id. Proc.
			oStruct:AddField("ZZ0_IDPROC","02",STR0012,STR0013,{},"C","@!",,,.F.)

			//Data Proc.
			oStruct:AddField("ZZ0_DTPROC","03",STR0014,STR0015,{},"D","@!",,,.F.)

			//Hora Proc.
			oStruct:AddField("ZZ0_HRPROC","04",STR0016,STR0017,{},"C","@!",,,.F.)

			//Movimentados
			oStruct:AddField("ZZ0_TOTMOV","05",STR0075,STR0075,{},"N","99999",,,.F.)

			//Correções
			oStruct:AddField("ZZ0_TOTCRR","06",STR0076,STR0076,{},"N","99999",,,.F.)

		ElseIf cAliasTmp == "ZZ1"

			//Item
			oStruct:AddField("ZZ1_ITEM","01",STR0018,STR0018,{},"C","@!",,,.F.)

			//Status
			oStruct:AddField("ZZ1_STATUS","02",STR0056,STR0056,{},"C","@!",,,.F.,,,{STR0068,STR0069,STR0070,STR0071,STR0072,STR0077},5) //{"1=Recepcionado","2=Movimentado","3=Corrigir","4=Cancelado","5=Agendado","6=Customizado"}

			//Banco
			oStruct:AddField("ZZ1_BCOCOD","03",STR0019,STR0020,{},"C","@!",,,.F.)

			//Agencia
			oStruct:AddField("ZZ1_BCOAGE","04",STR0021,STR0022,{},"C","@!",,,.F.)

			//Conta Corrente
			oStruct:AddField("ZZ1_BCOCTA","05",STR0023,STR0024,{},"C","@!",,,.F.)

			//Evento
			oStruct:AddField("ZZ1_EVENTO","06",STR0025,STR0026,{},"C","@!",,,.F.)

			//Descrição
			oStruct:AddField("ZZ1_EVTDSC","07",STR0027,STR0027,{},"C","",,,.F.)

			//Documento
			oStruct:AddField("ZZ1_NFDOC","08",STR0028,STR0029,{},"C","@!",,,.F.)

			//Tipo Lanc.
			oStruct:AddField("ZZ1_TPLANC","09",STR0030,STR0031,{},"C","@!",,,.F.,,,{STR0073,STR0074},2)  //{"1=Credito","2=Debito"}

			//Parcela
			oStruct:AddField("ZZ1_PARCELA","10",STR0032,STR0033,{},"C","@!",,,.F.)

			//Nr. Parcela
			oStruct:AddField("ZZ1_NRPARC","11",STR0034,STR0035,{},"C","@!",,,.F.)

			//Tipo Trans.
			oStruct:AddField("ZZ1_TPTRAN","12",STR0036,STR0037,{},"C","@!",,,.F.)

			//Lancamento
			oStruct:AddField("ZZ1_DTLANC","13",STR0038,STR0039,{},"D","",,,.F.)

			//Vlr. PTrans
			oStruct:AddField("ZZ1_VLPTRA","14",STR0040,STR0041,{},"N",cPictVlr,,,.F.)

			//Vlr.TTrans
			oStruct:AddField("ZZ1_VLTTRA","15",STR0042,STR0043,{},"N",cPictVlr,,,.F.)

			//Vlr.PParc
			oStruct:AddField("ZZ1_VLPPAR","16",STR0044,STR0045,{},"N",cPictVlr,,,.F.)

			//Vlr.TParc
			oStruct:AddField("ZZ1_VLTPAR","17",STR0046,STR0047,{},"N",cPictVlr,,,.F.)

			//Venc. Parc.
			oStruct:AddField("ZZ1_DTVPAR","18",STR0048,STR0049,{},"D","",,,.F.)

			//Venc. Atual
			oStruct:AddField("ZZ1_DTVAPA","19",STR0050,STR0051,{},"D","",,,.F.)

			//Custo de antecipação da parcela
			oStruct:AddField("ZZ1_CUSANT","20",STR0052,STR0053,{},"N",cPictVlr,,,.F.)

			//Vlr. Lanc
			oStruct:AddField("ZZ1_VLRLAN","21",STR0054,STR0055,{},"N",cPictVlr,,,.F.)

			//Observação
			oStruct:AddField("ZZ1_OBSERV","22",STR0057,STR0057,{},"M","",,,.T.)

		EndIf

	EndIf

Return Nil


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk90LbZZ0
Carga do modelo ZZ0

@return aLoadZZ0 , array, Retorna a carga do modelo ZZ0

@author Squad NT TechFin
@since  28/12/2020
/*/
//--------------------------------------------------------------------------------------
Static Function Rsk90LbZZ0()
	Local cAR4Temp	:= ""
	Local aRet 		:= {}
	Local aLoadZZ0 	:= {}

	If oAR4Temp != Nil
		cAR4Temp 	:= oAR4Temp:GetAlias()
		aRet		:= RskDTimeProc((cAR4Temp)->AR4_IDPROC)
		aLoadZZ0 	:= { (cAR4Temp)->AR4_FILIAL, (cAR4Temp)->AR4_IDPROC, aRet[1], aRet[2], (cAR4Temp)->AR4_TOTMOV, (cAR4Temp)->AR4_TOTCRR   }
	EndIf

Return aLoadZZ0

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk90LbZZ0
Carga do modelo ZZ1

@param oMdlZZ1, objeto, Estrutura de dados ZZ1
@return aLoadZZ1 , array, Retorna a carga do modelo ZZ1

@author Squad NT TechFin
@since  28/12/2020
/*/
//--------------------------------------------------------------------------------------
Static Function Rsk90LdZZ1(oMdlZZ1)
	Local cAR4Temp		:= ""
	Local aArea			:= GetArea()
	Local aAreaAR4		:= AR4->( GetArea() )
	Local aLoadZZ1 		:= {}
	Local aData			:= {}
	Local aCamposZZ1	:= {}
	Local nItem			:= 0
	Local nField		:= 0
	Local nTemp			:= 0
	Local oStructZZ1	:= Nil
	Local nLenFields	:= 0
	Local nSizeItem 	:= 0

	If oAR4Temp != Nil
		cAR4Temp 	:= oAR4Temp:GetAlias()
		oStructZZ1	:= oMdlZZ1:GetStruct()
		aCamposZZ1	:= oStructZZ1:GetFields()
		nLenFields	:= Len(aCamposZZ1)
		nSizeItem 	:= TamSX3( "AR4_ITEM" )[1]

		AR4->(DBSetOrder(1))	//AR4_FILIAL+AR4_IDPROC+AR4_ITEM

		If AR4->(MSSeek( (cAR4Temp)->AR4_FILIAL + (cAR4Temp)->AR4_IDPROC ) )
			cIdProc := (cAR4Temp)-> AR4_IDPROC

			While AR4->(!Eof())
				If AR4->AR4_TIPMOV == "8" .And. cIdProc == AR4->AR4_IDPROC
					nItem += 1
					cOrigem := StrTran(AR4->AR4_ORIGEM,CRLF,"#")
					aTemp := StrToKArr2(cOrigem,"|",.T.)

					aAdd(aData, AR4->AR4_FILIAL)
					aAdd(aData, AR4->AR4_IDPROC)
					aAdd(aData, StrZero( nItem, nSizeItem ))

					For nTemp := 1 To Len( aTemp )
						nStart := At("#",aTemp[nTemp])
						If nStart > 0
							cValue := AllTrim(SubStr(aTemp[nTemp],1,nStart-1))
							aAdd(aData,cValue)
							If Len(aData) == 7

								Do Case
								Case aData[7] == "IMPL"
									cValue := STR0058 //"Implantação do faturamento"
								Case aData[7] == "CANCE"
									cValue := STR0059 //"Débito por cancelamento"
								Case aData[7] == "CANCEP"
									cValue := STR0060 //"Débito por cancelamento parcial"
								Case aData[7] == "RPASSC"
									cValue := STR0061 //"Taxa por cancelamento de contrato"
								Case aData[7] == "RPASSP"
									cValue := STR0062 //"Taxa por prorrogação de vencimentos"
								Case aData[7] == "RPASSI"
									cValue := STR0063 //"Repasse de IOF"
								Case aData[7] == "BONIFI"
									cValue := STR0064 //"Débito por lançamento de bonificação"
								Case aData[7] == "DEBNF"
									cValue := STR0065 //"Débito cobrança nota fiscal"
								Case aData[7] == "BXSLDN"
									cValue := STR0066 //"Baixa de saldo negativo"
								OtherWise
									cValue := STR0067 //"Não identificado"
								EndCase
								aAdd(aData,cValue)
							EndIf
						EndIf
					Next nTemp

					aAdd(aData, AR4->AR4_STATUS)
					aAdd(aData, AR4->AR4_RESULT)
					aAdd(aLoadZZ1,{nItem, Array(nLenFields)})


					For nField := 1 To Len( aCamposZZ1 )
						If aCamposZZ1[nField][MODEL_FIELD_TIPO] == "N"
							aLoadZZ1[nItem][2][nField] := Val(aData[nField])
						ElseIf aCamposZZ1[nField][MODEL_FIELD_TIPO] == "D"
							aLoadZZ1[nItem][2][nField] := cTod(aData[nField])
						Else
							aLoadZZ1[nItem][2][nField] := aData[nField]
						EndIf
					Next nField
					aData := {}
				EndIf
				AR4->(DBSkip())
			End
		EndIf
	EndIf

	RestArea( aArea )
	RestArea( aAreaAR4 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaAR4 )
Return aLoadZZ1

/*/{Protheus.doc} RskRepro
	Função para que permitir a reabertura da conciliação para reprocessamento
	@author Lucas Silva Vieira
	@since 15/06/2022
	@param cIdproc, String, Id do processamento
	@return nil
/*/
Static Function RskRepro(cIdproc)
	Local aAreaAR4   As Array
	Local aRet       As Array
	Local aWhead     As Array
	Local cAR4Temp   As Character
	Local nItem      As Numeric
	Local oDialog    As Object
	Local oBrowse    As Object
	Local oButton1   As Object
	Local oButton2   As Object
	Local aTemp 	 As Array

	aAreaAR4 := AR4->( GetArea() )
	cAR4Temp := ""

	If oAR4Temp != Nil
		
		cAR4Temp := oAR4Temp:GetAlias()
		aWhead   := {STR0087, STR0088} //{"Data", "Qtde"}

		AR4->(DBSetOrder(1))
		If AR4->(MSSeek( (cAR4Temp)->AR4_FILIAL + (cAR4Temp)->AR4_IDPROC ) )
			cIdProc := (cAR4Temp)-> AR4_IDPROC
			aRet	:= {}
			nItem   := 0
			While AR4->(!Eof()) .And. cIdProc == AR4->AR4_IDPROC
				If AR4->AR4_STATUS == "3"
					nItem += 1
					cOrigem := StrTran(AR4->AR4_ORIGEM,CRLF,"#")
					aTemp  	:= StrToKArr2(cOrigem,"|",.T.)
					cValue 	:= AllTrim(SubStr(aTemp[11],2,8))
					nPos  	:= aScan(aRet,{|X| X[1] == cValue})
					If nPos > 0
						aRet[nPos,2]++
					Else
						aAdd(aRet,{cValue,1})
					Endif
				EndIf
				AR4->(DBSkip())
			EndDo
		EndIf

		aSort(aRet,,,{|x,y| cTod(x[1]) < cTod(y[1])})

		If Len(aRet) > 0
			DEFINE DIALOG oDialog TITLE STR0080 FROM 180,180 TO 405,490 PIXEL //"Datas a Reprocessar"
			oBrowse := TCBrowse():New( 01 , 01, 160, 90,,AWHEAD,{50,50},oDialog,,,,,,,,,,,,.F.,,.T.,,.F.,,.F.,.F.)
			oBrowse:SetArray(aRet)
			oBrowse:bLine := {||{aRet[oBrowse:nAt,01], aRet[oBrowse:nAt,02]}}

			@ 095, 060 BUTTON oButton1 PROMPT STR0081 SIZE 036, 013 OF oDialog ACTION (oDialog:End(),RskEnvPut(aRet)) PIXEL //"Confirmar"
			@ 095, 110 BUTTON oButton2 PROMPT STR0082 SIZE 036, 013 OF oDialog ACTION (oDialog:End()) PIXEL //"Cancelar"
			ACTIVATE DIALOG oDialog CENTERED
		Else
			MsgInfo(STR0083) //"Não e necessário reabrir o periodo."
		Endif
	EndIf

	RestArea( aAreaAR4 )

	FreeObj( oBrowse )
	FreeObj( oButton1 )
	FreeObj( oButton2 )
	FreeObj( oDialog )
	FwFreeArray( aWhead )
	FwFreeArray( aAreaAR4 )
	FwFreeArray( aRet )
	FwFreeArray( aTemp )
Return

/*/{Protheus.doc} RskEnvPut
	Envia as datas o endpoint conciliation/opendate/ para reabir o perido.
	@type  Static Function
	@author Lucas Silva Vieira
	@since 24/06/2022
	@param aRet, Array, Datas para reabertura
	@return nil
/*/
Static Function RskEnvPut(aRet)
	Local oRest     As Object
	Local cDate     As Character
	Local cEndPoint As Character
	Local nX        As Numeric
	Local cResult   As Character
	Local cBody     As Character
	Local dRet      As Date
	Local cMsg      As Character
	Local lDate     As Logical
	Local oJSON     As Object
	Local nTotalRet As Numeric
	Local lBxDtFin  As Logical

	cEndPoint := "/protheus-api/v1/conciliation/opendate/"
	nX 		  := 0
	cMsg 	  := ""
	cResult	  := ""
	nTotalRet := Len(aRet)
	lBxDtFin  := SuperGetMv("MV_BXDTFIN",,"1") == '2'

	For nX := 1 To nTotalRet
		dRet := ctod(aRet[nX][1])
		lDate := Iif(lBxDtFin, DtMovFin(dRet,.F.,"1"), .T.)
		If lDate
			cDate := left(fwtimestamp(6,dRet),10)
			cResult := RSKRestExec( RSKPUT, cEndPoint+cDate, @oRest, cBody, RISK, SERVICE, .F., .F. ) // PUT ### 1=Risk ### 2=URL de autenticação de serviços
			IF !Empty( cResult )
				oJSON := JSONObject():New()
				oJSON:FromJSON(cResult)
				cMsg += STR0091+dtoc(dRet)+Chr(10) 
			EndIf
		Endif
	Next nX

	If !empty(cResult)
		FWAlertInfo(cMsg)
		FWMsgRun(, {|| RskBaixa() }, STR0085, STR0086) //"Processando" # "Processando dados aguarde..."
	Else
		FWAlertInfo(STR0090) //"Não e possivel realizar esta movimentação período fechado!"
	EndIf
	FreeObj( oRest )
	FreeObj( oJSON )
Return

/*/{Protheus.doc} RskBaixa
	Realiza a chamada do RSKJobBank
	@type  Static Function
	@author Lucas Silva Vieira
	@since 27/06/2022
	@param aParam, Array, informações da empresa e filial
	@return nil
/*/
Static Function RskBaixa()
	Local aParam As Array
	aParam := { cEmpAnt, cFilAnt}
	FWMsgRun(, {|| StartJob("RSKJobBank", GetEnvServer() , .T., aParam, cFilAnt)}, STR0085, STR0086) //"Processando" # "Processando dados aguarde..."
	FwFreeArray( aParam )
Return
