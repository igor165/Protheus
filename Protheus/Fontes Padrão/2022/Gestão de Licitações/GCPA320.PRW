#include "GCPA320.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#DEFINE CRLF Chr(13)+Chr(10)

Static aSldPrds := {}

//-------------------------------------------------------------------
/*{Protheus.doc} Model
Manutencao de Saldo do Sistema de Registro de Precos

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel
 // Cria a estrutura a ser usada no Modelo de Dados
Local oStruCPH := FWFormStruct( 1,'CPH' ) 
Local oStruCPI := FWFormStruct( 1,'CPI' )
Local oStruCPE := FWFormStruct( 1,'CPE' )
//Estruturas auxiliares
Local oStruCPY := FWFormStruct( 1,'CPY' )
Local oStruCPZ := FWFormStruct( 1,'CPZ' )

Local lLote	:= GCP301Lote()

oStruCPI:AddField( ;                                                  
                        AllTrim('') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'CPI_LEGEND' , ;               // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        50 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { || A300CPILeg() } , ;  		// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual

oStruCPH:AddField( ;
	                    STR0036 , ; 					// [01] C Titulo do campo
	                    AllTrim('') , ; 				// [02] C ToolTip do campo
	                    'CPH_AUTO' , ;              	// [03] C identificador (ID) do Field
	                    'C' , ;                     	// [04] C Tipo do campo
	                    1 , ;                      	// [05] N Tamanho do campo
	                    NIL , ;							// [06] N Decimal do campo
	                    NIL , ;                     	// [07] B Code-block de validação do campo
	                    NIL , ;                     	// [08] B Code-block de validação When do campo
	                    NIL , ;                     	// [09] A Lista de valores permitido do campo
	                    NIL , ;                     	// [10] L Indica se o campo tem preenchimento obrigatório
	                    FwBuildFeature( STRUCT_FEATURE_INIPAD, "'0'" )  			,;	// [11] B Code-block de inicializacao do campo
	                    NIL , ;                     	// [12] L Indica se trata de um campo chave
	                    NIL , ;                     	// [13] L Indica se o campo pode receber valor em uma operação de update.
	                    .T. )

oModel := MPFormModel():New('GCPA320', /*bPreValidacao*/, {|oModel|GCP320Vld(oModel)}, {|oModel|GCP320Grv(oModel)} /*bCommit*/, /*bCancel*/ )
// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'CPHMASTER',/*cOwner*/  , oStruCPH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid( 'CPIDETAIL'  , 'CPHMASTER', oStruCPI, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPYDETAIL'  , 'CPIDETAIL', oStruCPY, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPZDETAIL'  , 'CPYDETAIL', oStruCPZ, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPEDETAIL'  , 'CPIDETAIL', oStruCPE, /*{|oModel, nLinha, cAcao,cCampo,xNewValue|A320CPEPVl(oModel, nLinha, cAcao,cCampo,xNewValue)}*/, /*{|oMode| GCP320Pos(oModel) }*//*bPosValidacao*/, /*bCarga*/ )

oModel:SetRelation( 'CPIDETAIL' , { { 'CPI_FILIAL' , 'xFilial("CPI")' } , { 'CPI_CODEDT' , 'CPH_CODEDT' } , { 'CPI_NUMPRO'	, 'CPH_NUMPRO' } , { 'CPI_NUMATA' , 'CPH_NUMATA' } }, CPI->(IndexKey(1)) )
oModel:SetRelation( 'CPEDETAIL' , { { 'CPE_FILIAL' , 'xFilial("CPE")' } , { 'CPE_CODORG' , 'CPI_CODORG' } , { 'CPE_TIPO'	, 'CPI_TIPO' 	 } , { 'CPE_CODEDT' , 'CPH_CODEDT' } , { 'CPE_NUMPRO' , 'CPH_NUMPRO' } , { 'CPE_CODPRO'	, 'CPI_CODPRO'} , { 'CPE_NUMATA' , 'CPI_NUMATA' }, { 'CPE_LOTE' , 'CPI_LOTE' } }, CPE->(IndexKey(1)) )
oModel:SetRelation( 'CPYDETAIL' , { { 'CPY_FILIAL' , 'xFilial("CPY")' } , { 'CPY_NUMATA' , 'CPH_NUMATA' } , { 'CPY_CODPRO' , 'CPI_CODPRO' } , { 'CPY_LOTE'	, 'CPI_LOTE'	} } , CPY->(IndexKey(1)) )

If lLote
	oModel:SetRelation( 'CPZDETAIL' , { { 'CPZ_FILIAL' , 'xFilial("CPZ")' } , { 'CPZ_NUMATA' , 'CPH_NUMATA' } , { 'CPZ_LOTE' , 'CPY_LOTE' } } , CPZ->( IndexKey(2) ) )
Else
	oModel:SetRelation( 'CPZDETAIL' , { { 'CPZ_FILIAL' , 'xFilial("CPZ")' } , { 'CPZ_NUMATA' , 'CPH_NUMATA' } , { 'CPZ_CODPRO' , 'CPY_CODPRO' } }, CPZ->( IndexKey(1) ) )
EndIf

oStruCPI:AddField(STR0001,STR0002 , 'CPI_DSCPRO', 'C',50,,,,,,FWBuildFeature( STRUCT_FEATURE_INIPAD, 'POSICIONE( "SB1", 1, xFilial("SB1")+CPI_CODPRO, "B1_DESC" )'),,.T.,.T. )//'Desc. Prod'//'Descrição do produto'

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0003 )	//"Manutenção de Saldo"

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CPHMASTER' ):SetDescription( STR0004 )		//"Ata"
oModel:GetModel( 'CPIDETAIL' ):SetDescription( STR0005 )		//"Participantes"
oModel:GetModel( 'CPEDETAIL' ):SetDescription( STR0006 )			//"Reservas"

oModel:GetModel( 'CPHMASTER' ):SetOnlyView(.T.)
//oModel:GetModel( 'CPIDETAIL' ):SetOnlyView(.T.)
oModel:GetModel( 'CPYDETAIL' ):SetOnlyView(.T.)
oModel:GetModel( 'CPZDETAIL' ):SetOnlyView(.T.)

oModel:GetModel( 'CPEDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CPZDETAIL' ):SetOptional(.T.)

oModel:GetModel( 'CPEDETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel( 'CPEDETAIL' ):SetNoDeleteLine(.T.)

oModel:GetModel( 'CPIDETAIL' ):SetNoInsertLine(.T.)
oModel:GetModel( 'CPIDETAIL' ):SetNoDeleteLine(.T.)
//oModel:GetModel( 'CPIDETAIL' ):SetNoUpdateLine(.T.)
oStruCPI:SetProperty("*",MODEL_FIELD_WHEN,{||.F.})

If SuperGetMV("MV_GCPDSLD", .F., .F.)
	oStruCPI:SetProperty("CPI_SALDO",MODEL_FIELD_WHEN,{||A320WhnSld()})
EndIf		

//--Apenas Reservas não consumidas
oModel:GetModel('CPEDETAIL'):SetLoadFilter({{'CPE_OK',"'F'",MVC_LOADFILTER_EQUAL}})

oModel:SetActivate({|oModel| GCP320Act(@oModel)})

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Manutencao de Saldo do Sistema de Registro de Precos

@author Alex Egydio
@since 10/09/2013
@version P11.90
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()

Local oStrCPH:= FWFormStruct(2, 'CPH' )
Local oStrCPI:= FWFormStruct(2, 'CPI' )
Local oStrCPE:= FWFormStruct(2, 'CPE' )

Local lLote	:= GCP301Lote()

oStrCPI:AddField( ;                                                            // Ord. Tipo Desc.
                                               'CPI_LEGEND' , ;                    // [01] C Nome do Campo
                                               '00' , ;                         // [02] C Ordem
                                               AllTrim('') , ;				   	// [03] C Titulo do campo
                                               AllTrim( 'Teste Bitmap' ) , ;   	// [04] C Descrição do campo
                                               { 'teste bitmap' } , ;           // [05] A Array com Help
                                               'C' , ;                          // [06] C Tipo do campo
                                               '@BMP' , ;                       // [07] C Picture
                                               NIL , ;                          // [08] B Bloco de Picture Var
                                               '' , ;                           // [09] C Consulta F3
                                               .F. , ;                          // [10] L Indica se o campo é evitável
                                               NIL , ;                          // [11] C Pasta do campo
                                               NIL , ;                          // [12] C Agrupamento do campo
                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
                                               NIL , ;                          // [15] C Inicializador de Browse
                                               .T. , ;                          // [16] L Indica se o campo é virtual
                                               NIL )                            // [17] C Picture Variável

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('VIEW_CPH', oStrCPH,'CPHMASTER' )
oView:AddGrid('VIEW_CPI' , oStrCPI,'CPIDETAIL')
oView:AddGrid('VIEW_CPE' , oStrCPE,'CPEDETAIL')

oStrCPI:AddField( 'CPI_DSCPRO','09',STR0007,STR0008,, 'Get',,,,.F. )//'Desc. Produto'//'Descrição do Produto'

oView:CreateHorizontalBox( 'SUPERIOR', 30)
oView:CreateHorizontalBox( 'INTERMEDIARIO',30)
oView:CreateHorizontalBox( 'INFERIOR', 40)

oView:SetOwnerView('VIEW_CPH','SUPERIOR')
oView:SetOwnerView('VIEW_CPI','INTERMEDIARIO')
oView:SetOwnerView('VIEW_CPE','INFERIOR')

oView:EnableTitleView('VIEW_CPI' , STR0005 ) 
oView:EnableTitleView('VIEW_CPE' , STR0006 ) 

oView:SetNoDeleteLine('VIEW_CPE')
oView:SetNoInsertLine('VIEW_CPE')

oView:SetNoDeleteLine('VIEW_CPI')
oView:SetNoInsertLine('VIEW_CPI')

oView:SetViewProperty('VIEW_CPH' , 'ONLYVIEW' )

//-- Remove Fields
oStrCPH:RemoveField( 'CPH_AVAL' )
oStrCPH:RemoveField( 'CPH_JUSTIF' )
oStrCPH:RemoveField( 'CPH_ETAPA' )
oStrCPH:RemoveField( 'CPH_STATUS' )
oStrCPH:RemoveField( 'CPH_NUMPRO' )
oStrCPH:RemoveField( 'CPH_CODEDT' )
oStrCPH:RemoveField( 'CPH_VGATAF' )
oStrCPH:RemoveField( 'CPH_VGATAI' )

oStrCPH:RemoveField( 'CPH_DTPB1' )
oStrCPH:RemoveField( 'CPH_CANAL1' )
oStrCPH:RemoveField( 'CPH_DTPB2' )
oStrCPH:RemoveField( 'CPH_CANAL2' )
oStrCPH:RemoveField( 'CPH_DTPB3' )
oStrCPH:RemoveField( 'CPH_CANAL3' )
oStrCPH:RemoveField( 'CPH_DTPB4' )
oStrCPH:RemoveField( 'CPH_CANAL4' )

If !lLote
	oStrCPI:RemoveField( 'CPI_LOTE' )
EndIf

oStrCPI:RemoveField( 'CPI_NUMPRO' )
oStrCPI:RemoveField( 'CPI_CODEDT' )
oStrCPI:RemoveField( 'CPI_TIPO' )
oStrCPI:RemoveField( 'CPI_NUMATA' )

oStrCPE:RemoveField( 'CPE_NUMPRO' )
oStrCPE:RemoveField( 'CPE_CODEDT' )
oStrCPE:RemoveField( 'CPE_TIPO' )
oStrCPE:RemoveField( 'CPE_DESORG' )
oStrCPE:RemoveField( 'CPE_CODORG' )
oStrCPE:RemoveField( 'CPE_LOTE' )
oStrCPE:RemoveField( 'CPE_NUMATA' )
oStrCPE:RemoveField( 'CPE_CODPRO' )

oStrCPE:SetProperty('*', 	MVC_VIEW_CANCHANGE,.F.)
oStrCPE:SetProperty('CPE_OK', 	MVC_VIEW_CANCHANGE,.T.)

oView:AddUserButton(STR0009, 'CLIPS', {|oView|  A320Legend()})//"Legenda"

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} GCP320Grv()
Funcao para gerar documentos e gravar manutencao dos saldos.	

@author alexandre.gimenez	
@since 16/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Static Function GCP320Grv(oModel)
Local oModOrg		:= oModel:GetModel("CPIDETAIL")
Local oModRes		:= oModel:GetModel("CPEDETAIL")
Local oModAta		:= oModel:GetModel("CPHMASTER")
Local oModCPY		:= oModel:GetModel("CPYDETAIL")
Local oModCPZ		:= oModel:GetModel("CPZDETAIL")
Local oModel300  	:= Nil

Local aPedidos		:= {}
Local aDados		:= {}
Local aDadosFE		:= {}
Local aDadosNG		:= {}
Local aQuebra		:= {}
local aOrgao		:= {}
Local aCab			:= {}
Local aItens		:= {}
Local aCTBEnt		:= CTBEntArr()
Local aForns		:= {}
Local aRecNoCPE   	:= {}
Local aRecNoFE   	:= {}
Local aAreaSM0		:= SM0->(GetArea())
Local aFornsFE		:= {}
Local aQuebraFE		:= {}
Local aRecPed		:= {}
Local aPrdSld		:= {}
Local aDadosOrg		:= {}
Local aAreaCX3		:= CX3->(GetArea()) 

Local cOrgao		:= ""
Local cQuebra		:= ""
Local cC7Item		:= ""
Local cC7Num		:= ""
Local cFilBkp		:= cFilAnt
Local cFilCX6		:= xFilial("CX6")
Local cFilAtu		:= Substr(cNumEmp, Len(cEmpAnt)+1, Len(cFilAnt))
Local cFilOri		:= ""
Local cTexto		:= ""
Local cFilCX3		:= xFilial("CX3")

Local lRet 			:= .T.
Local lNewItem		:= .T.
Local lGeraCtr		:= .F.
Local lGeraPed		:= .F.  
Local lIncManual	:= .F.
Local lGerCent		:= SuperGetMV("MV_GCPFIAP", .T., "C") == "C"  
Local lNotaEmp		:= .F.
Local lLote			:= GCP301Lote(oModAta:GetValue("CPH_NUMATA"))
Local lCond			:= .F.
Local lMsgPart		:= .F.

Local nX			:= 0
Local nY			:= 0
Local nXP			:= 0
Local nYP			:= 0
Local nC			:= 0	
local nPos			:= 0
Local nj			:= 0

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

CO1->(DbSetOrder(1))
If CPH->(FieldPos("CPH_FILORI")) > 0 .And. FWModeAccess("CPH",3) == 'C'
	lIncManual := !CO1->(DbSeek( oModAta:GetValue("CPH_FILORI") + oModAta:GetValue("CPH_CODEDT") + oModAta:GetValue("CPH_NUMPRO") ))
Else	
	lIncManual := !CO1->(DbSeek( xFilial("CO1") + oModAta:GetValue("CPH_CODEDT") + oModAta:GetValue("CPH_NUMPRO") ))
EndIf
	
oModOrg:SetNoUpdateLine(.F.)
// aQuebra[1] = Orgao
// aQuebra[2] = Produto
// aQuebra[3] = Quantidade

For nX := 1 to oModOrg:Length()
	oModOrg:Goline(nX)
	If 	oModAta:GetValue("CPH_CODORG") == oModOrg:GetValue("CPI_CODORG"); 
		.Or. lIncManual;
		.Or. (!Empty(oModOrg:GetValue("CPI_FILENT")) .And. oModOrg:GetValue("CPI_FILENT") == cFilAtu) 
		For nY := 1 To oModRes:Length()
			oModRes:GoLine(nY)
			If oModRes:GetValue('CPE_TIPDOC') == '1' .And. oModRes:GetValue('CPE_OK') 
				lGeraCtr := .T.
				For nXP:= 1 To oModCPY:Length()
					oModCPY:GoLine(nXP)			
					If lLote
						lCond := oModCPY:GetValue( 'CPY_CODPRO' ) == oModOrg:GetValue( "CPI_CODPRO" ) .And. Alltrim( oModCPY:GetValue( 'CPY_LOTE' ) ) == Alltrim( oModOrg:GetValue( "CPI_LOTE" ) )  
					Else	
						lCond := oModCPY:GetValue( 'CPY_CODPRO' ) == oModOrg:GetValue( "CPI_CODPRO" )
					EndIf	
					If lCond 
						For nYP := 1 To oModCPZ:Length()
							oModCPZ:GoLine(nYP)
							If 	oModCPZ:GetValue('CPZ_STATUS') == '5'
								//-- Separa em dois array, para geração na filial corrente e filial de entrega
								If Empty(oModOrg:GetValue("CPI_FILENT")) .Or. lGerCent 
									If aScan( aForns , { |x| ( x[1] + x[2] ) == ( oModCPZ:GetValue('CPZ_CODIGO') + oModCPZ:GetValue('CPZ_LOJA') ) } ) == 0
										Aadd(aForns, {oModCPZ:GetValue('CPZ_CODIGO'), oModCPZ:GetValue('CPZ_LOJA')})
									EndIf
								Else
									If aScan( aFornsFE, {|x| x[1] + x[2] + x[3] == oModCPZ:GetValue('CPZ_CODIGO') + oModCPZ:GetValue('CPZ_LOJA')+ oModOrg:GetValue("CPI_FILENT")} ) == 0
										Aadd(aFornsFE, {oModCPZ:GetValue('CPZ_CODIGO'), oModCPZ:GetValue('CPZ_LOJA'),oModOrg:GetValue("CPI_FILENT")})
									EndIf		
								EndIf									
							EndIf		
						Next nYP
					EndIf				
				Next nXP							
			ElseIf oModRes:GetValue('CPE_TIPDOC') == '2' .And. oModRes:GetValue('CPE_OK')
				lGeraPed := .T.	
				If Empty(oModOrg:GetValue("CPI_FILENT")) .Or. oModOrg:GetValue("CPI_FILENT") == cFilAnt .Or. lGerCent
					Aadd(aRecNoCPE, oModRes:GetDataId())
				Else
					Aadd(aRecNoFE, {oModRes:GetDataId(),oModOrg:GetValue("CPI_FILENT")})									
				EndIf			
			EndIf			
		Next nY
	ElseIf oModRes:GetValue('CPE_OK') .And. Empty(Posicione("CPA", 1, xFilial("CPA") + oModOrg:GetValue("CPI_CODORG"), "CPA_SISFIL"))
		aAdd(aDadosNG,oModOrg:GetValue("CPI_CODORG"))
	EndIf	
Next nX	

Begin Transaction 
	If lGeraCtr
		If lGerCent .And. Len(aForns) > 0
			lRet := GCP200Ctrs(oModel,'',aForns,.T.)	
		Else
			cFilOri := IIF(CPH->(FieldPos("CPH_FILORI")) > 0 .And. !Empty(CPH->CPH_FILORI), CPH->CPH_FILORI, FWCodFil())
			cFilAtu := Substr(cNumEmp, Len(cEmpAnt)+1, Len(cFilAnt))
			If Empty(aFornsFE)
				aFornsFE := aForns
			EndIf
			lRet := GCP200Ctrs(oModel,'',aFornsFE,.T.,cFilOri,cFilAtu)
		EndIf	
	EndIf
	If lRet .And. lGeraPed		
		If cFilBkp <> cFilAnt	
			SM0->(RestArea(aAreaSM0))
			cFilAnt := cFilBkp
		EndIf
		For nX := 1 to oModOrg:Length()
			oModOrg:Goline(nX)
			lNewItem	:= .T.
			For nY := 1 to oModRes:Length()
				oModRes:GoLine(nY)
				If !Empty(oModRes:GetValue("CPE_ITEM"))
					If oModRes:GetValue("CPE_OK") .And. oModRes:GetValue('CPE_TIPDOC') == '2'//-- Apenas Itens marcados e pedido
						lNotaEmp := !Empty(oModRes:GetValue('CPE_CODNE')) 
						If oModAta:GetValue("CPH_CODORG") == oModOrg:GetValue("CPI_CODORG") .Or. lIncManual .Or. (!Empty(oModOrg:GetValue("CPI_FILENT")) .And. oModOrg:GetValue("CPI_FILENT") <> cFilAnt)
							If Empty(oModOrg:GetValue("CPI_FILENT")) .Or. oModOrg:GetValue("CPI_FILENT") == cFilAnt .Or. lGerCent
								If lNewItem //-- Primeiro vez Cria Registro
									lNewItem := .F.
									aAdd(aQuebra,{oModOrg:GetValue("CPI_CODORG"),oModOrg:GetValue("CPI_CODPRO"),oModRes:GetValue("CPE_QUANT"),'',lNotaEmp})
								Else //-- Depois so Atualiza.
									aQuebra[Len(aQuebra)][3] +=  oModRes:GetValue("CPE_QUANT")
								EndIf	
							Else
								nLinhaFE := aScan( aQuebraFE, {|x| AllTrim(x[4]) == oModOrg:GetValue("CPI_FILENT")} )
								If nLinhaFE == 0								 
									If lNewItem //-- Primeiro vez Cria Registro
										lNewItem := .F.
										aAdd(aQuebraFE,{oModOrg:GetValue("CPI_CODORG"),oModOrg:GetValue("CPI_CODPRO"),oModRes:GetValue("CPE_QUANT"),oModOrg:GetValue("CPI_FILENT"),lNotaEmp})
									Else //-- Depois so Atualiza.
										aQuebraFE[Len(aQuebraFE)][3] +=  oModRes:GetValue("CPE_QUANT")											
									EndIf												
								Else
									aQuebraFE[nLinhaFE][3] +=  oModRes:GetValue("CPE_QUANT")										
								EndIf					
							EndIf
						EndIf												
					EndIf
				EndIf
			Next nY
		Next nX
		oModOrg:SetNoUpdateLine(.F.)
		If Len(aQuebra) > 0
			lRet := A320GerPed(aQuebra,aRecNoCPE)
		EndIf
		If lRet
			For nX := 1 To Len(aQuebraFE)
				aRecPed := {}
				If !lRet
					Exit
				EndIf
				For nJ := 1 To Len(aRecNoFE)
					If aRecNoFE[nj,2] == aQuebraFE[nX,4]
						Aadd(aRecPed,aRecNoFE[nJ,1])
					EndIf
				Next nJ						
				SM0->(dbSetOrder(1))
				SM0->(dbSeek(cEmpAnt+AllTrim(aQuebraFE[nX,4])))
				cFilAnt := FWCodFil()			
				lRet := A320GerPed({aQuebraFE[nX]},aRecPed,cFilBkp,aQuebraFE[nX,4])			
			Next nX
		EndIf
		If cFilBkp <> cFilAnt	
			SM0->(RestArea(aAreaSM0))
			cFilAnt := cFilBkp
		EndIf
	EndIf			
	If !lRet
		DisarmTransaction()
	EndIf		
End Transaction

If lRet
	If lLote
		dbSelectArea("CX6")
		dbSetOrder(1)
	EndIf
	CX3->(DbSetOrder(1))
	oModOrg:GetStruct():SetProperty("*",MODEL_FIELD_WHEN,{||.T.})
	For nX := 1 to oModOrg:Length()
		oModOrg:Goline(nX)				
		For nY := 1 to oModRes:Length()
			oModRes:GoLine(nY)
			If !Empty(oModRes:GetValue("CPE_ITEM"))
				If oModRes:GetValue("CPE_OK")// .And. oModRes:GetValue('CPE_TIPDOC') == '2'//-- Apenas Itens marcados e pedido
					If oModRes:GetValue("CPE_TIPMOV") == '1'//--Reserva
						oModRes:LoadValue("CPE_TIPMOV",'2')
						oModOrg:LoadVaLue("CPI_QTDRES",oModOrg:GetVaLue("CPI_QTDRES")- oModRes:GetValue("CPE_QUANT") )
						oModOrg:LoadVaLue("CPI_QTDCON",oModOrg:GetVaLue("CPI_QTDCON")+ oModRes:GetValue("CPE_QUANT") )						
					ElseIf oModRes:GetValue("CPE_TIPMOV") == '2'//--Baixa
						oModRes:LoadValue("CPE_TIPMOV",'1')
						oModOrg:LoadVaLue("CPI_QTDRES",oModOrg:GetVaLue("CPI_QTDRES")+ oModRes:GetValue("CPE_QUANT") )
						oModOrg:LoadVaLue("CPI_QTDCON",oModOrg:GetVaLue("CPI_QTDCON")- oModRes:GetValue("CPE_QUANT") )
					EndIf
					//Atualiza saldo do item
					oModCPY:LoadValue('CPY_SALDO',oModCPY:GetValue('CPY_SALDO') - oModRes:GetValue("CPE_QUANT"))								
					//Atualiza saldo do lote
					If lLote 
						If CX6->(dbSeek(cFilCX6 + oModel:GetValue("CPHMASTER","CPH_NUMATA") + oModCPY:GetValue('CPY_LOTE')))
							RecLock("CX6", .F.)
							CX6->CX6_SLDLOT -= oModRes:GetValue("CPE_QUANT") * oModCPY:GetValue('CPY_VALATU')
							CX6->(msUnlock())
						EndIf
					EndIf
					If !Empty(oModRes:GetValue("CPE_NUMSC")) .And. !Empty(oModRes:GetValue("CPE_ITEMSC"))
						If CX3->(MsSeek(cFilCX3+oModel:GetValue("CPHMASTER","CPH_NUMATA")+oModRes:GetValue("CPE_CODPRO")+oModRes:GetValue("CPE_NUMSC") + oModRes:GetValue("CPE_ITEMSC")))
							RecLock("CX3",.F.)
							CX3->CX3_SALDO -= oModRes:GetValue("CPE_QUANT")
							CX3->(MsUnlock())
						EndIf
					EndIf									
				EndIf
			EndIf				
		Next nY
	Next nX
	
	//Saldo zerado altera o status da ata para finalizada
	GCPSLDAta(oModOrg)		
	
EndIf
				
If lRet
	If !IsBlind() .And. !Empty(aDadosNG)
		cTexto := STR0034
		For nX := 1 To Len(aDadosNg)
			If nX > 1
				cTexto += ","
			EndIf
			cTexto += " "+aDadosNg[nX]
		Next nX
		cTexto += CRLF+CRLF+STR0035
		MsgAlert(cTexto)
	EndIf
	FwFormCommit(oModel)
EndIf	

RestArea(aAreaCX3)	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A320Legend()
Funcao para mostrar legendas.	

@author alexandre.gimenez	
@since 16/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A320Legend()
Local aLeg             := {}

aAdd(aLeg,{"BR_AZUL"     	,STR0014})	//"Participante"
aAdd(aLeg,{"BR_AMARELO"  	,STR0015 })//"Carona"
aAdd(aLeg,{"BR_VERDE"    	,STR0018 })//"Gerenciador"


BrwLegenda(STR0016,STR0017,aLeg) //"Legenda"//"Orgao"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A320GetQtC()
Funcao que retorna a quantidade do produto para os itens que gerarão contrato.	

@author alexandre.gimenez	
@since 16/12/2013
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A320GetQtC(oModel, cCodPro)
Local oModCPE		:= oModel:GetModel("CPEDETAIL")
Local oModCPH		:= oModel:GetModel("CPHMASTER")
Local oModCPI		:= oModel:GetModel("CPIDETAIL")
Local lIncManual	:= .F. 
Local nI			:= 0
Local nI2			:= 0
Local nQuant		:= 0
Local aSaveLines	:= FWSaveRows()

CO1->(DbSetOrder(1))	
lIncManual := !CO1->(DbSeek(xFilial("CO1")+oModCPH:GetValue("CPH_CODEDT")))

For nI := 1 To oModCPI:Length()
	oModCPI:GoLine(nI)
	If oModCPH:GetValue("CPH_CODORG") == oModCPI:GetValue("CPI_CODORG") .Or. lIncManual //-- Somente orgao Gerenciador		
		For nI2 := 1 To oModCPE:Length()
			oModCPE:GoLine(nI2)

			If oModCPE:GetValue('CPE_TIPDOC') == '1' .And. oModCPE:GetValue('CPE_OK') .And. oModCPE:GetValue('CPE_CODPRO') == cCodPro    
				nQuant := nQuant + oModCPE:GetValue('CPE_QUANT')
			EndIf		 
		Next nI2
	EndIf		
Next nI
		 

FWRestRows( aSaveLines )
Return nQuant


//-------------------------------------------------------------------
/*/{Protheus.doc} A320CPEPVl()
Pre-Valid do modelo que valida se o fornecedor possui Cond de Pagamento cadastrada	

@author Matheus Lando Raimundo	
@since 18/03/2015
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A320CPEPVl(oModel, nLinha, cAcao,cCampo,xNewValue)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aSaveLines	:= FWSaveRows()
Local oMdl			:= FwModelActive() 
Local oCPHMaster	:= oMdl:GetModel('CPHMASTER')
Local oCPEDetail	:= oMdl:GetModel('CPEDETAIL')
Local oCPZDetail	:= oMdl:GetModel('CPZDETAIL')
Local nX			:= 1
Local cCond			:= ''

If cCampo  == 'CPE_OK' .And. cAcao == 'SETVALUE' .And. xNewValue .And. oCPEDetail:GetValue('CPE_TIPDOC')  == '2'
	//Verifica condição de pagamento do modelo e depois do Fornecedor
	SA2->(dbSetOrder(1))
	For nX := 1 To oCPZDetail:Length()
		oCPZDetail:Goline(nX)
		If oCPZDetail:GetValue('CPZ_STATUS') == '5'
			cCond := oCPZDetail:GetValue('CPZ_CONDPG')
			Exit
		EndIf
	Next nX
	If Empty(cCond) .And. SA2->( dbSeek( xFilial("SA2")+oCPHMaster:GetValue('CPH_CODIGO')+oCPHMaster:GetValue('CPH_LOJA')) ) .And. Empty(SA2->A2_COND)						
		lRet:= .F.		
		Help('',1,'A320NOCPAGTO',,STR0010+AllTrim(oCPHMaster:GetValue('CPH_CODIGO'))+STR0011+AllTrim(oCPHMaster:GetValue('CPH_LOJA'))+ STR0012,4,1)//'O fornecedor:'//' Loja:'//' não possui condição de pagamento cadastrada. Por Favor cadastre para gerar pedido de compra.'
	EndIf
EndIf

RestArea( aArea )
FWRestRows( aSaveLines )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A320GerPed()
Rotina de geração de pedido da Ata	

@author Matheus Lando Raimundo	
@since 18/03/2015
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A320GerPed(aQuebra,aRecNoCPE,cFilOrig,cFilEnt)
Local lRet 		:= .T.
Local oModel	:= FwModelActive()
Local oModAta	:= oModel:GetModel("CPHMASTER")
Local oModOrg	:= oModel:GetModel("CPIDETAIL")
Local oModRes	:= oModel:GetModel("CPEDETAIL")
Local oModCPY	:= oModel:GetModel("CPYDETAIL")
Local oModCPZ	:= oModel:GetModel("CPZDETAIL")
Local oModel300 := Nil
Local aCTBEnt	:= CTBEntArr()
Local aPedidos	:= {}
Local aDados	:= {}
Local aDadosFE	:= {}
local aOrgao	:= {}
Local aCab		:= {}
Local aItens	:= {}
Local aGerPed	:= {}
Local aAtaNe	:= {}
Local aAreaCX0	:= {}
Local cOrgao	:= ""
Local cQuebra	:= ""
Local cC7Item	:= ""
Local cC7Num	:= ""
Local nX		:= 0
Local nY		:= 0
Local nXP		:= 0
Local nYP		:= 0
Local nC		:= 0	
Local nPos		:= 0
Local lGerNE	:= .T. 
Local lAta 		:= .F.
Local lNewItem	:= .T.
Local lNotEmp	:= SuperGetMV("MV_NOTAEMP",.F.,.F.)
Local lExEmp	:= .T.
Local lAtaMan	:= .F.

Default cFilOrig 		:= cFilAnt
Default cFilEnt 		:= cFilAnt  

For nX := 1 to Len(aQuebra)
	If cOrgao != aQuebra[nX,1]
		cOrgao := aQuebra[nX,1]
		aAdd(aOrgao,cOrgao)
	EndIf
next nX

If Empty(oModAta:GetValue("CPH_ETAPA"))
	lAtaMan := .T.
EndIf

aDados := GCPXPedCV(.T.,aRecNoCPE,cFilOrig,cFilEnt)
//aDados
//-- 1. Codigo do fornecedor
//-- 2. Loja do fornecedor
//-- 3. Codigo do produto 
//-- 4. Quantidade
//-- 5. Preço unitario
//-- 6. Codigo do  processo licitatório
//-- 7. Numero do processo
//-- 8. Centro de custo
//-- 9. Conta contabil
//-- 10. Item de conta
//-- 11. Classe de valor
//-- 12. Solicitacao
//-- 13. Item
//-- 14. Filial de Entrega
//-- 15. Lote
//-- 16. Código da Nota de Empenho
//-- 17. Item da Nota de Empenho
//-- 18. Possui Nota de Empenho	 
//-- 19. Condição de Pagamento
//-- 20 em diante - entidades contábeis

aAreaCX0 := CX0->(GetArea())
	
//-- Monta Estrtura de pedidos para cada Orgao
For nX := 1 to Len(aOrgao)
	aPedidos := {} 
	cQuebra := ""
	
	For nY := 1 to Len(aDados)
		//-- Busca se dados de pedido é necessario para orgao 
		If ( nPos := aScan( aQuebra,{|x| x[1] == aOrgao[nX] .and. x[2] = aDados[nY,3]  }) ) > 0 
			aAdd(aPedidos,aDados[nY]) 										
		EndIf
	Next nY
	
	//Rotina automatica dos pedidos
	For nXP := 1 to Len(aPedidos)
		aAtaNe := {aPedidos[nXP,3],aPedidos[nXP,4]}
		If !aDados[nXP,18]
			
			CX0->(dbSetOrder(2))
			lExEmp := CX0->(MsSeek(xFilial('CX0')+oModAta:GetValue('CPH_CODEDT')+oModAta:GetValue('CPH_NUMPRO')+oModAta:GetValue('CPH_NUMATA')))
			
			If lNotEmp .And. !lExEmp
				If lAtaMan	
					lGerNE := G320NEMANU(oModel)
					
					If !lGerNE
						Help("",1,"A320GERNE") //-- Nota de empenho não gerada, não será possivel a geração do pedido!		
					EndIf
				Else
					lGerNE := GCPXNEMP(,oModAta:GetValue('CPH_CODEDT'),oModAta:GetValue('CPH_NUMPRO'),,,,cFilOrig,oModAta:GetValue('CPH_NUMATA'),.T.,aAtaNe,.T.)
				EndIf
			EndIf
			
			If lGerNE 
				If cQuebra != aPedidos[nXP,1]+aPedidos[nXP,2]
					cQuebra := aPedidos[nXP,1]+aPedidos[nXP,2]
					//-- Preenche cabecalho
					cC7Item := StrZero(0,TamSX3("C7_ITEM")[1])
					cC7Num	 := CriaVar("C7_NUM",.T.)
					aCab   	:= {}
					aItens	:= {}
					AAdd(aCab,{"C7_NUM"	,    cC7Num			,NIL})
					AAdd(aCab,{"C7_EMISSAO", dDataBase			,NIL})
					AAdd(aCab,{"C7_FORNECE", aPedidos[nXP,1]	,NIL})
					AAdd(aCab,{"C7_LOJA"   , aPedidos[nXP,2]	,NIL})
					AAdd(aCab,{"C7_CONTATO", " "				,NIL})
					AAdd(aCab,{"C7_COND"   , aPedidos[nXP,19] ,NIL})
					AAdd(aCab,{"C7_FILENT" , cFilAnt    		,NIL})	
				EndIf
				cC7Item := Soma1(cC7Item)
				//-- Preenche itens
				aAdd(aItens,{})
				aAdd(aTail(aItens), {"C7_ITEM"		, cC7Item  			, Nil} ) 
				aAdd(aTail(aItens), {"C7_PRODUTO"	, aPedidos[nXP,3]		, Nil} ) 
				aAdd(aTail(aItens), {"C7_NUMSC"		, aPedidos[nXP,12]	, NIL} )
				aAdd(aTail(aItens), {"C7_ITEMSC"	, aPedidos[nXP,13]	, NIL} )
				aAdd(aTail(aItens), {"C7_QUANT"		, aPedidos[nXP,4]		, Nil} ) 
				aAdd(aTail(aItens), {"C7_PRECO"		, aPedidos[nXP,5]		, Nil} ) 
				aAdd(aTail(aItens), {"C7_OBS"		, aOrgao[nX]			, Nil} ) 
				aAdd(aTail(aItens), {"C7_CODED"		, aPedidos[nXP,6]		, Nil} )	
				aAdd(aTail(aItens), {"C7_NUMPR" 	, aPedidos[nXP,7]		, Nil} ) 
				aAdd(aTail(aItens), {"C7_CC"		, aPedidos[nXP,8]		, Nil} )
				aAdd(aTail(aItens), {"C7_CONTA"		, aPedidos[nXP,9]		, Nil} )
				aAdd(aTail(aItens), {"C7_ITEMCTA"	, aPedidos[nXP,10]	, Nil} )
				aAdd(aTail(aItens), {"C7_CLVL"		, aPedidos[nXP,11]	, Nil} )
				aAdd(aTail(aItens), {"C7_GCPLT"		, aPedidos[nXP,15]	, Nil} )
		
				//-- Caso tenha sido gerado a NE passar o valor novo para os campos abaixo
				If lExEmp
					CX1->(dbSetOrder(1))
					If CX1->(MsSeek(xFilial('CX1')+CX1->CX1_CODNE+CX1->CX1_CODPRO))
						aAdd(aTail(aItens), {"C7_CODNE"	, 	CX1->CX1_CODNE	, Nil} )
						aAdd(aTail(aItens), {"C7_ITEMNE", 	CX1->CX1_ITEM		, Nil} )
						aAdd(aTail(aItens), {"C7_FILEDT", 	CX0->CX0_FILENT	, Nil} )
					EndIf
				EndIf	
				For nYP := 1 To Len(aCTBEnt)
					If Len(aDados[nXP])>19 .And. SC7->(FieldPos("C7_EC" +aCTBEnt[nYP] +"CR")) > 0 
						aAdd(aTail(aItens),{"C7_EC"+aCTBEnt[nYP]+"CR", aPedidos[nXP,18 + (nYP * 2)],Nil})
						aAdd(aTail(aItens),{"C7_EC"+aCTBEnt[nYP]+"DB", aPedidos[nXP,19 + (nYP * 2)],Nil})   
					EndIf
				Next nYP
					
				//-- Valida se quebra no proximo e gera pedidos
				If nXP == Len(aPedidos) .Or. cQuebra != aPedidos[nXP+1,1]+aPedidos[nXP+1,2]
					lMsErroAuto := .F.
					lMsHelpAuto := .T.
					MsgRun(STR0013+Alltrim(aOrgao[nX]),, {||MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aCab,aItens,3)}) //"Gerando Pedido de Compra"//"Gerando Pedido de Compra para o Orgao: "
					
					If lMsErroAuto
						
						MostraErro()
						lRet := .F.
						Exit
						
					Else			

						For nYP := 1 to oModOrg:Length()
							
							oModOrg:Goline(nYP)
							
							For nC := 1 To oModRes:Length()
								
								oModRes:GoLine(nC)
								
								If oModRes:GetValue('CPE_TIPDOC') == '2' .And. oModRes:GetValue('CPE_OK') 										
																		
									If GCP301Lote( oModel:GetValue( "CPHMASTER" , "CPH_NUMATA" ) )
										lCond := AllTrim(oModCPY:GetValue('CPY_CODPRO')) == AllTrim(oModOrg:GetValue( "CPI_CODPRO" )) .And. AllTrim(oModCPY:GetValue('CPY_LOTE')) == AllTrim(oModOrg:GetValue( "CPI_LOTE" ))
									Else
										lCond := AllTrim(oModCPY:GetValue('CPY_CODPRO')) == AllTrim(oModOrg:GetValue( "CPI_CODPRO" ))
									EndIf			
								
									If lCond .And. oModCPZ:GetValue('CPZ_STATUS') == '5' .And. (AllTrim(oModCPZ:GetValue('CPZ_CODIGO')) == AllTrim(aPedidos[nXP,1]) .And. AllTrim(oModCPZ:GetValue('CPZ_LOJA')) == AllTrim(aPedidos[nXP,2]))
										lRet := oModRes:LoadValue("CPE_DOCMOV",cC7Num)	
									EndIf				
												
								EndIf
											
							Next nC
							
						Next nYP 
						
					EndIf
				EndIf
			Else
				lRet := .F.
			EndIf
		EndIf
	Next nXP
	
	If !lRet
		Exit
	EndIf
Next nX		

CX0->(RestArea(aAreaCX0))

Return lRet

/*****************/

Function GCP320Vld(oModel)
Local oCPHMaster		:= oModel:GetModel("CPHMASTER")
Local oCPIDetail		:= oModel:GetModel("CPIDETAIL")
Local oCPEDetail		:= oModel:GetModel("CPEDETAIL")
Local oCPYDetail		:= oModel:GetModel("CPYDETAIL")
Local oCPZDetail		:= oModel:GetModel("CPZDETAIL")
Local lRet				:= .T.
Local nI				:= 0
Local nJ				:= 0
Local nk				:= 0
Local lGerCent		:= SuperGetMV("MV_GCPFIAP", .T., "C") == "C"
Local lCentral		:= .T.
Local cFilEnt			:= ""
Local aFilsEnt		:= {}
Local cAviso			:= ""

SB1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SAH->(dbSetOrder(1))
SE4->(dbSetOrder(1))


For nI := 1 To oCPIDetail:Length()
 	oCPIDetail:GoLine(nI)
	lCentral :=  lGerCent .Or. Empty(oCPIDetail:GetValue("CPI_FILENT")) .Or. oCPIDetail:GetValue("CPI_FILENT") == cFilAnt
	
	For nJ := 1 To oCPEDetail:Length()
		oCPEDetail:GoLine(nJ)
		If oCPEDetail:GetValue('CPE_OK')			
			If lCentral
				//-- Validação para quando gerar contrato
				If oCPEDetail:GetValue('CPE_TIPDOC') == "1"
					cTpPla := SuperGetMV("MV_TPPLA", .T., "")
					If Empty(cTpPla)
						MtAaddLog(aFilsEnt, A320GetFil("CNL"), STR0019 ) // "Filial: " +" - Tipo de Planilha: "											
					Else
						lRet := CNL->( dbSeek(xFilial("CNL")+cTpPla))
						If !lRet
							MtAaddLog(aFilsEnt,A320GetFil("CNL"), STR0020 + " "   + cTpPla ) // "Filial: " +" - Tipo de Planilha: "
						EndIf						
					EndIf  
				Else
					//-- Validação para quando gerar pedido
					If ! A320CPEPVl(oModel, 0, 'SETVALUE','CPE_OK',.T.)										
						MtAaddLog(aFilsEnt, A320GetFil("SA2"), STR0021 + " " + AllTrim(oCPHMaster:GetValue("CPH_CODIGO")) + STR0011 + " " + AllTrim(oCPHMaster:GetValue("CPH_LOJA")))
					EndIf
					
				EndIf
			
			Else			
				cFilEnt := oCPIDetail:GetValue("CPI_FILENT") 						
				
				//-- Validação para quando gerar contrato
				If oCPEDetail:GetValue('CPE_TIPDOC') == "1"
					//-- Pesquisa tipo de planilha na filial de entrega
					cTpPla := SuperGetMV("MV_TPPLA", .T., "",cFilEnt)
					If Empty(cTpPla)
						MtAaddLog(aFilsEnt,A320GetFil("CNL",cFilEnt), STR0019 ) // "Filial: " +" - Tipo de Planilha: "											
					Else
						lRet := CNL->( dbSeek(xFilial("CNL",cFilEnt)+cTpPla))
						If !lRet
							MtAaddLog(aFilsEnt, A320GetFil("CNL",cFilEnt) , STR0020 + " "   + cTpPla ) // "Filial: " +" - Tipo de Planilha: "
						EndIf						
					EndIf
				EndIf
				//-- Pesquisa Fornecedor na filial de entrega
				lRet := SA2->( dbSeek(xFilial("SA2",cFilEnt)+oCPHMaster:GetValue("CPH_CODIGO")+oCPHMaster:GetValue("CPH_LOJA")) )	
				cCondPag := SA2->A2_COND			
				If !lRet
					MtAaddLog(aFilsEnt,A320GetFil("SA2",cFilEnt), STR0022 + " " + AllTrim(oCPHMaster:GetValue("CPH_CODIGO")) + STR0011 + " " + AllTrim(oCPHMaster:GetValue("CPH_LOJA")))	 //"Filial: " + " - Fornecedor: "+ "Loja: "
				EndIf						
				
				//-- Validação para quando gerar pedido
				If oCPEDetail:GetValue('CPE_TIPDOC') == "2"														
					//-- Pesquisa Condição de pagamento				
					If Empty(cCondPag)
						MtAaddLog(aFilsEnt, A320GetFil("SA2",cFilEnt), STR0021 + " " + AllTrim(oCPHMaster:GetValue("CPH_CODIGO")) + STR0011 + " " + AllTrim(oCPHMaster:GetValue("CPH_LOJA")))
					Else
						lRet := SE4->( dbSeek(xFilial("SE4",cFilEnt)+cCondPag) )
						If !lRet
							MtAaddLog(aFilsEnt, A320GetFil("SE4",cFilEnt), STR0023 + " " + cCondPag) 			 	
						EndIf	
					EndIf
				EndIf
				//-- Pesquisa Produto na filial de entrega				 												
				lRet := SB1->( dbSeek(xFilial("SB1", cFilEnt)+oCPEDetail:GetValue('CPE_CODPRO')) )
	
				If !lRet
					MtAaddLog(aFilsEnt,A320GetFil("SB1",cFilEnt), STR0024 + " " + oCPEDetail:GetValue('CPE_CODPRO'))  //"Filial: " +" - Produto: "				 	
				EndIf
													
				//-- Pesquisa Unidade de Medida na filial de entrega
				SB1->(dbSeek(xFilial("SB1")+oCPEDetail:GetValue('CPE_CODPRO')))
				cUndMed := SB1->B1_UM
				
				lRet := SAH->( dbSeek(xFilial("SAH",cFilEnt)+cUndMed) )
				If !lRet
					MtAaddLog(aFilsEnt,A320GetFil("SAH",cFilEnt), STR0025 + " " + cUndMed)	 //"Filial: " +" - Und. Medida: "			 	
				EndIf																			
			EndIf
		EndIf
	Next nJ
Next nI

lRet := (Len(aFilsEnt) == 0)

//-- Monta mensagem de aviso


ASORT(aFilsEnt,,, { | x,y | x[1] > y[1] } )
If !lRet
	For nI := 1 to Len(aFilsEnt)				  		
		cAviso += aFilsEnt[nI,1] + CRLF
			
		For nJ := 1 To Len(aFilsEnt[nI,2])
			cAviso += " - " + aFilsEnt[nI,2,nJ] + CRLF								
		Next nJ							
		If Len(aFilsEnt) > 1 
			cAviso += CRLF 
		EndIf
	Next nI
	Aviso(STR0026, cAviso, { "Ok" }, 3)
EndIf	


If lRet .And. SuperGetMV("MV_GCPDSLD", .F., .F.)
	For nI := 1 To oCPIDetail:Length()
 		oCPIDetail:GoLine(nI)
 		If !lRet
 			Exit
 		EndIf
 		
 		nSaldo := A320GetSld(oCPIDetail:GetValue('CPI_CODPRO'))
 		nPos := aScan(aSldPrds, {|x| x[1] == oCPIDetail:GetValue('CPI_CODPRO') })
		
		If nSaldo <> aSldPrds[nPos,2]
			Help("",1,STR0033,, STR0027 + " " + Alltrim(oCPIDetail:GetValue('CPI_CODPRO')) + ' ' + STR0028 + CRLF + CRLF;
				+ " " + STR0029 + "     " + Transform(aSldPrds[nPos,2],"@E 999,999,999.99") + CRLF;
				+ " " + SRE0030 + " " + Transform(nSaldo,"@E 999,999,999.99"),4,1)	
			lRet := .F.				
		EndIf
	Next nI
	

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MtAaddLog()
Função que popula o array de logs	

@author Matheus Lando Raimundo	
@since 04/07/2015
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function MtAaddLog(aArray,cFil,cValor)
Local nLinha := 0

nLinha := Ascan(aArray, {|x| x[1] == cFil })

If nLinha > 0
	If Ascan(aArray[nLinha,2], cValor) == 0	
		Aadd(aArray[nLinha,2],cValor)
	EndIf 
Else
	Aadd(aArray,{cFil,{}})
	Aadd(aArray[Len(aArray),2],cValor)
EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} A320GetFil()
Função que retorna a filial com a descrição 	

@author Matheus Lando Raimundo	
@since 04/07/2015
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function A320GetFil(cTab,cFil)
Local cRet := ""

Default cFil := cFilAnt

If Len(AllTrim(xFilial(cTab,cFil))) >  0
	cRet := STR0031 + " " + xFilial(cTab,cFil) + ' - ' + FWFilialName(cEmpAnt,cFil)
Else
	cRet := STR0032 + " "		
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP320Act()
Activate do modelo 	

@author Matheus Lando Raimundo	
@since 23/02/2016
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function GCP320Act(oModel)
Local nI	:= 0
Local oCPIDetail := oModel:GetModel('CPIDETAIL')
Local nPos := 0
Local aSaveLines	:= FWSaveRows()

aSldPrds := {} 
 
For nI := 1 To oCPIDetail:Length()
	oCPIDetail:GoLine(nI)
	If oCPIDetail:GetValue('CPI_TIPO') == '1'	
		nPos := aScan(aSldPrds, {|x| x[1] == oCPIDetail:GetValue('CPI_CODPRO') })
		If nPos > 0
			aSldPrds[nPos,2] += oCPIDetail:GetValue('CPI_SALDO') 		
		Else	
			Aadd(aSldPrds, {oCPIDetail:GetValue('CPI_CODPRO'), oCPIDetail:GetValue('CPI_SALDO') })
		EndIf		 		
	EndIf
Next nI 

FWRestRows( aSaveLines )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A320WhnSld()
When do campo CPI_SALDO
 	
@author Matheus Lando Raimundo	
@since 23/02/2016
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------

Function A320WhnSld()
Local lRet := .F.
Local oModel	:= FwModelActive()
Local oCPIDetail := oModel:GetModel('CPIDETAIL')

lRet := oCPIDetail:GetValue('CPI_TIPO') == '1' 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A320GetSld()
Função que retorna o saldo total dos produtos, desconsidendo os caronas da Ata 	 

@author Matheus Lando Raimundo	
@since 23/02/2016
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------

Function A320GetSld(cCodProd,nLinha)
Local oModel	   := FwModelActive()
Local oCPIDetail := oModel:GetModel('CPIDETAIL')
Local nSaldo		:= 0
Local nI			:= 1 
Local aSaveLines	:= FWSaveRows()
Default nLinha := 0

For nI := 1 To oCPIDetail:Length()
	oCPIDetail:GoLine(nI)
	If oCPIDetail:GetValue('CPI_TIPO') == '1' .And. oCPIDetail:GetValue('CPI_CODPRO') == cCodProd;
		 .And. oCPIDetail:GetLine() <> nLinha  		
		nSaldo += oCPIDetail:GetValue('CPI_SALDO') 		
	EndIf
Next nI 

FWRestRows( aSaveLines )
Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} G320NEMANU()
Função que faz a geração da nota de empenho para atas manuais

@author Filipe Gonçalves	
@since 28/03/2017 -> Meu aniversário
@version 1.0
@return Nil
/*/
//--------------------------------------------------------------------
Function G320NEMANU(oModel)
Local oModCPH	:= oModel:GetModel("CPHMASTER")
Local oModCPY	:= oModel:GetModel("CPYDETAIL")
Local oModCPI	:= oModel:GetModel("CPIDETAIL")
Local aProd		:= {} //{CODPROD,QUANT}
Local aAta		:= {} //{CODEDT,NUMATA,NUMPRO,{aProd}}
Local aDadosAta	:= {}
Local cCodNe	:= ""
Local cCodPro	:= ""
Local cFilEnt	:= ""
Local cNumSC 	:= ""
Local cItemSC	:= ""
Local nPos		:= 0
Local nQuant	:= 0
Local nGravou	:= 0
Local nPreco	:= 0
Local nX		:= 0
Local nY		:= 0
Local lRet		:= .F.
		
For nX := 1 to oModCPY:Length()
	oModCPY:GoLine(nX)
	cCodPro := oModCPY:GetValue('CPY_CODPRO')
	nQuant := oModel:GetModel("CPEDETAIL"):GetValue("CPE_QUANT")
	CX3->(DbSetOrder(1))
	If CX3->(DbSeek(oModCPH:GetValue('CPH_FILIAL')+oModCPH:GetValue('CPH_NUMATA')+cCodPro))
		//-- Pega o preço do produto
		CPZ->(DbSetOrder(1))							
		If CPZ->(DbSeek(xFilial("CPZ")+oModCPH:GetValue('CPH_NUMATA')+cCodPro))
			While CPZ->(!EOF()) .AND. CPZ->(CPZ_NUMATA) == oModCPH:GetValue('CPH_NUMATA') .AND. Alltrim(CPZ->(CPZ_CODPRO)) == Alltrim(cCodPro)
				If CPZ->CPZ_STATUS == "5"
					nPreco := CPZ->CPZ_VLUNIT
					Exit 
				EndIf																					
				CPZ->(dbSkip())
			EndDo
		EndIf
		
		While CX3->(!EOF()) .AND. CX3->(CX3_NUMATA) == oModCPH:GetValue('CPH_NUMATA') .AND. CX3->(CX3_CODPRO) == cCodPro
			If !CX3->(CX3_EMPENH)
				cNumSC 	:= CX3->CX3_NUMSC
				cItemSC	:= CX3->CX3_ITEMSC
				cFilEnt	:= CX3->CX3_FILENT
				nPos := aScan( aProd, {|x| AllTrim(x[1]) == AllTrim(cCodPro)} )
				If  nPos == 0 					
					Aadd(aProd, {cCodPro, nQuant,0,cFilEnt,cNumSC,cItemSC} )
				Else
					aProd[nPos][2] := aProd[nPos][2] + nQuant
				EndIf
			EndIf					
			CX3->(dbSkip())
		EndDo
			
		For nPos := 1 To Len(aProd)
			If aProd[nPos,1] == cCodPro
				aProd[nPos][3] := aProd[nPos][2] * nPreco
			EndIf
		Next nI
	EndIf
Next nX
		
aSort(aProd)
If Len(aProd) > 0
	aAdd(aAta, oModCPH:GetValue('CPH_CODEDT'))
	aAdd(aAta, oModCPH:GetValue('CPH_NUMATA'))
	aAdd(aAta, oModCPH:GetValue('CPH_NUMPRO'))
	aAdd(aAta, aProd)
				
	Aadd(aDadosAta,oModCPH:GetValue('CPH_CODEDT'))
	Aadd(aDadosAta,oModCPH:GetValue('CPH_NUMPRO'))
	Aadd(aDadosAta,oModCPI:GetValue('CPI_CODORG'))
EndIf
	
nGravou := GCPXGeraNE(oModel,,oModCPH:GetValue('CPH_CODIGO'),oModCPH:GetValue('CPH_LOJA'),.T.,.F.,.T.,aAta,aDadosAta)
cCodNe	 := CX0->CX0_CODNE
			
If nGravou == 0
	lRet := .T.
	For nPos := 1 To Len(aProd)
		CX3->(DbSetOrder(1))
		If CX3->(DbSeek(oModCPH:GetValue('CPH_FILIAL')+oModCPH:GetValue('CPH_NUMATA')+aProd[nPos][1]))
			While CX3->(!EOF()) .AND. CX3->(CX3_NUMATA) == oModCPH:GetValue('CPH_NUMATA') .AND. Alltrim(CX3->(CX3_CODPRO)) == Alltrim(aProd[nPos][1])
				If !CX3->(CX3_EMPENH)
					RecLock("CX3",.F.)
						CX3->CX3_EMPENH := .T.
						CX3->CX3_CODNE := CX0->CX0_CODNE
						If A400GetIt(CX0->CX0_CODNE,(aProd[nPos][1]))
							CX3->CX3_ITEMNE := CX1->CX1_ITEM 	
						EndIf
					CX3->(MsUnlock())
				EndIf
				CX3->(dbSkip())
			EndDo
		EndIf
	Next
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A320VlCnsm()
Função que valida se o saldo a ser consumido (CPE_OK) pertence a filial logada quando existe filial amarrada ao órgão.

@author Leonardo Magalhães Barbosa	
@since 01/08/2018
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------

Function A320VlCnsm()

Local lRet 	  := .T.
Local cFilOrg := ""
Local cFilAtu := ""
Local cCodOrg := ""

cCodOrg := FwFldGet("CPI_CODORG")
cFilOrg := Posicione("CPA", 1, xFilial("CPA") + cCodOrg, "CPA_SISFIL")
cFilAtu	:= Substr(cNumEmp, Len(cEmpAnt)+1, Len(cFilAnt))

If !Empty(cFilOrg) .And. (cFilAtu <> cFilOrg)
	lRet := .F.
	Help(Nil, Nil, "A320VLCNSM", Nil, "A filial " + cFilAtu + " - " + AllTrim(FWFilialName(,cFilAtu)) + " não pode consumir saldo do órgão " + cCodOrg + " pois ele pertence a filial " + cFilOrg + " - " + AllTrim(FWFilialName(,cFilOrg)) + ".", 1, 0, Nil, Nil, Nil, Nil, Nil, {""})
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCPSLDAta()
Função que verifica o saldo da ata para finalizar a ata.

@param oModel, model do orgão da ata

@author janaina.jesus
@since 22/01/2019
@version 1.0
@return lRet
/*/
//--------------------------------------------------------------------
Function GCPSLDAta(oModOrg)
	Local nX         := 0
	Local nSaldo     := 0
	Local nQtdReserv := 0
	Local aArea      := GetArea()
	Local aSaveLines := FWSaveRows()
	Local cJust      := "Saldo da ata zerado. Ata finalizada."
	
	For nX := 1 to oModOrg:Length()
		oModOrg:Goline(nX)
		nSaldo += oModOrg:GetValue("CPI_SALDO")
		nQtdReserv += oModOrg:GetValue("CPI_QTDRES")
	Next nX
	
	If nSaldo == 0 .And. nQtdReserv == 0
		GCP300AtSt("6", cJust)
	EndIf
	
	RestArea(aArea)
	FWRestRows(aSaveLines)
Return
