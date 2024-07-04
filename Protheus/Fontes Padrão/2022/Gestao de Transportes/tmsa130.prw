#include "TMSA130.ch"   
#include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"                 

Static lTMA010His := ExistBlock("TMA010HIS")

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Programa   �  TMSA130   � Autor �        Nava        � Data � 18/12/01 ���
��������������������������������������������������������������������������͹��
���                 Configuracao da Tabela de Frete                        ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA130()                                                 ���
��������������������������������������������������������������������������͹��
��� Parametros � Nenhum                                                    ���
��������������������������������������������������������������������������͹��
��� Retorno    � NIL                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � Seleciona quais Folders vao existir para cada tabela de   ���
���            � de Frete                                                  ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
��� Mauro      �06/12/13�      � Ajustes para funcionamento do Mile        ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

FUNCTION TMSA130()
LOCAL aArea	  := GetArea()
Local oBrowse   := Nil
Private aRotina := MenuDef()


oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DTL")
oBrowse:SetDescription(STR0001) //"Configuracao da Tabela de Frete"
oBrowse:SetCacheView(.F.) //-- Desabilita Cache da View, pois gera colunas dinamicamente
oBrowse:Activate()

//��������������������������������������������������������������Ŀ
//�Restaura os dados de entrada                                  �
//����������������������������������������������������������������

RestArea( aArea )


RETURN NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ModelDef � Autor � Daniel Leme           � Data �29.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Modelo de dados                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oModel Objeto do Modelo                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ModelDef()

Local oModel	  := Nil
Local oStruCDTL := FwFormStruct( 1, "DTL") 
Local oStruIDVE := FwFormStruct( 1, "DVE")

// Validacoes dos Fields
Local bPreValid := Nil
Local bPosValid := { |oModel| PosVldMdl(oModel) }
Local bComValid := Nil
Local bCancel	  := Nil
Local aCpoCheck := {'DVE_CODPAS'}

// Validacoes da Grid
Local bLinePost	:= { |oModel| PosVldLine(oModel) }

Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local lAux,bWheAux 
Local lNoUpd := .F.

If !IsInCallStack("CFG600LMdl") .And. !IsInCallStack("FWMILEIMPORT") .And. !IsInCallStack("FWMILEEXPORT") .And. Type("Altera") != "U" .And. Altera
	If lTMA010His
		lAux := ExecBlock("TMA010HIS",.F.,.F.,{4,DTL->DTL_TABFRE,DTL->DTL_TIPTAB}) 
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf   
		lContHis := lAux
	EndIf   

	If lContHis .And. TMSA130Has(DTL->DTL_TABFRE,DTL->DTL_TIPTAB)
		lNoUpd := .T.
		
		bWheAux := oStruIDVE:GetProperty( "DVE_COMOBR" , MODEL_FIELD_WHEN)
		oStruCDTL:SetProperty( "*" , MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, '.F.' )) //-- N�o permite alterar
		oStruIDVE:SetProperty( "*" , MODEL_FIELD_WHEN,FWBuildFeature( STRUCT_FEATURE_WHEN, '.F.' )) //So permite alterar na GetDados o campo "Componente Obrigatorio?"
		oStruIDVE:SetProperty( "DVE_COMOBR" , MODEL_FIELD_WHEN,bWheAux) //So permite alterar na GetDados o campo "Componente Obrigatorio?"
	EndIf	 
EndIf	

oModel:= MpFormMOdel():New("TMSA130",  /*bPreValid*/ , bPosValid, /*bComValid*/ ,/*bCancel*/ )
oModel:SetDescription(STR0001) 		//"Configuracao da Tabela de Frete"

oModel:AddFields("MdFieldCDTL",Nil,oStruCDTL,/*prevalid*/,,/*bCarga*/)

oModel:AddGrid("MdGridIDVE", "MdFieldCDTL" /*cOwner*/, oStruIDVE , {|oModelGrid,nLine,cAction| PreVldMdl(oModelGrid,nLine,cAction)} /*bLinePre*/ , bLinePost , /*bPre*/ , /*bPost*/,  /*bLoad*/)
oModel:SetRelation( "MdGridIDVE", { { "DVE_FILIAL" , 'xFilial("DVE")'  }, { "DVE_TABFRE", "DTL_TABFRE" } , { "DVE_TIPTAB","DTL_TIPTAB"} }, DVE->( IndexKey( 1 ) ) )

oModel:GetModel( "MdGridIDVE" ):SetUniqueLine( aCpoCheck )
oModel:GetModel("MdGridIDVE"):SetUseOldGrid()

If lNoUpd
	oModel:GetModel( "MdGridIDVE" ):SetNoDeleteLine( .T. )
	oModel:GetModel( "MdGridIDVE" ):SetNoInsertLine( .T. )
EndIf

oModel:SetVldActivate( { | oModel | VldActiv( oModel ) } )

Return ( oModel ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ViewDef  � Autor � Daniel Leme           � Data �29.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Exibe browse de acordo com a estrutura                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ViewDef()

Local oModel 	:= FwLoadModel("TMSA130")
Local oView 	:= Nil

Local oStruCDTL 	:= FwFormStruct( 2, "DTL") 
Local oStruIDVE 	:= FwFormStruct( 2, "DVE") 

Local aOpc			:= {MODEL_OPERATION_VIEW,MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE}

Local aSomaButtons
Local nCntFor

oStruIDVE:RemoveField("DVE_COPPAS")
oStruIDVE:RemoveField("DVE_PERREA")
oStruIDVE:RemoveField("DVE_TABFRE")
oStruIDVE:RemoveField("DVE_TIPTAB")

oView := FwFormView():New()
oView:SetModel(oModel)

oView:AddField('VwFieldCDTL', oStruCDTL , 'MdFieldCDTL') 
oView:AddGrid( 'VwGridIDVE', oStruIDVE , 'MdGridIDVE')

oView:CreateHorizontalBox("SUPERIOR",30)
oView:CreateHorizontalBox("INFERIOR",70)              

oView:EnableTitleView('VwFieldCDTL')
oView:EnableTitleView('VwGridIDVE',STR0027) //"Itens da Conf. Tabela Frete"

oView:AddIncrementField( 'VwGridIDVE', 'DVE_ITEM' ) 

oView:SetOwnerView("VwFieldCDTL","SUPERIOR")
oView:SetOwnerView("VwGridIDVE","INFERIOR")

//-- Ponto de entrada para incluir botoes
If	ExistBlock('TM130BUT')
	For nCntFor := 1 To Len(aOpc)
		aSomaButtons:=ExecBlock('TM130BUT',.F.,.F.,{aOpc[nCntFor]})
		If	ValType(aSomaButtons) == 'A'
			AEval( aSomaButtons, { |x| oView:AddUserButton( x[3], x[1], x[2] ,NIL,NIL, {aOpc[nCntFor]}) } ) 			
		EndIf
	Next nCntFor
EndIf

Return(oView)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VldActiv � Autor � Daniel Leme           � Data �29.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o Ativa��o do Model                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function VldActiv(oModel)
Local lRet := .T.
Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local lAux

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	If lTMA010His
		lAux := ExecBlock("TMA010HIS",.F.,.F.,{5,DTL->DTL_TABFRE,DTL->DTL_TIPTAB}) 
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf   
		lContHis := lAux
	EndIf   

	If lContHis .And. TMSA130Has(DTL->DTL_TABFRE,DTL->DTL_TIPTAB)
		Help("", 1, "TMSA13002") //A Configuracao da Tabela de Frete Nao podera ser Excluida pois esta sendo utilizado por alguma Tabela de Frete ...
		lRet := .F.
	EndIf	 
EndIf	

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PosVldMdl� Autor � Daniel Leme           � Data �29.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o TOk                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function PosVldMdl(oModel)
Local lRet := .T.
Local lContHis  := GetMv("MV_CONTHIS",.F.,.T.) //-- Controla Historico da Tabela de Frete
Local lAux

If oModel:GetOperation() == MODEL_OPERATION_DELETE
	If lTMA010His
		lAux := ExecBlock("TMA010HIS",.F.,.F.,{oModel:GetOperation(),DTL->DTL_TABFRE,DTL->DTL_TIPTAB}) 
		If ValType(lAux) <> "L"
			lAux :=.T.
		EndIf   
		lContHis := lAux
	EndIf   

	If lContHis .And. TMSA130Has(DTL->DTL_TABFRE,DTL->DTL_TIPTAB)
		Help("", 1, "TMSA13002") //A Configuracao da Tabela de Frete Nao podera ser Excluida pois esta sendo utilizado por alguma Tabela de Frete ...
		lRet := .F.
	EndIf	 
EndIf	 

If lRet .And. ExistBlock("TMA130TOK")
	lRet:=ExecBlock("TMA130TOK",.F.,.F.)
	If ValType(lRet) # "L"
		lRet:=.T.
	EndIf
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PosVldLine� Autor � Daniel Leme           � Data �29.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o LOk                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Logico - Se a linha foi aceita                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function PosVldLine(oModel)
Local aArea   := GetArea()
Local lRet		:= .T.
Local aTemp	:= {}
Local nPos		:= 0
Local nI		:= 0

Private aHeader
Private aCols	

SaveInter()

n		:= oModel:GetLine() //Controle de numero da linha
aHeader:= oModel:aHeader
aCols	:= oModel:aCols
    
//-- Nao avalia linhas deletadas.
If	 !GDDeleted( n )
	
	For ni:= 1 to Len(Acols)
		IF !GDDeleted( nI )
			DT3->(DBSETORDER(1))
			DT3->(DbSeek(XFILIAL("DT3")+ GdFieldGet('DVE_CODPAS',ni)))
			
			nPos13 := aScan(aTemp,{|x| x[1] == "13" })
			nPos14 := aScan(aTemp,{|x| x[1] == "14" })
			nPos18 := aScan(aTemp,{|x| x[1] == "18" })
			
     		IF DT3->DT3_TIPFAI > "50" .And. M->DTL_CATTAB == "1"
     			Help( ,, 'HELP',, "Componente do tipo 'a pagar' n�o pode ser relacionado a uma tabela de frete do tipo 'a receber'." , 1, 0)
     			lRet := .F.
     		EndIf			

     		If lRet
	     		IF DT3->DT3_TIPFAI == "09" .AND. M->DTL_CATTAB == "2"
		       		Help("", 1, "TMSA13009") // N�o � permitido vincular componentes com o campo calcula sobre igual pra�a de ped�gio em tabela de frete do tipo a pagar.
	        		lRet := .F.        
	     		EndIF
				IF DT3->DT3_TIPFAI == "13"
					
					IF Len(aTemp) == 0
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIF nPos13 > 0 .and. nPos14 == 0 .and. nPos18 == 0 
						aTemp[nPos13,2] := nI
					ElseIF (nPos13 > 0 .and. nPos14 > 0) .or. (nPos13 == 0 .and. nPos14 > 0)
						IF aTemp[nPos14,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						Else
							IF nPos13 > 0
								aTemp[nPos13,2] := nI
							Else
								AAdd(aTemp,{DT3->DT3_TIPFAI, ni})		
							EndIF
						EndiF
					ElseIf (nPos13 > 0 .and. nPos18 > 0) .Or. (nPos13 == 0 .and. nPos18 > 0)
						If aTemp[nPos18,2] < nI
							Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						EndIf 
					Endif
					
				ElseIF DT3->DT3_TIPFAI == "14"
					
					IF Len(aTemp) == 0
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIF nPos14 > 0 .and. nPos13 == 0 .and. nPos18 == 0  
						aTemp[nPos14,2] := nI
					ElseIF (nPos14 > 0 .and. nPos13 > 0) .or. (nPos14 == 0 .and. nPos13 > 0)
						IF aTemp[nPos13,2] > nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						ElseIf nPos18 > 0
						 	If aTemp[nPos18,2] < nI
								Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
								lRet := .F.
								Exit
							EndIf 
						Else
							IF nPos14 > 0
								aTemp[nPos14,2] := nI
							Else
								AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
							EndIF
						EndiF
					ElseIf (nPos14 > 0 .and. nPos18 > 0) .Or. (nPos14 == 0 .and. nPos18 > 0)
						If aTemp[nPos18,2] < nI
							Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
							Exit
						EndIf
					Endif
				ElseIf DT3->DT3_TIPFAI == "18"
				 	If Len(aTemp) == 0
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIf nPos18 > 0 .and. nPos13 == 0  .or. nPos18 > 0 .and. nPos14 == 0
						aTemp[nPos18,2] := nI
					ElseIf (nPos18 > 0 .and. nPos13 > 0 ) .or. (nPos18 == 0 .and. nPos13 > 0 )
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					ElseIf (nPos18 > 0 .and. nPos14 > 0 ) .or. (nPos18 == 0 .and. nPos14 > 0 )
						AAdd(aTemp,{DT3->DT3_TIPFAI, ni})
					EndIf
				ElseIf Len(aTemp) > 0 
					
					IF nPos13 > 0 
						IF aTemp[nPos13,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
						EndiF
					EndIF
					
					IF nPos14 > 0 
						IF aTemp[nPos14,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
						EndiF
					EndIF
				
					IF nPos18 > 0 
						IF aTemp[nPos18,2] < nI
						   Help("", 1, "TMSA13008") //Este componente nao pode ser configurado nesta posicao. Os componentes do tipo 13, 14 e 18 devem ser os ultimos componentes configurados, respectimante, nesta ordem.
							lRet := .F.
						EndiF
					EndIF
				EndIF
			EndIf
		
			If DVE->(ColumnPos("DVE_RATEIO")) > 0 .And. lRet 
				If GdFieldGet('DVE_RATEIO',ni) == StrZero(1,Len(DVE->DVE_RATEIO))  //Sim
					If GdFieldGet('DVE_COMOBR',ni) == StrZero(1,Len(DVE->DVE_COMOBR))  .And. GdFieldGet('DVE_DIZIMA',ni) <> StrZero(1,Len(DVE->DVE_DIZIMA))   //Componente Obrigatorio e Dizima igual a Nao 
						Help("", 1, "TMSA13010",,' ' + STR0028 + DT3->DT3_CODPAS  + ' / ' + DT3->DT3_DESCRI ,5,1 ) 	//Componentes 'Obrigatorio' que utilizam Rateio, devem ser configurados como 'Calcula Dizima' igual a SIM.
						lRet:= .F.
						Exit
					EndIf
					
				
				    If (DT3->DT3_TXADIC == '1' .Or.; 
				    	DT3->DT3_TIPFAI == StrZero(13, Len(DT3->DT3_TIPFAI)) .Or.;
					 	DT3->DT3_TIPFAI == StrZero(14, Len(DT3->DT3_TIPFAI)) .Or.;
					 	DT3->DT3_TIPFAI == StrZero(15, Len(DT3->DT3_TIPFAI)) .Or.;
						DT3->DT3_TIPFAI == StrZero(16, Len(DT3->DT3_TIPFAI)) .Or.;
					 	DT3->DT3_TIPFAI == StrZero(18, Len(DT3->DT3_TIPFAI)))
     					Help("", 1, "TMSA13012",,' ' + STR0028 + DT3->DT3_CODPAS  + ' / ' + DT3->DT3_DESCRI ,5,1 ) 	//O componente nao pode ser configurado como Rateio igual a Sim.   //13012 
						lRet:= .F.
						Exit
				    EndIf
				    
				Else
					If GdFieldGet('DVE_DIZIMA',ni) == StrZero(1,Len(DVE->DVE_DIZIMA))
						Help("", 1, "TMSA13011",,' ' + STR0028 + DT3->DT3_CODPAS  + ' / ' + DT3->DT3_DESCRI ,5,1 )	 	//O campo 'Calcula Dizima' deve ser configurado como 'SIM' somente para componentes que utilizam Rateio. 	
						lRet:= .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIF
	Next NI
	
EndIf

RestInter()
RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TMSA130Has� Autor � Daniel Leme           � Data �29.08.2013���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se h� movimenta��o com a configura��o da tabela   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � oView do objeto oView                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function TMSA130Has(cTabFre,cTipTab)
Local lExistDYA := AliasInDic('DYA')
Local lExistTab := .F.
Local aAreas := {	DT0->(GetArea()),;
					DTF->(GetArea()),;
					DUX->(GetArea())}

If lExistDYA
	aAdd(aAreas,DYA->(GetArea()))
EndIf
aAdd(aAreas,GetArea())

DT0->(dbSetOrder(1))              
DTF->(dbSetOrder(1))
DUX->(dbSetOrder(3))	    
If lExistDYA
	DYA->(dbSetOrder(1))
EndIf 

If DT0->( MsSeek( xFilial( "DT0" ) + cTabFre + cTipTab ) )   
	lExistTab := .T.
ElseIf DTF->( MsSeek( xFilial( "DTF" ) + cTabFre + cTipTab ) )
	lExistTab := .T.		
ElseIf DUX->( MsSeek( xFilial( "DUX" ) + cTabFre + cTipTab ) )
	lExistTab := .T.		
ElseIf lExistDYA .And. DYA->( MsSeek( xFilial( "DYA" ) + cTabFre + cTipTab ) )
	lExistTab := .T.		
EndIf				

aEval(aAreas,{|xArea| RestArea(xArea) })       

Return lExistTab

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA130Vld � Autor �Patricia A. Salomao � Data � 20/02/2006 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao dos campos                                        ��� 
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSA130Vld()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TMSA130                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA130Vld()
Local cCampo  := ReadVar()
Local lRet    := .T.          
Local nX      := 0

Local oModel
Local aSaveLines

If 'DTL_CATTAB' $ cCampo
   If M->DTL_CATTAB == StrZero(1,Len(DTL->DTL_CATTAB)) //-- Categoria da Tabela : Frete a Receber
		oModel 		  := FwModelActive()
		aSaveLines  := FWSaveRows()
		For nX := 1 To oModel:GetModel("MdGridIDVE"):Length()
			oModel:GetModel("MdGridIDVE"):SetLine(nX)
			oModel:SetValue("MdGridIDVE","DVE_BASIMP",PadR("1",Len(DVE->DVE_BASIMP)))  
		Next
		FWRestRows( aSaveLines )
	EndIf	
EndIf	
Return lRet 


/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
��� Funcao     �  TMSA130COP� Autor � Rafael M. Quadrotti� Data � 18/12/01 ���
��������������������������������������������������������������������������͹��
���                 Copia Configuracao da Tabela de Frete                  ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA130COP()                                              ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			         ���
���         01 � cAlias - Alias do arquivo                                 ���
���         02 � nReg   - Registro do Arquivo                              ���
���         03 � nOpcx  - Opcao da MBrowse                                 ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T.                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario � Efetua a copia das Configuracoes das Tabelas  com base    ���
���            � em Configuracoes ja existentes.                           ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/03�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function TMSA130COP(cAlias,nReg,nOpcx) 

//�����������������������������Ŀ
//�Objetos da janela            �
//�������������������������������
Local oDlg   
//�����������������������������Ŀ
//�Objetos do Get               �
//�Objetos da tabela de destino �
//�������������������������������
Local oTabOri
Local oTipOri
Local oTipDOri
//������������������������������Ŀ
//�Objetos da tabela de destino  �
//��������������������������������
Local oTabDes
Local oTipDes 
Local oTipDDes
//�����������������������������Ŀ
//�Variaveis da tabela de origem�
//�������������������������������
Local cTabOri   := Criavar("DTL_TABFRE",.F.)
Local cTipOri   := Criavar("DTL_TIPTAB",.F.)
Local cTipDOri  := Criavar("DTL_DESTIP",.F.)
//������������������������������Ŀ
//�Variaveis da tabela de destino�
//��������������������������������
Local cTabDes   := Criavar("DTL_TABFRE",.F.)
Local cTipDes   := Criavar("DTL_TIPTAB",.F.)
//������������������������������Ŀ
//�Variaveis da vigencia         �
//��������������������������������
Local dDatDe   := Criavar("DTL_DATDE",.F.)
Local dDatAte  := Criavar("DTL_DATATE",.F.)

//������������������������������Ŀ
//�BackUp da var Inclui          �
//��������������������������������
Local lOldInc  := Inclui

Private cTipDDes  := Criavar("DTL_DESTIP",.F.)

// Para a funcao ExistChav
Inclui := .T.

DbSelectArea("DTL")
DbSetOrder(1)
DbGoTo(nReg)

//���������������������������������Ŀ
//�Carrega dados da tabela de Origem�
//�����������������������������������
cTabOri  := DTL->DTL_TABFRE
cTipOri  := DTL->DTL_TIPTAB
cTipDOri := Tabela("M5",DTL->DTL_TIPTAB,.F.)

DEFINE MSDIALOG oDlg FROM 0,0 TO 150,355 TITLE STR0020 PIXEL //"Copia Configuracao da Tabela de Frete"
	 
	//�������������������������������������������������������������������������Ŀ
	//�Campos utilizados na Dialog                                              �
	//���������������������������������������������������������������������������

	@ 11,005 SAY STR0021 SIZE 41,8 OF oDlg PIXEL //"Da Tabela "
	@ 10,047 MSGet oTabOri  Var cTabOri  Picture "@!" SIZE 21,8 OF oDlg PIXEL WHEN .F.
	@ 11,078 SAY STR0022 SIZE 16,8 OF oDlg PIXEL //"Tipo: "
	@ 10,094 MSGet oTipOri  Var cTipOri  Picture "@!"    SIZE   5,8 OF oDlg PIXEL WHEN .F.
	@ 10,115 MSGet oTipDOri Var cTipDOri Picture "@!"    SIZE  59,8 OF oDlg PIXEL WHEN .F.

	@ 24,005 SAY STR0023 SIZE 41,8 OF oDlg PIXEL //"Para a Tabela "
	@ 23,047 MSGet oTabDes  Var cTabDes  Picture "@!" VALID !Empty(cTabDes) .And. ExistChav("DTL",cTabDes+cTipDes,1) F3 "DTL"  SIZE 21,8 OF oDlg PIXEL 
	@ 24,078 SAY STR0022 SIZE 16,8 OF oDlg PIXEL //"Tipo: "
	@ 23,094 MSGet oTipDes  Var cTipDes  Picture "@!"  F3 "M5" VALID !Empty(cTipDes) .And. TMA130TabOk(cTabDes, cTipDes)  SIZE 5,8 OF oDlg PIXEL
	@ 23,115 MSGet oTipDDes Var cTipDDes Picture "@!"   SIZE  59,8 OF oDlg PIXEL WHEN .F.

	@ 37,005 SAY STR0024 SIZE 41,8 OF oDlg PIXEL //"Ini.Vigencia "
	@ 36,047 MSGet oDatDe Var dDatDe  Picture PesqPict('DTL','DTL_DATDE') VALID(!Empty(dDatDe)) SIZE 41,8 OF oDlg PIXEL 

	@ 50,005 SAY STR0025 SIZE 41,8 OF oDlg PIXEL //"Fim Vigencia "
	@ 49,047 MSGet oDatAte Var dDatAte  Picture PesqPict('DTL','DTL_DATATE')  SIZE 41,8 OF oDlg PIXEL 

	DEFINE SBUTTON FROM 60,115  TYPE 1 ACTION (IIf(Tmsa130COK(cTabOri,cTipOri,cTabDes,cTipDes,dDatDe,dDatAte,oTabOri,oTipOri,oTabDes,oTipDes,oDatDe,oDatAte),oDlg:End(),"")) ENABLE OF oDlg
	DEFINE SBUTTON FROM 60,145  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
 
ACTIVATE MSDIALOG oDlg CENTERED
//������������������Ŀ
//�Restaura variavel.�
//��������������������
Inclui := lOldInc

Return .T.

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Funcao      �TMSA130COK  �Autor  �Rafael M. Quadrotti � Data �  02/19/03���
��������������������������������������������������������������������������͹��
���            Copia da Configuracao da Tabela de Frete                    ���
��������������������������������������������������������������������������͹��
��� Sintaxe    � TMSA130COK()                                              ���
��������������������������������������������������������������������������͹��
��� Parametros �                                         			      	���
���         01 � cTabOri - Codigo da Tabela de Origem 					      ���
���         02 � cTipOri - Codigo do Tipo (Tabela de Origem)               ���
���         03 � cTabDes - Codigo da Tabela de Destino 					      ���
���         04 � cTipDes - Codigo do Tipo de Destino  					      ���
���         05 � dDatDe  - Data de Inicio da Vigencia da nova tabela       ���
���         06 � dDatAte - Data do Fim da Vigencia da Nova tabela		      ���
���         07 � oTabOri - Objeto do Get da tabela de Origem     		      ���
���         08 � oTipOri - Objeto do Get do tipo de Origem       		      ���
���         09 � oTabDes - Objeto do Get da tabela de Destino    		      ���
���         10 � oTipDes - Objeto do Get do tipo de Destino      		      ���
���         11 � oDatDe  - Objeto do Get da Data de Vigencia     		      ���
���         12 � oDatAte - Objeto do Get da Data do Fim da Vigencia		   ���
��������������������������������������������������������������������������͹��
��� Retorno    � .T.                                                       ���
��������������������������������������������������������������������������͹��
��� Uso        � SigaTMS - Gestao de Transportes                           ���
��������������������������������������������������������������������������͹��
��� Comentario �Processamento da copia das configuracoes com base nas Confi���
���            �guracoes ja existentes.                                    ���
��������������������������������������������������������������������������͹��
���          Atualizacoes efetuadas desde a codificacao inicial            ���
��������������������������������������������������������������������������͹��
���Programador �  Data  � BOPS �             Motivo da Alteracao           ���
��������������������������������������������������������������������������͹��
���            �xx/xx/03�xxxxxx�                                           ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function Tmsa130COK(cTabOri,cTipOri,cTabDes,cTipDes,dDatDe,dDatAte,oTabOri,oTipOri,oTabDes,oTipDes,oDatDe,oDatAte)

Local lRet 	 := .T.
//--Variavel para controle de posicao dos arrays aCopyDTL e aCopyDVE
Local nLinha := 0 
Local nCount := 0 // Usado no For da gravacao
Local nW     := 0 // Usado no For da gravacao
//-- Arrays com dados para copia.
Local aCopyDTL := {}  
Local aCopyDVE := {}  
//--Variavel de auxilio para aCopyDTL/aCopyDVE
Local cCampo   := ""
Local aStruct

Do Case
	Case Empty(cTabDes)
		Help("", 1, "TMSA13005")// A tabela de Destino n�o foi informada. Por favor informe uma tabela valida.
		oTabDes:SetFocus()
		lRet := .F.
	
	Case Empty(cTipDes)
		Help("", 1, "TMSA13006")// O Tipo para Configuracao da Tabela de Frete nao foi informado. Por favor informe um tipo valido.
		oTipDes:SetFocus()
		lRet := .F.

	Case Empty(dDatDe)
		Help("", 1, "TMSA13007")// A data de vigencia n�o foi informada. Por favor informe uma data v�lida.
		oDatDe:SetFocus()
		lRet := .F.
EndCase

//����������������������������������Ŀ
//�Flag para retorno �nico na funcao.�
//������������������������������������
If lRet

	//�����������������������������������������������������������������������Ŀ
	//�Armazena dados do Dtl (Configuracao de tabela) para posterior gravacao.�
	//�������������������������������������������������������������������������
	DbSelectArea("DTL")
	DbSetOrder(1)
	If MsSeek(xFilial("DTL")+cTabOri+cTipOri)
		//�����������������������������������������������������������������Ŀ
		//�Adiciona linha no array .                                        �
		//�������������������������������������������������������������������
		nLinha++
		Aadd(aCopyDTL,{})

		//�������������Ŀ
		//�Seleciona DTL�
		//���������������
		aStruct := DTL->(DbStruct())
	
		For nCount := 1 To Len(aStruct)
			cCampo := AllTrim(aStruct[nCount][1])
			Do Case
				Case (cCampo == "DTL_FILIAL")
					Aadd(aCopyDTL[nLinha],{"DTL_FILIAL",xFilial("DTL")})
				Case (cCampo == "DTL_TABFRE")
					Aadd(aCopyDTL[nLinha],{"DTL_TABFRE",cTabDes})
				Case (cCampo == "DTL_TIPTAB")
					Aadd(aCopyDTL[nLinha],{"DTL_TIPTAB",cTipDes})
				Case (cCampo == "DTL_DATDE")
					Aadd(aCopyDTL[nLinha],{"DTL_DATDE",dDatDe})
				Case (cCampo == "DTL_DATATE")
					Aadd(aCopyDTL[nLinha],{"DTL_DATATE",dDatAte})
				OtherWise
					Aadd(aCopyDTL[nLinha],{cCampo,DTL->&(cCampo)})
			EndCase
		Next nCount
	
		nLinha:=0
		DbSelectArea("DVE")
		DbSetOrder(1)
		If MsSeek(xFilial("DVE")+cTabOri+cTipOri)
			While ((!EOF()) .And. xFilial("DVE")==DVE_FILIAL .And. DVE_TABFRE==cTabOri .And. DVE_TIPTAB==cTipOri  )
				//�����������������������������������������������������������������Ŀ
				//�Adiciona linha no array .                                        �
				//�������������������������������������������������������������������
				nLinha++
				Aadd(aCopyDVE,{})
				
				aStruct := DVE->(DbStruct())
				For nCount := 1 To Len(aStruct)
					cCampo := ALLTRIM(aStruct[nCount][1])
					Do Case
						Case (cCampo == "DVE_FILIAL")
							Aadd(aCopyDVE[nLinha],{"DVE_FILIAL",xFilial("DVE")})
						Case (cCampo == "DVE_TABFRE")
							Aadd(aCopyDVE[nLinha],{"DVE_TABFRE",cTabDes})
						Case (cCampo == "DVE_TIPTAB")
							Aadd(aCopyDVE[nLinha],{"DVE_TIPTAB",cTipDes})
						OtherWise
							Aadd(aCopyDVE[nLinha],{cCampo,DVE->&(cCampo)})
					EndCase
				Next nCount
				DbSelectArea("DVE")
				DbSkip()
			End
		EndIf
	EndIf

	BEGIN TRANSACTION
	
		//�������������Ŀ
		//�Gera novo DTL�
		//���������������
		DbSelectArea("DTL")
		DbSetOrder(1)
		
		If (Len(aCopyDTL)>0)
			For nCount:=1 To Len(aCopyDTL)
				RecLock("DTL",.T.)
				For nW:=1 To Len(aCopyDTL[nCount])
					Replace DTL->&(aCopyDtl[nCount][nW][1])  With aCopyDtl[nCount][nW][2] // Nova tabela
				Next nW
				MsUnlock()
				Dbcommit()
			Next nCount
		
		
	        If (Len(aCopyDVE)>0)
				DbSelectArea("DVE")
				DbSetOrder(1)
			
				For nCount:=1 To Len(aCopyDVE)
					RecLock("DVE",.T.)
					For nW:=1 To Len(aCopyDVE[nCount])
						Replace DVE->&(aCopyDVE[nCount][nW][1])  With aCopyDVE[nCount][nW][2] // Nova tabela
					Next nW
					MsUnlock()
					Dbcommit()
				Next nCount
			EndIf    
		EndIf
	
	END TRANSACTION

EndIf	

Return (lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMA130TabOk� Autor �Patricia A. Salomao � Data � 15/03/2003 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao da Tabela/Tipo Tab. informados na Copia de Configu��� 
���          �racao da Tabela de Frete.                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMA130TabOk()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1 - Tabela de Frete                                     ��� 
���          �ExpC2 - Tipo da Tabela de Frete                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TMSA130                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function TMA130TabOk(cTabDes, cTipDes)

If Empty(Tabela("M5",cTipDes,.F.))
	HELP("",1,"REGNOIS") //"Nao existe registro relacionado a este codigo"
	Return( .F. )
EndIf                                  

DTL->(dbSetOrder(1))
If DTL->(MsSeek(xFilial("DTL")+cTabDes+cTipDes))
	HELP("",1,"JAGRAVADO") //"Ja existe registro com esta informacao"
	Return( .F. )
EndIf

cTipDDes :=Tabela("M5",cTipDes,.F.)	

Return .T. 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA130Whe � Autor �Patricia A. Salomao � Data � 21/05/2004 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �X3_WHEN do campo DTL_CATTAB. Nao permite a ALTERACAO do con-��� 
���          �teudo deste campo, mesmo se o parametro MV_CONTHIS (Controle��� 
���          �de Historico de Tabela) estiver desabilitado                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSA130Whe()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TMSA130                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA130Whe()
Local lRet   := .T.

If !Inclui
	lRet := .F.
EndIf	

Return lRet 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA130Whn � Autor �Patricia A. Salomao � Data � 20/02/2006 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �X3_WHEN do campo DVE_BASIMP. Nao permite a ALTERACAO do con-��� 
���          �teudo deste campo, se a categoria da tabela for diferente de��� 
���          �'Frete a Pagar'                                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �TMSA130Whn()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ��� 
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       �TMSA130                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA130Whn(cCampo)

Local lRet   := .T.          

Default cCampo:= ReadVar()
If cCampo == "M->DVE_BASIMP"
	If M->DTL_CATTAB <> StrZero(2,Len(DTL->DTL_CATTAB)) //-- Se a Categoria da Tabela for diferente de 'Frete a Pagar'
		lRet := .F.
	EndIf	

ElseIf cCampo == "M->DVE_RATEIO"  
	DT3->(DBSETORDER(1))
	DT3->(DbSeek(XFILIAL("DT3")+ GdFieldGet('DVE_CODPAS',n)))

 	If GdFieldGet('DVE_RATEIO',n) <> '1'   
	    // Se for um Componente Adicionar, nao podera ser configurado como RATEIO=SIM //
	    IF DT3->DT3_TXADIC == "1" .And. GdFieldGet('DVE_RATEIO',n) <> '1'
	       lRet := .F.
	    EndIF
	     
	    // Se for Calcula Sobre 13 / 14 / 15 / 18 nao podera ser configurado como RATEIO=SIM //
	    If (lRet) .And.(DT3->DT3_TIPFAI == StrZero(13, Len(DT3->DT3_TIPFAI)) .Or.;
					 DT3->DT3_TIPFAI == StrZero(14, Len(DT3->DT3_TIPFAI)) .Or.;
					 DT3->DT3_TIPFAI == StrZero(15, Len(DT3->DT3_TIPFAI)) .Or.;
					 DT3->DT3_TIPFAI == StrZero(18, Len(DT3->DT3_TIPFAI)))
	       lRet := .F.
		EndIf
	EndIf	
EndIf

Return lRet 
 

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()
Private aRotina := {}
     
ADD OPTION aRotina TITLE STR0002 	ACTION "AxPesqui"         OPERATION 1 ACCESS 0   //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA130" OPERATION 2 ACCESS 0   //"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA130" OPERATION 3 ACCESS 0   //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA130" OPERATION 4 ACCESS 0   //"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA130" OPERATION 5 ACCESS 0   //"Excluir"
ADD OPTION aRotina TITLE STR0019 	ACTION "TMSA130Cop" OPERATION 6 ACCESS 0   //"Copiar"


If ExistBlock("TMA130MNU")
	ExecBlock("TMA130MNU",.F.,.F.)
EndIf

Return(aRotina)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSA130Gat � Autor �Katia              � Data � 02/07/2015 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Gatilho para o campo DVE_DIZIMA									 �� 
�������������������������������������������������������������������������Ĵ��
���Retorno   �Logico                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Function TMSA130Gat()
Local cRet:= '2' //Dizima N�o

//--- Componente Obrigatorio e Rateio igual a SIM
If FwFldGet('DVE_RATEIO') == '1'  
	If FwFldGet('DVE_COMOBR') == '1' 
		cRet:= '1'   //Dizima SIM
	EndIf	     
EndIf	

Return cRet


/*/-----------------------------------------------------------
{Protheus.doc} PreVldMdl
Pr�-valida a Linha do grid

Uso: TMSA130

@sample
//PreVldMdl(oModelGrid)

@author Katia
@since 23/01/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldMdl(oModelGrid,nLine,cAction)
Local lRet 		:= .T.					// Recebe o Retorno
Local aAreaDVE	:= DVE->(GetArea())	// Recebe a Area da tebela DDJ

oModelGrid:GoLine(nLine)

If cAction ==  "CANSETVALUE"
	If oModelGrid:cId == "MdGridIDVE" .AND.  Empty(oModelGrid:GetValue("DVE_TABFRE",nLine))
		oModelGrid:LoadValue("DVE_TABFRE", M->DTL_TABFRE)
		oModelGrid:LoadValue("DVE_TIPTAB", M->DTL_TIPTAB)
	EndIf 
EndIf

RestArea(aAreaDVE)	
Return lRet
