#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEW010.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GPEW010  ³ Autor ³ Totvs                      ³ Data ³ 08/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Workflow FLUIG - Solicitação Desligamento                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ³±±±±±±±±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄ¿±±
±±³Programador   ³ Data   ³ PRJ/REQ-Chamado ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³                 ³                                            ³±±
±±³Renan Borges  ³27/09/16³TVWVWI           ³Ajuste ao utilizar Visão por Departamento e ³±±
±±³              ³        ³                 ³realizar a soli³tação para um membro da equi³±±
±±³              ³        ³                 ³pe, seja carregado o aprovador corretamente ³±±
±±³              ³        ³                 ³quando o responsável pelo departamento esti-³±± 
±±³              ³        ³                 ³ver em um departamento diferente ao do soli-³±± 
±±³              ³        ³                 ³citante. Conceito utilizado também para au- ³±± 
±±³              ³        ³                 ³mento de quadro e novas contratações.       ³±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEW011()
WF Solicitação Aumento Desligamento - TIPO 6(Portal)

@author Flavio S. Correa
@since 10/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GPEW011
   Local oMBrowse                   
   Local cFiltro  := ""


	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("RH3")
	oMBrowse:AddLegend('RH3->RH3_STATUS=="1"',  "YELLOW", STR0002) //"Solicitado"
	oMBrowse:AddLegend('RH3->RH3_STATUS=="2"',  "GREEN"	, STR0003) //"Atendido"
	oMBrowse:AddLegend('RH3->RH3_STATUS=="3"',  "RED"	, STR0004) //"Rejeitado"
	oMBrowse:AddLegend('RH3->RH3_STATUS=="5"',  "ORANGE", STR0008) //"Aguardando Aprovacao RH"
    oMBrowse:AddLegend('RH3->RH3_STATUS=="4"',  "BLUE"	, STR0007) //"Aguardando Efetivacao RH"
	
	Do Case
		Case cModulo == "GPE"
			cFiltro := 'RH3_TIPO $ "B/7/6/4/2/1"'
		Case cModulo == "RSP"
			cFiltro := 'RH3_TIPO $ "9/5/2/1/H"'
		Case cModulo == "TRM"
			cFiltro := 'RH3_TIPO $ "A/2/1"'
		Case cModulo == "ORG"
			cFiltro := 'RH3_TIPO $ "3/2/1"'
		Case cModulo == "PON"
			cFiltro := 'RH3_TIPO $ "8"'
		Case cModulo == "VDF"
        	cFiltro := 'RH3_TIPO $ "N/O/P/Q/R/S/T"'
      	Otherwise						
        	cFiltro := 'RH3_TIPO $ ""'
	EndCase
	
	oMBrowse:SetFilterDefault(cFiltro)
	oMBrowse:Activate()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional

@return aRotina - Estrutura
            [n,1] Nome a aparecer no cabecalho
            [n,2] Nome da Rotina associada            
            [n,3] Reservado
            [n,4] Tipo de Transação a ser efetuada:
                1 - Pesquisa e Posiciona em um Banco de Dados
                2 - Simplesmente Mostra os Campos
                3 - Inclui registros no Bancos de Dados
                4 - Altera o registro corrente
                5 - Remove o registro corrente do Banco de Dados
                6 - Alteração sem inclusão de registros
                7 - Copia
                8 - Imprimir
            [n,5] Nivel de acesso
            [n,6] Habilita Menu Funcional
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0029 ACTION "VIEWDEF.GPEW010" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0028 ACTION "VIEWDEF.GPEW011" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0030 ACTION "VIEWDEF.GPEW012" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0031 ACTION "VIEWDEF.GPEW013" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0032 ACTION "VIEWDEF.GPEW014" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0033 ACTION "VIEWDEF.GPEW015" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0034 ACTION "VIEWDEF.GPEW016" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0035 ACTION "VIEWDEF.GPEW017" OPERATION 4 ACCESS 0	//"Atende"
	ADD OPTION aRotina TITLE STR0036 ACTION "VIEWDEF.GPEW018" OPERATION 4 ACCESS 0	//"Atende"
		
	//aAdd( aRotina, { STR0010,"GPEW010Leg", 0 , 2,,.F.} )	//"Legenda"	
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do modelo da regra de negocios

@author Flavio S. Correa
@since 10/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel     := MPFormModel():New("GPEW011",,{ |oModel| W011Grav( oModel ) })
	Local oStructRH3 := FWFormStruct(1, "RH3")
	Local oStruct 	 := FWFormModelStruct():New()
	Local oStructApr := FWFormModelStruct():New()

	//campos RH3
	W011Str( 1,@oStructRH3 ,"RH3" )
	
	//campos RH4
	W011Str( 1,@oStruct ,"RH4" )
	
	//campos aprovacao
	W011Str( 1,@oStructApr ,"APR" )
    
	oStructRH3:SetProperty( "RH3_MAT", MODEL_FIELD_OBRIGAT, .F. )
	oStructRH3:SetProperty( "RH3_TIPO", MODEL_FIELD_OBRIGAT, .F. )
	oStructRH3:SetProperty( "RH3_STATUS", MODEL_FIELD_OBRIGAT, .F. )
	oStructRH3:SetProperty( "RH3_DTATEN", MODEL_FIELD_OBRIGAT, .F. )
	oStructRH3:SetProperty( "RH3_DTSOLI", MODEL_FIELD_OBRIGAT, .F. )
	
	oModel:AddFields("GPEW011_RH3", NIL, oStructRH3)
	oModel:AddFields("GPEW011_RH", "GPEW011_RH3", oStruct,,,{|| LoadRH4(1)})
	oModel:AddFields("GPEW011_APR", "GPEW011_RH3", oStructApr,,,{|| LoadRH4(2)})
	
	oModel:GetModel( "GPEW011_RH" ):SetDescription( STR0023 )
	oModel:GetModel( "GPEW011_APR" ):SetDescription( STR0024 )
		
	oModel:SetPrimaryKey({"RH3_CODIGO"})
	
	oModel:SetRelation(	 "GPEW011_RH",;
					{	{"RH4_FILIAL", "xFilial('RH4')"},;
				      	{"RH4_CODIGO", "RH3_CODIGO"}	},;
						 "RH4_FILIAL+RH4_CODIGO+STR(RH4_ITEM,3)")
										 
	
	oModel:GetModel( 'GPEW011_RH' ):SetOnlyView ( .T. ) 
	oModel:GetModel( 'GPEW011_RH3' ):SetOnlyView ( .T. ) 
	
	oModel:SetDescription(STR0028)
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
VIEW DESLIGAMENTO
@author Flavio S. Correa
@since 10/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel 		:= FWLoadModel("GPEW011")
	Local oView 		:= FWFormView():New()	
	Local nI			:= 1
	Local nPos			:= 0
	Local oStructRH3 	:= FWFormStruct(2, "RH3")
	Local oStruct 		:= FWFormViewStruct():New()
	Local oStructApr 	:= FWFormViewStruct():New()
	Local aStr			:= {"RA_FILIAL","RA_MAT","RA_NOME","RX_TXT","TMP_NOVAC" }
	//Local aStr			:= {"RA_FILIAL","RA_MAT","RA_NOME" }
	Local aFields 		:= {}
	
	//campos RH3
	W011Str( 2,@oStructRH3 ,"RH3" )

	//Campos RH4
	W011Str(2,@oStruct ,"RH4" )
	
	//Campos de aprovacao
	W011Str(2,@oStructApr ,"APR" )


	oStructRH3:RemoveField("RH3_FILIAL")	
	oStructRH3:RemoveField("RH3_VISAO")
	oStructRH3:RemoveField("RH3_NVLINI")
	oStructRH3:RemoveField("RH3_FILINI")
	oStructRH3:RemoveField("RH3_MATINI")
	oStructRH3:RemoveField("RH3_NVLAPR")
	oStructRH3:RemoveField("RH3_FILAPR")
	oStructRH3:RemoveField("RH3_MATAPR")
	oStructRH3:RemoveField("RH3_WFID")
	oStructRH3:RemoveField("RH3_IDENT")
	oStructRH3:RemoveField("RH3_KEYINI")
	oStructRH3:RemoveField("RH3_ORIGEM")
	oStructRH3:RemoveField("RH3_STATUS")
	oStructRH3:RemoveField("RH3_TIPO")
	oStructRH3:RemoveField("RH3_DTATEN")
	oStructRH3:RemoveField("RH3_TPDESC")
	oStructRH3:RemoveField("RH3_FLUIG")
	
	oStruct:RemoveField("RH4_FILIAL")
	aFields := aclone(oStruct:GetFields())
	For nI := 1 To Len(aFields)	
		If (nPos := aScan(aStr,{|x| Alltrim(x) == alltrim(aFields[nI][1])})) == 0
			//Remove campos que não sao referente ao tipo da solicitação
			oStruct:RemoveField(aFields[nI][1])
		Else                                                            
			//acerta a ordem dos campos de acordo com o tipo de solicitação
			oStruct:SetProperty(aFields[nI][1],MVC_VIEW_ORDEM,nPos)
		EndIf
	Next nI

	oView:SetModel(oModel)
	oView:AddField("GPEW011_RH3", oStructRH3)   
	oView:AddField("GPEW011_RH", oStruct)   
	oView:AddField("GPEW011_APR", oStructApr)   

	oView:CreateHorizontalBox("TOP", 40)
	oView:CreateHorizontalBox("MEIO", 40)
	oView:CreateHorizontalBox("BOTTOM", 20)
	
	oView:SetOwnerView("GPEW011_RH3", "TOP")
	oView:SetOwnerView("GPEW011_RH", "MEIO")
	oView:SetOwnerView("GPEW011_APR", "BOTTOM")
	
	oView:SetCloseOnOk({ || .T. }) //Fecha tela apos commit

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} W010Str
Estrutura Adicional do Header
nTipo 1=Model;2=View
@author Flavio Correa
@since 24/03/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function W011Str(nTipo, oStruct ,cGrupo )
Local aArea    := GetArea()
Local bValid   := Nil
Local bWhen    := Nil
Local bRelac   := Nil
Local aTit 		:= {}
Local nI		:= 1
Local aTodos	:= {'QG_CIC','QG_CURRIC','QG_NOME','R8_DATAFIM','R8_DATAINI','R8_DURACAO','R8_FILIAL','R8_MAT','RA_FILIAL',;
			'RA_MAT','RA_NOME','RA3_CALEND','RA3_CURSO','RA3_DATA','RA3_FILIAL','RA3_MAT','RA3_TURMA','RB7_CARGO','RB7_CATEG',;
			'RB7_FILIAL','RB7_FUNCAO','RB7_MAT','RB7_PERCEN','RB7_SALARI','RB7_TPALT','RBT_CARGO','RBT_CC','RBT_CODMOV','RBT_CODPOS',;
			'RBT_DEPTO','RBT_FILIAL','RBT_FUNCAO','RBT_JUSTIF','RBT_PROCES','RBT_QTDMOV','RBT_REMUNE','RBT_TIPOR','RBT_TPCONT',;
			'RBT_TPOSTO','RE_CCP','RE_DEPTOP','RE_EMPP','RE_FILIALD','RE_FILIALP','RE_MATD','RE_MATP','RE_POSTOP','RE_PROCESS',;
			'RF0_CODABO','RF0_DTPREF','RF0_DTPREI','RF0_FILIAL','RF0_HORFIM','RF0_HORINI','RF0_HORTAB','RF0_MAT','RX_COD','RX_TXT',;
			'TMP_1P13SL','TMP_ABOND','TMP_ABONO','TMP_DCARGO','TMP_DCC','TMP_DCCP','TMP_DDEPTO','TMP_DESC','TMP_DFUNCA',;
			'TMP_DPROCP','TMP_FILIAL','TMP_MAT','TMP_NOME','TMP_NOTA','TMP_NOVAC','TMP_NOVACO','TMP_SITUAC','TMP_TEST','TMP_TIPO','TMP_VAGA',;
			"RI1_FILIAL","RI1_MAT","RI1_TABELA","TMP_NMCURS","TMP_NMINST","TMP_CONTAT","TMP_TELEFO","RI1_DINIPG","RI1_DFIMPG","TMP_VLRMEN","TMP_QTDEPA"; 					
			}

dbSelectArea("SX3")
SX3->(dbSetOrder(2))

If Alltrim(Upper(cGrupo)) == "RH4"
	For nI := 1 To Len(aTodos)
		If SX3->(dbSeek(Alltrim(aTodos[nI]))) 
			If Alltrim(aTodos[nI]) != "RX_TXT" 
				If Alltrim(aTodos[nI]) == "RI1_TABELA"
					aadd(aTit,{X3Descric(),X3Descric(),aTodos[nI],'C',40,SX3->X3_DECIMAL,,,,.F.,"GET",bRelac,.F.})
				Else
					aadd(aTit,{X3Descric(),X3Descric(),aTodos[nI],'C',SX3->X3_TAMANHO + 4,SX3->X3_DECIMAL,,,,.F.,"GET",bRelac,.F.})
				EndIf
			Else
				aadd(aTit,{RH4InitDesc(aTodos[nI]),RH4InitDesc(aTodos[nI]),aTodos[nI],'C',SX3->X3_TAMANHO+4,SX3->X3_DECIMAL,,,,.F.,"GET",bRelac,.F.})
			EndIf
			     
		Else
			If Alltrim(aTodos[nI]) == "TMP_NOME" 
				SX3->(dbSeek(Alltrim("RA_NOME")))
				aadd(aTit,{RH4InitDesc(aTodos[nI]),RH4InitDesc(aTodos[nI]),aTodos[nI],'C',SX3->X3_TAMANHO,SX3->X3_DECIMAL,,,,.F.,"GET",bRelac,.F.})     
			Else
				aadd(aTit,{RH4InitDesc(aTodos[nI]),RH4InitDesc(aTodos[nI]),aTodos[nI],'C',50,0,"@!",,,.F.,"GET",bRelac,.F.})
			EndIf
		EndIf
	Next nI
ElseIf Alltrim(Upper(cGrupo)) == "RH3"
	//Admissao
	bRelac := {|| Posicione('SRA',1,xFilial('SRA')+RH3->RH3_MAT,'RA_ADMISSA')}
	//bRelac := {|| "31/12/2014"}
	If SX3->(dbSeek("RA_ADMISSA")) 
		aadd(aTit,{X3Descric(),X3Descric(),"RA_ADMISSA",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,,,,.F.,"GET",bRelac,.T.})
	EndIf
Else	
	//combo aprovação
	aadd(aTit,{STR0026,STR0026,"TMP_OPER",'C',1,0,"@!",,{"1="+STR0011,"2="+STR0012},.T.,"C",bRelac,.F.})     
	//Observação
	aadd(aTit,{STR0027,STR0027,"TMP_OBSER",'C',250,0,"@!",,,.T.,"GET",bRelac,.F.})     
EndIf
	
For nI := 1 To Len(aTit)
	If nTipo = 1
		oStruct:AddField( ;
			aTit[nI][1]           , ;              // [01] Titulo do campo
			aTit[nI][2]           , ;              // [02] ToolTip do campo
			aTit[nI][3]           , ;              // [03] Id do Field
			aTit[nI][4]           , ;              // [04] Tipo do campo
			aTit[nI][5]           , ;              // [05] Tamanho do campo
			aTit[nI][6]           , ;              // [06] Decimal do campo
			bValid                , ;              // [07] Code-block de validação do campo
			bWhen                 , ;              // [08] Code-block de validação When do campo
			aTit[nI][9]           , ;              // [09] Lista de valores permitido do campo
			.F.                   , ;              // [10] Indica se o campo tem preenchimento obrigatório
			aTit[nI][12]          , ;              // [11] Code-block de inicializacao do campo
			NIL                   , ;              // [12] Indica se trata-se de um campo chave
			Nil                   , ;              // [13] Indica se o campo não pode receber valor em uma operação de update.
			aTit[nI][13])          		           // [14] Indica se o campo é virtual
	Else
		oStruct:AddField( 				      ;
		   		aTit[nI][3]                 , ;              // [01] Campo
				alltrim(strzero(nI+3,2))  	, ;              // [02] Ordem
				aTit[nI][1]                 , ;              // [03] Titulo
				aTit[nI][1]                 , ;              // [04] Descricao
				NIL                    		, ;              // [05] Help
				aTit[nI][11]                  		, ;              // [06] Tipo do campo   COMBO, Get ou CHECK
				aTit[nI][7]                 , ;              // [07] Picture
				                       		, ;              // [08] PictVar
				                  			, ;              // [09] F3
				aTit[nI][10]   	               , ;              // [10] Editavel
				                       , ;              // [11] Folder
				cGrupo                  , ;              // [12] Group
				 aTit[nI][9]                      , ;              // [13] Lista Combo
				                       , ;              // [14] Tam Max Combo
				                       , ;              // [15] Inic. Browse
				aTit[nI][13])                                    // [16] Virtual
			
	EndIf

Next nI

RestArea( aArea )

Return oStruct

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadRH4
Load do model SEADETAIL
As posições do vetor de retorno devem ser na mesma sequência dos campos.
@author Flavio S. Correa
@since 10/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function LoadRH4(nTipo)
Local aRet       	:= {}
Local aArea      	:= GetArea()                          
Local nI			:= 1
Local nJ			:= 1
Local nPos			:= 1
Local cRH4Alias		:= GetNextAlias()
Local cWhere		:= ""
Local aTemp 		:= {}
Local cRx			:= ""
Local aTabS043		:= {}
Local nPos			:= 0
Local aTodos		:= {'QG_CIC','QG_CURRIC','QG_NOME','R8_DATAFIM','R8_DATAINI','R8_DURACAO','R8_FILIAL','R8_MAT','RA_FILIAL',;
						'RA_MAT','RA_NOME','RA3_CALEND','RA3_CURSO','RA3_DATA','RA3_FILIAL','RA3_MAT','RA3_TURMA','RB7_CARGO','RB7_CATEG',;
						'RB7_FILIAL','RB7_FUNCAO','RB7_MAT','RB7_PERCEN','RB7_SALARI','RB7_TPALT','RBT_CARGO','RBT_CC','RBT_CODMOV','RBT_CODPOS',;
						'RBT_DEPTO','RBT_FILIAL','RBT_FUNCAO','RBT_JUSTIF','RBT_PROCES','RBT_QTDMOV','RBT_REMUNE','RBT_TIPOR','RBT_TPCONT',;
						'RBT_TPOSTO','RE_CCP','RE_DEPTOP','RE_EMPP','RE_FILIALD','RE_FILIALP','RE_MATD','RE_MATP','RE_POSTOP','RE_PROCESS',;
						'RF0_CODABO','RF0_DTPREF','RF0_DTPREI','RF0_FILIAL','RF0_HORFIM','RF0_HORINI','RF0_HORTAB','RF0_MAT','RX_COD','RX_TXT',;
						'TMP_1P13SL','TMP_ABOND','TMP_ABONO','TMP_DCARGO','TMP_DCC','TMP_DCCP','TMP_DDEPTO','TMP_DESC','TMP_DFUNCA',;
						'TMP_DPROCP','TMP_FILIAL','TMP_MAT','TMP_NOME','TMP_NOTA','TMP_NOVAC','TMP_NOVACO','TMP_SITUAC','TMP_TEST','TMP_TIPO','TMP_VAGA',;
						"RI1_FILIAL","RI1_MAT","RI1_TABELA","TMP_NMCURS","TMP_NMINST","TMP_CONTAT","TMP_TELEFO","RI1_DINIPG","RI1_DFIMPG","TMP_VLRMEN","TMP_QTDEPA"; 					
						}

If nTipo == 1                    
	
	cWhere := "% AND RH4.RH4_CODIGO = '"+RH3->RH3_CODIGO+"' AND RH4.RH4_FILIAL = '"+RH3->RH3_FILIAL+"'%"
	BEGINSQL ALIAS cRH4Alias
			SELECT *
			FROM %table:RH4% RH4
			WHERE RH4.%notDel% 
			       %exp:cWhere%
	ENDSQL
	
	While !(cRH4Alias)->(Eof())
		aAdd(aTemp,{(cRH4Alias)->RH4_CAMPO,(cRH4Alias)->RH4_VALNOV})
	
		(cRH4Alias)->(dbSkip())
		nI++
	EndDo                      
	(cRH4Alias)->(dbCloseArea())
	For nI := 1 To Len(aTodos)
		If nI == 1
			aAdd(aRet,{})
	        aadd(aRet,1)
	  	EndIf
		If (nPos := aScan(aTemp,{|x| alltrim(x[1]) == alltrim(aTodos[nI])})) > 0
		    If Alltrim(aTemp[nPos][1]) == "RX_COD"
				aAdd(aRet[1],aTemp[nPos][2])
		    	cRx := aTemp[nPos][2]
			elseIf Alltrim(aTemp[nPos][1]) == "RX_TXT"
				fCarrTab( @aTabS043, "S043", date() ,.T.)
				nPos := ascan(aTabS043,{|x| x[5]==cRx})
				If nPos > 0
					aAdd(aRet[1],Alltrim( aTabS043[nPos][06] ))
				EndIf
			Else
				aAdd(aRet[1],aTemp[nPos][2])
			EndIf
		Else
		    aAdd(aRet[1],"")			
		EndIf
	Next nI	
Else
	aAdd(aRet,{})
	aadd(aRet,1)
	aRet[1] := {"",""}
EndIf	


RestArea( aArea )				
Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³W010Grav ºAutor  ³Flavio Correa     º Data ³  09/04/14	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Aprova ou Reprova Solicitação							  	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function W011Grav( oModel )
Local oStruct    := oModel:GetModel("GPEW011_APR")
Local aArea      := GetArea()
Local cObs		:= ""
Local cTipo		:= ""//1=aprovar;2=reprovar
Local nEtapa	:= Val(oModel:GetWKNumState())
Local cAliasTMP	:= GetNextAlias()
Local cSql		:= ""
//conout("oModel:GetWKNumState()"+oModel:GetWKNumState())
If nEtapa == 2 
	If Valida()
		cObs := ostruct:getvalue("TMP_OBSER")
		cTipo := ostruct:getvalue("TMP_OPER")
		If !GPEW011WF(oModel,cObs,cTipo)
			Return .F.
		EndIf	
	Else
		Return .F.
	EndIf           
EndIf

RestArea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fSuperior		 ³ Autor ³Flavio S. Correa    ³Data ³09/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna superior								    		 	³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function fSuperior(cVision,cFilFun,cMatFun)
Local cDepto 		:= ""
Local aDeptos 		:= fEstrutDepto(cFilFun)
Local aSuperior		:= {}  
Local cTypeOrg		:= ""

dbSelectArea("SRA")
SRA->(dbSetOrder(1))
If SRA->(dbSeek(cFilFun+cMatFun))
	cDepto := SRA->RA_DEPTO
EndIf

TipoOrg(@cTypeOrg, cVision)
aSuperior := fBuscaSuperior(cFilFun, cMatFun, cDepto, aDeptos, cTypeOrg, cVision)

Return aSuperior



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TipoOrg		 ³ Autor ³Flavio S. Correa    ³Data ³24.11.2009 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa o Tipo de Estrutura - Departamentos/postos    		 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ APD/RH/Portais                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TipoOrg(cTypeOrg, cVision)
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³SE O PARAMETRO cTypeOrg ESTIVER VAZIO ENTAO OLHAMOS O TIPO DE ESTRUTURA PELA VISAO    ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
If Empty(cTypeOrg)
	If Empty(cVision)
		cTypeOrg := "0"
	Else
		dbSelectArea("RDK")
		If RDK->(dbSeek(xFilial("RDK")+cVision))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³RDK->RDK_HIERAR -> 1=Departamento;2=Postos                                            ³ 
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If RDK->RDK_HIERAR == "1"
				cTypeOrg := "2" //departamento
			Else
				cTypeOrg := "1" //posto
			EndIf 
		Else
			Return .F.
		EndIf
	EndIf
EndIf         

RestArea(aArea)
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} GPEW011WF()

@author Flavio S. COrrea
@since 10/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function GPEW011WF(oModel,cObs,cTipo)
Local oObj
Local oStructRH3    := oModel:GetModel("GPEW011_RH3")
Local aSuperior		:= {}
Local cErro 		:= ""
Local lOk			:= .T.
Local cVision 		:= oStructRH3:getvalue("RH3_VISAO")
Local cFilFun 		:= oStructRH3:getvalue("RH3_FILAPR")
Local cMatFun 		:= oStructRH3:getvalue("RH3_MATAPR")   
Local cUrlWS		:= GetMV("MV_URLWSRH",,"http://10.10.1.36:8070/ws")  //URL com endereço do webservice de RHREQUEST
Local cEmp 
Local cFil
Local cMat
Local cDepto
Local cRecno
Local cCPF
Local cFilMatEst
Local cUserId		:= oModel:GetWKUser()
Local cEmail		:= oModel:GetWKUserEmail()
Local aInfo			:= {}

aInfo:=FWSFLoadUser(cEmail)
If Len(aInfo) > 2
	__cuserId := aInfo[2] //usuario do protheus logado no FLUIG
EndIf

//variavel usada na funcao RhGetFuncInfo
//__cuserId := cUserId //"000008" //usuario logado no FLUIG
RhGetFuncInfo(@cEmp,@cFil,@cMat,@cDepto,@cRecno,@cCPF,@cFilMatEst,.F.)

If !Empty(cFil) .And. !empty(cMat)
	cFilFun := cFil
	cMatFun := cMat
EndIf

If alltrim(oStructRH3:getvalue("RH3_MATAPR") ) <> alltrim(cMat)
	lOk := .F.
	oModel:SetErrorMessage (,,,,,STR0049 +oStructRH3:getvalue("RH3_MATAPR")+STR0050,"") //"O funcionário " /  tem que aprovar antes está solicitação! 
	return .f.
EndIf
//busca superiores para proxima aprovação
aSuperior := fSuperior(cVision,cFilFun,cMatFun)
oObj := WsRhRequest():New()
WsChgURL(@oObj, "RHREQUEST.APW")   
oObj:_URL := cUrlWS + "/RHREQUEST.APW"  

oObj:oWsRequest                    		 := RHREQUEST_TREQUEST():New()
oObj:oWsRequest:cBranch              	 := cFilFun//oStructRH3:getvalue("RH3_FILIAL")//[filial]  usuario logado
oObj:oWsRequest:cRegistration     		 := cMatFun //oStructRH3:getvalue("RH3_MATAPR")//[matricula] usuario logado
oObj:oWsRequest:cCode                 	 := oStructRH3:getvalue("RH3_CODIGO")
oObj:oWsRequest:cObservation      	 	 := cObs
oObj:oWsRequest:cORIGEM		      	 	 := "2" //1=Portal,2=FLUIG
If Len(aSuperior) > 0
	oObj:oWsRequest:cApproverBranch	   		 := aSuperior[1][1]
	oObj:oWsRequest:cApproverRegistration  	 := aSuperior[1][2]
	oObj:oWsRequest:nApproverLevel		   	 := aSuperior[1][4]
Else
	oObj:oWsRequest:cApproverBranch	   		 := ""
	oObj:oWsRequest:cApproverRegistration  	 := ""
	oObj:oWsRequest:nApproverLevel		   	 := 99
EndIf			         

If cTipo == "1"
	If oObj:ApproveRequest()
		lOk := .T.
	Else
		cErro := PWSGetWSError()
		lOk := .F.
	EndIf
Else
	If oObj:ReproveRequest()
		lOk := .T.
	Else
		cErro := PWSGetWSError()
		lOk := .F.
	EndIf
EndIf	 

asize(aInfo,0)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Valida()
@author Flavio S. Correa
@since 10/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Valida()
	Local lValid:= .T.
	
	If RH3->RH3_STATUS == "2" .OR. RH3->RH3_STATUS == "3"
		MsgAlert(STR0006, STR0005)		//"A solicitacao ja foi atendida!"###"Atencao!"
		lValid:= .F.
	EndIf

Return lValid

Static Function RH4InitDesc(cCampo)
	Local cDesc := ""               
	Local aDescCampos := {{"TMP_TIPO"  , STR0014},;	//"Tipo Desligamento"
						  {"TMP_RAZAO" , STR0015},;	//"Motivo Desligamento"
						  {"TMP_NOVAC" , STR0016},;	//"Gera Nova Contratação?"
						  {"TMP_POSTO" , STR0017},;	//"Posto"
						  {"TMP_FILIAL", STR0019},;	//"Filial"
						  {"TMP_MAT"   , STR0020},;	//"Matricula"
						  {"TMP_VAGA"  , STR0021},;	//"Vaga"
						  {"TMP_NOME"  , STR0025},;	//"Nome"
						  {"RX_TXT"    , STR0022},;	//"Nome"
						  {"TMP_ABOND" , STR0022},;	//"Nome"
						  {"TMP_DDEPTO", STR0037},;	//"Nome"
						  {"TMP_DCC"   , STR0038},;	//"Nome"
						  {"TMP_DFUNCA", STR0039},;	//"Nome"
						  {"TMP_DCARGO", STR0040},;	//"Nome"
						  {"TMP_NOVACO", STR0016},;	//"Nome"
						  {"TMP_DCCP"  , STR0038},;	//"Nome"
						  {"TMP_DDEPTO" , STR0037},;	//"Nome"
						  {"RE_PROCESS", STR0041},;	//"Nome"
						  {"TMP_DPROCP"  , STR0042},;	//"Nome"
						  {"TMP_DESC"    , STR0022},;	//"Descrição"
						  {"TMP_QTDEPA"    , STR0043},;	//Quantidade de parcelas
						  {"TMP_NMCURS"    , STR0044},;	//Nome do curso
						  {"TMP_NMINST"    , STR0045},;	//Nome da instituição
						  {"TMP_CONTAT"    , STR0046},;	//Nome do contato
						  {"TMP_TELEFO"    , STR0047},;	//Telefone do contato 
						  {"TMP_VLRMEN"    , STR0048}}	///Valor mensal
	
	If (nPos := aScan(aDescCampos, {|x| Alltrim(x[1]) == AllTrim(cCampo)})) > 0
		cDesc := aDescCampos[nPos][2]
	EndIf

	If Empty(cDesc)
		cDesc := AllTrim(cCampo)
	EndIf
	
Return cDesc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fSuperior		 ³ Autor ³Flavio S. Correa    ³Data ³09/04/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna superior								    		 	³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
function fAllSuperior(cVision,cFilFun,cMatFun,aSuperior,cEmpFun,cFilSol,cMatSol,cDepto,cEmpResp)
Local aArea			:= GetArea()
Local aDeptos 		:= fEstrutDepto(cFilFun)
Local cTypeOrg		:= ""
Local aTemp			:= {}
Local cQry			:= GetNextAlias()
Local cSra			:= ""
Default cEmpFun := cEMpAnt
DEFAULT cFilSol := cFilFun
DEFAULT cMatSol := cMatFun
DEFAULT cDepto  := ""
DEFAULT cEmpResp := ""

If Empty(cDepto)
cSra := "%"+RetFullName("SRA",cEmpFun)+"%"
	BeginSql alias cQry
		SELECT RA_DEPTO
		FROM %Exp:cSra% SRA
		WHERE
		SRA.RA_MAT  	 = %exp:cMatFun%  AND
		SRA.RA_FILIAL  	 = %exp:cFilFun%  AND
		SRA.%notdel%
	EndSql
	
	If !(cQry)->(eof())
		cDepto := (cQry)->RA_DEPTO
	EndIf
	(cQry)->(dbclosearea())
EndIf

TipoOrg(@cTypeOrg, cVision)
aTemp := fBuscaSuperior(cFilFun, cMatFun, cDepto, aDeptos, cTypeOrg, cVision,cEmpFun,cFilSol,cMatSol,cEmpResp)
If Len(aTemp) > 0 .and.  ascan(aSuperior,{|x| x[1][1] == aTemp[1][1] .and.  x[1][2] == aTemp[1][2]}) == 0
	If aTemp[1][4] <> 99
		aadd(aSuperior ,aTemp)
		fAllSuperior(cVision,cFilFun,cMatFun,@aSuperior,aTemp[1][7],aTemp[1][1],aTemp[1][2],cDepto,aTemp[1][9])
	EndIf
EndIf

RestArea(aArea)
Return aSuperior
