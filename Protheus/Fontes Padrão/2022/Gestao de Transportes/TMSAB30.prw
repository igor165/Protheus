#INCLUDE "TMSAB30.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE CRLF Chr(13)+Chr(10)

Static lTMB30Num := ExistBlock("TMB30NUM")

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30()
Controle de Diárias 

Uso: SIGATMS

@sample
//TMSAB30()

@author Paulo Henrique Corrêa Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB30()
Local oBrowse   := Nil				// Recebe o  Browse          

Private  aRotina   := MenuDef()		// Recebe as rotinas do menu.

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DYV")			    // Alias da tabela utilizada
oBrowse:SetMenuDef("TMSAB30")		// Nome do fonte onde esta a função MenuDef
oBrowse:SetDescription(STR0001)		//"Controle de Diarias"

oBrowse:AddLegend( "DYV_STATUS =='1'", "GREEN"	, STR0041 ) // Nao Pendente
oBrowse:AddLegend( "DYV_STATUS =='2'", "YELLOW" , STR0040 ) // Pendente

oBrowse:Activate()

Return Nil

 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSAB30

@sample
//MenuDef()

@author Paulo Henrique Corrêa Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAB30" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAB30" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAB30" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0039  ACTION "TMSAB30Apv()"    OPERATION 2 ACCESS 0 // "Aprovacao"
	ADD OPTION aRotina TITLE STR0031  ACTION "U_TMSRB10()"       OPERATION 2 ACCESS 0 // "Recibos"
	ADD OPTION aRotina TITLE STR0032  ACTION "U_TMSRB11()"       OPERATION 2 ACCESS 0 // "Relatorio"

Return(aRotina)  

/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSAB30

@sample
//ModelDef()

@author Paulo Henrique Corrêa Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()
Local oStruDYV	:= Nil		// Recebe a Estrutura da tabela DYV
Local oStruDYX	:= Nil 		// Recebe a Estrutura da tabela DYX
Local oModel	:= Nil		// Objeto do Model
oStruDYV:= FWFormStruct( 1, "DYV" )
oStruDYX:= FWFormStruct( 1, "DYX" )

// Se for executado apartir da rotina de aprovação
	// Adiciona o Campo de Legenda
	oStruDYX:AddField(	''				, ; // Titulo do campo
						''				, ; // ToolTip do campo
						'DYX_LEG' 		, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						20	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}			, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{|| AB30Cor() }	, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
						
	// Adiciona o campo de Marcação
	oStruDYX:AddField(	STR0037			, ; // Titulo do campo  ----- Selecionado
						STR0037			, ; // ToolTip do campo ----- Selecionado
						'DYX_MARC' 		, ; // Nome do Campo
						'L' 			, ; // Tipo do campo
						1	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						NIL				, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						NIL				, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
						
oModel := MPFormModel():New( "TMSAB30",,{ |oModel| PosVldMdl( oModel ) },/*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDYV',, oStruDYV,,,/*Carga*/ ) 

oModel:SetVldActivate( { |oModel| VldActMdl( oModel ) } ) // Realiza a pre validação do Model

oModel:AddGrid( 'MdGridDYX', 'MdFieldDYV', oStruDYX,{ |oModelGrid, nLine, cAction| PreVldDYX( oModelGrid, nLine, cAction ) },{|oModelGrid,nLine| PosVldDYX(oModelGrid, nLine)}, /*bPreVal*/, /*bPosVal*/,/*BLoad*/  )

oModel:SetRelation('MdGridDYX',{ {"DYX_FILIAL","FWxFilial('DYX')"},{"DYX_IDCDIA","DYV_IDCDIA"} }, DYX->(IndexKey(1)) )
oModel:GetModel('MdGridDYX'):SetUniqueLine( { "DYX_ITEM","DYX_DATDIA"} )                

oModel:GetModel('MdGridDYX'):SetDescription(STR0002) 		//Itens do Controle de Diarias 
oModel:SetDescription( STR0001 )							//"Controle de Diarias"
oModel:GetModel( 'MdFieldDYV' ):SetDescription( STR0001 ) 	//"Controle de Diarias" 

oModel:SetPrimaryKey({"DYV_FILIAL" , "DYV_IDCDIA"})  
     
oModel:SetActivate()

     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAB30

@sample
//ViewDef()

@author Paulo Henrique Corrêa Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	:= Nil		// Objeto do Model 
Local oStruDYV	:= Nil		// Recebe a Estrutura da tabela DYV
Local oStruDYX	:= Nil 		// Recebe a Estrutura da tabela DYX 
Local oView					// Recebe o objeto da View

oModel   := FwLoadModel("TMSAB30")
oStruDYV:= FWFormStruct( 2, "DYV" )
oStruDYX:= FWFormStruct( 2, "DYX" )

oStruDYV:RemoveField("DYV_STATUS")

oStruDYX:RemoveField("DYX_IDCDIA")  
oStruDYX:RemoveField("DYX_FORNEC")  
oStruDYX:RemoveField("DYX_LOJA")  
oStruDYX:RemoveField("DYX_VALTIT")  

oView := FwFormView():New()
oView:SetModel(oModel)     



// Se for executado apartir da rotina de aprovação
If IsInCallStack("TMSAB30Apv")

	//Bloqueia todos os campos da tela
	oStruDYV:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
	oStruDYX:SetProperty( '*' , MVC_VIEW_CANCHANGE,.F.)
	oStruDYX:SetProperty( 'DYX_OBS' , MVC_VIEW_CANCHANGE,.T.)
	
	oStruDYX:RemoveField("DYX_STATUS")  
	
	// Adiciona o campo de marcação(CheckBox)
	oStruDYX:AddField(	'DYX_MARC' 	, ; // Nome do Campo
					'01' 			, ; // Ordem
					STR0037			, ; // Titulo do campo  ---- Selecionado
					STR0037			, ; // Descrição do campo  ---- Selecionado
					{STR0037}		, ; // Array com Help  ---- Selecionado
					'L' 			, ; // Tipo do campo
					'' 				, ; // Picture
					NIL 			, ; // Bloco de Picture Var
					'' 				, ; // Consulta F3
					.T. 			, ; // Indica se o campo é evitável
					NIL 			, ; // Pasta do campo
					NIL 			, ; // Agrupamento do campo
					{ }				, ; // Lista de valores permitido do campo (Combo)
					NIL 			, ; // Tamanho Maximo da maior opção do combo
					NIL 			, ; // Inicializador de Browse
					.T. 			, ; // Indica se o campo é virtual
					NIL 			  ) // Picture Variável
					
	// Adiciona o campo de Legenda
	oStruDYX:AddField(	'DYX_LEG' 	, ; // Nome do Campo
					'01' 			, ; // Ordem
					''				, ; // Titulo do campo
					'' 				, ; // Descrição do campo
					{''} 			, ; // Array com Help
					'C' 			, ; // Tipo do campo
					'@BMP' 			, ; // Picture
					NIL 			, ; // Bloco de Picture Var
					'' 				, ; // Consulta F3
					.T. 			, ; // Indica se o campo é evitável
					NIL 			, ; // Pasta do campo
					NIL 			, ; // Agrupamento do campo
					{ }				, ; // Lista de valores permitido do campo (Combo)
					NIL 			, ; // Tamanho Maximo da maior opção do combo
					"" 				, ; // Inicializador de Browse
					.T. 			, ; // Indica se o campo é virtual
					"" 			  ) // Picture Variável
						
	 
	// Botão de Aprovação				
	oView:AddUserButton(STR0008 , 'CLIPS', {|oModel| TMSAB30AOK(oModel)} )// Aprovar
	oView:AddUserButton(STR0016 , 'CLIPS', {|oModel| AB30Reprov(oModel)} )// Reprovar
	oView:AddUserButton(STR0014 , 'CLIPS', {|oModel| TMSAB30EOK(oModel)} )// Cancelar
	oView:AddUserButton(STR0017 , 'CLIPS', {|| AB30Legend()} )// Legenda

EndIf

oView:AddUserButton(STR0036 , 'CLIPS', {|| AB30VISTIT()} )// "Det. Titulo"

oView:AddField('VwFieldDYV', oStruDYV , 'MdFieldDYV') 
oView:AddGrid( 'VwGridDYX', oStruDYX , 'MdGridDYX')   

oView:CreateHorizontalBox('CABECALHO', 30)
oView:CreateHorizontalBox('GRID'	 , 70)  
oView:SetOwnerView('VwFieldDYV','CABECALHO')
oView:SetOwnerView('VwGridDYX','GRID'     )     

oView:AddIncrementField('VwGridDYX','DYX_ITEM') 

Return oView


/*/-----------------------------------------------------------
{Protheus.doc} AB30Cor()
Retorna a Legenda para o Grid

Uso: TMSAB30

@sample
//AB30Cor()

@author Paulo Henrique Corrêa Cardoso.
@since 17/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30Cor( cStatus )
Local cLegenda 		:= "" // Recebe a Legenda

Default cStatus		:= DYX->DYX_STATUS

If cStatus == "1" 		//Pendente sem Restrição
	cLegenda := "BR_AMARELO" 
ElseIf cStatus == "2" 	//Pendente com Restrição
	cLegenda := "BR_LARANJA"
ElseIf cStatus == "3" 	//Aprovado
	cLegenda := "ENABLE"
ElseIf cStatus == "4" 	//Reprovado
	cLegenda := "BR_VERMELHO"
ElseIf cStatus == "5" 	//Cancelado
	cLegenda := "BR_PRETO"
EndIf

Return cLegenda

/*/-----------------------------------------------------------
{Protheus.doc} AB30Legend()
Exibe a Legenda

Uso: TMSAB30

@sample
//AB30Legend()

@author Paulo Henrique Corrêa Cardoso.
@since 17/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30Legend()
Local aLegenda :={}		//Recebe a Legenda

Aadd(aLegenda,{"BR_AMARELO"		, STR0019}) 	//Pendente sem Restrição
Aadd(aLegenda,{"BR_LARANJA"		, STR0020}) 	//Pendente com Restrição
Aadd(aLegenda,{"ENABLE"			, STR0021}) 	//Aprovado
Aadd(aLegenda,{"BR_VERMELHO"	, STR0022})		// Reprovado
Aadd(aLegenda,{"BR_PRETO"		, STR0023}) 	//Cancelado

BrwLegenda(STR0017, STR0018, aLegenda)// "Legenda"###"Status"
				
Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} VldActMdl()
Realiza a Validaçãod de ativação do Model

Uso: TMSAB30

@sample
//VldActMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 18/02/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function VldActMdl(oModel)
Local lRet 		 := .T. 		// Recebe o Retorno
Local nOperation := 0			// Recebe a Operacao realizada

nOperation := oModel:GetOperation()
If DYV->DYV_STATUS == '1' .AND. nOperation == MODEL_OPERATION_UPDATE .AND. !IsInCallStack("TMSAB30Apv")
	Help('', 1,"HELP",, STR0025,1)// "Este item nao podera sofrer alteracoes"
	lRet  := .F. 
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Validação Final

Uso: TMSAB30

@sample
//PosVldMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 14/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lErro 	 := .F.		// Recebe o Erro
Local lContinua	 := .T.		// Verifica se continua a execução da validação
Local nRecPar	 := 0		// Recebe o Recno da Parametrização corrente
Local cErro		 := ""		// Recebe as Msgs de Erro
Local nRecViag	 := 0		// Recebe o Recno da Ultima viagem do Motorista
Local cViagem	 := ""		// Recebe o Codigo da Viagem
Local cFilOriVia := ""		// Recebe a Filial de Origem da Viagem
Local cQuery	 := ""		// Recebe a Query
Local cAliasDTW	 := ""		// Recebe o proximo alias 
Local cAtivCHG	 := ""		// Recebe a Atividade de Chegada 
Local oModelItem := NIL		// Recebe o Model de Itens
Local aSaveLine  := {}		// Recebe a posição das Linhas do Grid
Local nCount 	 := 0		// Recebe o contador
Local cErroQtd	 := ""		// Rcebe o Erro de quantidade
Local nRecnoDTW  := ""		// Rcebe o Recno da DTW
Local lChegada   :=	.F.		// Indica se ja sofreu apontamento de chegada
Local lRet		 := .T.		// Recebe o Retorno

nRecPar := TMSAB30PARM()
cAtivCHG	 := SuperGetMv ("MV_ATIVCHG", .F., "")

If !Empty(FwFldGet("DYV_VIAGEM",,oModel))
	lRet := TB30VlViag(oModel)
ElseIf !Empty(FwFldGet("DYV_FILORI",,oModel))
	Help('', 1,"HELP",, STR0046,1) //"Preencha a Viagem."
	lRet := .F.	
EndIf

If lRet
	dbSelectArea("DYU")
	DYU->( dbGoTo(nRecPar) )
	If !DYU->(EOF())
	
		// Verifica se não utiliza as validações. Caso o Tipo Hora = Não Utiliza
		If	DYU->DYU_TPHORA != "3" 
			
			// Se viagem não for preenchida, verifica o Status da ultima viagem do Motorista
			If EMPTY(FwFldGet("DYV_VIAGEM",,oModel))
			
				// Busca a ultima viagem do motorista
				nRecViag :=  AB30UltVia(FwFldGet("DYV_CODMOT",,oModel))
				
				If !Empty(nRecViag)
					dbSelectArea("DTQ")
					DTQ->(dbGoTo(nRecViag))
					
					cViagem 	:= DTQ->DTQ_VIAGEM
					cFilOriVia 	:= DTQ->DTQ_FILORI
					
					dbSelectArea("DTW")
					DTW->( dbSetOrder(4) )
					
					// Verifica se ja teve apontamento de chegada
					If DTW->( dbSeek(FWxFilial("DTW")+cFilOriVia + cViagem + cAtivCHG) ) 
						If  DTW->DTW_STATUS == "2"
							lChegada := .T.
						EndIF
					EndIf 
					
					// Verifica se os Status esta igual a parametrização
					If (DYU->DYU_STAVIA == "2" .AND. lChegada); // Viagem Fechada
						.OR. (DTQ->DTQ_STATUS == "3" .AND. DYU->DYU_STAVIA == "1") // Viagem Encerrada
						
						lContinua := .F.
					EndIf
				EndIf
			Else
				cViagem 	:= FwFldGet("DYV_VIAGEM",,oModel)
				cFilOriVia 	:= FwFldGet("DYV_FILORI",,oModel)
				
				dbSelectArea("DUP")
				DUP->( dbSetOrder(2) )
				If !DUP->( dbSeek( FWxFilial("DUP") + cFilOriVia + cViagem + FwFldGet("DYV_CODMOT",,oModel)  ) )
					
					Help('', 1,"HELP",, STR0043,1) //"O motorista não pertence a viagem selecionada"
					
					lContinua := lRet := .F.
				EndIf
				
			EndIf
			
			If lContinua
				
				cAliasDTW	 := GetNextAlias()
				
				cQuery += " SELECT MAX(R_E_C_N_O_) AS RECNO 			"+ CRLF
				cQuery += " FROM " + RetSqlName( 'DTW' )				 + CRLF
				cQuery += " WHERE D_E_L_E_T_ = ' ' 						"+ CRLF
				cQuery += "		  AND DTW_VIAGEM = '"+ cViagem +"' 		"+ CRLF
				cQuery += "	  	  AND DTW_ATIVID = '"+ cAtivCHG +"' 	"+ CRLF
				cQuery += "		  AND DTW_FILORI = '"+ cFilOriVia +"' 	"+ CRLF
			
				cQuery := ChangeQuery(cQuery)
			
				dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDTW, .F., .T. )
				
				If !(cAliasDTW)->(EOF())
					nRecnoDTW := (cAliasDTW)->RECNO
				EndIf
				(cAliasDTW)->(dbCloseArea())
				
				oModelItem := oModel:GetModel( 'MdGridDYX' )
				aSaveLine  := FWSaveRows() 
				
				For nCount := 1 To oModelItem:Length()
					
					oModelItem:GoLine( nCount )
					If (oModelItem:IsInserted() .OR. oModelItem:IsUpdated()) .AND. FwFldGet("DYX_ORIGEM",nCount,oModel) == "1";
					.AND. FwFldGet("DYX_TIPDIA",nCount,oModel) == "1"
					
						lErro := .F.
						cErro := ""
						
						// Tipo Hora Fixo 
						If DYU->DYU_TPHORA == "1" 
							
							//Se for antes do horario definido
							If Hrs2Min(Transform(FwFldGet("DYX_HORDIA",nCount,oModel),DYX->(X3Picture("DYX_HORDI")))) < Hrs2Min(DYU->DYU_HORAS) - DYU->DYU_TOLERA 
								cErro += STR0010 + CRLF	// "Lancamento da Diaria fora do Prazo"
								lErro := .T.
							EndIf
							
						// Tipo Hora Variavel 	
						Else
							
							dbSelectArea("DTW")
							DTW->( dbGoto(nRecnoDTW ) ) 
							
							If  Hrs2Min(Transform(FwFldGet("DYX_HORDIA",nCount,oModel),DYX->(X3Picture("DYX_HORDIA")))) - Hrs2Min(Transform(DTW->DTW_HORREA,DTW->(X3Picture("DTW_HORREA")))) <= Hrs2Min(DYU->DYU_HORAS) + DYU->DYU_TOLERA 
								lErro := .T.
								cErro += STR0010 + CRLF	// "Lancamento da Diaria fora do Prazo"
							EndIf
						
						EndIf
						
						dbSelectArea("DA4")
						DA4->(dbSetOrder(1))
						
						If DbSeek(FWxFilial("DA4")+FwFldGet("DYV_CODMOT",,oModel))
							// Verifica se a filial do Motorista é diferente da Filial da Viagem
							If (DA4->DA4_FILBAS != cFilOriVia ) .AND. DYU->DYU_PGFLDS == "2"
								lErro := .T.
								cErro += STR0011 + CRLF	//"Filial do motorista diferente da filial de origem da viagem."
							EndIf	
						EndIf
						
						
						// Verifica a quantidade de diarias permitidas
						cErroQtd :=  AB30QtdDia(cViagem,cFilOriVia,nCount,oModel)
						
						If !Empty(cErroQtd)
							lErro := .T.
							cErro += cErroQtd
						EndIf
					
						
						//Verifica se o motorista esta disponivel
						If AB30RsvMot(FwFldGet("DYV_CODMOT",,oModel))
							lErro := .T.
							cErro += STR0024 + CRLF	 //"Motorista ja esta Reservado para outra Viagem"
						EndIf
						
						// Verifica se exitem erros
						If lErro
							FwFldPut("DYX_OBSRES",cErro,nCount,oModel,,.T.)
							FwFldPut("DYX_STATUS","2",nCount,oModel,,.T.)
							FwFldPut("DYV_STATUS","2",,oModel)
						EndIf
					EndIf	
				Next nCount
										
				FWRestRows( aSaveLine )
			EndIf
			
		Endif
	
	EndIf
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PreVldDYX()
PreValidação na Linha do Grid

Uso: TMSAB30

@sample
//TPreVldDYX(oModelGrid, nLine, cAction)

@author Paulo Henrique Corrêa Cardoso.
@since 15/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldDYX(oModelGrid, nLine, cAction)
Local lRet 			:= .T.						// Recebe o Retorno
Local oModel 		:= oModelGrid:GetModel()	// Recebe o Model
Local nOperation 	:= oModel:GetOperation()	// Recebe a operação realizada

If !IsInCallStack("TMSAB30Apv")
	// Valida se a linha ja foi Aprovada neste caso não podera ser alterada
	If cAction $ 'DELETE|CANSETVALUE' .AND. nOperation == MODEL_OPERATION_UPDATE .AND. FwFldGet("DYX_STATUS",nLine) $ "3|5" 
		lRet := .F.
		Help('', 1,"HELP",, STR0025,1)// "Este item nao podera sofrer alteracoes"
	EndIf
EndIf
	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PosVldDYX()
Valida diarias pendentes com a mesma configuração

Uso: TMSAB30

@sample
//PosVldDYX(oModelGrid, nLine)

@author Paulo Henrique Corrêa Cardoso.
@since 24/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldDYX(oModelGrid, nLine)
Local lRet := .T.							// Recebe o Retorno
Local oModelItem := NIL						// Recebe o Model de Itens
Local aSaveLine  := {}						// Recebe a posição das Linhas do Grid
Local oModel 	 := oModelGrid:GetModel()	// Recebe o Model
Local nCount	 := 0 						// Recebe o Contador
Local cStatus	 := ""						// Recebe o Status
Local cTipVia	 := ""						// Recebe o Tipo da Viagem
Local cCondut	 := ""						// Recebe o Tipo do Condutor
Local cTipVal	 := ""						// Recebe o Tipo de Valor	
Local cTipVei	 := ""						// Recebe o Tipo de Veiculo

If FwFldGet("DYX_TIPDIA",nLine,oModel) == "1"

	cStatus	 := FwFldGet("DYX_STATUS",nLine,oModel)
	cTipVia	 := FwFldGet("DYX_TIPVIA",nLine,oModel)
	cCondut	 := FwFldGet("DYX_CONDUT",nLine,oModel)
	cTipVal	 := FwFldGet("DYX_TIPVAL",nLine,oModel)
	cTipVei	 := FwFldGet("DYX_TIPVEI",nLine,oModel)
		
	oModelItem := oModel:GetModel( 'MdGridDYX' )
	aSaveLine  := FWSaveRows()
	
	// Valida todas as Linhas	
	For nCount := 1 To oModelItem:Length()
		oModelItem:GoLine( nCount )
		
		
		If FwFldGet("DYX_TIPVIA",nCount,oModel) == cTipVia .AND.;
		   FwFldGet("DYX_CONDUT",nCount,oModel) == cCondut .AND.;
		   FwFldGet("DYX_TIPVAL",nCount,oModel) == cTipVal .AND.;
		   FwFldGet("DYX_TIPVEI",nCount,oModel) == cTipVei .AND.;
		   FwFldGet("DYX_STATUS",nCount,oModel) $ "1|2" .AND.;
		   FwFldGet("DYX_TIPDIA",nCount,oModel) == "1" .AND. nLine != nCount .AND. !oModelItem:IsDeleted()
		   		   
		   	Help('', 1,"HELP",, STR0026,1)//"Ja existe uma diaria pendente com a mesmas informacoes."
		    //oModel:SetErrorMessage (,,,,,STR0026,STR0027)//"Ja existe uma diaria pendente com a mesmas informacoes."###"Altere a diaria existente"
		    lRet := .F.
			Exit
		Endif
	Next nCount
	FWRestRows( aSaveLine )
EndIf
	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30Apv()
Tela para Aprovação

Uso: TMSAB30

@sample
//TMSAB30Apv()

@author Paulo Henrique Corrêa Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB30Apv() 
Local aButtons := {} 	// Recebe os Botões

// Adiciona apenas o botão padrão Cancelar
aButtons := {{.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,""},;
			 {.T.,STR0038},; // Fechar
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil},;
			 {.F.,Nil}}
		
// Executa a View para aprovação	 
FWExecView(STR0012,'TMSAB30',MODEL_OPERATION_UPDATE,, { || .T. },{ || .F. },,aButtons,{ || .T. })  // "Aprovacao" 

Return NIL

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30AOK()
Executa a Aprovação

Uso: TMSAB30

@sample
//TMSAB30AOK(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 13/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function TMSAB30AOK(oModel)
Local oModelItem := NIL		// Recebe o Model de Itens
Local oModelPrc := NIL		// Recebe o Model Principal
Local nCount 	 := 0		// Recebe o contador
Local aSaveLine  := {}		// Recebe a posição das Linhas do Grid
Local nRecPar	 := 0  		// Recebe a Parametrização corrente
Local aAprov	 := {}		// Recebe o Array com o retorno da Aprovação
Local aItens	 := {}		// Recebe o Array com os itens para aprovação

oModelItem := oModel:GetModel( 'MdGridDYX' )
oModelPrc := oModel:GetModel()
aSaveLine  := FWSaveRows() 
nRecPar	   := TMSAB30PARM() // Busca a Parametrização corrente
// Verifica se possui a Parametrização da Diaria para adata corrente
If !Empty(nRecPar)
	// Varre os Itens da Diaria 
	For nCount := 1 To oModelItem:Length()
		aItens := {}
		oModelItem:GoLine( nCount )
		//Verifica se o mesmo não esta deletado, se esta marcado e se aindo não foi aprovado, cancelado ou reprovado
		If !oModelItem:IsDeleted() .AND. FwFldGet("DYX_MARC",nCount,oModelPrc) .AND. FwFldGet("DYX_STATUS",nCount,oModelPrc) $ "1|2"
			
			AADD(aItens,{ FwFldGet("DYV_IDCDIA",,oModelPrc),FwFldGet("DYX_ITEM",nCount,oModelPrc)})
			
			// Aprova o item
			aAprov := TMSAB30API(nRecPar,aItens,.T.,.T.)  
			If !Empty(aAprov) .And. aAprov[1][1]  
				// Atualiza os campos da tela
				FWFldPut("DYX_STATUS", aAprov[1][2],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_NUMREC", aAprov[1][3],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_PRETIT", aAprov[1][4],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_NUMTIT", aAprov[1][5],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_NUMDES", aAprov[1][6],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_DATAPR", aAprov[1][7],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_USRAPR", aAprov[1][8],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_NOMUSR", aAprov[1][9],nCount,oModelPrc,,.T.)
				FWFldPut("DYX_LEG",AB30Cor(),nCount,oModelPrc,,.T.)
				
			EndIf			
		EndIf
	Next nCount
	FWRestRows( aSaveLine )
Else
	Help('', 1,"HELP",, STR0028,1)//"Nao possui uma parametrizacao de diaria cadastrada para a data corrente"
	//oModel:SetErrorMessage (,,,,,STR0028,STR0029)//"Nao possui uma parametrizacao de diaria cadastrada para a data corrente"###"Inclua a Parametrizacao"
EndIf
	
Return NIL

/*/-----------------------------------------------------------
{Protheus.doc} AB30Reprov()
Executa a Reprovação

Uso: TMSAB30

@sample
//AB30Reprov(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 17/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30Reprov(oModel)
Local oModelItem := NIL		// Recebe o Model de Itens
Local nCount 	 := 0		// Recebe o contador
Local aSaveLine  := {}		// Recebe a posição das Linhas do Grid

oModelItem := oModel:GetModel( 'MdGridDYX' )
aSaveLine  := FWSaveRows() 

// Varre os Itens da Diaria 
For nCount := 1 To oModelItem:Length()
	
	oModelItem:GoLine( nCount )
	//Verifica se o mesmo não esta deletado, se esta marcado e se ainda não foi aprovado, cancelado ou reprovado
	If !oModelItem:IsDeleted() .AND. FwFldGet("DYX_MARC",nCount) .AND. FwFldGet("DYX_STATUS",nCount) $ "1|2"
		
		dbSelectArea("DYV")
		DYV->( dbSetOrder(1) )
		If DYV->( dbSeek(FWxFilial("DYV")+FwFldGet("DYV_IDCDIA") ) )
			RECLOCK("DYV", .F. )
			DYV->DYV_STATUS := "2"
			MSUNLOCK() 
			
			dbSelectArea("DYX")
			DYX->( dbSetOrder(1) )
			If DYX->( dbSeek(FWxFilial("DYX")+FwFldGet("DYV_IDCDIA")+FwFldGet("DYX_ITEM",nCount)) )
				RECLOCK("DYX", .F. )	
				DYX->DYX_STATUS  := "4"
				MSUNLOCK() 
				FWFldPut("DYX_LEG",AB30Cor(),nCount,,,.T.)
				FWFldPut("DYX_STATUS","4",nCount,,,.T.)
			EndIf
		EndIf	
	EndIf
	
	FWFldPut("DYX_MARC",.F.,nCount,,,.T.) // Remove a marcação
Next nCount
FWRestRows( aSaveLine )

Return NIL

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30EOK()
Executa o Estorno

Uso: TMSAB30

@sample
//TMSAB30EOK(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 15/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB30EOK(oModel)
Local oModelItem := NIL		// Recebe o Model de Itens
Local nCount 	 := 0		// Recebe o contador
Local aSaveLine  := {}		// Recebe a posição das Linhas do Grid
Local nRecPar	 := 0	  	// Recebe a Parametrização corrente
Local oView		 := FwViewActive()
Local lRet       := .F.

oModelItem := oModel:GetModel( 'MdGridDYX' )
aSaveLine  := FWSaveRows()

BEGIN TRANSACTION

// Varre os Itens da Diaria 
For nCount := 1 To oModelItem:Length()
	
	oModelItem:GoLine( nCount )

	//-- Verifica se o mesmo não esta deletado e se esta marcado
	If !oModelItem:IsDeleted() .AND. oModelItem:GetValue("DYX_MARC") .AND. oModelItem:GetValue("DYX_ORIGEM") == "1"
		
		//-- Estorna o item
		Processa( {|lEnd| lRet := TMSAB30ESI(oModelItem:GetValue("DYX_IDCDIA"),oModelItem:GetValue("DYX_ITEM"),oModelItem:GetValue("DYX_NUMTIT"))  },,STR0050 + oModelItem:GetValue("DYX_ITEM") + " - " + STR0051 + oModelItem:GetValue("DYX_NUMTIT")  , .F. ) //"Aguarde...Cancelando o Item: "

		If lRet 
			      
			// Atualiza os campos da Tela
			oModelItem:LoadValue("DYX_NUMREC","")
			oModelItem:LoadValue("DYX_STATUS","5")
			oModelItem:LoadValue("DYX_NUMTIT","")
			oModelItem:LoadValue("DYX_DATAPR",STOD("//"))
			oModelItem:LoadValue("DYX_USRAPR","")
			oModelItem:LoadValue("DYX_NOMUSR","")
			oModelItem:LoadValue("DYX_LEG",AB30Cor( oModelItem:GetValue("DYX_STATUS") ))
			
		ElseIf !Empty(SE2->E2_BAIXA)
			Help('', 1,"HELP",, STR0030,1) //"O titulo ja foi baixado no financeiro."
		EndIf
	EndIf
	oModelItem:LoadValue("DYX_MARC",.F.) // Remove a marcação

Next nCount

END TRANSACTION

oView:Refresh("MdGridDYX")

FWRestRows( aSaveLine )

Return NIL

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30API()
Aprova Item

Uso: TMSAB30

@sample
//TMSAB30API(nRecPar,aItens,lBaixa,lImprime)

@author Paulo Henrique Corrêa Cardoso.
@since 15/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB30API(nRecPar,aItens,lBaixa,lImprime)
Local lRet 		:= .F.		// Recebe o Retorno logico
Local aRet		:= {}		// Recebe o Retorno
Local aTit 		:= {}		// Recebe o Titulo de Contas a Pagar
Local cCodTit	:= ""		// Recebe o codigo do titulo
Local cDocDes 	:= ""		// Recebe o Codigo da despesa
Local nCount	:= 0		// Recebe o contador
Local cChave	:= ""		// Recebe a Chave DYX	
Local nValor	:= 0		// Recebe o Valor 
Local lAglutina	:= .F.		// Verifica se aglutina	
Local cNatureza	:= ""		// Recebe a natureza
Local aRecibos	:= {}		// Recebe os recibos
Local lDebito	:= .F.		// Verifica se é diaria de Debito
Local cTipTit	:= ""		// Recebe o tipo do titulo
Local cNumRec	:= ""		// Recebe o codigo do recibo
Local aRecSe2	:= {}		// Recebe os titulos de credito para compensacao
Local aRecNDF	:= {}		// Recebe os titulos de debito para compensacao
Local cCodUsr 	:= RetCodUsr() 
Local cNomUser  := UsrFullName(cCodUsr)
Local cCCusto	:= ""
Local cCContabil:= ""
Local aAreas	:= {}

Local lErro := .F.

Private lMsErroAuto := .F.

Default nRecPar 	:= 0
Default aItens 		:= {}
Default lBaixa 		:= .F.
Default lImprime 	:= .T.

aAreas := {;
	DYU->(GetArea()),;
	DT7->(GetArea()),;
	DYV->(GetArea()),;
	DYX->(GetArea()),;
	SE2->(GetArea()),;
	SA2->(GetArea()),;
	DA4->(GetArea())}

// Posiciona na Paramentrização corrente
dbSelectArea("DYU")
DYU->( dbGoTo(nRecPar) )

DT7->(dbSetOrder(1))
If DT7->(MsSeek(FwxFilial("DT7")+DYU->DYU_CODDES))
	cCCusto		:= DT7->DT7_CC
	cCContabil	:= DT7->DT7_CONTA
EndIf

lAglutina := Iif(DYU->DYU_AGLUTI == "1",.T.,.F.)

dbSelectArea("DYV")
DYV->( dbSetOrder(1) )

dbSelectArea("DYX")
DYX->( dbSetOrder(1) )

dbSelectArea("SE2")
SE2->( dbSetOrder(1) )

dbSelectArea("SA2")
SA2->( dbSetOrder(1) )

dbSelectArea("DA4")
DA4->( dbSetOrder(1) )

// Verifica se aglutina o titulo da E2
If lAglutina

	cCodTit := TMSAB30Tit("SE2",DYU->DYU_PREFIX)	
		
	For nCount := 1 To Len(aItens)
		cChave := aItens[nCount][1]+aItens[nCount][2]
	
		If DYX->(dbSeek(FWxFilial("DYX")+cChave))
			
			lDebito := iIF(DYX->DYX_TIPDIA == "2",.T.,.F.)
			
			DYV->(dbSeek(FWxFilial("DYV")+aItens[nCount][1]))
			If !lDebito
				cDocDes := AB30Despes(1,cChave,lBaixa,DYX->DYX_VLRTOT,DYV->DYV_FILORI,DYV->DYV_VIAGEM,DYU->DYU_CODDES)
				AADD(aRecibos,{aItens[1][1],aItens[1][2]})
				cTipTit := DYU->DYU_TPTCRE 
				cNumRec := aItens[1][1] + aItens[1][2]
			Else
				cTipTit := DYU->DYU_TPTDEB 
				cDocDes := ""
				cNumRec := ""
			EndIf
			nValor	+= DYX->DYX_VLRTOT
			
			
			If DA4->( dbSeek( FWxFilial("DA4") + DYV->DYV_CODMOT ) ) 
			
				//Atualiza os campos do item da diaria
				RECLOCK("DYX", .F. )	
				DYX->DYX_STATUS  := "3"
				DYX->DYX_PRETIT  := DYU->DYU_PREFIX 
				DYX->DYX_NUMTIT  := cCodTit
				DYX->DYX_DATAPR	 := dDataBase
				DYX->DYX_USRAPR	 := cCodUsr		
				DYX->DYX_NUMDES  := cDocDes
				DYX->DYX_NUMREC  := cNumRec
				DYX->DYX_FORNEC	 := DA4->DA4_FORNEC
				DYX->DYX_LOJA	 := DA4->DA4_LOJA
	
				MSUNLOCK()  	
				lRet := .T.	
			
				// Array de Retorno
				/*
				 [1]Retorno Logico 
				 [2]Status
				 [3]Numero do Recibo
				 [4]Numero do Titulo
				 [5]Documento de Despesa
				 [6]Data de Aprovação
				 [7]Usuario de Aprovação
				*/
				AADD(aRet,{lRet,"3",cNumRec,DYU->DYU_PREFIX,cCodTit,cDocDes,dDataBase,cCodUsr,cNomUser}) 
			EndIf	
		EndIf
		
	Next nCount
	
	// Busca o Fornecedor
	If DA4->( dbSeek( FWxFilial("DA4") + DYV->DYV_CODMOT ) ) 
		
		// Verifica se a natureza do fornecedor esta preenchida
		If SA2->( dbSeek(FWxFilial("SA2")+ DA4->DA4_FORNEC + DA4->DA4_LOJA) )
			
			If !Empty(SA2->A2_NATUREZ)
				cNatureza := SA2->A2_NATUREZ
			Else
				cNatureza := DYU->DYU_NATDIA 
			EndIf
		EndIf
		
		aTit :=   { { "E2_PREFIXO"  , DYU->DYU_PREFIX   , NIL },;
		            { "E2_NUM"      , cCodTit		    , NIL },;
		            { "E2_TIPO"     , cTipTit           , NIL },;
		            { "E2_NATUREZ"  , cNatureza			, NIL },;
		            { "E2_FORNECE"  , DA4->DA4_FORNEC   , NIL },;
		            { "E2_LOJA"  	, DA4->DA4_LOJA		, NIL },;
		            { "E2_EMISSAO"  , dDatabase			, NIL },;
		            { "E2_VENCTO"   , dDatabase			, NIL },;
		            { "E2_VENCREA"  , dDatabase			, NIL },;
		            { "E2_ORIGEM" 	, 'SIGATMS'			, NIL },;
		            { "E2_VALOR"    , nValor		    , NIL },;
		            { "E2_HIST"     , DA4->DA4_NOME	    , NIL },;
					{ "E2_CCUSTO"   , cCCusto			, NIL },;
					{ "E2_CONTAD"   , cCContabil		, NIL } }
	 
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTit,, 3)  // Adiciona o Titulo
	 
		If lMsErroAuto
			lErro := .T.
			aRet := {}
			MostraErro()
		Else
			
			If !lDebito
				aRecSe2 := {}
				AADD(aRecSe2,SE2->(RECNO()))
				
				aRecNDF := AB30TitAbt(DYV->DYV_CODMOT,DYU->DYU_TPTDEB)
				
				//Compensacao automatica do titulo
				MaIntBxCP(2,aRecSe2,,aRecNDF,,{.T.,.F.,.F.,.F.,.F.,.F.}) 
			
			
				//Atualiza o campo de Valor do Titulo na DYX
				nCount := 0
				For nCount := 1 To Len(aItens)
					cChave := aItens[nCount][1]+aItens[nCount][2]
					If DYX->(dbSeek(FWxFilial("DYX")+cChave))
						If DYX->DYX_TIPDIA != "2"
							RECLOCK("DYX", .F. )
							DYX->DYX_VALTIT := SE2->E2_SALDO
							MSUNLOCK()  
						EndIf
					EndIF
				Next nCount
				
			EndIf
					
			If !Empty(aRecibos) .AND. lImprime
				U_TMSRB10(aRecibos)
			EndIf
		EndIf
	EndIf
Else
	For nCount := 1 To Len(aItens)
		lRet := .F.
		
		cChave := aItens[nCount][1]+aItens[nCount][2]
		
		cCodTit := TMSAB30Tit("SE2",DYU->DYU_PREFIX)	
	
		If DYX->(dbSeek(FWxFilial("DYX")+cChave))
			
			lDebito := iIF(DYX->DYX_TIPDIA == "2",.T.,.F.)
			DYV->(dbSeek(FWxFilial("DYV")+aItens[nCount][1]))
			
			If !lDebito
				cTipTit := DYU->DYU_TPTCRE 
			Else
				cTipTit := DYU->DYU_TPTDEB 
			EndIf
			
			// Busca o Fornecedor
			If DA4->( dbSeek( FWxFilial("DA4") + DYV->DYV_CODMOT ) ) 
				// Verifica se a natureza do fornecedor esta preenchida
				If SA2->( dbSeek(FWxFilial("SA2")+DA4->DA4_FORNEC + DA4->DA4_LOJA) )
					
					If !Empty(SA2->A2_NATUREZ)
						cNatureza := SA2->A2_NATUREZ
					Else
						cNatureza := DYU->DYU_NATDIA 
					EndIf
				EndIf
				
				aTit :=   { { "E2_PREFIXO"  , DYU->DYU_PREFIX   , NIL },;
				            { "E2_NUM"      , cCodTit		    , NIL },;
				            { "E2_TIPO"     , DYU->DYU_TPTCRE   , NIL },;
				            { "E2_NATUREZ"  , cNatureza         , NIL },;
				            { "E2_FORNECE"  , DA4->DA4_FORNEC   , NIL },;
				            { "E2_LOJA"  	, DA4->DA4_LOJA		, NIL },;
				            { "E2_EMISSAO"  , dDatabase			, NIL },;
				            { "E2_VENCTO"   , dDatabase			, NIL },;
				            { "E2_VENCREA"  , dDatabase			, NIL },;
				            { "E2_ORIGEM" 	, 'SIGATMS'			, NIL },;
				            { "E2_VALOR"    , DYX->DYX_VLRTOT   , NIL },;
		            		{ "E2_HIST"     , DA4->DA4_NOME	    , NIL },;
							{ "E2_CCUSTO"   , cCCusto			, NIL },;
							{ "E2_CONTAD"   , cCContabil		, NIL } }
		            		
			    MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTit,, 3)  // Adiciona o Titulo
	 
				If lMsErroAuto
					lErro := .T.
					MostraErro()
				Else
	
					If !lDebito
						aRecSe2 := {}
						AADD(aRecSe2,SE2->(RECNO()))
						aRecNDF := AB30TitAbt(DYV->DYV_CODMOT,DYU->DYU_TPTDEB)
						//Compensacao automatica do titulo
						MaIntBxCP(2,aRecSe2,,aRecNDF,,{.T.,.F.,.F.,.F.,.F.,.F.}) 
						
						cDocDes := AB30Despes(1,cChave,lBaixa,DYX->DYX_VLRTOT,DYV->DYV_FILORI,DYV->DYV_VIAGEM,DYU->DYU_CODDES)
						AADD(aRecibos,{aItens[nCount][1],aItens[nCount][2]})
						cNumRec := cChave
					Else
						cDocDes := ""
						cNumRec := ""
					EndIf
					//Atualiza os campos do item da diaria
					RECLOCK("DYX", .F. )	
					DYX->DYX_STATUS  := "3"
					DYX->DYX_PRETIT  := DYU->DYU_PREFIX 
					DYX->DYX_NUMTIT  := cCodTit
					DYX->DYX_DATAPR	 := dDataBase
					DYX->DYX_USRAPR	 := cCodUsr
					DYX->DYX_NUMREC  := cNumRec
					DYX->DYX_NUMDES  := cDocDes
					DYX->DYX_FORNEC	 := SE2->E2_FORNECE
					DYX->DYX_LOJA	 := SE2->E2_LOJA 
					DYX->DYX_VALTIT	 := SE2->E2_SALDO
					MSUNLOCK()  	
					lRet := .T.	
					
					// Array de Retorno
					/*
					 [1]Retorno Logico 
					 [2]Status
					 [3]Numero do Recibo
					 [4]Numero do Titulo
					 [5]Documento de Despesa
					 [6]Data de Aprovação
					 [7]Usuario de Aprovação
					*/
					AADD(aRet,{lRet,"3",cNumRec,DYU->DYU_PREFIX,cCodTit,cDocDes,dDataBase,cCodUsr,cNomUser}) 	
				EndIf 
			EndIf       
		EndIf
		
	Next nCount
	If !Empty(aRecibos).AND. lImprime
		U_TMSRB10(aRecibos)
	EndIf
EndIf

// Atualiza o Staus da DYV
If !lErro .And. Len(aItens)>0
	If AB30BusSta(aItens[1][1])
		dbSelectArea("DYV")
		DYV->(dbSetOrder(1))
		If DYV->( dbSeek(FWxFilial("DYV")+aItens[1][1]) )
			RECLOCK("DYV", .F. )
			DYV->DYV_STATUS := "1"
			MSUNLOCK() 
		EndIf 
	Endif
EndIf

AEval(aAreas,{|x,y| RestArea(x)})
aAreas := aSize(aAreas,0)
aAreas := Nil

Return aRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30ESI()
Estorna Item

Uso: TMSAB30

@sample
//TMSAB30ESI(cCodigo,cItem,cCodTit)

@author Paulo Henrique Corrêa Cardoso.
@since 15/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB30ESI(cCodigo,cItem,cCodTit)
Local lRet 		:= .F.		// Recebe o Retorno
Local aTit 		:= {}		// Recebe o Titulo de Contas a Pagar
Local aArea		:= GetArea()
Local aAreaDYX	:= DYX->(GetArea())

Private lMsErroAuto := .F.

Default cCodigo := ""
Default cItem 	:= ""
Default	cCodTit	:= ""

dbSelectArea("SE2")  
SE2->( dbSetOrder(1) )

dbSelectArea("DYX")
DYX->( dbSetOrder(1) )

//Realiza o Estorno
If DYX->( dbSeek(FWxFilial("DYX")+cCodigo+cItem) )

	// Verifica se o Titulo existe
	If SE2->(dbSeek(FWxFilial("SE2")+DYX->DYX_PRETIT+ALLTRIM(cCodTit))) 
		
		If Empty(SE2->E2_BAIXA)
	
			aTit :=   { { "E2_PREFIXO"  , SE2->E2_PREFIXO   	, NIL },;
			            { "E2_NUM"      , SE2->E2_NUM   	    , NIL } }
			 
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aTit,, 5)  //Exclui o Titulo
			 
			If lMsErroAuto
			    MostraErro() 
			Else
				AB30Despes(2,DYX->DYX_NUMDES)
				//Atualiza os campos do item da diaria
				RECLOCK("DYX", .F. )	
				DYX->DYX_STATUS := "5"
				DYX->DYX_NUMREC := ""
				DYX->DYX_NUMTIT := ""
				DYX->DYX_NUMDES := ""
				DYX->DYX_DATAPR	:= STOD("//")
				DYX->DYX_USRAPR	:= ""
				DYX->DYX_FORNEC	:= ""
				DYX->DYX_LOJA	:= "" 
				DYX->DYX_VALTIT := 0
				MSUNLOCK()  	
				lRet := .T.	
			Endif
		EndIf
	Else
		//Atualiza os campos do item da diaria
		AB30Despes(2,DYX->DYX_NUMDES)
		RECLOCK("DYX", .F. )	
		DYX->DYX_STATUS := "5"
		DYX->DYX_NUMREC := ""
		DYX->DYX_NUMTIT := ""
		DYX->DYX_NUMDES := ""
		DYX->DYX_DATAPR	:= STOD("//")
		DYX->DYX_USRAPR	:= ""
		DYX->DYX_FORNEC	:= ""
		DYX->DYX_LOJA	:= "" 
		DYX->DYX_VALTIT := 0
		MSUNLOCK()  	
		lRet := .T.	
	EndIf
	
	// Atualiza o Staus da DYV
	If AB30BusSta(cCodigo)
		dbSelectArea("DYV")
		DYV->(dbSetOrder(1))
		If DYV->( dbSeek(FWxFilial("DYV")+cCodigo) )
			RECLOCK("DYV", .F. )
			DYV->DYV_STATUS := "1"
			MSUNLOCK() 
		EndIf 
	Endif
	
EndIf

RestArea(aAreaDYX)
RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30PARM()
Busca o RECNO da Parametrização corrente

Uso: TMSAB30

@sample
//TMSAB30PARM()

@author Paulo Henrique Corrêa Cardoso.
@since 15/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB30PARM()
Local cDatAtual  := ""		// Recebe a data atual
Local cQuery	 := ""		// Recebe a Query
Local cAliasDYU	 := ""		// Recebe o proximo alias disponivel
Local nRecParDia := 0		// Recebe o Recno da Parametrização corrente

cAliasDYU := GetNextAlias()
cDatAtual := DTOS(dDataBase)

// Busca a Parametrização(DYU) corrente
cQuery += " SELECT R_E_C_N_O_ AS RECNO 				"	+ CRLF
cQuery += " FROM " + RetSqlName( 'DYU' )				+ CRLF
cQuery += " WHERE	D_E_L_E_T_ = ' ' 				"	+ CRLF
cQuery += " 	AND DYU_INIVIG <= '"+ cDatAtual +"' " 	+ CRLF
cQuery += " 	AND DYU_FIMVIG >= '"+ cDatAtual +"' " 	+ CRLF

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDYU, .F., .T. )

If !(cAliasDYU)->(EOF())
	nRecParDia := (cAliasDYU)->RECNO
EndIf

(cAliasDYU)->( DbCloseArea() )

Return nRecParDia


/*/-----------------------------------------------------------
{Protheus.doc} AB30UltVia()
Busca o RECNO da Ultima Viagem do Motorista

Uso: TMSAB30

@sample
//AB30UltVia(cCodMot)

@author Paulo Henrique Corrêa Cardoso.
@since 20/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30UltVia(cCodMot)
Local cAliasDUP := GetNextAlias()	// Recebe o Proximo alias disponivel
Local nRecno	:= 0				// Recebe o Recno da Viagem 
Local cQuery	:= ""				// Recebe a query

//Busca a ultima Viagem do Motorista
			
cQuery += " SELECT	MAX(DTQ.R_E_C_N_O_) AS RECNO 			" + CRLF
cQuery += " FROM " + RetSqlName( 'DTQ' )+ " DTQ 			" + CRLF
cQuery += " 	INNER JOIN " + RetSqlName( 'DUP' )+ " DUP 	" + CRLF
cQuery += " 		ON	DTQ_FILIAL = DUP_FILIAL				" + CRLF
cQuery += " 			AND DTQ_FILORI = DUP_FILORI			" + CRLF
cQuery += " 			AND DTQ_VIAGEM = DUP_VIAGEM			" + CRLF	
cQuery += " WHERE	DTQ.D_E_L_E_T_ = ' '					" + CRLF
cQuery += " 		AND DUP.D_E_L_E_T_ = ' '				" + CRLF
cQuery += " 		AND DUP_CODMOT = '"+ cCodMot +"'		" + CRLF
cQuery += " GROUP BY DUP_CODMOT								" + CRLF

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasDUP, .F., .T. )

If !(cAliasDUP)->(EOF())
	nRecno := (cAliasDUP)->RECNO
EndIf

(cAliasDUP)->(dbCloseArea())

Return nRecno 

/*/-----------------------------------------------------------
{Protheus.doc} AB30Despes()
Movimentações de Despesa

Uso: TMSAB30

@sample
//AB30Despes(nOpc,cDoc,lBaixa,nVlTot,cFilOri,cViagem)

@author Paulo Henrique Corrêa Cardoso.
@since 21/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30Despes(nOpc,cDoc,lBaixa,nVlTot,cFilOri,cViagem,cDespesa)
Local cRet 		:= .T.	// Recebe o Retorno
Local cNumSeq 	:= ""	// Recebe o proximo numero da Sequencia
Local aCabSDG	:= {} 
Local lGerador  := SDG->(ColumnPos("DG_GERADOR") > 0)
Local lCont     := .T.

Default nOpc 	 := 0	// Recebe a Opção 1=Inclui 2= Exclui
Default cDoc 	 := ""	// Recebe o Numero do documento
Default lBaixa 	 := .F.	// Recebe a opção de baixa automatica
Default nVlTot	 := 0	// Recebe o Valor total
Default cFilOri	 := ""	// Recebe a Filial de Origem
Default cViagem	 := ""	// Recebe a Viagem
Default cDespesa := ""	// Recebe o Codigo da Despesa

dbSelectArea("SDG")
SDG->(dbSetorder(1))

// Incluir Despesa
If nOpc == 1
	
	cDoc := TMSAB30Tit("SDG")	

	cRet := cDoc
	
	cNumSeq := ProxNum()
	Aadd( aCabSDG , { "DG_FILIAL" , xFilial("SDG") , Nil })
	Aadd( aCabSDG , { "DG_ITEM" , "01" , Nil })
	Aadd( aCabSDG , { "DG_DOC" , cDoc , Nil })
	Aadd( aCabSDG , { "DG_EMISSAO" , dDataBase , Nil })
	Aadd( aCabSDG , { "DG_ORIGEM" , "DYV" , Nil })
	Aadd( aCabSDG , { "DG_CODDES" , cDespesa, Nil })
	Aadd( aCabSDG , { "DG_FILORI" , cFilOri, Nil })
	Aadd( aCabSDG , { "DG_VIAGEM" , cViagem , Nil })
	Aadd( aCabSDG , { "DG_NUMSEQ" , cNumSeq, Nil })
	Aadd( aCabSDG , { "DG_SEQORI" , cNumSeq, Nil })
	Aadd( aCabSDG , { "DG_SEQMOV" , cNumSeq, Nil })
	Aadd( aCabSDG , { "DG_TOTAL" , nVlTot, Nil })
	Aadd( aCabSDG , { "DG_CUSTO1" , nVlTot, Nil })
	Aadd( aCabSDG , { "DG_VALCOB" , nVlTot, Nil })
	Aadd( aCabSDG , { "DG_SALDO" , nVlTot, Nil })
	Aadd( aCabSDG , { "DG_DATVENC" , dDataBase, Nil })
	Aadd( aCabSDG , { "DG_TES" , "999", Nil })
	Aadd( aCabSDG , { "DG_PERC" , 100 , Nil })
	Aadd( aCabSDG , { "DG_STATUS" , StrZero(1,Len(SDG->DG_STATUS)) , Nil })
	
	If lGerador
		Aadd( aCabSDG , { "DG_GERADOR" , "TMSAB30" , Nil })
		Aadd( aCabSDG , { "DG_TIPGER" ,  "1" , Nil })
	EndIf

	AtuTabSDG( aCabSDG , 3 )	
	//Baixar Despesa
	If lBaixa
		TMSA070Bx("1",cNumSeq,cFilOri,cViagem,,,,nVlTot)
	EndIf
	lRet := .T.
// Estornar Despesa	
ElseIf nOpc == 2

	// Estornar baixa da despesa
	If SDG->(dbSeek( xFilial("SDG")+ cDoc ))
		lCont := Iif(lGerador,AllTrim(SDG->DG_GERADOR) == "TMSAB30" .And. SDG->DG_TIPGER == "1",.T.)
		If lCont
			If SDG->DG_STATUS  == "3"
				TMSA070Bx("2",SDG->DG_NUMSEQ)
			EndIf	
			
			AtuTabSDG( , 5 )
			
		EndIf
		cRet := ""
		lRet := .T.
	EndIf
EndIf	

Return cRet

/*/-----------------------------------------------------------
{Protheus.doc} AB30CalTot()
Calcula o campo Total

Uso: TMSAB30

@sample
//AB30CalTot()

@author Paulo Henrique Corrêa Cardoso.
@since 21/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function AB30CalTot()
Local lRet := .F.		// Recebe o Retorno
Local nVlrTot := 0		// Recebe o Valor Liquido Calculado

nVlrTot := (FwFldGet("DYX_QTDE") * FwFldGet("DYX_VLRUNI"))

If nVlrTot >= 0
	FwFldPut("DYX_VLRTOT",nVlrTot,,,,.T.)
	lRet := .T.
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} AB30RsvMot()
Verifica as reservas do Motorista

Uso: TMSAB30

@sample
//AB30RsvMot(cCodMot)

@author Paulo Henrique Corrêa Cardoso.
@since 21/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30RsvMot(cCodMot)
Local cAliasMot := GetNextAlias()	// Recebe o Proximo alias disponivel
Local lRet		:= .F.				// Recebe o Retorno	
Local cQuery	:= ""				// Recebe a Query	
			
Default cCodMot := ""
//Verifica as reservas do Motorista
		
cQuery += " SELECT COUNT(1) AS QTD 						   " + CRLF
cQuery += " FROM " + RetSqlName( 'DTQ' )+ " DTQ 		   " + CRLF
cQuery += " INNER JOIN " + RetSqlName( 'DUP' )+ " DUP 	   " + CRLF
cQuery += "		 ON	DTQ_FILIAL = DUP_FILIAL 			   " + CRLF
cQuery += " 		AND DTQ_FILORI = DUP_FILORI 		   " + CRLF
cQuery += " 		AND DTQ_VIAGEM = DUP_VIAGEM 		   " + CRLF
cQuery += " WHERE  DTQ.D_E_L_E_T_ = ' ' 				   " + CRLF
cQuery += " 	   AND DUP.D_E_L_E_T_ = ' ' 			   " + CRLF
cQuery += "        AND DTQ_FILIAL = '"+FWxFilial("DTQ")+"' " + CRLF
cQuery += "	   	   AND DUP_CODMOT = '"+ cCodMot +"'  	   " + CRLF
cQuery += " 	   AND DTQ_STATUS IN ('1','5','2','4') 	   " + CRLF

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasMot, .F., .T. )

If !(cAliasMot)->(EOF()) .AND. (cAliasMot)->QTD > 0
	lRet := .T.
EndIf

(cAliasMot)->(dbCloseArea())
	   
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} AB30QtdDia()
Verifica se ultrapassou a quantidade de diarias

Uso: TMSAB30

@sample
//AB30QtdDia(cViagem,cFilOriVia,nCount)

@author Paulo Henrique Corrêa Cardoso.
@since 23/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30QtdDia(cViagem,cFilOriVia,nLinha,oModel)
Local cRet 		 := ""				// Recebe o Retorno
Local cAliasQtd  := GetNextAlias()	// Recebe o Proximo alias disponivel
Local cQuery	 := ""				// Recebe a Query
Local nQtdDYT	 := 0				// Recebe a quantidade da DYT
Local nQtdDyxAut := 0				// Recebe a Quantidade Automatica da DYX
Local nQtdDyxMan := 0				// Recebe a Quantidade Manual da DYX
Local cTipVia	 := ""				// Recebe o Tipo da Viagem 
Local cTipVei	 := ""				// Recebe o Tipo do Veiculo
Local cCondut	 := ""				// Recebe o Tipo do Condutor
Local cTipVal	 := ""				// Recebe o Tipo de Valor
Local cIdCDia	 := ""				// Recebe o Id do Controle de Diarias
Local cItemCDia	 := ""				// Recebe o Item do Controle de Diarias
Local nQtdDia	 := 0				// Recebe a quantidade lançada	

Default cViagem		:= ""
Default cFilOriVia	:= ""
Default nLinha		:= 0
Default oModel := FwLoadModel("TMSAB30") 
dbSelectArea("DTQ")
DTQ->( dbSetOrder(2) )

If DTQ->( dbSeek(FWxFilial("DTQ")+ cFilOriVia + cViagem ) )
	
	cTipVia	  := FwFldGet("DYX_TIPVIA",nLinha,oModel)
	cTipVei	  := FwFldGet("DYX_TIPVEI",nLinha,oModel)
	cCondut	  := FwFldGet("DYX_CONDUT",nLinha,oModel) 
	cTipVal	  := FwFldGet("DYX_TIPVAL",nLinha,oModel)
	cIdCDia   := FwFldGet("DYX_IDCDIA",nLinha,oModel)
	cItemCDia := FwFldGet("DYX_ITEM"  ,nLinha,oModel)
	nQtdDia   := FwFldGet("DYX_QTDE"  ,nLinha,oModel)
	
	// Busca a quantidade de diarias permitida para a viagem		 
	cQuery := "  SELECT DYT_QTDE 				  														" + CRLF
	cQuery += "  FROM " + RetSqlName( 'DYS' )+ " DYS 													" + CRLF
	cQuery += "  INNER JOIN " + RetSqlName( 'DYT' )+ " DYT												" + CRLF
	cQuery += "  	ON  DYS_FILIAL = DYT_FILIAL															" + CRLF
	cQuery += "  		AND DYS_IDDIA = DYT_IDDIA														" + CRLF
	cQuery += "  WHERE  DYS.D_E_L_E_T_ = ' '															" + CRLF
	cQuery += " 		AND DYT.D_E_L_E_T_ = ' ' 														" + CRLF
	cQuery += " 		AND (																			" + CRLF
	cQuery += " 			    ( DYS_ROTA = '"+ DTQ->DTQ_ROTA +"'  AND DYS_TIPVIA = '"+ cTipVia +"')	" + CRLF
	cQuery += " 			 	OR (DYS_ROTA = '"+ DTQ->DTQ_ROTA +"'  AND   DYS_TIPVIA = '')			" + CRLF
	cQuery += " 			 	OR (DYS_TIPVIA = '"+ cTipVia +"' AND DYS_ROTA = '')						" + CRLF
	cQuery += " 			 )																			" + CRLF
	cQuery += " 		AND DYT_TIPVEI = '"+ cTipVei +"'												" + CRLF
	cQuery += " 		AND DYT_CONDUT = '"+ cCondut +"' 												" + CRLF
	cQuery += " 		AND DYT_TIPVAL = '"+ cTipVal +"'												" + CRLF
	cQuery += "  ORDER BY DYS_ROTA DESC ,DYS_TIPVIA DESC												" + CRLF
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQtd, .F., .T. )
	
	If !(cAliasQtd)->(EOF())
		nQtdDYT := (cAliasQtd)->DYT_QTDE
		
		(cAliasQtd)->(dbCloseArea())
		
		// Busca a quantidade de diarias ja inseridas para a viagem
		cAliasQtd := GetNextAlias()
		
		cQuery := "	SELECT ISNULL(SUM(DYX_QTDE),0) AS QTDDIA	" + CRLF
		cQuery += "        ,DYX_ORIGEM							" + CRLF
		cQuery += " FROM " + RetSqlName( 'DYV' )+ " DYV			" + CRLF
		cQuery += " INNER JOIN " + RetSqlName( 'DYX' )+ " DYX	" + CRLF
		cQuery += " ON DYV_FILIAL = DYX_FILIAL 					" + CRLF
		cQuery += "    AND DYV_IDCDIA = DYX_IDCDIA	 			" + CRLF
		cQuery += " WHERE DYV.D_E_L_E_T_ = ' '					" + CRLF
		cQuery += "	  AND DYV_FILORI = '"+ cFilOriVia +"'		" + CRLF
		cQuery += "	  AND DYV_VIAGEM = '"+ cViagem +"'			" + CRLF
		cQuery += "	  AND DYX_CONDUT = '"+ cCondut +"'			" + CRLF
		cQuery += "	  AND DYX_TIPVAL = '"+ cTipVal +"'			" + CRLF
		cQuery += "	  AND DYX_TIPVEI = '"+ cTipVei +"'			" + CRLF
		cQuery += "	  AND DYX_TIPVIA = '"+ cTipVia +"'			" + CRLF
		cQuery += "	  AND DYX_STATUS <> '5'						" + CRLF
		cQuery += "	  AND DYX.R_E_C_N_O_ NOT IN (SELECT R_E_C_N_O_ 						" + CRLF
		cQuery += "	 	     						FROM " + RetSqlName( 'DYX' ) 		  + CRLF
		cQuery += "								 WHERE D_E_L_E_T_ = ' ' 				" + CRLF
		cQuery += "								 AND DYX_IDCDIA = '"+ cIdCDia +" '		" + CRLF
		cQuery += "								 AND DYX_ITEM = '"+ cItemCDia +"' 		" + CRLF
		cQuery += "								 AND DYX_FILIAL = DYX.DYX_FILIAL )		" + CRLF
		cQuery += " Group By DYX_ORIGEM													" + CRLF

		cQuery := ChangeQuery(cQuery)
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQtd, .F., .T. )		
 		
		While !(cAliasQtd)->(EOF()) 
		
			If (cAliasQtd)->DYX_ORIGEM == "1" // Manual
			
				nQtdDyxMan += (cAliasQtd)->QTDDIA
				
			ElseIf (cAliasQtd)->DYX_ORIGEM == "2" // Automatica
			
				nQtdDyxAut += (cAliasQtd)->QTDDIA 
				
			EndIf
			(cAliasQtd)->(DbSkip())
		EndDo
		
		(cAliasQtd)->(dbCloseArea())
		
		dbSelectArea("DUP")
		DUP->( dbSetOrder(2) )
		
		If	DUP->(dbSeek( FWxFilial("DUP")+ cFilOriVia + cViagem + ALLTRIM(FwFldGet("DYV_CODMOT",,oModel)) ))	
			// Verifica se ja ocorreu fechamento para a viagem quando o motorista recebe diaria
			If nQtdDyxAut == 0 .AND. DTQ->DTQ_STATUS == "1"  .AND. DUP->DUP_PAGDIA == '1' 
				cRet += STR0009 + CRLF //"Ainda não foi realizado o fechamento para esta viagem."
			EndIf
			
		EndIf
		
		// Verifica se a quantidade lançada ja ultrapassou a quantidade permitida na diaria
		If nQtdDyxMan +  nQtdDyxAut + nQtdDia > nQtdDYT
			cRet += STR0013 +cValToChar(nQtdDYT) + CRLF //"Quantidade lançada acima do limite no cadastro de diarias: "	
		EndIf
		
	Else
		cRet += STR0015 + CRLF //"Não existe nenhum cadastro de diarias para os valores informados."
	EndIf
	
EndIf

Return cRet 

/*/-----------------------------------------------------------
{Protheus.doc} AB30ValMot()
Valida o Motorista

Uso: TMSAB30


@sample
//AB30ValMot()

@author Paulo Henrique Corrêa Cardoso.
@since 24/01/2014
@version 1.0
-----------------------------------------------------------/*/
Function AB30ValMot()
Local lRet 	  := .T. 			// Recebe o Retorno
Local cForGen := ""				// Recebe o Fornecedor Generico

cForGen :=  SuperGetMv ("MV_FORGEN", .F., "") 

dbSelectArea("DA4")
DA4->(dbSetOrder(1))

// Busca o Motorista
If DbSeek(FWxFilial("DA4")+("DYV_CODMOT"))
	
	// Verifica se é um Motorista Proprio
	If DA4->DA4_TIPMOT != "1"
		Help('', 1,"HELP",, STR0033,1)//"Nao e um motorista proprio."
		lRet:= .F.
	EndIf
	
	// Verifica se o Motorista esta cadastrado como fornecedor
	dbSelectArea("SA2")
	SA2->( dbSetOrder(1) )
	If !SA2->( dbSeek(FWxFilial("SA2")+ DA4->DA4_FORNEC + DA4->DA4_LOJA) ) 
		Help('', 1,"HELP",, STR0034,1) //"O motorista nao esta vinculado a um fornecedor."
		lRet:= .F.
	ElseIf  cForGen == DA4->DA4_FORNEC + DA4->DA4_LOJA  
		Help('', 1,"HELP",, STR0042,1) //"O fornecedor vinculado ao motorista não pode ser o fornecedor generico."
		lRet:= .F.
	EndIf
EndIf
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} AB30VISTIT()
Exibe o Detalhe do Titulo

Uso: TMSAB30


@sample
//AB30VISTIT()

@author Paulo Henrique Corrêa Cardoso.
@since 31/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30VISTIT()
Local cNumTit	:= ""				// Recebe o Numero do Titulo
Local cPreTit	:= ""				// Recebe o Prefixo do Titulo

cPreTit := FwFldGet("DYX_PRETIT") 
cNumTit := ALLTRIM(FwFldGet("DYX_NUMTIT"))
 
If !Empty(cNumTit) .AND. !Empty(cPreTit)

	dbSelectArea("SE2")
	SE2->(dbSetOrder(1))
	
	If SE2->(dbSeek( xFilial("SE2")+ cPreTit + cNumTit ))
		Fc050Con()	
	EndIf
Else	
	ApMsgInfo(STR0035)//"Necessaria a Aprovacao da Diaria."
EndIf

Return 

/*/-----------------------------------------------------------
{Protheus.doc} AB30TitAbt()
Busac os titulos de Debito sem baixa ou com baixa parcial do Motorista

Uso: TMSAB30


@sample
//AB30TitAbt(cMotorista,cTipTit)

@author Paulo Henrique Corrêa Cardoso.
@since 31/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30TitAbt(cMotorista,cTipTit)
Local aRet 		:= {}		// Recebe o Retorno
Local cQuery	:= ""		// Recebe a Query
Local cAliasQry	:= ""		// Recebe o Proximo alias disponivel

cAliasQry 	:= GetNextAlias()

dbSelectarea("DA4")
DA4->(dbSetOrder(1))

If DA4->(dbSeek(FWxFilial("DA4") + cMotorista ))

	cQuery += " SELECT R_E_C_N_O_ AS RECNO 						" + CRLF
	cQuery += " FROM " + RetSqlName( "SE2" ) 					  + CRLF
	cQuery += " WHERE D_E_L_E_T_ = ' ' 							" + CRLF
	cQuery += " 	  AND E2_FILIAL = '"+ FWxFilial("SE2") +"'	" + CRLF 
	cQuery += " 	  AND ( E2_BAIXA = ' ' OR E2_SALDO > 0 )	" + CRLF
	cQuery += " 	  AND E2_FORNECE = '"+ DA4->DA4_FORNEC +"'	" + CRLF
	cQuery += " 	  AND E2_LOJA = '"+ DA4->DA4_LOJA +"'		" + CRLF
	cQuery += " 	  AND E2_TIPO = '"+ cTipTit +"' 			" + CRLF
	
	cQuery := ChangeQuery(cQuery)
			
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )		
	 		
	While !(cAliasQry)->(EOF()) 
		AADD(aRet, (cAliasQry)->RECNO)
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

EndIf

Return aRet


/*/-----------------------------------------------------------
{Protheus.doc} AB30BusSta()
Busca o status do controle de diaria

Uso: TMSAB30


@sample
//AB30BusSta(cIdDiar)

@author Paulo Henrique Corrêa Cardoso.
@since 17/02/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function AB30BusSta(cIdDiar)
Local lRet 		:= .T.		// Recebe o retorno.
Local cQuery	:= ""		// Recebe a Query.
Local cAliasQry	:= ""		// Recebe o Proximo alias disponivel.
Local aArea		:= GetArea()

cAliasQry 	:= GetNextAlias()
cQuery += " SELECT COUNT(1) AS QTD						    " + CRLF
cQuery += " FROM " + RetSqlName( "DYX" ) +" DYX  			" + CRLF
cQuery += " WHERE D_E_L_E_T_ = ' '							" + CRLF
cQuery += "       AND DYX_FILIAL = '"+ FWxFilial("DYX") +"'	" + CRLF
cQuery += "       AND DYX_IDCDIA = '"+ cIdDiar +"' 			" + CRLF
cQuery += "       AND DYX_STATUS IN ('1','2','4')			" + CRLF

cQuery := ChangeQuery(cQuery)
		
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .F., .T. )		
 		
If !(cAliasQry)->(EOF()) 
	If (cAliasQry)->QTD > 0
		lRet := .F.
	EndIf
EndIf
(cAliasQry)->(dbCloseArea())

RestArea(aArea)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TB30VlViag()
Valida a digitação do campo Viagem 

Uso: TMSAB30

@sample
//TB30VlViag()

@author Paulo Henrique Corrêa Cardoso.
@since 04/07/2014
@version 1.0
-----------------------------------------------------------/*/
Function TB30VlViag(oModel)	
Local lRet 		:= .T.						// Recebe o retorno
Local cFilOri	:= FwFldGet("DYV_FILORI",,oModel)// Recebe a Filial de Origem
Local cViagem 	:= FwFldGet("DYV_VIAGEM",,oModel)	// Recebe a Viagem

If Empty(cFilOri) .AND. !Empty(cViagem)
	Help('', 1,"HELP",, STR0044,1) //"Preencha a Filial de Origem."
	lRet := .F.	
Else

	dbSelectArea("DTQ")
	DTQ->( dbSetOrder(2) )
	
	If !DTQ->( dbSeek( FwxFilial("DTQ")+cFilOri+cViagem ) ) .AND. !Empty(cViagem)
		Help('', 1,"HELP",, STR0045,1) //"A viagem não pertence a filial escolhida."
		lRet := .F.
	EndIf

EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} TMSAB30Tit()
Localiza o proximo número de titulo

Uso: TMSAB30

@sample
//TMSAB30Tit(cPrefix)

@author Valdemar Roberto Mognon
@since 06/04/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSAB30Tit(cAlias,cPrefix)
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasQRY := GetNextAlias()
Local cRet      := ""
Local cNumUsu   := ""

Default cAlias  := ""
Default cPrefix := ""

If !Empty(cAlias)
	cQuery := "SELECT MAX(" + Iif(cAlias == "SE2","E2_NUM","DG_DOC") + ") ULTREG "
	cQuery += "  FROM " + RetSqlName(cAlias) + " " + cAlias + " "
	cQuery += " WHERE " + Right(cAlias,2) + "_FILIAL  = '" + xFilial(cAlias) + "' "
	If cAlias == "SE2"
		cQuery += "   AND E2_PREFIXO = '" + cPrefix + "' "
	EndIf
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQRY,.T.,.T.)
	If (cAliasQRY)->(Eof()) .Or. Empty((cAliasQRY)->ULTREG)
		cRet := StrZero(1,Len(SE2->E2_NUM))
	Else
		cRet := Soma1((cAliasQRY)->ULTREG)
	EndIf
	(cAliasQRY)->(DbCloseArea())
EndIf

If lTMB30Num
	cNumUsu := ExecBlock("TMB30NUM",.F.,.F.,{cRet,cAlias,cPrefix})
	If ValType(cNumUsu) == "C" .And. !Empty(cNumUsu)
		cRet := cNumUsu
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return cRet

//-------------------------------------------------------------------
/*{Protheus.doc} AtuTabSDG
Atualiza SDG
@type Function
@author CAio Murakami
@since 10/06/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Static Function AtuTabSDG( aCab , nOpc )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If FindFunction("TMSA070Aut")
	TMSA070Aut( aCab , nOpc )
Else 

	If nOpc == 3 
		RecLock("SDG",.T.)
	ElseIf nOpc == 4 .Or. nOpc == 5 
		RecLock("SDG",.F.)
		If nOpc == 5 
			lExclui	:= .T. 
		EndIf 
	EndIf 

	If lExclui
		SDG->(DbDelete())
	Else	
		For nCount := 1 To Len(aCab )
			SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
		Next nCount 
	EndIf 

	SDG->(MsUnlock())
EndIf 

RestArea(aArea)
Return 
