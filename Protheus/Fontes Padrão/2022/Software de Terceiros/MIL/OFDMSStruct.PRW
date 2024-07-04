#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

Function OFDMSStruct()
Return()

/*/{Protheus.doc} OFDMSStruct
	Criei essa classe para evitar em fontes MVC sem tabela de criar varios metodos <br>
	para view e model, com essa classe os dados são convertidos independente do que precisa <br>
	model ou view
	
	Ela funciona criando todos os campos dentro e você pega o model e view usando getmodel ou getview
	usando direto na tela sem gastar

	Essa classe agora também pode ser usada para adicionar campos em fontes MVC que usam tabelas SX3 normais,
	para isso o metodo Complement foi criado,  ele vai chamar addFild dentro do objeto passado por parametro
	que sera ou um FormStruct de model ou view
	
	@type function
	@author Vinicius Gati
	@since 29/01/2018
/*/
Class OFDMSStruct
	Data _aAttrs
	Data _oView
	Data _oModel

	Method New() CONSTRUCTOR
	Method AddField()
	Method AddFieldDictionary()
	Method AddSimple()
	Method AddSelect()
	Method AddButton()
	Method ModelComplement()
	Method ViewComplement()
	Method GetModel()
	Method GetView()

	Method _ViewAddField() // privado
	Method _ModelAddField() // privado
EndClass

/*/{Protheus.doc} New
	Construtor simples
	@author Vinicius Gati
	@since 05/05/2014
/*/
Method New() Class OFDMSStruct
	::_aAttrs := {}
Return self

Method AddSelect(cTitulo, cIdField, bValid, lCanChange) class OFDMSStruct
	Local aDados
	Default bValid := { || .T. }
	Default lCanChange := .t.

	aDados := {;
		{'cTitulo'  , cTitulo },;
		{'cTipo'    , 'Check' },;
		{'nTamanho' , 1 },;
		{'nDecimal' , 0 },;
		{'cIdField' , cIdField },;
		{'bInit'    , FWBuildFeature( STRUCT_FEATURE_INIPAD, ".F.") },;
		{'bValid'   , bValid   },;
		{'lCanChange' , lCanChange },;
		{'lVirtual' , .t. } ;
	}
	self:AddField(aDados)
Return .T.


/*/{Protheus.doc} AddButton
	Criar um botao dentro de uma Field

	@type function
	@author Rubens Takahashi
	@since 14/11/2018
/*/
Method AddButton(cTitulo, cIdField, bClick ) Class OFDMSStruct
	self:AddField({;
		{'cTitulo'  , cTitulo },;
		{'cIdField' , cIdField },;
		{'cTipo'    , 'BT' },;
		{'nTamanho' , 1 },;
		{'nDecimal' , 0 },;
		{'bValid'   , bClick  } ;
	})
Return

/*/{Protheus.doc} AddField
	Adiciona um campo novo a lista de campos
	@param aData, Dados do campo
	@author Vinicius Gati
	@since 11/10/2014
/*/
Method AddField(aData) Class OFDMSStruct
	Local oData := DMS_DataContainer():New(aData)
	AADD(self:_aAttrs, oData)
Return .T.


/*/{Protheus.doc} AddFieldDictionary
	Adiciona um campo baseado no dictionary de dados

	@type function
	@author Rubens Takahashi
	@since 23/02/2019
/*/
Method AddFieldDictionary(cAlias, cField, aData) Class OFDMSStruct
	Local oData := DMS_DataContainer():New()
	Local nPos
	Local oAuxStruct := FWFormStruct( 3, cAlias ,  { |x| ALLTRIM(x) == cField }, .f. )

	oData:SetValue( 'cTitulo'  , oAuxStruct[1,1][MODEL_FIELD_TITULO] )
	oData:SetValue( 'cTooltip' , oAuxStruct[1,1][MODEL_FIELD_TOOLTIP] )
	oData:SetValue( 'cIdField' , oAuxStruct[1,1][MODEL_FIELD_IDFIELD] )
	oData:SetValue( 'cTipo'    , oAuxStruct[1,1][MODEL_FIELD_TIPO] )
	oData:SetValue( 'nTamanho' , oAuxStruct[1,1][MODEL_FIELD_TAMANHO] )
	oData:SetValue( 'nDecimal' , oAuxStruct[1,1][MODEL_FIELD_DECIMAL] )
//	oData:SetValue( 'bValid'   , oAuxStruct[1,1][MODEL_FIELD_VALID] )
//	oData:SetValue( 'bWhen'    , oAuxStruct[1,1][MODEL_FIELD_WHEN] )
	oData:SetValue( 'aValues'  , oAuxStruct[1,1][MODEL_FIELD_VALUES] )
//	oData:SetValue( 'lObrigat' , oAuxStruct[1,1][MODEL_FIELD_OBRIGAT] )
	oData:SetValue( 'bInit'    , oAuxStruct[1,1][MODEL_FIELD_INIT] )
	oData:SetValue( 'lKey'     , oAuxStruct[1,1][MODEL_FIELD_KEY] )
	oData:SetValue( 'lNoUpd'   , oAuxStruct[1,1][MODEL_FIELD_NOUPD] )
	oData:SetValue( 'lVirtual' , oAuxStruct[1,1][MODEL_FIELD_VIRTUAL] )
//	oData:SetValue( 'cValid'   , oAuxStruct[1,1][MODEL_FIELD_CVALID] )

//	oData:SetValue( 'cOrdem'       , oAuxStruct[3,1][MVC_VIEW_ORDEM] )
	oData:SetValue( 'cDescric'     , oAuxStruct[3,1][MVC_VIEW_DESCR] )
	oData:SetValue( 'cPicture'     , oAuxStruct[3,1][MVC_VIEW_PICT] )
	oData:SetValue( 'bPictVar'     , oAuxStruct[3,1][MVC_VIEW_PVAR] )
	oData:SetValue( 'cLookUp'      , oAuxStruct[3,1][MVC_VIEW_LOOKUP] )
	oData:SetValue( 'lCanChange'   , oAuxStruct[3,1][MVC_VIEW_CANCHANGE] )
//	oData:SetValue( 'cFolder'      , oAuxStruct[3,1][MVC_VIEW_FOLDER_NUMBER] )
//	oData:SetValue( 'cGroup'       , oAuxStruct[3,1][MVC_VIEW_GROUP_NUMBER] )
	oData:SetValue( 'aComboValues' , oAuxStruct[3,1][MVC_VIEW_COMBOBOX] )
	oData:SetValue( 'nMaxLenCombo' , oAuxStruct[3,1][MVC_VIEW_MAXTAMCMB] )
//	oData:SetValue( 'cIniBrow'     , oAuxStruct[3,1][MVC_VIEW_INIBROW] )
	oData:SetValue( 'cPictVar'     , oAuxStruct[3,1][MVC_VIEW_PICTVAR] )
//	oData:SetValue( 'lInsertLine'  , oAuxStruct[3,1][MVC_VIEW_INSERTLINE] )
	oData:SetValue( 'nWidth'       , oAuxStruct[3,1][MVC_VIEW_WIDTH] )

	For nPos := 1 To Len(aData)
		oData:SetValue(aData[nPos,1], aData[nPos,2])
	Next nPos

	AADD(self:_aAttrs, oData)

Return .t.

/*/{Protheus.doc} AddSimple
	Adiciona um campo novo a lista de campos com valores de parametro já pre
	definidos evitando código nas telas pois tem valores padroes para varios campos

	@param, cTitulo, Titulo do campo
	@param, cTipo, Tipo do campo como no SX3
	@param, nTam, tamanho do campo
	@param, nDec, tamanho decimal do campo em caso numerico
	@param, cIdField, id do campo ou como ele será acessado nos getvalues
	@param, cF3, seek padrao igual sx3
	@param, cPic, picture do campo
	@param, bValid, valid do campo
	@param, lObrigat, se obrigatorio ou nao
	@author Vinicius Gati
	@since 11/10/2014
/*/
Method AddSimple(cTitulo, cTipo, nTam, nDec, cIdField, cF3, cPic, bValid, lObrigat) Class OFDMSStruct
	Local aDados     := Nil
	Default nDec     := 0
	Default cF3      := ''
	Default cPic     := "@!"
	Default bValid   := { || .T. }
	Default lObrigat := .T.
	aDados := {;
		{'cTitulo' , cTitulo  },;
		{'cTipo'   , cTipo    },;
		{'nTamanho', nTam     },;
		{'nDecimal', nDec     },;
		{'cIdField', cIdField },;
		{'cPicture', cPic     },;
		{'bValid'  , bValid   },;
		{'lObrigat', lObrigat },;
		{'cLookUp' , cF3      } ;
	}
	self:AddField(aDados)
Return .T.

/*/{Protheus.doc} GetModel
	Retorna FwFOrmModelStruct que pode ser usada em MVC

	@author Vinicius Gati
	@since 11/10/2014
/*/
method GetModel() class OFDMSStruct
	self:_oModel := FWFormModelStruct():New()
return self:ModelComplement(self:_oModel)

/*/{Protheus.doc} GetView
	Retorna FWFormViewStruct que pode ser usada em MVC

	@author Vinicius Gati
	@since 11/10/2014
/*/
Method GetView() Class OFDMSStruct
	self:_oView  := FWFormViewStruct():New()
Return self:ViewComplement(self:_oView)

/*/{Protheus.doc} ModelComplement
	Adiciona os campos no model

	@author Vinicius Gati
	@since 11/10/2014
/*/
method ModelComplement(oModel) class OFDMSStruct
	local  nX := 1
	default oModel := self:_oModel

	for nX:= 1 to Len(self:_aAttrs)
		aAttr := self:_aAttrs[nX]
		self:_ModelAddField(oModel, aAttr, nX)
	next
return oModel

/*/{Protheus.doc} ViewComplement
	Adiciona os campos na view

	@author Vinicius Gati
	@since 11/10/2014
/*/
Method ViewComplement(oView) Class OFDMSStruct
	local  nX := 1
	default oView := self:_oView
			
	for nX:= 1 to Len(self:_aAttrs)
		aAttr := self:_aAttrs[nX]
		self:_ViewAddField(oView, aAttr, nX)
	next
Return oView

/*/{Protheus.doc} _ViewAddField
	Adiciona campo a view conforme documentacao da totvs

	@author Vinicius Gati
	@since 11/10/2014
/*/
Method _ViewAddField(oView, aAttr, nX) Class OFDMSStruct
	local lCanChange := aAttr:Gv('lCanChange', .t.)
	if valtype(lCanChange) == "B"
		lCanChange := eval(aAttr:Gv('lCanChange'))
	endif
	oView:AddField( ;
				aAttr:Gv('cIdField', "FLD_" + cValToChar(nX)) ,;
				aAttr:Gv('cOrdem', StrZero(nX,3)) ,;
				aAttr:Gv('cTitulo', Nil) ,;
				aAttr:Gv('cDescric', aAttr:Gv('cTitulo')) ,;
				aAttr:Gv('aHelp', {}) ,;
				aAttr:Gv('cTipo', 'C') ,;
				aAttr:Gv('cPicture', '@!') ,;
				aAttr:Gv('bPictVar', Nil) ,;
				aAttr:Gv('cLookUp', aAttr:Gv('f3')) ,;
				lCanChange,;
				aAttr:Gv('cFolder', Nil) ,;
				aAttr:Gv('cGroup', Nil) ,;
				aAttr:Gv('aComboValues', Nil) ,;
				aAttr:Gv('nMaxLenCombo', Nil) ,;
				aAttr:Gv('cIniBrow', Nil) ,;
				aAttr:Gv('lVirtual', Nil) ,;
				aAttr:Gv('cPictVar', Nil) ,;
				aAttr:Gv('lInsertLine', Nil) ,;
				aAttr:Gv('nWidth', Nil) ;
			)
Return .t.

/*/{Protheus.doc} _ModelAddField
	Adiciona campo ao model conforme documentacao da totvs

	@author Vinicius Gati
	@since 11/10/2014
/*/
Method _ModelAddField(oModel, aAttr, nX) Class OFDMSStruct
	Local cTipo := aAttr:Gv('cTipo', 'C')
	If cTipo == 'Check'
		cTipo := 'L'
	EndIf
	oModel:AddField( ;
		aAttr:Gv('cTitulo', Nil),;
		aAttr:Gv('cTooltip', aAttr:Gv('cTitulo')),;
		aAttr:Gv('cIdField', "FLD_" + cValToChar(nX)),;
		cTipo,;
		aAttr:Gv('nTamanho', 100),;
		aAttr:Gv('nDecimal', 0),;
		aAttr:Gv('bValid', {|| .t. }),;
		aAttr:Gv('bWhen', {|| .t. }),;
		aAttr:Gv('aValues', Nil),;
		aAttr:Gv('lObrigat', .F.),;
		aAttr:Gv('bInit', Nil),;
		aAttr:Gv('lKey', .F.),;
		aAttr:Gv('lNoUpd', .F.),;
		aAttr:Gv('lVirtual', .F.),;
		aAttr:Gv('cValid', Nil) ;
	)
Return .t.

