#include "GTPC300.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static oGC300Model	:= Nil
Static oGC300View	:= Nil
Static oGC300Timer	:= Nil
Static oTableTemp	:= Nil
Static oStrViewGYN	:= Nil
Static oStrModelGYN	:= Nil

Static nGC300Cont	:= 0

Static cGC300Focus	:= ""
Static cFldMaster	:= ""

#DEFINE cGC300Alias "MONITOR"

/*
	MVC - Monitor de Viagens
	Programa que é chamado via Menu.
*/

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GTPC300

Programa Monitor de Viagens

@sample GTPC300()
@author Fernando Radu Muscalu

@since 05/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------	
Function GTPC300(oWorkArea)

Local oPanel 	:= oWorkArea:GetPanel("WDGT01")	
Local oModel

Local nP 		:= 0

If ( ValType(oGC300Model) == "O" .And. oGC300Model:IsActive() )

	If ( MsgYesNo(STR0001,STR0002) )//"Com esta operação pode ser que se perca as informações alteradas. Gostaria de guardar as informações prévias?";"Monitor"
		GC300Commit(oGC300Model)
	EndIf
	
EndIf

If ( Pergunte("GTPC300",.t.) )

	GC300ClearObj(.t.)
	
	If ( ValType(oGC300View) == "O" .And. oGC300View:IsActive() )
		oGC300View:GetViewObj('VIEW_GYN')[3]:lOrdered := .F.
		oGC300View:GetViewObj('VIEW_G55')[3]:lOrdered := .F.
		oGC300View:GetViewObj('VIEW_GQE')[3]:lOrdered := .F.
		
		oGC300View:DeActivate()
	ElseIf ( ValType(oGC300View) <> "O" )	
		oGC300View 	:= FWLoadView("GTPC300")
	EndIf	
	
	oModel 	:= oGC300View:GetModel()
	
	nP 		:= aScan(oModel:Cargo,{|z| z[1] == "FUNNAME"})
	
	If (nP > 0 )
		oModel:Cargo[nP][2] := "GTPC300"
	EndIf
	
	oGC300View:SetOperation(MODEL_OPERATION_UPDATE)
	oGC300View:SetOwner(oPanel)
	
	If ( GTPGetRules("MONITTIMER") .And. GTPGetRules("MONITQTDTM") > 0 )
		oGC300Timer := TTimer():New(GTPGetRules("MONITQTDTM")*1000, {|| GC300Commit(oGC300Model) }, oPanel:oWnd)
		oGC300Timer:Activate()
	EndIf
	
	oGC300View:Activate()
						
Endif

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definição do modelo de Dados

@return oModel. Objeto. objeto da classe MPFormModel
@sample oModel := ModelDef()
@author Fernando Radu Muscalu

@since 05/12/2015
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ModelDef()
	
Local oModel		:= Nil
Local oStruMst	:= FWFormModelStruct():New()
Local oStruGYN	:= FWFormStruct(1,"GYN")
Local oStruG55	:= FWFormStruct(1,"G55")
Local oStruGQE	:= FWFormStruct(1,"GQE" )   //-- Recebe a estrututa da Tabela de Veículos por linha
Local bLoad		:= {|oGrid|GC300RunQry(oModel)}
Local aRelation	:= {}

GC300Struct(oStruMst,oStruGYN,oStruG55,oStruGQE,'M')

oStrModelGYN	:= oStruGYN

oModel := MPFormModel():New("GTPC300")

oModel:AddFields('MASTER',/*cOwner*/,oStruMst,,,{|| GC300Load() })
oModel:AddGrid('GYNDETAIL','MASTER',oStruGYN,/*bPreG57*/,/*bPosG57*/,,/*bPosG57*/,bLoad)
oModel:AddGrid('G55DETAIL','GYNDETAIL',oStruG55, {|oSubMdl,nLn,cAct,cFld,xVl,xOld| GC300Valid(oSubMdl,nLn,cAct,cFld,xVl,xOld) }/*bPreValid*/  , /*bPosLValid*/ , /*bPre*/,/*bPost*/,/*bLoad*/ )
oModel:AddGrid('GQEDETAIL','G55DETAIL',oStruGQE, {|oSubMdl,nLn,cAct,cFld,xVl,xOld| GC300Valid(oSubMdl,nLn,cAct,cFld,xVl,xOld) } /*bPreValid*/  , /*bPosLValid*/ , /*bPre*/,/*bPost*/,/*bLoad*/ )

aRelation	:= {{"GYN_FILIAL","xFilial('GYN')"},;
				"GYN_MASTER","MONITOR"}

oModel:SetRelation( 'GYNDETAIL', aRelation,GYN->(IndexKey(3)) )

aRelation	:= {{"G55_FILIAL","xFilial('G55')"},;
				{"G55_CODVIA","GYN_CODIGO"}}

oModel:SetRelation("G55DETAIL", aRelation, G55->(IndexKey(4)))//G55_FILIAL+G55_CODVIA+G55_SEQ

aRelation	:= {{"GQE_FILIAL","xFilial('GQE')"},;
				{"GQE_VIACOD","G55_CODVIA"},;
				{"GQE_SEQ","G55_SEQ"}}

oModel:SetRelation("GQEDETAIL", aRelation, GQE->(IndexKey(3)))

oModel:SetDescription(STR0003)//"Monitor de Viagens"
oModel:GetModel("MASTER"):Setdescription(STR0003)//"Monitor de Viagens"
oModel:GetModel("GYNDETAIL"):Setdescription(STR0004)//"Viagens"
oModel:GetModel("G55DETAIL"):Setdescription(STR0005)//"Montagem da Escala"
oModel:GetModel("GQEDETAIL"):Setdescription(STR0006)//"Horarios"

oModel:GetModel("GYNDETAIL"):SetOptional(.t.)
oModel:GetModel("G55DETAIL"):SetOptional(.t.)
oModel:GetModel("GQEDETAIL"):SetOptional(.t.)

oModel:GetModel("GYNDETAIL"):SetNoDeleteLine(.t.)
oModel:GetModel("G55DETAIL"):SetNoDeleteLine(.t.)
oModel:GetModel("G55DETAIL"):SetNoDeleteLine(.t.)

oModel:GetModel("GYNDETAIL"):SetNoInserLine(.t.)
oModel:GetModel("G55DETAIL"):SetNoInserLine(.t.)
oModel:GetModel("G55DETAIL"):SetNoInserLine(.t.)

oModel:SetPrimaryKey({})

oGC300Model	:= oModel
	
Return(oModel)

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definição do interface

@return oView. Objeto. objeto da classe FWFormView
@sample oView := ViewDef()

@authorFernando Radu Muscalu

@since 05/12/2015
@version 1.0
*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef()
Local oStruGYN	:= FWFormStruct(2,"GYN")
Local oStruG55	:= FWFormStruct(2,"G55")
Local oStruGQE	:= FWFormStruct(2,"GQE" )   //-- Recebe a estrututa da Tabela de Veículos por linha
Local oView		:= FWFormView():New()

GC300Struct(,oStruGYN,oStruG55,oStruGQE,'V')

oStrViewGYN := oStruGYN

oView:SetModel(oModel)
oView:SetDescription(STR0003)  //"Planejamento da Escala"

oView:AddGrid("VIEW_GYN",oStruGYN,"GYNDETAIL")
oView:AddGrid("VIEW_G55",oStruG55,"G55DETAIL")
oView:AddGrid("VIEW_GQE",oStruGQE,"GQEDETAIL")

oView:CreateHorizontalBox( 'TOP'  	, 35)
oView:CreateHorizontalBox( 'MIDDLE'	, 35)
oView:CreateHorizontalBox( 'DOWN', 30)

oView:SetOwnerView('VIEW_GYN','TOP')
oView:SetOwnerView('VIEW_G55','MIDDLE')
oView:SetOwnerView('VIEW_GQE','DOWN')

oView:EnableTitleView('VIEW_GYN',STR0004)//"Viagens"
oView:EnableTitleView('VIEW_G55',STR0007)//"Seções por viagem"
oView:EnableTitleView('VIEW_GQE',STR0008)//"Recursos por seção"

oView:GetViewObj("VIEW_GYN")[3]:SetGotFocus({||cGC300Focus := "GYNDETAIL"})
oView:GetViewObj("VIEW_G55")[3]:SetGotFocus({||cGC300Focus := "G55DETAIL"})
oView:GetViewObj("VIEW_GQE")[3]:SetGotFocus({||cGC300Focus := "GQEDETAIL"})

oView:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)
oView:GetModel("GYNDETAIL"):SetNoInsertLine(.T.)
oView:GetModel('G55DETAIL'):SetNoDeleteLine(.T.)
oView:GetModel("G55DETAIL"):SetNoInsertLine(.T.)
oView:GetModel('GQEDETAIL'):SetNoDeleteLine(.T.)
oView:GetModel("GQEDETAIL"):SetNoInsertLine(.T.)

oView:GetViewObj("VIEW_GYN")[3]:SetSeek(.t.)
oView:GetViewObj("VIEW_G55")[3]:SetSeek(.t.)

oGC300View := oView

Return ( oView )

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300Struct

Criar um estrutura fake para GTPC300
@Param
		oMaster		- O modelo Pai
		oStruGYN	- O modelo da viagem
		oStruG55	- O modelo do trecho da viagem
		oStruGQE	- O modelo do recurso da viagem
		cTipo		- Tipo da ação realizado no monitor
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 05/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------	
Static Function GC300Struct(oMaster,oStruGYN,oStruG55,oStruGQE,cTipo)
Local bTrig		:= {|oMdl,cField,xVal|GTPc300TRG(oMdl,cField,xVal)}
Local aOrdem	:= {}
Local bInit		:= {|oMdl,cField,xVal,nLine,xOldValue| GTPc300Init(oMdl,cField,xVal,nLine,xOldValue)}
Local nI		:= 0

Local cNoFields	:= ""

If ( cTipo == "M" )
	
	//eEstrutura Fake - MASTER
	oMaster:AddField(	STR0034,;	// 	[01]  C   Titulo do campo // "Monitor"
				 		STR0034,;	// 	[02]  C   ToolTip do campo // "Monitor"
				 		"MONITOR",;	// 	[03]  C   Id do Field
				 		"C",;		// 	[04]  C   Tipo do campo
				 		8,;		// 	[05]  N   Tamanho do campo
				 		0,;			// 	[06]  N   Decimal do campo
				 		Nil,;		// 	[07]  B   Code-block de validação do campo
				 		Nil,;		// 	[08]  B   Code-block de validação When do campo
				 		Nil,;		//	[09]  A   Lista de valores permitido do campo
				 		.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		{|| IIf(INCLUI,cValToChar(Randomize(1,9999999)),'') },;		//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		// 	[14]  L   Indica se o campo é virtual  
	
	//Estrutura de GYNDETAIL
	
	cNoFields := "GYN_EXEC|GYN_DTGER|GYN_HRGER|GYN_SETOR|GYN_IDENT|"
	cNoFields += "GYN_DESIDE|GYN_PROPOS|GYN_ITINI|GYN_ITFIM|GYN_LOCTER|"
	cNoFields += "GYN_DSCTER|GYN_HRITR|GYN_ENDITR|"//"GYN_DSCTER|GYN_HRITR|GYN_ENDITR|GYN_KMPROV|GYN_KMREAL|"
	cNoFields += "GYN_MOTIVO|GYN_CODGIE|GYN_MSBLQL|GYN_ALTER|"
	
	aFields := aClone(oStruGYN:GetFields())
	
	For nI := 1 to Len(aFields)	
	
		If ( aFields[nI,3] $ cNoFields .And. oStruGYN:HasField(aFields[nI,3]) )
			oStruGYN:RemoveField(aFields[nI,3])
		EndIf
			
	Next nI
	
	oStruGYN:AddField(	STR0009,;	// 	[01]  C   Titulo do campo // "Mestre"
				 		STR0009,;	// 	[02]  C   ToolTip do campo // "Mestre"
				 		"GYN_MASTER",;	// 	[03]  C   Id do Field
				 		"C",;		// 	[04]  C   Tipo do campo
				 		8,;		// 	[05]  N   Tamanho do campo
				 		0,;			// 	[06]  N   Decimal do campo
				 		Nil,;		// 	[07]  B   Code-block de validação do campo
				 		Nil,;		// 	[08]  B   Code-block de validação When do campo
				 		Nil,;		//	[09]  A   Lista de valores permitido do campo
				 		.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;		//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;		//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)		// 	[14]  L   Indica se o campo é virtual  
				 		
	oStruGYN:AddField(	" ",;										//Descrição (Label) do campo  
						STR0010,;									//Descrição Tooltip do campo//"Legenda"
						"GYN_LEGEND",;								//Identificador do campo
						"C",;										//Tipo de dado
						15,;										//Tamanho
						0,;											//Decimal
						nil,;										//Valid do campo
						nil,;										//When do campo
						{},;										//Lista de Opções (Combo)
						.f.,;										//Indica se campo é obrigatório
						Nil,;										//inicializador Padrão
						.f.,;										//Indica se o campo é chave
						.f.,;										//Indica se o campo pode receber um valor em uma operação update
						.f.)										//Indica se o campo é virtual
	
	oStruGYN:AddField(	" ",;										//Descrição (Label) do campo  
						STR0010,;									//Descrição Tooltip do campo//"Legenda"
						"GYN_STSLEG",;								//Identificador do campo
						"C",;										//Tipo de dado
						15,;										//Tamanho
						0,;											//Decimal
						nil,;										//Valid do campo
						nil,;										//When do campo
						{},;										//Lista de Opções (Combo)
						.f.,;										//Indica se campo é obrigatório
						Nil,;										//inicializador Padrão
						.f.,;										//Indica se o campo é chave
						.f.,;										//Indica se o campo pode receber um valor em uma operação update
						.f.)										//Indica se o campo é virtual	
						
	//definição da estrutura do modelo G55DETAIL
	oStruG55:AddField(	" ",;										//Descrição (Label) do campo 
						STR0010,;									//Descrição Tooltip do campo//"Legenda"
						"G55_LEGEND",;								//Identificador do campo
						"C",;										//Tipo de dado
						15,;										//Tamanho
						0,;											//Decimal
						nil,;										//Valid do campo
						nil,;										//When do campo
						{},;										//Lista de Opções (Combo)
						.f.,;										//Indica se campo é obrigatório
						Nil,;										//inicializador Padrão
						.f.,;										//Indica se o campo é chave
						.f.,;										//Indica se o campo pode receber um valor em uma operação update
						.f.)										//Indica se o campo é virtual			 		
	
	//Definições da estrutura do model GQEDETAIL
	oStruGQE:SetProperty("*", MODEL_FIELD_OBRIGAT , .F.)
	oStruGQE:SetProperty("*", MODEL_FIELD_VALID , {||.T.})
	oStruGQE:SetProperty("*", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruGYN:SetProperty("GYN_CONF", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruGYN:SetProperty("GYN_CANCEL", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruG55:SetProperty("G55_CONF", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruG55:SetProperty("G55_CANCEL", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	
	oStruGQE:SetProperty("GQE_TPCONF", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruGQE:SetProperty("GQE_USRCON", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruGQE:SetProperty("GQE_DTCONF", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruGQE:SetProperty("GQE_USRALO", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	oStruGQE:SetProperty("GQE_DTALOC", MODEL_FIELD_WHEN , {|oModel,cField| GC300When(oModel,cField) })
	
	oStruGQE:SetProperty('GQE_DRECUR', MODEL_FIELD_INIT,{|| GC300DRECUR()} )
	
	oStruG55:SetProperty('G55_LEGEND', MODEL_FIELD_INIT, bInit )
	oStruGYN:SetProperty('GYN_STSLEG', MODEL_FIELD_INIT, bInit )
	
	oStruGQE:SetProperty("GQE_STATUS"	, MODEL_FIELD_VALID , {|oMld,cCpo,xValue|G300ConfVld(oMld,cCpo,xValue)})
	oStruG55:SetProperty("G55_CONF"		, MODEL_FIELD_VALID , {|oMld,cCpo,xValue|G300ConfVld(oMld,cCpo,xValue)})
	oStruGYN:SetProperty("GYN_CONF"		, MODEL_FIELD_VALID , {|oMld,cCpo,xValue|G300ConfVld(oMld,cCpo,xValue)})
	oStruG55:SetProperty("G55_CANCEL"	, MODEL_FIELD_VALID , {|oMld,cCpo,xValue|G300ConfVld(oMld,cCpo,xValue)})
	oStruGYN:SetProperty("GYN_CANCEL"	, MODEL_FIELD_VALID , {|oMld,cCpo,xValue|G300ConfVld(oMld,cCpo,xValue)})
	
	oStruGQE:AddTrigger("GQE_STATUS"	,"GQE_STATUS"		,{||.T.},bTrig)
	oStruG55:AddTrigger("G55_CONF"		,"G55_CONF"			,{||.T.},bTrig)	
	oStruGYN:AddTrigger("GYN_CONF"		,"GYN_CONF"			,{||.T.},bTrig)
	oStruGQE:AddTrigger("GQE_TPCONF"	,"GQE_TPCONF"		,{||.T.},bTrig)
Else
	
	//Definição da estrutura da view GYNDETAIL
	oStruGYN:AddField( 	"GYN_LEGEND",; 									// [01] C Nome do Campo
						"01",; 											// [02] C Ordem
						" ",; 								// [03] C Titulo do campo
						STR0010 ,; 							// [04] C Descrição do campo//"Legenda"
						{STR0010},;//{"Legenda"} ,;							// [05] A Array com Help//"Somatória dos Lançamentos de Receita"//"Cor do Status da Viagem"
						"GET",; 										// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@BMP",;											// [07] C Picture
						NIL,; 											// [08] B Bloco de Picture Var
						"",; 											// [09] C Consulta F3
						.F.,; 											// [10] L Indica se o campo é editável
						NIL, ; 											// [11] C Pasta do campo
						NIL,; 											// [12] C Agrupamento do campo
						{},; 											// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 											// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 										// [15] C Inicializador de Browse
						.f.) 											// [16] L Indica se o campo é virtual
	
	oStruGYN:AddField( 	"GYN_STSLEG",; 									// [01] C Nome do Campo
						"01",; 											// [02] C Ordem
						" ",; 								// [03] C Titulo do campo
						STR0010 ,; 							// [04] C Descrição do campo//"Legenda"
						{STR0010},;//{"Legenda"} ,;							// [05] A Array com Help//"Somatória dos Lançamentos de Receita"//"Cor do Status da Viagem"
						"GET",; 										// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@BMP",;											// [07] C Picture
						NIL,; 											// [08] B Bloco de Picture Var
						"",; 											// [09] C Consulta F3
						.F.,; 											// [10] L Indica se o campo é editável
						NIL, ; 											// [11] C Pasta do campo
						NIL,; 											// [12] C Agrupamento do campo
						{},; 											// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 											// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 										// [15] C Inicializador de Browse
						.f.) 											// [16] L Indica se o campo é virtual
	
	//Definição da estrutura da view GYNDETAIL
	oStruG55:AddField( 	"G55_LEGEND",; 									// [01] C Nome do Campo
						"01",; 											// [02] C Ordem
						" ",; 											// [03] C Titulo do campo
						STR0010 ,; 									// [04] C Descrição do campo//"Legenda"
						{STR0010},;//{"Legenda"} ,;									// [05] A Array com Help//"Somatória dos Lançamentos de Receita"//"Cor do Status da Viagem"
						"GET",; 										// [06] C Tipo do campo - GET, COMBO OU CHECK
						"@BMP",;										// [07] C Picture
						NIL,; 											// [08] B Bloco de Picture Var
						"",; 											// [09] C Consulta F3
						.F.,; 											// [10] L Indica se o campo é editável
						NIL, ; 											// [11] C Pasta do campo
						NIL,; 											// [12] C Agrupamento do campo
						{},; 											// [13] A Lista de valores permitido do campo (Combo)
						NIL,; 											// [14] N Tamanho Maximo da maior opção do combo
						NIL,;	 										// [15] C Inicializador de Browse
						.f.) 											// [16] L Indica se o campo é virtual
		
	//Remoção de campos da view na estrutura de GYNDETAIL
	cNoFields := "GYN_LINCOD|GYN_EXEC|GYN_DTGER|GYN_HRGER|"
	cNoFields += "GYN_SETOR|GYN_IDENT|GYN_DESIDE|GYN_PROPOS|GYN_ITINI|"
	cNoFields += "GYN_ITFIM|GYN_LOCTER|GYN_DSCTER|GYN_HRITR|GYN_ENDITR|"	
	cNoFields += "GYN_KMPROV|GYN_KMREAL|GYN_MOTIVO|" 
	cNoFields += "GYN_CODGIE|GYN_MSBLQL|GYN_LOCORI|GYN_LOCDES|GYN_ALTER|GYN_STSOCR|"
		
	aFields := aClone(oStruGYN:GetFields())
	
	For nI := 1 to Len(aFields)	
	
		If ( aFields[nI,1]$ cNoFields .And. oStruGYN:HasField(aFields[nI,1]) )
			oStruGYN:RemoveField(aFields[nI,1])
		EndIf
			
	Next nI
	
	//Ordenação dos campos da view da estrutura GYNDETAIL
	aAdd(aOrdem,{"GYN_LEGEND"	,"GYN_CONF"		})
	aAdd(aOrdem,{"GYN_CONF"		,"GYN_NUMSRV"	})
	aAdd(aOrdem,{"GYN_NUMSRV"	,"GYN_TIPO"		})
	aAdd(aOrdem,{"GYN_TIPO"		,"GYN_DTINI"	})
	aAdd(aOrdem,{"GYN_DTINI"	,"GYN_HRINI"	})
	aAdd(aOrdem,{"GYN_HRINI"	,"GYN_DSCORI"	})
	aAdd(aOrdem,{"GYN_DSCORI"	,"GYN_DTFIM"	})
	aAdd(aOrdem,{"GYN_DTFIM"	,"GYN_HRFIM"	})
	aAdd(aOrdem,{"GYN_HRFIM"	,"GYN_DSCDES"	})
	aAdd(aOrdem,{"GYN_DSCDES"	,"GYN_CODIGO"	})
	aAdd(aOrdem,{"GYN_CODIGO"	,"GYN_CODGID"	})
	aAdd(aOrdem,{"GYN_CODGID"	,"GYN_CANCEL"	})
	aAdd(aOrdem,{"GYN_CANCEL"	,"GYN_LOTACA"	})
	aAdd(aOrdem,{"GYN_LOTACA"	,"GYN_SRVEXT"	})
	aAdd(aOrdem,{"GYN_SRVEXT"	,"GYN_DSVEXT"	})

	GTPOrdVwStruct(oStruGYN,aOrdem)
	
	oStruGYN:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)
	oStruGYN:SetProperty("GYN_CONF", MVC_VIEW_CANCHANGE, .T.)
	oStruGYN:SetProperty("GYN_CANCEL", MVC_VIEW_CANCHANGE, .T.)
	oStruGYN:SetProperty("GYN_CANCEL", MVC_VIEW_COMBOBOX, {STR0039,STR0040})//'1=Não','2=Sim'
	oStruGYN:SetProperty("GYN_CONF", MVC_VIEW_COMBOBOX,   {STR0041,STR0042,STR0043})//'1=Confirmado','2=Não Confirmado','3=Confirmado Parcialmente'

	//Remoção de campos da view na estrutura de G55DETAIL
	cNoFields := "G55_LOCORI|G55_LOCDES|G55_CODIGO|"
	cNoFields += "G55_CODGID|"
		
	aFields := aClone(oStruG55:GetFields())
	
	For nI := 1 to Len(aFields)	
	
		If ( aFields[nI,1]$ cNoFields .And. oStruG55:HasField(aFields[nI,1]) )
			oStruG55:RemoveField(aFields[nI,1])
		EndIf
			
	Next nI
	
	//Ordenação dos campos da view da estrutura GYNDETAIL
	aAdd(aOrdem,{"G55_CONF","G55_CANCEL"  })
	aAdd(aOrdem,{"G55_CANCEL","G55_SEQ"   })
	aAdd(aOrdem,{"G55_SEQ","G55_DTPART"   })
	aAdd(aOrdem,{"G55_DTPART","G55_HRINI" })
	aAdd(aOrdem,{"G55_HRINI","G55_DESORI" })
	aAdd(aOrdem,{"G55_DESORI","G55_DTCHEG"})	
	aAdd(aOrdem,{"G55_DTCHEG","G55_HRFIM" })	 //g55_dtloca se torna G55_DTCHEG
	aAdd(aOrdem,{"G55_HRFIM","G55_DESDES" })
	
	GTPOrdVwStruct(oStruG55,aOrdem)
	
	oStruG55:SetProperty("*"         , MVC_VIEW_CANCHANGE, .F.)
	oStruG55:SetProperty("G55_CONF"  , MVC_VIEW_CANCHANGE, .T.)
	oStruG55:SetProperty("G55_CANCEL", MVC_VIEW_CANCHANGE, .T.)
	oStruG55:SetProperty("G55_DTPART", MVC_VIEW_CANCHANGE, .T.)
	oStruG55:SetProperty("G55_DTCHEG", MVC_VIEW_CANCHANGE, .T.)
	
	oStruG55:SetProperty("G55_CANCEL", MVC_VIEW_COMBOBOX, {STR0039,STR0040})//'1=Não','2=Sim'                                                                    
	oStruG55:SetProperty("G55_CONF"  , MVC_VIEW_COMBOBOX, {STR0041,STR0042,STR0043})//'1=Confirmado','2=Não Confirmado','3=Confirmado Parcialmente'              
		
	aFields := aClone(oStruGQE:GetFields())
	
	For nI := 1 to Len(aFields)	
	
		If ( aFields[nI,1]$ cNoFields .And. oStruGQE:HasField(aFields[nI,1]) )
			oStruGQE:RemoveField(aFields[nI,1])
		EndIf
			
	Next nI
	
	//Ordenação dos campos da view da estrutura GYNDETAIL
	aAdd(aOrdem,{"GQE_VIACOD","GQE_SEQ"   })
	aAdd(aOrdem,{"GQE_SEQ","GQE_ITEM"     })	
	aAdd(aOrdem,{"GQE_STATUS","GQE_CANCEL"})
	aAdd(aOrdem,{"GQE_CANCEL","GQE_TRECUR"})
	aAdd(aOrdem,{"GQE_TRECUR","GQE_TCOLAB"})
	aAdd(aOrdem,{"GQE_TCOLAB","GQE_DCOLAB"})
	aAdd(aOrdem,{"GQE_DCOLAB","GQE_RECURS"})
	aAdd(aOrdem,{"GQE_RECURS","GQE_DRECUR"})
	aAdd(aOrdem,{"GQE_DRECUR","GQE_TERC"  })
	aAdd(aOrdem,{"GQE_TERC","GQE_HRINTR"  })
	aAdd(aOrdem,{"GQE_HRINTR","GQE_HRFNTR"})
	aAdd(aOrdem,{"GQE_HRFNTR","GQE_MARCAD"})
	aAdd(aOrdem,{"GQE_MARCAD","GQE_JUSTIF"})
	aAdd(aOrdem,{"GQE_JUSTIF","GQE_ESCALA"})
	aAdd(aOrdem,{"GQE_ESCALA","GQE_ESCITE"})
	aAdd(aOrdem,{"GQE_ESCITE","GQE_DTREF" })
	aAdd(aOrdem,{"GQE_DTREF","GQE_CONF"   })
	aAdd(aOrdem,{"GQE_CONF","GQE_ESPHIN"  })
	aAdd(aOrdem,{"GQE_ESPHIN","GQE_ESPHFM"})
	aAdd(aOrdem,{"GQE_ESPHFM","GQE_OCOVIA"})
	aAdd(aOrdem,{"GQE_OCOVIA","GQE_DSCOCO"})
	aAdd(aOrdem,{"GQE_DSCOCO","GQE_NUMSRV"})
	aAdd(aOrdem,{"GQE_NUMSRV","GQE_TPCONF"})
	aAdd(aOrdem,{"GQE_TPCONF","GQE_USRALO"})
	aAdd(aOrdem,{"GQE_USRALO","GQE_DTALOC"})
	aAdd(aOrdem,{"GQE_DTALOC","GQE_USRCON"})
	aAdd(aOrdem,{"GQE_USRCON","GQE_DTCONF"})
	
	GTPOrdVwStruct(oStruGQE,aOrdem)
	
	oStruGQE:SetProperty("*"         , MVC_VIEW_CANCHANGE, .F.)
	oStruGQE:SetProperty("GQE_STATUS", MVC_VIEW_CANCHANGE, .T.)	
	oStruGQE:SetProperty("GQE_TRECUR", MVC_VIEW_CANCHANGE, .T.)
	oStruGQE:SetProperty("GQE_TCOLAB", MVC_VIEW_CANCHANGE, .T.)
	oStruGQE:SetProperty("GQE_JUSTIF", MVC_VIEW_CANCHANGE, .T.)
	oStruGQE:SetProperty("GQE_TPCONF", MVC_VIEW_CANCHANGE, .T.)
	oStruGQE:SetProperty("GQE_RECURS", MVC_VIEW_CANCHANGE, IIf(FindFunction("GTPCrashOn"),GTPCrashOn(),.F.))
	oStruGQE:SetProperty("GQE_STATUS", MVC_VIEW_COMBOBOX , {STR0041,STR0042})//'1=Confirmado','2=Não Confirmado'
			
EndIf

Return()


/*/{Protheus.doc} GC300RunQry
Função responsavel pelo carregamento das informações de viagens
@type function
@author jacomo.fernandes
@since 16/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GC300RunQry(oModel, lAut)

Local aFldConv	:= {}
Local cQry		:= ""
// Local cFields	:= ""

Default lAut    := .F.

if lAut
	mv_par03 := '000001'
endif

Pergunte("GTPC300",.F.)

cFldMaster := GTPFld2Str(oModel:GetModel("GYNDETAIL"):GetStruct(),.t.,aFldConv,,,,"GYN") 

cFldMaster += ",GI1ORI.GI1_DESCRI AS GYN_DSCORI "
cFldMaster += ",GI1DES.GI1_DESCRI AS GYN_DSCDES "

cFldMaster += ",(Case "
cFldMaster += "	When GYN.GYN_CANCEL = '2' then 'BR_PRETO' "
cFldMaster += "	When GYN.GYN_FINAL = '1' then 'BR_AZUL' "
cFldMaster += "	When GYN.GYN_CONF = '1' then 'BR_VERDE' "
cFldMaster += "	When GYN.GYN_CONF = '2' then 'BR_VERMELHO' "
cFldMaster += "	When GYN.GYN_CONF = '3' then 'BR_AMARELO' "
cFldMaster += "End) as GYN_LEGEND "

cFldMaster += ",(Case "
cFldMaster += "	When GYN.GYN_STSOCR = '' then 'BR_BRANCO' "
cFldMaster += "	When GYN.GYN_STSOCR = '1' then 'BR_VERDE' "
cFldMaster += "	When GYN.GYN_STSOCR = '2' then 'BR_VERMELHO' "
cFldMaster += "	When GYN.GYN_STSOCR = '3' then 'BR_AMARELO' "
cFldMaster += "End) as GYN_STSLEG "

cQry := "SELECT " + chr(13)
cQry += "	" + cFldMaster + chr(13)
cQry += "FROM "+RetSQLName("GYN")+" GYN " + chr(13)

cQry += "		INNER JOIN " + chr(13)
cQry += "			"+RetSQLName("GI1")+" GI1ORI ON " + chr(13)
cQry += "				GI1ORI.GI1_FILIAL = '"+xFilial("GI1")+"' " + chr(13)
cQry += "				AND GI1ORI.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "				AND GI1ORI.GI1_COD = GYN_LOCORI " + chr(13)

cQry += "		INNER JOIN " + chr(13)
cQry += "			"+RetSQLName("GI1")+" GI1DES ON " + chr(13)
cQry += "				GI1DES.GI1_FILIAL = '"+xFilial("GI1")+"' " + chr(13)
cQry += "				AND GI1DES.D_E_L_E_T_ = ' ' " + chr(13)
cQry += "				AND GI1DES.GI1_COD = GYN_LOCDES " + chr(13)

If mv_par06 == 1
	cQry += "		LEFT JOIN " + chr(13)
	cQry += "			"+RetSQLName("GID")+" GID ON " + chr(13)
	cQry += "				GID.GID_FILIAL = GYN.GYN_FILIAL " + chr(13)
	cQry += "				AND GID.GID_COD = GYN.GYN_CODGID " + chr(13)
	cQry += "				AND GID.GID_HIST = '2' " + chr(13)
	cQry += "				AND GID.D_E_L_E_T_ = ' ' " + chr(13)				
Endif

cQry += "WHERE " + chr(13)
cQry += "	GYN_FILIAL = '"+xFilial("GYN")+"' " + chr(13)
cQry += "	AND GYN.D_E_L_E_T_ = ' ' " + chr(13)

cQry += "	AND ( " + chr(13)
cQry += "			(GYN.GYN_DTINI >= '" + DtoS(mv_par01) + "'  " + chr(13) 
cQry += "			and GYN.GYN_DTFIM <= '" + DtoS(mv_par02) + "' ) " + chr(13) 
cQry += "			or" + chr(13)
cQry += "			(GYN.GYN_DTINI >= '" + DtoS(mv_par01) + "' and ('" + DtoS(mv_par02) + "' BETWEEN GYN.GYN_DTINI AND GYN.GYN_DTFIM)) " + chr(13)
cQry += "		) " + chr(13)

IF !Empty(mv_par04)
	cQry += "	AND GYN_LOCORI = '" +mv_par04 + "' " + chr(13)
Endif
IF !Empty(mv_par05)
	cQry += "	AND GYN_LOCDES = '" +mv_par05 + "' " + chr(13)
Endif

If mv_par06 == 1
	cQry += " AND GID.GID_STATUS IN ('','1') " + chr(13)
	cQry += " AND GID.GID_STATUS Is Not Null " + chr(13)
Endif

If mv_par07 == 1
	cQry += " AND GYN_CANCEL  = '1' " + chr(13)
Endif

IF !Empty(mv_par08) .AND. mv_par08 <> 3
	//Tipo Viagem :1=Normal;2=Extraordinária;3=Todas 
	cQry += "	AND GYN_TIPO = '"+cValToChar(mv_par08)+"' " + chr(13)
Endif

If ( !Empty(mv_par03) )	//Se Houver setor, então efetua o filtro das viagens, cujos trechos, possuem localidades pertencentes ao setor

	cQry += "	AND EXISTS ( " + chr(13) 
	cQry += "			SELECT G55_CODVIA " + chr(13) 
	cQry += "			FROM "+RetSQLName("G55")+" G55 " + chr(13) 
	cQry += "				INNER JOIN "+RetSQLName("GY1")+" GY1 ON " + chr(13)
	cQry += "					GY1_FILIAL = '"+xFilial("GY1")+"' " + chr(13)
	cQry += "					AND GY1.D_E_L_E_T_ = ' ' " + chr(13)
	cQry += "					AND GY1_SETOR = '"+mv_par03+"' " + chr(13)
	cQry += "					AND (  " + chr(13)
	cQry += "							G55_LOCORI = GY1_LOCAL " + chr(13) 
	cQry += "							OR                   	" + chr(13)
	cQry += "							G55_LOCDES = GY1_LOCAL " + chr(13)
	cQry += "						) " + chr(13)                     
    cQry += "			WHERE  " + chr(13)
	cQry += "				G55_FILIAL = GYN.GYN_FILIAL " + chr(13)
	cQry += "				AND G55_CODVIA = GYN.GYN_CODIGO  " + chr(13)
	cQry += "				AND G55.D_E_L_E_T_ = ' '  " + chr(13)
	cQry += "		)  " + chr(13)
		
Endif

cQry += "ORDER BY GYN_FILIAL, GYN_DTINI, GYN_HRINI " + chr(13)
//RADU - JCA: DSERGTP-8012
GTPNewTempTable(cQry,GetNextAlias(),{{"INDEX1",{'GYN_FILIAL','GYN_DTINI','GYN_HRINI'}}},aFldConv,@oTableTemp)	//GTPTemporaryTable(cQry,GetNextAlias(),{{"INDEX1",{'GYN_FILIAL','GYN_DTINI','GYN_HRINI'}}},aFldConv,@oTableTemp)

aRet := FWLoadByAlias(oModel:GetModel("GYNDETAIL"), oTableTemp:GetAlias())

// oTable:Delete()

// GTPDestroy(oTable)

Return(aRet)

//-------------------------------------------------------------------
/*{Protheus.doc} GC300GetMVC
Retorna o o modelo do GTPC300

@sample GC300AliasTemp()
@author Fernando Radu Muscalu

@since 21/08/2017
@version 1.0
*/
//-------------------------------------------------------------------

Function GC300GetMVC(cTipo)

Local xRet

Default cTipo := ""

If (Empty(cTipo))
	xRet := {oGC300Model,oGC300View}
ElseIf ( SubStr(Upper(cTipo),1,1) == "M" )
	xRet := oGC300Model
ElseIf ( SubStr(Upper(cTipo),1,1) == "V" )
	xRet := oGC300View
ElseIf Upper(cTipo) == "ISACTIVE"
	xRet := ValType(oGC300Model) == "O"  .and. oGC300Model:ClassName() == "FWFORMMODEL" .and. oGC300Model:IsActive() 
EndIf

Return(xRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300Destroy

Função para destruir o modelo
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 05/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------	

Function GC300Destroy()

If ( ValType(oGC300View) == "O" )

	If ( oGC300View:IsActive() )
		oGC300View:DeActivate()
	EndIf
	
	oGC300View:Destroy()
	FreeObj(oGC300View)
		
EndIf

If ( ValType(oGC300Model) == "O" )

	If ( oGC300Model:IsActive() )
		oGC300Model:DeActivate()
	EndIf
	
	oGC300Model:Destroy()
	FreeObj(oGC300Model)
	
EndIf

If ( ValType(oGC300Timer) == "O" )
	
	If ( oGC300Timer:lActive )
		oGC300Timer:DeActivate()
	EndIf	
	
	oGC300Timer:End()
	
EndIf
	
Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300Load

Função Função para realizar o load dos dados do monitor
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------	
Static Function GC300Load()

Local aRet	:= {{cValToChar(Randomize(1,9999999))},0}

Return(aRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300SetLegenda

Função para altera a legenda do monitor de acordo 
com a situação da viagem, trecho e recurso
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------	

Function GC300SetLegenda(oSubMdl)

Local cLegenda	:= ""
Local nCont     := 0
Local aAux      := {}

Local lUpdLine	:= !oSubMdl:CanUpdateLine()

If ( oSubMdl:GetId() == "GYNDETAIL" )
	
	cFldLegend := "GYN_LEGEND"
	
	If ( oSubMdl:GetValue("GYN_CANCEL") == "2"  )
		cLegenda := "BR_PRETO"
	ElseIf ( oSubMdl:GetValue("GYN_FINAL") == "1" )
		cLegenda := "BR_AZUL"
	ElseIf ( oSubMdl:GetValue("GYN_CONF") == "1" )
		cLegenda := "BR_VERDE" 
	ElseIf ( oSubMdl:GetValue("GYN_CONF") == "2" )
		cLegenda := "BR_VERMELHO"
	ElseIf ( oSubMdl:GetValue("GYN_CONF") == "3" )
		cLegenda := "BR_AMARELO"
	EndIf
	AADD(aAux,{cFldLegend,cLegenda})
	
	cFldLegend := "GYN_STSLEG"
	
	If ( empty(oSubMdl:GetValue("GYN_STSOCR"))  )
		cLegenda := "BR_BRANCO"
	ElseIf ( oSubMdl:GetValue("GYN_STSOCR") == "1" )
		cLegenda := "BR_VERDE" 
	ElseIf ( oSubMdl:GetValue("GYN_STSOCR") == "2" )
		cLegenda := "BR_VERMELHO"
	ElseIf ( oSubMdl:GetValue("GYN_CONF") == "3" )
		cLegenda := "BR_AMARELO"
	EndIf
	AADD(aAux,{cFldLegend,cLegenda})
	
ElseIf ( oSubMdl:GetId() == "G55DETAIL" )
	
	cFldLegend := "G55_LEGEND"
	
	If ( oSubMdl:GetValue("G55_CANCEL") == "2"  )
		cLegenda := "BR_PRETO"
	ElseIf ( oSubMdl:GetValue("G55_CONF") == "1" )
		cLegenda := "BR_VERDE" 
	ElseIf ( oSubMdl:GetValue("G55_CONF") == "2" )
		cLegenda := "BR_VERMELHO"	
	ElseIf ( oSubMdl:GetValue("G55_CONF") == "3" )
		cLegenda := "BR_AMARELO"
	EndIf
	AADD(aAux,{cFldLegend,cLegenda})
EndIf

oSubMdl:SetNoUpdateLine(.F.)

If Len(aAux) > 0
	For nCont := 1 To Len(aAux)
		oSubMdl:LoadValue(aAux[nCont,1],aAux[nCont,2])
	Next nCont
Endif

oSubMdl:SetNoUpdateLine(lUpdLine)

Return()
//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300ScreenLeg

Função para exibir a descrição das legenda do monitor
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------	

Function GC300ScreenLeg()

Local aCores := {}

Local oViewMonitor	:= GC300GetMVC('V')

If ValType(oViewMonitor) == 'O' .AND. oViewMonitor:IsActive()

	If ( cGC300Focus == "GYNDETAIL" )
		
		aAdd(aCores, {"BR_VERDE", STR0011})//"Viagem Confirmada"
		aAdd(aCores, {"BR_AMARELO", STR0012})//"Viagem Parcialmente Confirmada"
		aAdd(aCores, {"BR_VERMELHO", STR0013})//"Viagem Não Confirmada"
		aAdd(aCores, {"BR_PRETO", STR0014})//"Viagem Cancelada"
		aAdd(aCores, {"BR_AZUL", STR0038})//"Viagem Finalizada"
		
		aAdd(aCores, {"", ""})//"Viagem Confirmada"
		aAdd(aCores, {"BR_BRANCO", "Sem ocorrências"})
		aAdd(aCores, {"BR_VERMELHO", "Ocorrencia com Operacional"})
		aAdd(aCores, {"BR_AMARELO", "Ocorrência sem Operacional"})
		aAdd(aCores, {"BR_VERDE", "Ocorrência fechada"})
		
		BrwLegenda(STR0003, STR0004, aCores)//"Monitor - Viagens"//"Viagens"
		
	ElseIf ( cGC300Focus == "G55DETAIL" )
		
		aAdd(aCores, {"BR_VERDE",STR0015})//"Recursos da Seção, confirmados"
		aAdd(aCores, {"BR_AMARELO", STR0016})//"Recursos da Seção, parcialmente confirmados"
		aAdd(aCores, {"BR_VERMELHO", STR0017})//"Recursos da Seção, não confirmados"
		aAdd(aCores, {"BR_PRETO", STR0018})//"Seção Cancelada"
		
		BrwLegenda(STR0003, STR0019, aCores)//"Monitor de Viagens"//"Seções"
		
	Endif
Else
	FwAlertHelp(STR0010,STR0029) //'legenda'"Esta rotina só funciona com monitor ativo"
Endif


Return(.T.)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300Commit

Função para exibir a descrição das legenda do monitor
@Param
			oModel	- O modelo Pai 	
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------	
Function GC300Commit(oModel)

Local lRet	:= .t.

Local nI		:= 0 
Local nX		:= 0
Local nZ		:= 0
Local nInd		:= 0

Local aAreaGYN	:= GYN->(GetArea())
Local aFields	:= {}
Local aSeekGrid	:= {}

Local oSubGYN
Local oSubG55
Local oSubGQE
Local oModelGQF

Local aLnModel := FWSaveRows(oModel)
Local oGtpLog	:= GTPLog():New(STR0057,.F.)
Local cViagens	:= ''


If ( Valtype(oModel) == "O" .And. (oModel:GetId() == "GTPC300" .And. oModel:IsActive()) )
	
	CursorWait()
	
	Begin Transaction 
	
	oMdlSave := FwLoadModel("GTPC300D")
	
	oMdlSave:SetOperation(MODEL_OPERATION_UPDATE)
	
	oSubGYN	:= oMdlSave:GetModel("GYNMASTER")
	oSubG55	:= oMdlSave:GetModel("G55DETAIL")
	oSubGQE	:= oMdlSave:GetModel("GQEDETAIL")
		
	GYN->(DbSetOrder(1))
	
	For nI := 1 to oModel:GetModel("GYNDETAIL"):Length()
		
		oModel:GetModel("GYNDETAIL"):GoLine(nI)
		
		GYN->(DbSeek(XFilial("GYN") + oModel:GetModel("GYNDETAIL"):GetValue("GYN_CODIGO")))
		
		
		If !(oModel:GetModel("GYNDETAIL"):GetValue("GYN_FINAL") == '1' .AND. GYN->GYN_FINAL == '1')	
		
			oMdlSave:Activate()
			//ATUALIZAÇÃO DE GYNMASTER (MVC GTPC300C)
			lRet := oSubGYN:LoadValue("GYN_CONF",oModel:GetModel("GYNDETAIL"):GetValue("GYN_CONF")) .And.;
					oSubGYN:LoadValue("GYN_CANCEL",oModel:GetModel("GYNDETAIL"):GetValue("GYN_CANCEL")) .And.;				
					oSubGYN:LoadValue("GYN_FINAL",oModel:GetModel("GYNDETAIL"):GetValue("GYN_FINAL"))				
				
				
			If ( lRet )
			
				//ATUALIZAÇÃO DE G55DETAIL (MVC GTPC300C)	
				For nX := 1 to oModel:GetModel("G55DETAIL"):Length()
					
					oModel:GetModel("G55DETAIL"):GoLine(nX)
					
					aSeekGrid := {	{"G55_CODVIA",oModel:GetModel("G55DETAIL"):GetValue("G55_CODVIA")},;
									{"G55_SEQ",oModel:GetModel("G55DETAIL"):GetValue("G55_SEQ")} }
					
					oSubG55:GoLine(1)
					
					If ( oSubG55:SeekLine(aSeekGrid) )
					
						lRet := oSubG55:LoadValue("G55_CONF",oModel:GetModel("G55DETAIL"):GetValue("G55_CONF")) .And.;
								oSubG55:LoadValue("G55_DTPART"	,oModel:GetModel("G55DETAIL"):GetValue("G55_DTPART"	)) .And.;
								oSubG55:LoadValue("G55_HRINI"	,oModel:GetModel("G55DETAIL"):GetValue("G55_HRINI"	)) .And.;
								oSubG55:LoadValue("G55_DTCHEG"	,oModel:GetModel("G55DETAIL"):GetValue("G55_DTCHEG"	)) .And.;
								oSubG55:LoadValue("G55_HRFIM"	,oModel:GetModel("G55DETAIL"):GetValue("G55_HRFIM"	)) .And.;
								oSubG55:LoadValue("G55_CANCEL",oModel:GetModel("G55DETAIL"):GetValue("G55_CANCEL"))
							
					Else
						lRet := .f.
					EndIf		
					
					If ( lRet )
						If oModel:GetModel("GQEDETAIL"):Length() > 1 .Or. (oModel:GetModel("GQEDETAIL"):Length() == 1  .AND. !Empty(oModel:GetModel("GQEDETAIL"):GetValue("GQE_VIACOD"))) 
							//ATUALIZAÇÃO DE GQEDETAIL (MVC GTPC300C)
							For nZ := 1 to oModel:GetModel("GQEDETAIL"):Length()
							
								oModel:GetModel("GQEDETAIL"):GoLine(nZ)					
								If !oModel:GetModel("GQEDETAIL"):IsDeleted()
									aSeekGrid := {	{"GQE_VIACOD",oModel:GetModel("GQEDETAIL"):GetValue("GQE_VIACOD")},;
													{"GQE_SEQ",oModel:GetModel("GQEDETAIL"):GetValue("GQE_SEQ")},;
													{"GQE_ITEM",oModel:GetModel("GQEDETAIL"):GetValue("GQE_ITEM")} }
									
									oSubGQE:GoLine(1)
									
									If ( !oSubGQE:SeekLine(aSeekGrid) )
										If ( !Empty(oSubGQE:GetValue("GQE_VIACOD")) )   
											lRet := oSubGQE:Length() < oSubGQE:AddLine(.t.,.t.) 
										EndIf								
									Endif
										
									If ( lRet )
										
										aFields := oSubGQE:GetStruct():GetFields()
										
										For nInd := 1 to Len(aFields)
											
											If ( oModel:GetModel("GQEDETAIL"):HasField(aFields[nInd,3]) )
												
												
												lRet := oSubGQE:LoadValue(aFields[nInd,3],oModel:GetModel("GQEDETAIL"):GetValue(aFields[nInd,3]))
													
											Else
												lRet := oSubGQE:LoadValue(aFields[nInd,3],GTPCastType(,aFields[nInd,4]))
											EndIf
											
											If ( !lRet )
												Exit
											EndIf	
																					
										Next nInd
										 
									EndIf
								Else
									aSeekGrid := {	{"GQE_VIACOD",oModel:GetModel("GQEDETAIL"):GetValue("GQE_VIACOD")},;
													{"GQE_SEQ",oModel:GetModel("GQEDETAIL"):GetValue("GQE_SEQ")},;
													{"GQE_ITEM",oModel:GetModel("GQEDETAIL"):GetValue("GQE_ITEM")} }
									
									oSubGQE:GoLine(1)
									
									If ( oSubGQE:SeekLine(aSeekGrid) )
										oSubGQE:DeleteLine()
									Endif					
								Endif
							Next nZ
							If oSubGQE:Length() > oModel:GetModel("GQEDETAIL"):Length()
								For nI := nZ to oSubGQE:Length() 
									oSubGQE:GoLine(nI)
									oSubGQE:DeleteLine()
								Next
							Endif
							
						Endif
					EndIf
					
				Next nX
				
			EndIf
			
				If ( lRet )
					lRet := oMdlSave:VldData() .and. oMdlSave:CommitData() 	
				EndIf
		
				oMdlSave:DeActivate()
			
		Else
			cViagens += oModel:GetModel("GYNDETAIL"):GetValue("GYN_CODIGO") + Chr(13) + Chr(10)			
		EndIf
		
		If ( !lRet )
			Exit	
		EndIf 
		
	Next nI	
	
	If ( lRet )
		
		//ATUALIZAÇÃO DE GQFDETAIL (MVC GTPC300C)
		oModelGQF := GCC300GetModel()
		
		If ( Valtype(oModelGQF) == "O" .And. oModelGQF:IsActive() )			
			lRet := oModelGQF:VldData() .And. oModelGQF:CommitData()			
		EndIf
		
	EndIf

	If ( !lRet )
		DisarmTransaction()
		//Apresenta o Erro do MVC	
	EndIf
	
	End Transaction
	If ( Valtype(oModelGQF) == "O" .And. oModelGQF:IsActive() )
		oModelGQF:GetModel("GQFDETAIL"):ClearData(.t.)
	Endif
	
	CursorArrow()
	
	If !Empty(cViagens)
		oGtpLog:SetText(STR0058)
		oGtpLog:SetText(cViagens)		
		oGtpLog:ShowLog()
	EndIf
				
EndIf

RestArea(aAreaGYN)
FWRestRows(aLnModel)

Return(lRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300When

Função para realizar o bloqueios dos campos de acordo com 
codição de definida no cancelamento, status e recuros

@Param
			oSubMdl	- SubModelo 
			cField	- Campo posicionado 	

@Return 	lRet - .T. não bloqueia o campo
			lRet - .F. bloqueia o campo 	
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function GC300When(oSubMdl,cField)


Local lRet		:= .T.
Local oMaster		:= GC300GetMVC('M')
Local oModelGYN 	:= oMaster:GetModel("GYNDETAIL")
	

If oSubMdl:GetID() == 'GYNDETAIL'
	If oSubMdl:GetValue("GYN_CANCEL") == '2'
		lRet := cField $ "GYN_CANCEL"			
	ElseIf oSubMdl:GetValue("GYN_FINAL") == '1'
		lRet := ( cField $ "GYN_CONF|GYN_CANCEL" )
		IF lRet
			lRet:= .F.
		EndIF
	EndIf
ElseIf oSubMdl:GetID() == 'G55DETAIL'
	If oSubMdl:GetValue("G55_CANCEL") == '2'
		lRet := cField $ "G55_CANCEL"
	EndIf
	IF ValType(oModelGYN) == 'O'
		If oModelGYN:GetValue("GYN_FINAL") == "1"
			lRet:= .F.
		EndIF
	EndIf
ElseIf oSubMdl:GetID() == 'GQEDETAIL'
	If oSubMdl:GetValue("GQE_CANCEL") == '2'
		lRet := .F.
	Else
		If ( cField $ "GQE_STATUS|GQE_RECURS|GQE_DRECUR|GQE_JUSTIF|GQE_TPCONF|GQE_USRCON|GQE_DTCONF|GQE_USRALO|GQE_DTALOC" )
			lRet := .T.
		Else
			lRet := cField $ "GQE_TRECUR|GQE_TCOLAB" .And. Empty(oSubMdl:GetValue("GQE_RECURS"))
		Endif
	Endif
	
	IF ValType(oModelGYN) == 'O'
		If oModelGYN:GetValue("GYN_FINAL") == "1"
			lRet:= .F.
		EndIF
	EndIf
	
Endif

Return(lRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300Valid

Função responsável para validação do monitor 

@Param
			oSubMdl	- O submodelo 
			nLine	- Line posicionada
			cAction - Ação realizado 
			cField 	- Campo posicionado
			xValue	- Valor Novo 
			xOldVl	- Valor Antigo
			
@Return 	.t.  
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function GC300Valid(oSubMdl,nLine,cAction,cField,xValue,xOldVl)

Local oViewMonitor	:= GC300GetMVC('V')
Local oVwGYN
Local oVwG55
Local oVwGQE
Local oMdlGYN
Local oMdlG55
Local lRet	:= .t.

If cAction == 'CANSETVALUE'
	
	lRet	:= !oSubMdl:IsEmpty()
	
	If ( lRet .And. cField $ "G55_DTPART|G55_DTCHEG" )
		
		cSrvExt := Alltrim(GetMV("MV_GTPCSVE")) 
		
		If ( oSubMdl:GetModel():GetModel("GYNDETAIL"):GetValue("GYN_TIPO") <> "2" .Or.; 
				(oSubMdl:GetModel():GetModel("GYNDETAIL"):GetValue("GYN_TIPO") == "2" .And.;
				 (!Empty(cSrvExt) .And. oSubMdl:GetModel():GetModel("GYNDETAIL"):GetValue("GYN_SRVEXT") <> cSrvExt) ))
				 
			lRet := .f.
			
		Endif
				
	EndIf
	
Endif


If lRet .and. (cAction == "SETVALUE") .AND. ( cField $ "GQE_STATUS|GQE_CANCEL|GQE_RECURS" )
	
	If ( cField == "GQE_RECURS" .And. cAction == "SETVALUE" )
		lRet := GC300ChkRec(xValue,oSubMdl:GetValue("GQE_TRECUR",nLine),oSubMdl)
	EndIf
	
	If ( lRet )
		
		If ( ValType(oViewMonitor) == "O" )
		
			oVwGYN := oViewMonitor:GetViewObj("GYNDETAIL")[3]
			oVwG55 := oViewMonitor:GetViewObj("G55DETAIL")[3]
			oVwGQE := oViewMonitor:GetViewObj("GQEDETAIL")[3]
			
		EndIf
		
		If ( oSubMdl:GetId() == "GQEDETAIL" .And. cAction == "SETVALUE" )
			
			oMdlGYN := oSubMdl:GetModel():GetModel("GYNDETAIL")
			oMdlG55 := oSubMdl:GetModel():GetModel("G55DETAIL")
			
			oSubMdl:GoLine(nLine)
			
			aHist := {	oSubMdl:GetValue("GQE_VIACOD",nLine),;
						oSubMdl:GetValue("GQE_SEQ",nLine),;
						oSubMdl:GetValue("GQE_ITEM",nLine),;
						oSubMdl:GetValue("GQE_TRECUR",nLine),;
						oSubMdl:GetValue("GQE_TCOLAB",nLine),;
						oSubMdl:GetValue("GQE_RECURS",nLine),;
						oSubMdl:GetValue("GQE_JUSTIF",nLine)}
			
			If ( cField == "GQE_RECURS" )
				GTPAddHist(aHist,1,xOldVl)
			ElseIf ( cField == "GQE_STATUS" )
				GTPAddHist(aHist,2,xOldVl)
			ElseIf ( cField == "GQE_CANCEL" )
				GTPAddHist(aHist,3,xOldVl)
			EndIf	
			
		EndIf
		
		If ( cAction == "SETVALUE" .And. cField == "GQE_RECURS" .And. xValue <> xOldVl)
			oSubMdl:SetValue("GQE_STATUS","2")
		EndIf	
	
	EndIf

ElseIf ( lRet .And. cAction == "SETVALUE")
	
	If ( cField == "G55_DTPART" )
		
		If ( xValue < oSubMdl:GetModel():GetModel("GYNDETAIL"):GetValue("GYN_DTINI") .Or.;
				xValue > oSubMdl:GetModel():GetModel("GYNDETAIL"):GetValue("GYN_DTFIM") )
				
			lRet := .f.
				
			FWAlertHelp(STR0046,STR0047)//"Data de partida incorreta","Informe uma data de partida para esta seção que esteja entre a data inicial e final da viagem"
		
		EndIf
		
	ElseIf ( cField == "G55_DTCHEG" )
	
		If ( xValue < oSubMdl:GetModel():GetModel("GYNDETAIL"):GetValue("GYN_DTINI") .Or.;
				xValue > oSubMdl:GetModel():GetModel("GYNDETAIL"):GetValue("GYN_DTFIM") )
				
			lRet := .f.
				
			FWAlertHelp(STR0046,STR0048)//"Data de partida incorreta","Informe uma data de chegada para esta seção que esteja entre a data inicial e final da viagem"
		
		EndIf
		
	EndIf
		
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} G300ConfVld

Função responsável para verificar se no monitor operacional 
possui algum conflito

@Param
			oMld	- O submodelo 
			cCpo	- Campo posicionado
			xValue 	- Valor atual

@Return 	lRet  
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Function G300ConfVld(oMld,cCpo,xValue)

Local lRet			:= .T.

Local nX			:= 0
Local nA			:= 0
Local nY			:= 0

Local oViewMonitor	:= GC300GetMVC('V')
Local oMldMaster	:= oViewMonitor:getModel()
Local oMdlG55		
Local oMdlGYN		
Local oMdlGQE

Local cRetLog		:= ""
Local cMsgSol		:= ""
Local cCodVia		:= ''
Local cSeq			:= ''
Local nlinhaA		:= 0
Local aHist			:= {}
Local lSobeNivel	:= .T.
Local lConfirm		:= .T.
Local nQtdVei		:= 0 
Local nQtdRec		:= 0 
Local xOld

If ( FwIsInCallStack("GC300COMMIT") )
	Return(.T.)
EndIf

If ValType(oViewMonitor) == 'O' .AND. oViewMonitor:IsActive()

	If cCpo == "GQE_STATUS"
		
		lRet := VldRecurso(oMld:GetModel(),xValue,@cRetLog,@cMsgSol)
		If !lRet
			cRetLog := Iif(Empty(cRetLog), STR0049, cRetLog)
			oMld:GetModel():SetErrorMessage(oMld:GetId(),"GQE_STATUS",oMld:GetId(),"GQE_STATUS",'STATUS',cRetLog,cMsgSol )//"Não foi possivel confirmar o Colaborador"
		Endif
	ElseIf cCpo == "G55_CONF"
		oMdlGYN		:= oMldMaster:GetModel("GYNDETAIL")
		oMdlGQE		:= oMldMaster:GetModel("GQEDETAIL")
		oMdlG55		:= oMldMaster:GetModel("G55DETAIL")
		If xValue ==  '1'
			 //Verifica quantidade 
			For nY	:= 1 to oMdlGQE:Length()
				If !oMdlGQE:IsDeleted(nY)
					oMdlGQE:GoLine( nY )
					If (lRet := VldRecurso(oMld:GetModel(),xValue,@cRetLog,@cMsgSol))
						If oMdlGQE:GetValue("GQE_TRECUR") == "1"
							nQtdRec++
						ElseIf oMdlGQE:GetValue("GQE_TRECUR") == "2"
							nQtdVei++
						EndIf
					Else
						Exit
					Endif
				Endif
			Next
			If (nQtdRec == 0 .or. nQtdVei == 0)
				lRet := .F.
				cRetLog := Iif(Empty(cRetLog), STR0050, cRetLog)
				oMld:GetModel():SetErrorMessage(oMld:GetId(),"GYN_CONF",oMld:GetId(),"G55_CONF",'STATUS',cRetLog,cMsgSol )//"Não foi possivel confirmar a seção "
			Endif
			If lRet
				If !GC300VldPrf(oMldMaster)
				
					lRet := .F.
					oMld:GetModel():SetErrorMessage(oMld:GetId(),"GYN_CONF",oMld:GetId(),"G55_CONF",'STATUS',STR0051, STR0050 )//"O trecho não possui todos os colaboradores necessários conforme definido no perfil da linha"#"Não foi possivel confirmar a seção"
					
				
				Endif
				
			Endif
			
		Endif
		
	ElseIf cCpo == "GYN_CONF"
		
		//RADU -> MOVER ISTO PARA DEPOIS DO IF XVALUE <> '2'
		//JCA: DSERGTP-8012, Início
		If ( lRet )
			
			lRet := ValidFinanceiro(oMldMaster:GetModel("GYNDETAIL"))

			If ( !lRet )
				
				cErro := "O cliente solicitante dessa viagem possui pendências "
				cErro += "financeiras."

				cSolucao := "Verifique se o pedido de vendas " + Alltrim(oMldMaster:GetModel("GYNDETAIL"):GetValue("GYN_CODPED"))
				cSolucao += " possui títulos desse cliente que não foram liquidados (com saldo maior que zero). "
				oMld:GetModel():SetErrorMessage(oMld:GetId(),"GYN_CONF",oMld:GetId(),"GYN_CONF",'FINANCEIRO',cErro, cSolucao )
			EndIf

		EndIf
		//JCA: DSERGTP-8012, Fim
		
		If lRet .And. xValue <>  '2'
			oMdlG55		:= oMldMaster:GetModel("G55DETAIL")
		
			For nA := 1 To oMdlG55:Length()
				lRet := G300ConfVld(oMld,"G55_CONF",xValue)
				If !lRet
					Exit
				Endif
			Next

		Endif
	ElseIf cCpo == "G55_CANCEL"
	    cCodVia		:= oMld:GetValue( 'G55_CODVIA' )
		cSeq		:= oMld:GetValue( 'G55_SEQ' )
		nLinhaA		:= oMld:GetLine()
		oMdlGYN		:= oMldMaster:GetModel("GYNDETAIL")
		oMdlGQE		:= oMldMaster:GetModel("GQEDETAIL")
		oMdlG55		:= oMldMaster:GetModel("G55DETAIL")
		If xValue <>  '1'
			 oMdlGYN:SeekLine({ {'GYN_CODIGO', cCodVia}})
			 oMdlG55:SeekLine({ {'G55_CODVIA', cCodVia},{"G55_SEQ",cSeq}})
				
			For nX := 1 To oMdlGQE:Length()
			
				aHist := {	oMdlGQE:GetValue("GQE_VIACOD",nX),;
							oMdlGQE:GetValue("GQE_SEQ",nX),;
							oMdlGQE:GetValue("GQE_ITEM",nX),;
							oMdlGQE:GetValue("GQE_TRECUR",nX),;
							oMdlGQE:GetValue("GQE_TCOLAB",nX),;
							oMdlGQE:GetValue("GQE_RECURS",nX),;
							oMdlGQE:GetValue("GQE_JUSTIF",nX)}
				
				oMdlGQE:GoLine( nX )
				If ( !oMdlGQE:IsDeleted() .AND. !Empty(oMdlGQE:GetValue('GQE_VIACOD')))
					
					xOld := oMdlGQE:GetValue("GQE_CANCEL")
					
					oMdlGQE:SetNoDeleteLine(.F.)
					oMdlGQE:DeleteLine()							
					oMdlGQE:SetNoDeleteLine(.T.)			
					
					GTPAddHist(aHist,3,xOld)
					
				Endif
				
			Next nX
			
			lSobeNivel 	:= .T.
			lConfirm	:= .T.
			oMdlG55:Goline(1)
			oMdlG55:SeekLine({ {'G55_CODVIA', cCodVia}})
					
			For nX := 1 To oMdlG55:Length()				
				oMdlG55:GoLine( nX )
				If ( !oMdlG55:IsDeleted() .AND. !Empty(oMdlG55:GetValue('G55_CODVIA')))
					If oMdlG55:GetValue('G55_CANCEL') <> '2' .AND. nX <> nLinhaA
						lSobeNivel := .F.
						Exit					
					Endif
				Endif
					
			Next nX
				
			If lSobeNivel
				oMdlGYN:Goline(1)
				oMdlGYN:SeekLine({ {'GYN_CODIGO', cCodVia}})					
				oMdlGYN:LoadValue( "GYN_CANCEL"	, '2' )
			Endif
			
			For nX := 1 To oMdlG55:Length()				
				oMdlG55:GoLine( nX )
				If ( !oMdlG55:IsDeleted() .AND. !Empty(oMdlG55:GetValue('G55_CODVIA')))					
					If (oMdlG55:GetValue('G55_CONF') <> '1' .AND. oMdlG55:GetValue('G55_CANCEL') == '1' .AND. nX <> nLinhaA)
						lConfirm := .F.
					Endif
				Endif
					
			Next nX
			If lConfirm
				oMdlGYN:LoadValue( "GYN_CONF"	, '1' )
			ENdif
			
		Else
			oMdlGYN:SeekLine({ {'GYN_CODIGO', cCodVia}})
			oMdlG55:SeekLine({ {'G55_CODVIA', cCodVia},{"G55_SEQ",cSeq}})
			
			For nX := 1 To oMdlGQE:Length()
				
				aHist := {	oMdlGQE:GetValue("GQE_VIACOD",nX),;
							oMdlGQE:GetValue("GQE_SEQ",nX),;
							oMdlGQE:GetValue("GQE_ITEM",nX),;
							oMdlGQE:GetValue("GQE_TRECUR",nX),;
							oMdlGQE:GetValue("GQE_TCOLAB",nX),;
							oMdlGQE:GetValue("GQE_RECURS",nX),;
							oMdlGQE:GetValue("GQE_JUSTIF",nX)}
					
				oMdlGQE:GoLine( nX )
				If ( !oMdlGQE:IsDeleted() .AND. !Empty(oMdlGQE:GetValue('GQE_VIACOD')))
					
					xOld := oMdlGQE:GetValue("GQE_CANCEL")
					
					oMdlGQE:LoadValue( "GQE_CANCEL"	, '1' )
					
					GTPAddHist(aHist,3,xOld)
					
				Endif
				
			Next nX
			oMdlGYN:LoadValue( "GYN_CANCEL"	, '1' )
			lConfirm := .F.
			For nX := 1 To oMdlG55:Length()				
				oMdlG55:GoLine( nX )
				If ( !oMdlG55:IsDeleted() .AND. !Empty(oMdlG55:GetValue('G55_CODVIA')))					
					If (oMdlG55:GetValue('G55_CONF') <> '1'  )
						lConfirm := .T.
					Endif
				Endif
					
			Next nX
			If lConfirm
				oMdlGYN:SetValue( "GYN_CONF"	, '2' )
			ENdif
		Endif
		oMdlGYN:SeekLine({ {'GYN_CODIGO', cCodVia}})
		GC300SetLegenda(oMdlGYN)		
		oMdlG55:SeekLine({ {'G55_CODVIA', cCodVia},{"G55_SEQ",cSeq}})
		GC300SetLegenda(oMld)
		oViewMonitor:Refresh("G55DETAIL")
		
	ElseIf cCpo == "GYN_CANCEL"
		cCodVia		:= oMld:GetValue( 'GYN_CODIGO' )
		oMdlGYN		:= oMldMaster:GetModel("GYNDETAIL")
		oMdlGQE		:= oMldMaster:GetModel("GQEDETAIL")
		oMdlG55		:= oMldMaster:GetModel("G55DETAIL")
			
		If xValue <>  '1'
			oMdlGYN:SeekLine({ {'GYN_CODIGO', cCodVia}})	
			For nA := 1 To oMdlG55:Length()
				oMdlG55:GoLine( nA )
				If ( !oMdlG55:IsDeleted() .AND. !Empty(oMdlG55:GetValue('G55_CODVIA')))
					
					For nX := 1 To oMdlGQE:Length()
					
						aHist := {	oMdlGQE:GetValue("GQE_VIACOD",nX),;
									oMdlGQE:GetValue("GQE_SEQ",nX),;
									oMdlGQE:GetValue("GQE_ITEM",nX),;
									oMdlGQE:GetValue("GQE_TRECUR",nX),;
									oMdlGQE:GetValue("GQE_TCOLAB",nX),;
									oMdlGQE:GetValue("GQE_RECURS",nX),;
									oMdlGQE:GetValue("GQE_JUSTIF",nX)}
								
						oMdlGQE:GoLine( nX )
						If ( !oMdlGQE:IsDeleted() .AND. !Empty(oMdlGQE:GetValue('GQE_VIACOD')))						
							
							xOld := oMdlGQE:GetValue("GQE_CANCEL")
							oMdlGQE:SetNoDeleteLine(.F.)
							oMdlGQE:DeleteLine()							
							oMdlGQE:SetNoDeleteLine(.T.)
							GTPAddHist(aHist,3,xOld)
							
						Endif
						
					Next nX
					
					oMdlG55:LoadValue( "G55_CANCEL"	, '2' )					
					
				Endif
					
			Next nA
		
		Else
			oMdlGYN:SeekLine({ {'GYN_CODIGO', cCodVia}})
			For nA := 1 To oMdlG55:Length()
				oMdlG55:GoLine( nA )
				If ( !oMdlG55:IsDeleted() .AND. !Empty(oMdlG55:GetValue('G55_CODVIA')))
		
					For nX := 1 To oMdlGQE:Length()
					
						aHist := {	oMdlGQE:GetValue("GQE_VIACOD",nX),;
									oMdlGQE:GetValue("GQE_SEQ",nX),;
									oMdlGQE:GetValue("GQE_ITEM",nX),;
									oMdlGQE:GetValue("GQE_TRECUR",nX),;
									oMdlGQE:GetValue("GQE_TCOLAB",nX),;
									oMdlGQE:GetValue("GQE_RECURS",nX),;
									oMdlGQE:GetValue("GQE_JUSTIF",nX)}
						
						oMdlGQE:GoLine( nX )
						If ( !oMdlGQE:IsDeleted() .AND. !Empty(oMdlGQE:GetValue('GQE_VIACOD')))
							
							xOld := oMdlGQE:GetValue("GQE_CANCEL")
							
							oMdlGQE:LoadValue( "GQE_CANCEL"	, '1' )
							
							GTPAddHist(aHist,3,xOld)				
							
						Endif
						
					Next nX
					
					oMdlG55:LoadValue( "G55_CANCEL"	, '1' )
					
				Endif
				
				
			Next nA
		
		Endif
	
		oMdlGYN:SeekLine({ {'GYN_CODIGO', cCodVia}})
		GC300SetLegenda(oMld)
		
		oMdlG55:SeekLine({ {'G55_CODVIA', cCodVia}})
		For nA := 1 To oMdlG55:Length()
			oMdlG55:GoLine( nA )	
			GC300SetLegenda(oMdlG55)
		next nA
				
		oViewMonitor:Refresh("GYNDETAIL")
		oViewMonitor:Refresh("G55DETAIL")			
	Endif
	
Else
	FwAlertHelp(STR0001,STR0002) //"Esta rotina só funciona com monitor ativo"
	lRet := .F.
Endif

Return lRet

//-----------------------------------------------------------------------------
/*{Protheus.doc} GC300GetFld
Função responsável por captura do conteúdo do campo de tipo de colaborador  para 
filtro da consulta padrão GYGFIL - Colaboradores. esta consulta é utilizada em 
conjunto com a GQEREC - Recursos x Viagens. 

Como esta consulta de colaboradores pode ser efetuada de diversas interfaces,
houve a necessidade desta função. 

@Return
 cRet: String. Código do Tipo de Colaborador a ser retornado para o filtro da 
 consulta padrão

@sample cRet := GC300GetFld()
@author Fernando Radu Muscalu

@since 07/12/2015
@version 1.0
*/
//-----------------------------------------------------------------------------
Function GC300GetFld(lAut)
Local oModel
Local cRet   := ""

Default lAut := .F.

If ( IsInCallStack("GTPC300") )
	cRet := oGC300Obj:GetModel():GetModel("RECURSOS"):GetValue("GQE_TCOLAB")
ElseIf ( IsInCallStack("GTPA304") )
	cRet := oGC300Obj:GetModel("GTPA304"):GetModel("GQEITEM"):GetValue("GQE_TCOLAB")
ElseIf ( IsInCallStack("GTPA306") )
	oModel := FwModelActive()
	
	If ( oModel:GetId() == "GTPA306" )
		cRet := oModel:GetModel("GQKMASTER"):GetValue("GQK_TCOLAB")
	Else
		cRet := FwFldGet("GQK_TCOLAB")
	Endif
Else
	if !lAut
		cRet := FwFldGet("GQE_TCOLAB") 
	endif
Endif

Return(cRet)

/*/{Protheus.doc} GC300ChkRec
Função responsável validar o recurso 
@type function
@author Fernando Radu Muscalu
@since 30/08/2017
@version 1.0
@param cRecurs, character, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@param oSubMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GC300ChkRec(cRecurso,cTipo,oSubMdl, lTerceiro)

Local lRet		:= .T.
Local oModel	:= nil
Local oMdlGYN	:= nil	
Local oMdlG55	:= nil
Local oMdlGQE	:= nil
Local dDtRef	:= nil
Local dDtIni	:= nil
Local cHrIni    := nil
Local dDtFim    := nil
Local cHrFim    := nil
Local cLinha	:= ""
Local cMsgErro  := ""
Local cMsgSol	:= ""
Default lTerceiro := .F.

If lTerceiro
	lRet := ExistCpo("G6Z", cRecurso) 
Else
	If ( cTipo == "1" )	
		lRet := ExistCpo("GYG",cRecurso)  
	Else
		lRet := ExistCpo("ST9",cRecurso)
	EndIf
EndIf

If lRet .and. FwIsInCallStack('GC300VALID')

	oModel	:= oSubMdl:GetModel()                
	oMdlGYN	:= oModel:GetModel('GYNDETAIL')      
	oMdlG55	:= oModel:GetModel('G55DETAIL')      
	oMdlGQE	:= oModel:GetModel('GQEDETAIL')
	dDtRef	:= oMdlGQE:GetValue('GQE_DTREF')
	dDtIni	:= oMdlG55:GetValue('G55_DTPART')    
	cHrIni  := oMdlGQE:GetValue('GQE_HRINTR')     
	dDtFim  := oMdlG55:GetValue('G55_DTCHEG')    
	cHrFim  := oMdlGQE:GetValue('GQE_HRFNTR')
	cLinha	:= oMdlGYN:GetValue("GYN_LINCOD")     
	nRecGQK := oMdlGQE:GetDataId()  

	If !Gc300VldAloc(cRecurso,cTipo,dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,      ,nRecGQK,      ,cLinha,@cMsgSol) 

		Help( ,, 'Help',"GC300ChkRec", cMsgErro, 1, 0,,,,,,{cMsgSol} )//A sequência informada não poderá ser igual a de inicio, fim ou zero.
		lRet := .F.

	Endif 
	
Endif
 
Return(lRet)

/*/{Protheus.doc} GC300ClearObj
(long_description)
@type function
@author jacomo.fernandes
@since 17/09/2018
@version 1.0
@param lFinishTable, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GC300ClearObj(lFinishTable)

Default lFinishTable	:= .f.

If ( ValType(oGC300Model) == "O" .and. oGC300Model:IsActive() )
	oGC300Model:GetModel("MASTER"):DeActivate()
	oGC300Model:GetModel("GYNDETAIL"):DeActivate()
	oGC300Model:GetModel("G55DETAIL"):DeActivate()
	oGC300Model:GetModel("GQEDETAIL"):DeActivate()
EndIf

If ( ValType(oGC300View) == "O" )
	oGC300View:ClearPanel()
EndIf	

Return()


/*/{Protheus.doc} GC300DRECUR
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GC300DRECUR()
Local cDescri := ""
Local lTerceiro := GQE->GQE_TERC == '1'

	If lTerceiro
		cDescri :=  Posicione("G6Z",1,xFilial("G6Z")+ GQE->GQE_RECURS,"G6Z_NOME"  )
	Else
		If GQE->GQE_TRECUR == "1"
			cDescri :=  Posicione("GYG",1,xFilial("GYG")+ GQE->GQE_RECURS,"GYG_NOME"  )
		Else
			cDescri :=  Posicione("ST9",1,xFilial("ST9")+ GQE->GQE_RECURS,"T9_NOME"  )
		EndIf
	EndIf
Return(cDescri)


/*/{Protheus.doc} VldRecurso
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param xValue, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldRecurso(oModel,xValue,cRetLog,cMsgSol)
Local lRet := .T.
Local oMdlGYN		:= oModel:GetModel("GYNDETAIL")
Local oMdlG55		:= oModel:GetModel("G55DETAIL")
Local oMdlGQE		:= oModel:GetModel("GQEDETAIL")
Local aRetLog		:= {}

Default cRetLog		:= ''
Default cMsgSol		:= ""

If lRet .AND. xValue == '1'
	
	If oMdlGQE:GetValue("GQE_TRECUR") == '1' .AND. (oMdlGQE:GetValue("GQE_TERC") == '2' .OR. oMdlGQE:GetValue("GQE_TERC") == ' ')
		lRet :=  GTP409ColConf(oMdlGQE:GetValue("GQE_RECURS"),oMdlGQE:GetValue("GQE_DTREF"),oMdlGYN:GetValue("GYN_LINCOD"),,@aRetLog)
		cRetLog := aRetLog[2]
	Else		
		lRet :=  GTP409ConfVei(oMdlGQE:GetValue("GQE_RECURS"),oMdlG55:GetValue("G55_DTPART"),oMdlG55:GetValue("G55_DTCHEG"),@cRetLog,oMdlG55:GetValue("G55_HRINI"),oMdlG55:GetValue("G55_HRFIM"),oMdlGYN:GetValue("GYN_LINCOD"),@cMsgSol,.f.)
	Endif

Endif

GTPDestroy(aRetLog)

Return lRet


//-------------------------------------------------------
/*/{Protheus.doc} GTPc300TRG
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//-------------------------------------------------------
Static Function GTPc300TRG(oMdl,cField,xVal)
Local oModel		:= oMdl:GetModel()
Local oMdlG55		:= oModel:GetModel('G55DETAIL')
Local oMdlGYN		:= oModel:GetModel('GYNDETAIL')
Local oViewMonitor	:= GC300GetMVC('V')
Local n1			:= 1
Do Case
	Case cField == "GQE_STATUS"
		If !FwIsInCallStack("GC300TRGG55")
			Gc300TrgGQE(oModel)
		Endif
		If !FwIsInCallStack('GTPC300K')
			oMdl:SetValue('GQE_TPCONF','2')//Planejamento
		Endif
			
	Case cField == "G55_CONF"
		IF !FwIsInCallStack("GC300TRGGQE")
			Gc300TrgG55(oModel,1,xVal)
		Else
			Gc300TrgG55(oModel,2,xVal)
		Endif
	Case cField == "GYN_CONF"
		IF !FwIsInCallStack("GC300TRGG55")
			xVal := If(xVal=='1',xVal,'2')
			For n1	:= 1 to oMdlG55:Length()
				If !oMdlG55:IsDeleted(n1)
					oMdlG55:GoLine(n1)
					oMdlG55:SetValue('G55_CONF',xVal)
				Endif
			Next
			Gc300TrgG55(oModel,2,xVal)
		Endif
		GC300SetLegenda(oMdlGYN)
	Case cField == 'GQE_TPCONF'
		If !FwIsInCallStack('GTPC300K')
			oMdl:SetValue('GQE_USRCON',cUserName)
			oMdl:SetValue('GQE_DTCONF',FwTimeStamp(2))
		Endif
	
EndCase
If ValType(oViewMonitor) == 'O' .AND. oViewMonitor:IsActive()
	oViewMonitor:Refresh()
Endif
Return xVal

/*/{Protheus.doc} Gc300TrgGQE
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Gc300TrgGQE(oModel)
Local oMdlG55	:= oModel:GetModel('G55DETAIL')
Local oMdlGQE	:= oModel:GetModel('GQEDETAIL')
Local nLine		:= oMdlGQE:GetLine() 
Local lConf		:= .F.
Local lNaoConf	:= .F.
Local lColab	:= .F.
Local lVeic		:= .F.
Local xOld		:= nil
Local aHist		:= {;	
						oMdlGQE:GetValue("GQE_VIACOD"),;
						oMdlGQE:GetValue("GQE_SEQ"),;
						oMdlGQE:GetValue("GQE_ITEM"),;
						oMdlGQE:GetValue("GQE_TRECUR"),;
						oMdlGQE:GetValue("GQE_TCOLAB"),;
						oMdlGQE:GetValue("GQE_RECURS"),;
						oMdlGQE:GetValue("GQE_JUSTIF");
					}
				
						
	xOld := oMdlGQE:GetValue("GQE_STATUS")
	GTPAddHist(aHist,2,xOld)
				
	lConf		:= oMdlGQE:SeekLine({{"GQE_STATUS",'1'}})
	lNaoConf	:= oMdlGQE:SeekLine({{"GQE_STATUS",'2'}})
	lColab		:= oMdlGQE:SeekLine({{"GQE_TRECUR",'1'}})
	lVeic		:= oMdlGQE:SeekLine({{"GQE_TRECUR",'2'}})
		
	If lConf .and. !lNaoConf
		If lColab .and. lVeic 
			oMdlG55:SetValue('G55_CONF','1') //Confirmado
		Else
			oMdlG55:SetValue('G55_CONF','3') //Confirmado Parcialment
		Endif
	Elseif lConf .and. lNaoConf
		oMdlG55:SetValue('G55_CONF','3') //Confirmado Parcialment
	Else
		oMdlG55:SetValue('G55_CONF','2') //Não Confirmado
	Endif
	oMdlGQE:GoLine(nLine)
	GC300SetLegenda(oMdlG55)
Return

/*/{Protheus.doc} Gc300TrgG55
(long_description)
@type function
@author jacom
@since 14/04/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nTipo, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Gc300TrgG55(oModel,nTipo,xVal)
Local oMdlGYN	:= oModel:GetModel('GYNDETAIL')
Local oMdlG55	:= oModel:GetModel('G55DETAIL')
Local oMdlGQE	:= oModel:GetModel('GQEDETAIL')
Local nLine		:= oMdlG55:GetLine() 
Local n1		:= 0
Local lConf		:= .F.
Local lNaoConf	:= .F.
Local lConfParc	:= .T.
Local lVldPerf	:= .F.

	IF nTipo == 1
		For n1	:= 1 to oMdlGQE:Length()
			If !oMdlGQE:IsDeleted(n1)
				oMdlGQE:GoLine(n1)
				oMdlGQE:SetValue('GQE_STATUS',If(xVal=='1',xVal,'2'))
				GC300SetLegenda(oMdlGQE)
			Endif
		Next
		Gc300TrgGQE(oModel)
		GC300SetLegenda(oMdlG55)
	Endif
	
	lConf		:= oMdlG55:SeekLine({{"G55_CONF",'1'} })
	lNaoConf	:= oMdlG55:SeekLine({{"G55_CONF",'2'},{"G55_CANCEL",'1'}  })
	lConfParc	:= oMdlG55:SeekLine({{"G55_CONF",'3'} })
	lVldPerf	:= GC300VldPrf(oModel)
	
	If lConfParc //Confirmado Parcialmente
		oMdlGYN:SetValue('GYN_CONF','3')
	ElseIf lConf .and. !lNaoConf .and. lVldPerf
		oMdlGYN:SetValue('GYN_CONF','1') //Confirmado
	Elseif lConf .and. lNaoConf
		oMdlGYN:SetValue('GYN_CONF','3') //Confirmado Parcialmente
	Else
		oMdlGYN:SetValue('GYN_CONF','2') //Não Confirmado
	Endif
	oMdlG55:GoLine(1)
	GC300SetLegenda(oMdlGYN)

oMdlG55:GoLine(nLine)
oMdlGQE:GoLine(1)
Return


/*/{Protheus.doc} Gc300VldAloc
Função responsavel para validar a alocação do recurso
@type function
@author jacomo.fernandes
@since 17/09/2018
@version 1.0
@param cRecurso, character, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@param dDtIni, data, (Descrição do parâmetro)
@param cHrIni, character, (Descrição do parâmetro)
@param dDtFim, data, (Descrição do parâmetro)
@param cHrFim, character, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@param lVldRh, boolean, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function Gc300VldAloc(cRecurso,cTipo,dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,cMsgErro,lVldRh,nRecGQK,cTpDia,cLinha,cMsgSol)

Local lRet		:= .T.
Local lMonitor	:= GC300GetMVC("IsActive")
Local aRetLog	:= {}

Default cRecurso:= ""
Default cTipo   := ""
Default dDtIni  := ""
Default cHrIni  := ""
Default dDtFim  := ""
Default cHrFim  := ""
Default cMsgErro:= ""
Default lVldRh	:= .T.
Default nRecGQK := 0
Default cTpDia	:= "1" //Trabalhado
Default cLinha	:= ""
Default cMsgSol	:= ""

If Empty(dDtRef)
	dDtRef := dDtIni
Endif

If !VldQryAloc(cRecurso,cTipo,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,dDtRef,cTpDia)
	lRet		:= .F.
ElseIf !VldAlocExt(cRecurso,cTipo,dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,nRecGQK,cTpDia)
	lRet 	:= .F.
ElseIf lMonitor .and. !VldMntAloc(cRecurso,cTipo,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,dDtRef,cTpDia)
	lRet		:= .F.
ElseIf cTipo == '1' .and. lVldRh .and. !GTP409ColConf(cRecurso,dDtRef,cLinha,/*aConf*/,aRetLog)
	lRet		:= .F.
	cMsgErro	:= aRetLog[2]
	cMsgSol		:= aRetLog[3]
ElseIf cTipo == '2' .and. !GTP409ConfVei(cRecurso,dDtIni,dDtFim,@cMsgErro,cHrIni,cHrFim,cLinha,@cMsgSol,.f.)
	lRet		:= .F.
Endif

GTPDestroy(aRetLog)

Return lRet
 
/*/{Protheus.doc} VldQryAloc
Função responsavel para verificar via base de dados se o recurso se encontra em alguma viagem no periodo informado de alocação
@type function
@author jacomo.fernandes
@since 17/09/2018
@version 1.0
@param cRecurso, character, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@param dDtIni, data, (Descrição do parâmetro)
@param cHrIni, character, (Descrição do parâmetro)
@param dDtFim, data, (Descrição do parâmetro)
@param cHrFim, character, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldQryAloc(cRecurso,cTipo,dDtIni,cHrIni,dDtFim,cHrFim,cMsgErro,dDtRef,cTpDia)

Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()
Local cViagem	:= ""

If !(EMPTY(cHrIni)) .AND. !(EMPTY(cHrFim))

	BeginSQL alias cAliasTmp
		Select DISTINCT
			GQE.GQE_RECURS,
			GQE.GQE_DTREF,
			GQE.GQE_VIACOD,
			G55.G55_DTPART,
			G55.G55_DTCHEG,
			G55.G55_HRINI,
			G55.G55_HRFIM
		From %Table:GYN% GYN
			Inner Join %Table:G55% G55 on 
				G55.G55_FILIAL		=	GYN.GYN_FILIAL
				AND G55.G55_CODVIA	=	GYN.GYN_CODIGO
				
				AND (
						(%Exp:DTOS(dDtIni)+cHrIni% >=  G55.G55_DTPART || G55.G55_HRINI 
							and %Exp:DTOS(dDtIni)+cHrIni% <  G55.G55_DTCHEG || G55.G55_HRFIM	)
							
					 	or (%Exp:DTOS(dDtFim)+cHrFim% >  G55.G55_DTPART || G55.G55_HRINI 
					 		and %Exp:DTOS(dDtFim)+cHrFim% <=  G55.G55_DTCHEG || G55.G55_HRFIM )
					 		
					 	or (G55.G55_DTPART || G55.G55_HRINI >= %Exp:DTOS(dDtIni)+cHrIni%  
					 		and G55.G55_DTPART || G55.G55_HRINI < %Exp:DTOS(dDtFim)+cHrFim%  )
					 		
					 	or (G55.G55_DTCHEG || G55.G55_HRFIM > %Exp:DTOS(dDtIni)+cHrIni%  
					 		and G55.G55_DTCHEG || G55.G55_HRFIM <= %Exp:DTOS(dDtFim)+cHrFim%  )
					)
				AND G55.%NotDel%
		
			Inner Join %Table:GQE% GQE ON 
				GQE.GQE_FILIAL		= GYN.GYN_FILIAL
				AND GQE.GQE_VIACOD	= GYN.GYN_CODIGO
				AND GQE.GQE_SEQ		= G55.G55_SEQ
				AND GQE.GQE_TRECUR	= %Exp:cTipo%
				AND GQE.GQE_RECURS	= %Exp:cRecurso%
				AND NOT (GYN.GYN_TIPO = '2' 
						AND GQE.GQE_TRECUR = '1' 
						AND GYN.GYN_FINAL = '1') //Não considerar colaborador na Viagem Especial, pois o mesmo vai ser cadastrado como plantão 
				AND GQE.%NotDel%
		
		where 
			GYN.GYN_FILIAL = %xFilial:GYN%
			AND (
					%Exp:DTOS(dDtIni)%  between GYN.GYN_DTINI AND GYN.GYN_DTFIM 
					or %Exp:DTOS(dDtFim)%  between GYN.GYN_DTINI AND GYN.GYN_DTFIM
				)
			AND GYN.%NotDel%
	EndSQL		
	
	While (cAliasTmp)->(!Eof())
		If cTpDia <= '2'
			cViagem	:= (cAliasTmp)->GQE_VIACOD
			Exit
		ElseIf (cAliasTmp)->GQE_DTREF == DtoS(dDtRef)
			cViagem	:= (cAliasTmp)->GQE_VIACOD
			Exit
		Endif
		(cAliasTmp)->(DbSkip())
	End

	(cAliasTmp)->(DbCloseArea())
EndIf

If !Empty(cViagem)
	cMsgErro := I18n("O recurso: #1 está alocado entre o periodo: #2-#3 até #4-#5 na(s) viagem(ns): #6",{cRecurso,DtoC(dDtIni),Transform(cHrIni,"@R 99:99"),DtoC(dDtFim),Transform(cHrFim,"@R 99:99"), cViagem}) 
	lRet	:= .F.
Endif

Return lRet

/*/{Protheus.doc} VldMntAloc
Função responsavel para verificar via monitor de alocação se o recurso se encontra em alguma viagem no periodo informado de alocação
@type function
@author jacomo.fernandes
@since 17/09/2018
@version 1.0
@param cRecurso, character, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@param dDtIni, data, (Descrição do parâmetro)
@param cHrIni, character, (Descrição do parâmetro)
@param dDtFim, data, (Descrição do parâmetro)
@param cHrFim, character, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldMntAloc(cRecurso,cTipo,dDtIni,cHrIni,dDtFim,cHrFim,cMsgErro,dDtRef,cTpDia)
Local lRet		:= .T.
Local oMdlMonit	:= GC300GetMVC('M')
Local oMdlGYN	:= oMdlMonit:GetModel("GYNDETAIL")
Local oMdlG55	:= oMdlMonit:GetModel("G55DETAIL")
Local oMdlGQE	:= oMdlMonit:GetModel("GQEDETAIL")

Local nLinGYN	:= oMdlGYN:GetLine()  
Local nLinG55	:= oMdlG55:GetLine()
Local nLinGQE	:= oMdlGQE:GetLine()

Local nX		:= 0
Local nY 		:= 0

For nX	:= 1 to oMdlGYN:Length()
	oMdlGYN:GoLine(nX)
	//Ignora quando a validação for colaborador e o tipo de viagem é extraordinário
	If cTipo == '1' .and. oMdlGYN:GetValue('GYN_TIPO') == '2' .and. oMdlGYN:GetValue('GYN_FINAL') == '1'
		Loop 
	Endif
	For nY	:= 1 to oMdlG55:Length()
		oMdlG55:GoLine(nY)
		
		If (;
				(DtoS(dDtIni)+cHrIni >=  DtoS(oMdlG55:GetValue("G55_DTPART"))+oMdlG55:GetValue("G55_HRINI") ;
					.and. DtoS(dDtIni)+cHrIni <  Dtos(oMdlG55:GetValue("G55_DTCHEG"))+oMdlG55:GetValue("G55_HRFIM") ) ;
				;	
			 	.or. (DtoS(dDtFim)+cHrFim >  DtoS(oMdlG55:GetValue("G55_DTPART"))+oMdlG55:GetValue("G55_HRINI") ;
			 		.and. DtoS(dDtFim)+cHrFim <=  Dtos(oMdlG55:GetValue("G55_DTCHEG"))+oMdlG55:GetValue("G55_HRFIM") ) ;
			 	;	
			 	.or. (DtoS(oMdlG55:GetValue("G55_DTPART"))+oMdlG55:GetValue("G55_HRINI") >= DtoS(dDtIni)+cHrIni  ;
			 		.and. DtoS(oMdlG55:GetValue("G55_DTPART"))+oMdlG55:GetValue("G55_HRINI") < DtoS(dDtFim)+cHrFim  ) ;
			 	;	
			 	.or. (Dtos(oMdlG55:GetValue("G55_DTCHEG"))+oMdlG55:GetValue("G55_HRFIM") > DtoS(dDtIni)+cHrIni  ;
			 		.and. Dtos(oMdlG55:GetValue("G55_DTCHEG"))+oMdlG55:GetValue("G55_HRFIM") <= DtoS(dDtFim)+cHrFim  ) ;
			)
			
			If oMdlGQE:SeekLine({{"GQE_RECURS",cRecurso}})
				If cTpDia <= '2'
					lRet := .F.
					Exit
				ElseIf oMdlGQE:GetValue("GQE_DTREF") == dDtRef
					lRet := .F.
				Endif
			
				If !lRet 
					cMsgErro := I18n("O recurso: #1 está alocado entre o periodo: #2-#3 até #4-#5 na viagem: #6",{cRecurso,DtoC(dDtIni),Transform(cHrIni,"@R 99:99"),DtoC(dDtFim),Transform(cHrFim,"@R 99:99"),oMdlGYN:GetValue('GYN_CODIGO')})
					Exit
				Endif
			EndIf
		
		EndIf
	Next
	If !lRet
		Exit
	Endif
Next

oMdlGYN:GoLine(nLinGYN)
oMdlG55:GoLine(nLinG55)
oMdlGQE:GoLine(nLinGQE)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} GC300VldPrf(oModel)
Valida o perfil da linha 

@sample GC300VldPrf(oModel)
@author Flavio Martins

@since 17/09/2018
@version 1.0
*/
//-------------------------------------------------------------------
Function GC300VldPrf(oModel)
Local lRet 		:= .F.
Local cAliasGYM	:= GetNextAlias()
Local oMdlGYN		
Local oMdlGQE	:= oModel:GetModel("GQEDETAIL")
Local cLinha	:= ""
Local cFldObg	:= ""

	If oModel:GetId() == 'GTPA300'
		oMdlGYN	:= oModel:GetModel("GYNMASTER")
	ElseIf oModel:GetId() == 'GTPC300'
		oMdlGYN	:= oModel:GetModel("GYNDETAIL")
	Endif
	
	cLinha	:= oMdlGYN:GetValue("GYN_LINCOD")	
	
	//Quando Viagem normal, verificar só os recursos obrigatórios de viagem normal
	If !oMdlGYN:GetValue('GYN_EXTRA')
		cFldObg := "% AND GYM.GYM_OBG = '1' %"
	Else //Quando Viagem extra, verificar só os recursos obrigatórios de viagem extra
		cFldObg := "% AND GYM.GYM_OBGEXT = '1' %"
	Endif
	
	BeginSql Alias cAliasGYM
	
		SELECT GYM_RECCOD,
       		GYM_CODENT
		FROM %Table:GYM% GYM
		WHERE 
			GYM.%NotDel%
	  		AND GYM.GYM_FILIAL = %xFilial:GYN%
	  		AND GYM_ORIGEM = 'GI2'
	  		%Exp:cFldObg%
	  		AND GYM.GYM_CODENT = %Exp:cLinha%
	  			
	EndSql
	
	If !(cAliasGYM)->(Eof())	
	
		While (cAliasGYM)->(!Eof())	
		
			lRet := oMdlGQE:SeekLine({ {'GQE_TCOLAB',(cAliasGYM)->GYM_RECCOD} })
			
			If !lRet
				Exit
			Endif
			
			(cAliasGYM)->(dbSkip())
	
		End
	
	Else
 		lRet := .T.
 	Endif
	
	(cAliasGYM)->(dbCloseArea())	

Return lRet

/*/{Protheus.doc} VldAlocExt
Função responsavel para verificar se o recurso foi possui uma alocação extraordinária
@type function
@author Flavio Martins
@since 08/02/2019
@version 1.0
@param cRecurso, character, (Descrição do parâmetro)
@param cTipo, character, (Descrição do parâmetro)
@param dDtIni, data, (Descrição do parâmetro)
@param cHrIni, character, (Descrição do parâmetro)
@param dDtFim, data, (Descrição do parâmetro)
@param cHrFim, character, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldAlocExt(cRecurso,cTipo,dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,cMsgErro,nRecGQK,cTpDia)
Local lRet			:= .T.
Local cAliasGQK	:= GetNextAlias()

	BeginSQL alias cAliasGQK
	
		SELECT GQK_CODIGO, 
		       GQK_CODVIA,
		       GQK_TPDIA,
		       GQK_DTREF 
    	FROM %Table:GQK% GQK
		WHERE
			GQK.GQK_FILIAL 	= %xFilial:GQK%
			AND GQK.GQK_RECURS = %Exp:cRecurso%
			AND GQK.R_E_C_N_O_ != %Exp:nRecGQK%
			AND GQK.%NotDel%
			AND ((%Exp:DTOS(dDtIni)+cHrIni% BETWEEN (GQK.GQK_DTINI || GQK.GQK_HRINI) AND (GQK.GQK_DTFIM || GQK.GQK_HRFIM) ) 
			OR  (%Exp:DTOS(dDtFim)+cHrFim% BETWEEN (GQK.GQK_DTINI || GQK.GQK_HRINI) AND (GQK.GQK_DTFIM || GQK.GQK_HRFIM) ) )
					
	EndSQL		

	If !(EMPTY(cHrFim))
		While (cAliasGQK)->(!Eof())
		
			If (cTpDia >= '3' .and. (cAliasGQK)->GQK_DTREF == DTOS(dDtRef)) .or. cTpDia <= "2"
					
				If (cAliasGQK)->GQK_TPDIA >= '3'
				
					Do Case 
						Case (cAliasGQK)->GQK_TPDIA == '3'
							cTpDia := 'Folga'
						Case (cAliasGQK)->GQK_TPDIA == '4'
							cTpDia := 'Nao Trabalhado'
						Case (cAliasGQK)->GQK_TPDIA == '5'
							cTpDia := 'Indisponivel RH'
						Case (cAliasGQK)->GQK_TPDIA == '6'
							cTpDia := 'DSR'
					EndCase
				
					If (cAliasGQK)->GQK_DTREF == DTOS(dDtRef)
					
						cMsgErro := STR0054 + cTpDia + STR0055//"O recurso escolhido foi alocado com o status '"#"' nesta data e está indisponível " 
						lRet := .F.
				
					Endif
					
				Else
				
					cMsgErro := STR0056//"O recurso escolhido possui uma alocação extraordinária cadastrada para esta data e está indisponível " 
					lRet := .F.
					
				Endif
			Endif
			
			If !lRet
			
				Exit
			
			Endif
			
			(cAliasGQK)->(dbSkip())
		End
	EndIf
	(cAliasGQK)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} GTPc300Init
(long_description)
@type function
@author jacomo.fernandes
@since 01/03/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param xOldValue, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPc300Init(oMdl,cField,xVal,nLine,xOldValue)
Local xRet	:= nil

Do Case 
	Case cField == "G55_LEGEND"
		
		If G55->G55_CANCEL == "2"  
			xRet := "BR_PRETO"
		ElseIf G55->G55_CONF == "1" 
			xRet := "BR_VERDE" 
		ElseIf G55->G55_CONF == "2" 
			xRet := "BR_VERMELHO"	
		ElseIf G55->G55_CONF == "3" 
			xRet := "BR_AMARELO"
		EndIf
	Case cField == "GYN_STSLEG"
		
		If EMPTY(GYN->GYN_STSOCR)  
			xRet := "BR_BRANCO"
		ElseIf GYN->GYN_STSOCR == "1" 
			xRet := "BR_VERDE" 
		ElseIf GYN->GYN_STSOCR == "2" 
			xRet := "BR_VERMELHO"	
		ElseIf GYN->GYN_STSOCR == "3" 
			xRet := "BR_AMARELO"
		EndIf
EndCase
Return xRet

/*/{Protheus.doc} ValidFinanceiro(oMldMaster:GetModel("GYNDETAIL"))
	(long_description)
	@type  Static Function
	@author user
	@since 27/09/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function ValidFinanceiro(oMdlGYN)
	
	Local lRet		:= .t.
	
	Local cQuery	:= ""
	Local cPedido	:= ""

	Local aCliente 	:= {}
	Local aField	:= {}

	Local oTable

	cPedido := oMdlGYN:GetValue("GYN_CODPED")
	aCliente := IIf(!Empty(cPedido),SC6->(GetAdvFVal("SC6",{"C6_CLI","C6_LOJA"},xFilial("SC6")+cPedido,1,{})),{})
	
	If ( Len(aCliente) > 0 )
	
		cQuery := GCR300QryFin(aCliente[1],aCliente[2])
	
		aAdd(aField,{;
			"SALDO",;
			"N",;
			TamSx3("E1_SALDO")[1],;
			TamSx3("E1_SALDO")[2];			
		})
	
		GTPNewTempTable(cQuery,,,aField,@oTable)

		lRet := (oTable:GetAlias())->SALDO == 0

	EndIf

Return(lRet)

//------------------------------------------------------------------------------
/* /{Protheus.doc} GC300FldsMaster
Função responsável por retornar a lista de campos da tabela temporária de viagens
do monitor ooperacional

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
//JCA - DSERGTP-8012
Function GC300FldsMaster()
Return(cFldMaster)

//------------------------------------------------------------------------------
/* /{Protheus.doc} GC300FldsMaster
Função responsável por retornar o objeto da tabela temporária de viagens
do monitor ooperacional

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
//JCA - DSERGTP-8012
Function GC300TabMaster()

Return(oTableTemp)

//------------------------------------------------------------------------------
/* /{Protheus.doc} GC300StrMaster
Função responsável por retornar a estrutura de dados do submodelo de viagens
Monitor operacional

@type Function
@author Fernando Radu Muscalu
@since 06/10/2022
@version 1.0
/*/
//------------------------------------------------------------------------------
//JCA - DSERGTP-8012
Function GC300StrMaster(lView)
	
	Local oStruct
	
	Default lView := .f.
	
	If ( lView )
		oStruct := oStrViewGYN
	Else
		oStruct := oStrModelGYN
	EndIf
		
Return(oStruct)
