#INCLUDE "TOTVS.ch"
#INCLUDE "FWBROWSE.CH"

Class OFVisualizaDados

	Data cDescricaoJanela

	Data aResumo
	Data aBrwDados
	Data aBrwCabecalho
	Data aBrwSubTotal
	Data aBrwTotal
	Data aHeaderMGet
	Data aFooterMGet

	Data oColunas
	Data oBrwVisDados
	Data oDialog
	Data oIHelper
	Data oAuxParColuna

	Data cBrwProfileID

	Data lColTotalizadora

	Method New() Constructor
	Method AddColumn()
	Method CreateObjects()
	Method Activate()
	Method SetData()
	Method AddDataRow()
	Method GetData()
	Method HasData()

	Method AddHeaderMGET()
	Method AddFooterMGET()

	Method SubTotal()
	Method Total()

	Method ProcSomaTotal()    // Metodos Internos - Nao Devem ser utilizados fora da Classe
	Method SomaTotal()        // Metodos Internos - Nao Devem ser utilizados fora da Classe
	Method ProcSomaSubTotal() // Metodos Internos - Nao Devem ser utilizados fora da Classe
	Method SomaSubTotal()     // Metodos Internos - Nao Devem ser utilizados fora da Classe
	Method CriaLinha()        // Metodos Internos - Nao Devem ser utilizados fora da Classe

EndClass

/*/{Protheus.doc} New

Cria uma janela para exibição de dados genericos

@author Rubens
@since 01/10/2018
@version 1.0
@return Self, instancia da classe
@param cParProfileID, characters, descricao
@type function
/*/
Method New(cParProfileID, cDescJanela) Class OFVisualizaDados

	Default cParProfileID := ""
	Default cDescJanela := ""

	Self:cDescricaoJanela := cDescJanela

	Self:aBrwDados := {}
	Self:aBrwCabecalho := {}
	Self:aBrwSubTotal := {}
	Self:aBrwTotal := {}
	Self:oAuxParColuna := DMS_DataContainer():New()
	Self:cBrwProfileID := cParProfileID
	Self:lColTotalizadora := .f.
	Self:aHeaderMGet := {}
	Self:aFooterMGet := {}
	
	Self:oIHelper := DMS_InterfaceHelper():New()
	Self:oIHelper:SetOwnerPvt(FunName())
Return Self

/*/{Protheus.doc} SetData

Define os dados a serem exibidos na Grid

@author Rubens
@since 01/10/2018
@version 1.0
@param aParDados, array, dados para exibicao na Grid
@type function
/*/
Method SetData(aParDados) Class OFVisualizaDados
	Self:aBrwDados := aClone(aParDados)
	Self:ProcSomaSubTotal(aParDados)
	Self:ProcSomaTotal(aParDados)
Return

/*/{Protheus.doc} AddDataRow
Adiciona uma nova linha para Grid
@author Rubens
@since 01/10/2018
@version 1.0
@param aParDados, array, dados da linha da Grid
@type function
/*/
Method AddDataRow(aParDados) Class OFVisualizaDados
	AADD(Self:aBrwDados, aClone(aParDados))
	self:SomaSubTotal(aParDados)
	self:SomaTotal(aParDados)
Return

/*/{Protheus.doc} ProcSomaSubTotal
Atualiza colunas de subtotal
@author Rubens
@since 01/10/2018
@version 1.0
@param aParDados, array, descricao
@type function
/*/
Method ProcSomaSubTotal(aParDados) Class OFVisualizaDados
	AEval(aParDados, { |x| self:SomaSubTotal(x) })
Return

/*/{Protheus.doc} SomaSubTotal
Atualiza uma determinada coluna de subtotal
@author Rubens
@since 01/10/2018
@version 1.0
@param aParDados, array, descricao
@type function
/*/
Method SomaSubTotal(aParDados) Class OFVisualizaDados
	If self:lColTotalizadora == .f.
		Return
	EndIf

	AEval(self:aBrwSubTotal,{ |x| x[2] += aParDados[x[1]] })
Return

/*/{Protheus.doc} SubTotal
//TODO Descrição auto-gerada.
@author Rubens
@since 01/10/2018
@version 1.0
@param aDadosRes, array, descricao
@type function
/*/
Method SubTotal(aDadosRes) Class OFVisualizaDados
	Local nPosLinha := self:CriaLinha()
	Local nAuxPos

	For nAuxPos := 1 to Len(aDadosRes)
		self:aBrwDados[nPosLinha, aDadosRes[nAuxPos,1]] := aDadosRes[nAuxPos,2]
	Next nAuxPos

	AEval(self:aBrwSubTotal,{ |x|;
		Self:aBrwDados[nPosLinha, x[1]] := x[2] ,; // Atualiza linha com o SubTotal
		x[2] := 0 }) // Zera Totalizador 
	
Return

/*/{Protheus.doc} ProcSomaTotal
Atualiza colunas de total
@author Rubens
@since 01/10/2018
@version 1.0
@param aParDados, array, descricao
@type function
/*/
Method ProcSomaTotal(aParDados) Class OFVisualizaDados
	AEval(aParDados, { |x| self:SomaTotal(x) })
Return


/*/{Protheus.doc} SomaTotal
Atualiza uma determinada coluna de total
@author Rubens
@since 01/10/2018
@version 1.0
@param aParDados, array, descricao
@type function
/*/
Method SomaTotal(aParDados) Class OFVisualizaDados
	If self:lColTotalizadora == .f.
		Return
	EndIf

	AEval(self:aBrwTotal,{ |x| x[2] += aParDados[x[1]] })
Return

/*/{Protheus.doc} Total
Cria uma linha com os valores totais
@author Rubens
@since 01/10/2018
@version 1.0
@param aDadosRes, array, descricao
@type function
/*/
Method Total(aDadosRes) Class OFVisualizaDados
	Local nPosLinha := self:CriaLinha()
	Local nAuxPos

	For nAuxPos := 1 to Len(aDadosRes)
		self:aBrwDados[nPosLinha, aDadosRes[nAuxPos,1]] := aDadosRes[nAuxPos,2]
	Next nAuxPos

	AEval(self:aBrwTotal,{ |x|;
		Self:aBrwDados[nPosLinha, x[1]] := x[2] ,; // Atualiza linha com o SubTotal
		x[2] := 0 }) // Zera Totalizador 
	
Return

/*/{Protheus.doc} CriaLinha
Cria uma nova linha na Grid
@author Rubens
@since 02/10/2018
@version 1.0

@type function
/*/
Method CriaLinha() Class OFVisualizaDados
	Local aAuxLinha := Array(Len(Self:aBrwCabecalho))
	Local nPosCol := 0
	Local cTipo

	For nPosCol := 1 to Len(self:aBrwCabecalho)

		cTipo := self:aBrwCabecalho[nPosCol]:GetType()

		Do Case
		Case cTipo == "N"
			aAuxLinha[nPosCol] := 0
		Case cTipo == "D"
			aAuxLinha[nPosCol] := CtoD(" ")
		Otherwise 
			aAuxLinha[nPosCol] := Space(self:aBrwCabecalho[nPosCol]:GetSize())
		End Case

	Next nPosCol
	
	AADD( Self:aBrwDados , aClone(aAuxLinha))
Return Len(Self:aBrwDados)

/*/{Protheus.doc} GetData
Retorna os dados da Grid
@author Rubens
@since 02/10/2018
@version 1.0
@return array, array com os dados da grid

@type function
/*/
Method GetData() Class OFVisualizaDados
Return self:aBrwDados

/*/{Protheus.doc} HasData
Retorna se a grid possui dados
@author Rubens
@since 02/10/2018
@version 1.0
@return logical, Valor booleano que indica se existe dados na Grid

@type function
/*/
Method HasData() Class OFVisualizaDados
	Local nRet := Len(self:aBrwDados)
Return ( nRet<> 0 )

/*/{Protheus.doc} AddColumn
Adiciona uma coluna na Grid.
Cria um objeto do tipo FWBrwColumn
@author Rubens
@since 02/10/2018
@version 1.0
@param aDataContainer, array, descricao
@type function
/*/
Method AddColumn(aDataContainer) Class OFVisualizaDados

	Local oColuna
	Local cSetData

	Self:oAuxParColuna:aData := aDataContainer

	oColuna := FWBrwColumn():New()

	// Definições Básicas do Objeto
	cTipo := self:oAuxParColuna:GetValue("TIPO","C")
	Do Case
	Case cTipo == "C"
		oColuna:SetAlign(CONTROL_ALIGN_LEFT)
	Case cTipo == "N"
		oColuna:SetAlign(CONTROL_ALIGN_RIGHT)
	Otherwise
		oColuna:SetAlign(CONTROL_ALIGN_LEFT)
	End Case
	oColuna:SetEdit(.F.)

	// Definições do Dado apresentado
	oColuna:SetSize(self:oAuxParColuna:GetValue("TAMANHO",10))
	oColuna:SetDecimal(self:oAuxParColuna:GetValue("DECIMAL",0))
	oColuna:SetTitle(self:oAuxParColuna:GetValue("TITULO",""))
	oColuna:SetType(cTipo)
	oColuna:SetPicture(self:oAuxParColuna:GetValue("PICTURE",""))

	cSetData := "{|| self:oBrwVisDados:Data():GetArray()[self:oBrwVisDados:AT()][" + ;
		cValToChar(;
			self:oAuxParColuna:GetValue("COLUNA_DADOS",Len(self:aBrwCabecalho) + 1);
		) + "] }"
	oColuna:SetData(&(cSetData))

	aAdd(self:aBrwCabecalho, oColuna)

	// Configura coluna de Totalizador 
	If self:oAuxParColuna:GetValue("TOTALIZADOR",.f.)
		AADD( self:aBrwSubTotal , { Len(self:aBrwCabecalho) , 0 } )
		AADD( self:aBrwTotal    , { Len(self:aBrwCabecalho) , 0 } )
		Self:lColTotalizadora := .t.
	EndIf
	
Return

/*/{Protheus.doc} AddHeaderMGET
Adiciona um campo na MSMGet da janela
@author Rubens
@since 02/10/2018
@version 1.0
@param aDataContainer, array, descricao
@type function
/*/
Method AddHeaderMGET(aDataContainer) Class OFVisualizaDados

	AADD( self:aHeaderMGet , aClone(aDataContainer) )

Return

/*/{Protheus.doc} CreateObjects
Cria os objetos da tela
@author Rubens
@since 02/10/2018
@version 1.0

@type function
/*/
Method CreateObjects() Class OFVisualizaDados

	Local nPos
	Local oAuxParam

	//Self:oDialog := Self:oIHelper:CreateDialog("Visualizacao de Log",, .t.)

	Self:oIHelper:SetDialog(oAuxObjDialog)
	oPanDialog := Self:oIHelper:CreateTPanel({;
		{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
		})


	If Len(Self:aHeaderMGet) > 0 
		oAuxParam := DMS_DataContainer():New()
		Self:oIHelper:nOpc := 3
		For nPos := 1 to Len(Self:aHeaderMGet)
			oAuxParam:aData := Self:aHeaderMGet[nPos]
			
			Self:oIHelper:AddMGetTipo( {;
					{ 'X3_TIPO'    , oAuxParam:GetValue( 'TIPO'    , 'C' ) },;
					{ 'X3_TAMANHO' , oAuxParam:GetValue( 'TAMANHO'       ) },;
					{ 'X3_DECIMAL' , oAuxParam:GetValue( 'DECIMAL' , 0   ) },;
					{ 'X3_CAMPO'   , oAuxParam:GetValue( 'CAMPO'         ) },;
					{ 'X3_TITULO'  , oAuxParam:GetValue( 'TITULO'        ) },;
					{ 'X3_PICTURE' , oAuxParam:GetValue( 'PICTURE' , '@!') } ;
				})
			&(oAuxParam:GetValue('CAMPO')) := oAuxParam:GetValue("VALOR")

		Next nPos

		Self:oIHelper:SetDialog(oPanDialog)
		Self:oIHelper:CreateMSMGet(.F., {;
			{"VISUALIZA"  , .t.               },;
			{"YSIZE", 50},;
			{"ALINHAMENTO", CONTROL_ALIGN_TOP};
			})

	EndIf

	Self:oIHelper:SetDialog(oPanDialog)
	oAuxPanel := Self:oIHelper:CreateTPanel({;
		{"ALINHAMENTO", CONTROL_ALIGN_ALLCLIENT};
		})

	Self:oBrwVisDados := FWFORMBROWSE():New()
	Self:oBrwVisDados:SetOwner(oAuxPanel)
	Self:oBrwVisDados:SetDataArray()
	Self:oBrwVisDados:SetColumns(self:aBrwCabecalho)
	Self:oBrwVisDados:SetArray(self:aBrwDados)
	Self:oBrwVisDados:AddButton("Gerar Planilha",{ || OFVD_GeraExcel(::oBrwVisDados) } )
	Self:oBrwVisDados:SetProfileID(self:cBrwProfileID)
	Self:oBrwVisDados:Activate() // Ativação do Browse

	Self:oBrwVisDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
Return

/*/{Protheus.doc} Activate
Ativa janela
@author Rubens
@since 02/10/2018
@version 1.0
@param lCriaObjetos, logical, Indica se deve criar os objetos da tela
@type function
/*/
Method Activate(lCriaObjetos) Class OFVisualizaDados
	Default lCriaObjetos := .t.

	Private oAuxObjDialog := Self:oIHelper:CreateDialog(Self:cDescricaoJanela,, .t.)

	Private oAuxPanel

	If lCriaObjetos
		self:CreateObjects()
	EndIf

	Self:oBrwVisDados:Refresh()
	Self:oBrwVisDados:GoTop()
	
	ACTIVATE MSDIALOG ;
		oAuxObjDialog ON INIT EnchoiceBar(oAuxObjDialog,{ || oAuxObjDialog:End() }, { || oAuxObjDialog:End() })
Return

Static Function OFVD_GeraExcel(oAuxBrowse)
	Local oExcel
	Local aAuxLinha
	Local nQtdCol
	Local nLoopRec
	Local nPosCol

	If oAuxBrowse:LogicLen() <= 0
		Return .t.
	EndIf
	
	cArq := &("cGetFile('Planilha do Excel|*.xls', '', 1, '', .f., " + str(nOR(GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY)) + ", .T., .T.)")

	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet("Dados")
	oExcel:AddTable("Dados","Dados")

	nQtdCol := Len(oAuxBrowse:aColumns)
	For nPosCol := 1 to nQtdCol
		oExcel:AddColumn( "Dados" , "Dados" , oAuxBrowse:GetColumn(nPosCol):GetTitle() , 1 , 1 , .f. )
	Next nPosCol

	oAuxBrowse:GoTop()
	nUlRec := oAuxBrowse:LogicLen()
	nCurrRec := oAuxBrowse:At()
	While .T.
		nLoopRec := oAuxBrowse:At()

		aAuxLinha := Array(nQtdCol)
		For nPosCol := 1 to nQtdCol
			aAuxLinha[nPosCol] := oAuxBrowse:GetColumnData(nPosCol)
		Next nPosCol
	
		oExcel:AddRow("Dados","Dados",aAuxLinha)

		oAuxBrowse:GoDown()
		If nLoopRec == oAuxBrowse:At()
			Exit
		EndIf
	End

	oExcel:Activate()

	oExcel:GetXMLFile(AllTrim(cArq))
	oExcel:DeActivate()

	oAuxBrowse:GoTo( nCurrRec, .T. )

	MsgInfo("Arquivo Gerado.")

Return