#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
#include 'gtpa700H.ch'

Static n700HLinMark    := 0
Static nTotTit 		   := 0


Static Function ModelDef()

Local oModel    := nil
Local oStruPai  :=  FWFormModelStruct():New()
Local oStruSon  := FWFormStruct(1,"GZK")
Local aRelation := {}
Local bLoadGrid	:= {|oMdl| G700HCarga(oMdl)}
Local bPosValid := {|oMdl| G700HPOS(oMdl)}
Local lReabCaixa := FwIsInCallStack("GTPPROCREAB")
G700HStruct(@oStruPai,@oStruSon,'M')


oModel :=  MPFormModel():New("GTPA700H",,bPosValid)

oModel:AddFields("MASTER",/*PAI*/,oStruPai,,,{|oField|GTP700HLoad(oField)} )
oModel:AddGrid("TITDETAIL", "MASTER", oStruSon) //,,,,,bLoadGrid)

aRelation	:= {{ "GZK_FILIAL", "XFILIAL('GZK')" } ,;
						{"GZK_CAIXA","CODIGO"}}	

oModel:SetRelation( "TITDETAIL", aClone(aRelation), GZK->(IndexKey(1))  )



oModel:AddCalc('700HTOT1' , 'MASTER', 'TITDETAIL',  'GZK_VALOR' , 'TOTSALDO'	, 'FORMULA',{|oModel| .T.},, STR0001,{|oModel| T700HCalc(oModel)}, 14, 2) // STR0001 //"Total Saldo"
oModel:AddCalc('700HTOT2' ,'MASTER','TITDETAIL','GZK_MARQUE','TOTTIT'        ,'FORMULA',{|oModel| .T.},, STR0002,{|oModel| nTotTit}, 14, 2) // //"Total Titulos"

oStruSon:AddTrigger("GZK_MARQUE"	, "GZK_MARQUE"	,{ || .T. }, { |oModel,nValor,xValor,lVld| T700HCMar(oModel,nValor,xValor,lVld) } )

oModel:GetModel("MASTER"):SetDescription(STR0003)  //"Titulos"
oModel:GetModel("TITDETAIL"):SetDescription(STR0003) //"Titulos"


oModel:SetDescription(STR0003)  //"Titulos"

oModel:SetPrimaryKey({})

If !lReabCaixa
	oModel:SetActivate(bLoadGrid )
EndIF

Return(oModel)



Static Function ViewDef()

Local oModel		:= FWLoadModel("GTPA700H")
Local oStruPai	    := FWFormViewStruct():New()
Local oStruSon      := FWFormStruct(2,"GZK")
Local oStruTot1     := FWCalcStruct( oModel:GetModel('700HTOT1') )
Local oStruTot2     := FWCalcStruct( oModel:GetModel('700HTOT2') )


	G700HStruct(@oStruPai,@oStruSon,"V")

	oView := FWFormView():New()

	oView:SetModel(oModel)	

	oView:AddGrid("TITULOS"  ,oStruSon,"TITDETAIL")
	oView:AddField("V_TOTAL1" ,oStruTot1,'700HTOT1')
	oView:AddField("V_TOTAL2" ,oStruTot2,'700HTOT2')


	oView:CreateHorizontalBox("TITULOS" 	, 70) 
	oView:CreateHorizontalBox("TOTALIZA"  	, 30) // Totalizadores
	//oView:SetOnlyView("TITDETAIL")
	oView:CreateVerticalBox("TOTAL1",50,"TOTALIZA")
	oView:CreateVerticalBox("TOTAL2",50,"TOTALIZA")

	oView:EnableTitleView("V_TOTAL1", "Total Saldo") 
	oView:EnableTitleView("V_TOTAL2", "Total Titulos") 
		
	oView:SetNoInsertLine("TITULOS")
	oView:GetModel('TITDETAIL'):SetNoDeleteLine(.T.)
	
	oView:SetOwnerView( "TITULOS", "TITULOS")
	oView:SetOwnerView( "V_TOTAL1", "TOTAL1")
	oView:SetOwnerView( "V_TOTAL2", "TOTAL2")

	

Return(oView)



Static Function G700HStruct(oStruPai,oStruSon,cTipo)

	

If cTipo == "M"
	If ValType( oStruPai ) == "O"
		oStruPai:AddTable("   ",{" "}," ")
		oStruPai:AddField(						  ;
			AllTrim( 'Codigo' ) 					, ; //'Codigo'
			AllTrim( 'Codigo' ) 					, ; //'Codigo'
			'CODIGO' 								, ;
			'C' 									, ;
			TamSX3("G6Y_CODIGO")[1] 				, ;
			0 										, ;
			Nil										, ;
			NIL 									, ;
			Nil										, ; 
			NIL 									, ;
			NIL										, ;
			NIL 									, ;
			NIL 									, ; 
			.T. 										)
	Endif	
	If ValType( oStruSon ) == "O"
	
		oStruSon:AddField(	AllTrim( "Vlr. Comp." ) 					, ; //'XVALOR'
			AllTrim( "Vlr. Comp." ) 					, ; //'XVALOR'
			'GZK_XVAL' 								, ;
			'N' 									, ;
			TamSX3("GZK_VALOR")[1] 					, ;
			TamSX3("GZK_VALOR")[2]					, ;
			Nil										, ;
			NIL 									, ;
			Nil										, ; 
			NIL 									, ;
			NIL										, ;
			NIL 									, ;
			NIL 									, ; 
			.T. 										)
	
	
			
		oStruSon:SetProperty( 'GZK_MARQUE',MODEL_FIELD_VALID,{|oMdl,cField,cNewValue,cOldValue|VldMarque(oMdl,cField,cNewValue,cOldValue) } )
	EndIf
Else
	If ValType( oStruSon ) == "O"
	
		oStruSon:AddField(	"GZK_XVAL",;				// [01] C Nome do Campo
						"15",;						// [02] C Ordem
						"Vlr Comp",; 					// [03] C Titulo do campo //"Seguro"
						"Vlr Comp",; 					// [04] C Descrição do campo //"Seguro"
						{"Vlr Comp"} ,;				// [05] A Array com Help //"Seguro"
						"GET",; 					// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@E 999,999,999.99",;			// [07] C Picture
						NIL,; 						// [08] B Bloco de Picture Var
						"",; 						// [09] C Consulta F3
						.F.,; 						// [10] L Indica se o campo é editável
						NIL, ; 						// [11] C Pasta do campo
						NIL,; 						// [12] C Agrupamento do campo
						{},; 						// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 						// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 					// [15] C Inicializador de Browse
						.t.) 						// [16] L Indica se o campo é virtual
	Endif
Endif

		
Return



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTP700HLoad()

Função responsável pelo Load do Cabeçalho da Tesouraria.
 
@sample	GTPA700X()
 
@return	
 
@author	SIGAGTP | Gabriela Naomi Kamimoto
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------


Static Function GTP700HLoad(oFieldModel)

Local aLoad 	:= {}
Local aCampos 	:= {}
Local aArea		:= GetArea()

Local nOperacao := oFieldModel:GetOperation()

	aAdd(aCampos,Space(TamSx3("G6T_CODIGO")[1]))
	
	Aadd(aLoad,aCampos)
	Aadd(aLoad,0)


RestArea(aArea)

Return aLoad




//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G700HCarga()

Função responsável pelo Load do Grid 1 - Ficha de Remessa
 
@sample	G700HCarga()
 
@return	
 
@author	SIGAGTP | Fernando Amorim (Cafu)
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function G700HCarga(oModel)

Local oMdlGZK	:= oModel:GetModel("TITDETAIL")


Local nI		:= 0
Local nX		:= 0
Local nCount	:= 0
Local nOperacao := oModel:GetOperation()
Local cAlias	:= GetNextAlias()

Local aGZKStru	:= oMdlGZK:GetStruct():GetFields()

If nOperacao == 5
	Return .T.
Endif
If ( !(oMdlGZK:IsEmpty()) )
	oMdlGZK:ClearData(.t.)
EndIf

BeginSQL Alias cAlias
				
	SELECT  E2_PREFIXO GZK_PREFIX, E2_NUM GZK_NUMTIT,E2_PARCELA GZK_PARCEL,E2_TIPO GZK_TIPO, E2_FORNECE GZK_FORNEC,
			E2_LOJA GZK_LOJA,E2_VENCREA GZK_DTVENC, E2_SALDO GZK_VALOR
	FROM %Table:SE2% SE2
	WHERE E2_FILIAL = %xFilial:SE2%
	AND E2_FORNECE = %Exp:GI6->GI6_FORNEC%
	AND E2_LOJA = %Exp:GI6->GI6_LOJA%
	AND E2_SALDO > 0
	AND %NotDel%
				
EndSQL
		

(cAlias)->(DbGoTop())

While (cAlias)->(!Eof())
	nCount++	
	If nCount > 1
		oMdlGZK:AddLine(.t.,.t.)
	EndIf
	
	For nI := 1 to Len(aGZKStru)
		
		If ( (cAlias)->(FieldPos(aGZKStru[nI,3])) > 0 )
			If aGZKStru[nI,3] == 'GZK_CAIXA'
				oMdlGZK:SetValue(aGZKStru[nI,3],G6T->G6T_CODIGO)
			ElseIf aGZKStru[nI,3] == 'GZK_AGENCI'
				oMdlGZK:SetValue(aGZKStru[nI,3],G6T->G6T_AGENCI)
			ElseIf aGZKStru[nI,3] == 'GZK_FICHA'
				oMdlGZK:SetValue(aGZKStru[nI,3],G6X->G6X_NUMFCH)
			ElseIf aGZKStru[nI,3] == 'GZK_DTVENC'
				oMdlGZK:SetValue(aGZKStru[nI,3],STOD((cAlias)->&(aGZKStru[nI,3])))
			ElseIf aGZKStru[nI,3] == 'GZK_XVAL'
				oMdlGZK:SetValue(aGZKStru[nI,3],0)
			Else
				oMdlGZK:SetValue(aGZKStru[nI,3],(cAlias)->&(aGZKStru[nI,3]))
			Endif
		
		EndIf
		
	Next nI
	oMdlGZK:SetValue('GZK_CAIXA',G6T->G6T_CODIGO)
	oMdlGZK:SetValue('GZK_AGENCI',G6T->G6T_AGENCI)
	oMdlGZK:SetValue('GZK_FICHA',G6X->G6X_NUMFCH)
	
	(cAlias)->(DbSkip())
EndDo

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
Endif


oMdlGZK:GoLine(1)				

Return(.t.)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} T700HCMar()

Função responsável pela calculo da ficha de remessa
 
@sample	T700HCMar()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		01/11/2017
@version	P12
/*/
Function T700HCMar(oMdl,nValor,xValor,lVld)

Local nI		:= 0
Local nSld		:=  T700HCalc(oMdl)


If oMdl:GetValue("GZK_VALOR") > 0 
	If xValor
		oMdl:SetValue("GZK_XVAL",If (oMdl:GetValue("GZK_VALOR") > (nSld-nTotTit), (nSld-nTotTit),oMdl:GetValue("GZK_VALOR")))
		nTotTit += If (oMdl:GetValue("GZK_VALOR") > (nSld-nTotTit), (nSld-nTotTit),oMdl:GetValue("GZK_VALOR"))
		
	Else
		nTotTit -= oMdl:GetValue("GZK_XVAL")
		oMdl:SetValue("GZK_XVAL",0)
	Endif
	If nTotTit < 0
		nTotTit 	:= 0
	Endif
	
	oMdl:getmodel():getmodel("700HTOT2"):LoadValue("TOTTIT",nTotTit)
Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825ATdOk
	Valida a seleção de pelo menos 1 item para realizar a reserva
@sample 	GTP3RTdOk(oModel)
@since		07/07/2017        
@version	P12
/*/
//------------------------------------------------------------------------------
Function G700HPOS(oModel)

Local lRet 		:= .F.
Local oMdlM		:= oModel:GetModel("MASTER")
Local oMdl		:= oModel:GetModel("TITDETAIL")
Local nI		:= 0
Local oView		:= FwViewActive()

Local nOperation := oModel:GetOperation()

If nOperation <> 5
	oMdlM:SetValue('CODIGO',G6T->G6T_CODIGO)
	
	
	If oModel:GetModel("700HTOT2"):GetValue("TOTTIT") == 0
		lRet 		:= .F.
		FwAlertHelp(STR0005,STR0006) //'Marque pelo menos um título.' //"Titulo"
	Else
		lRet 		:= .T. 
	EndIf

	If lRet 	
		For nI := 1 To oMdl:Length()
			oMdl:GoLine( nI )
			If oMdl:GetValue("GZK_MARQUE")
				lRet 		:= .T.
				oMdl:SetNoUpdateLine( .F. )
				oMdl:SetValue("GZK_VALOR",oMdl:GetValue("GZK_XVAL"))
				oMdl:SetNoUpdateLine( .T. )
			Else
				
				oView:GetModel('TITDETAIL'):SetNoDeleteLine(.F.)
				oMdl:DeleteLine(.T.)
				oView:GetModel('TITDETAIL'):SetNoDeleteLine(.T.)
			EndIf
		Next nI
	EndIf
Else
	lRet := .T.

Endif
If lRet
	nTotTit 	:= 0
Endif

Return lRet



Static Function VldMarque(oMdl, cField, cNewValue)
Local lRet     	:= .T.
Local nA		:= 0
Local nCount	:= 0
Local nLin		:= oMdl:GetLine()

If cField == "GZK_MARQUE"
	If cNewValue			
		If oMdl:getmodel():getmodel("700HTOT2"):GetValue("TOTTIT") >= oMdl:getmodel():getmodel("700HTOT1"):GetValue("TOTSALDO")
			For nA := 1 to oMdl:Length()
				oMdl:GoLine(nA)
				If !oMdl:IsDeleted(nA) .AND. oMdl:GetValue("GZK_MARQUE")
					nCount++
				Endif
			Next nA
			If nCount > 1
				lRet     	:= .F.
				//FwAlertHelp(STR0005,STR0004)	 //'Total de titulos maior ou igual ao saldo não permitido.' //"Titulo"
				oMdl:getmodel():SetErrorMessage(oMdl:getmodel():getid(),'',oMdl:getmodel():getid(),'',STR0005,"Total dos títulos.",STR0004)
			Endif
			oMdl:GetLine(nLin)
		Endif 			
	Endif
Endif

Return lRet
