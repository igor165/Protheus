#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA244.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA244

Cadastro MVC de Agentes Nocivos do eSocial

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA244()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro de Agentes Nocivos"
oBrw:SetAlias("C98")
oBrw:SetMenuDef("TAFA244")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA244"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC98 := FwFormStruct(1,"C98")
Local oModel   := MpFormModel():New("TAFA244")

oModel:AddFields("MODEL_C98",/*cOwner*/,oStruC98)
oModel:GetModel("MODEL_C98"):SetPrimaryKey({"C98_FILIAL","C98_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 13/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA244")
Local oStruC98 := FwFormStruct(2,"C98")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C98",oStruC98,"MODEL_C98")

oView:EnableTitleView("VIEW_C98",STR0001) //"Cadastro de Agentes Nocivos"
oView:CreateHorizontalBox("FIELDSC98",100)
oView:SetOwnerView("VIEW_C98","FIELDSC98")

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1032.00

If nVerEmp < nVerAtu
	aAdd( aHeader, "C98_FILIAL" )
	aAdd( aHeader, "C98_ID" )
	aAdd( aHeader, "C98_IDFAM" )
	aAdd( aHeader, "C98_IDGRU" )
	aAdd( aHeader, "C98_IDNIV" )
	aAdd( aHeader, "C98_IDITEM" )
	aAdd( aHeader, "C98_CODIGO" )
	aAdd( aHeader, "C98_DESCRI" )
	aAdd( aHeader, "C98_VALIDA" )

	aAdd( aBody, { "", "000001", "000001", "000001", ""	     , ""	   , "F1", "FISICO - ELETRICIDADE", "" } )
	aAdd( aBody, { "", "000002", "000001", "000002", "000001", ""	   , "F2.1", "FISICO - TEMPERATURAS ANORMAIS - FRIO", "" } )
	aAdd( aBody, { "", "000003", "000001", "000002", "000002", ""	   , "F2.2", "FISICO - TEMPERATURAS ANORMAIS - CALOR", "" } )
	aAdd( aBody, { "", "000004", "000001", "000003", ""	   	 , ""	   , "F3", "FISICO - UMIDADE", "" } )
	aAdd( aBody, { "", "000005", "000001", "000004", "000003", ""	   , "F4.1", "FISICO - PRESSAO ATMOSFERICA ANORMAL - HIPOBERISMO", "" } )
	aAdd( aBody, { "", "000006", "000001", "000004", "000004", ""	   , "F4.2.1", "FISICO - PRESSAO ATMOSFERICA ANORMAL - HIPERBARISMO - HIPERBARISMO EM TRABALHO SOB AR COMPRIMIDO", "" } )
	aAdd( aBody, { "", "000007", "000001", "000004", "000004", ""	   , "F4.2.2", "FISICO - PRESSAO ATMOSFERICA ANORMAL - HIPERBARISMO - HIPERBARISMO EM TRABALHO SUBMERSO", "" } )

	aAdd( aBody, { "", "000008", "000001", "000005", "000005", ""	   , "F5.1", "FISICO - RUIDO - CONTINUO OU INTERMITENTE", "" } )
	aAdd( aBody, { "", "000009", "000001", "000005", "000006", ""	   , "F5.2", "FISICO - RUIDO - IMPACTO", "" } )
	aAdd( aBody, { "", "000010", "000001", "000006", "000007", ""	   , "F6.1", "FISICO - VIBRACAO - CORPO INTEIRO", "" } )
	aAdd( aBody, { "", "000011", "000001", "000006", "000008", ""	   , "F6.2", "FISICO - VIBRACAO - LOCALIZADA", "" } )

	aAdd( aBody, { "", "000012", "000001", "000007", "000009", ""	   , "F7.1.1", "FISICO - RADIACAO IONIZANTE - ELETROMAGNETICA - RAIO X", "" } )
	aAdd( aBody, { "", "000013", "000001", "000007", "000009", ""	   , "F7.1.2", "FISICO - RADIACAO IONIZANTE -  ELETROMAGNETICA - GAMA", "" } )
	aAdd( aBody, { "", "000014", "000001", "000007", "000010", ""	   , "F7.2.1", "FISICO - RADIACAO IONIZANTE -  CORPUSCULAR - ALFA", "" } )
	aAdd( aBody, { "", "000015", "000001", "000007", "000010", ""	   , "F7.2.2", "FISICO - RADIACAO IONIZANTE -  CORPUSCULAR - BETA", "" } )
	aAdd( aBody, { "", "000016", "000001", "000007", "000010", ""	   , "F7.2.3", "FISICO - RADIACAO IONIZANTE -  CORPUSCULAR - NEUTRONS", "" } )
	aAdd( aBody, { "", "000017", "000001", "000008", "000011", ""	   , "F8.1", "FISICO - RADIACAO NAO IONIZANTE - LASER", "" } )
	aAdd( aBody, { "", "000018", "000001", "000008", "000012", ""	   , "F8.2", "FISICO - RADIACAO NAO IONIZANTE - ULTRAVIOLETA", "" } )
	aAdd( aBody, { "", "000019", "000001", "000008", "000013", ""	   , "F8.3", "FISICO - RADIACAO NAO IONIZANTE - RADIOFREQUENCIA E MICROONDAS", "" } )
	aAdd( aBody, { "", "000020", "000001", "000008", "000014", ""	   , "F8.4", "FISICO - RADIACAO NAO IONIZANTE - RADIACAO VISIVEL E INFRAVERMELHO", "" } )
	aAdd( aBody, { "", "000021", "000001", "000008", "000015", ""	   , "F8.5", "FISICO - RADIACAO NAO IONIZANTE - OUTROS", "" } )
	aAdd( aBody, { "", "000022", "000001", "000009", ""	   	 , ""	   , "F9", "FISICO - OUTROS", "" } )
	aAdd( aBody, { "", "000023", "000002", "000010", ""	   	 , ""	   , "Q1", "QUIMICO - GAS", "" } )
	aAdd( aBody, { "", "000024", "000002", "000011", ""	   	 , ""	   , "Q2", "QUIMICO - VAPOR", "" } )
	aAdd( aBody, { "", "000025", "000002", "000012", ""	   	 , ""	   , "Q3", "QUIMICO - OLEO", "" } )
	aAdd( aBody, { "", "000026", "000002", "000013", ""	   	 , ""	   , "Q4", "QUIMICO - GRAXAS", "" } )
	aAdd( aBody, { "", "000027", "000002", "000014", ""	   	 , ""	   , "Q5", "QUIMICO - SOLVENTES", "" } )
	aAdd( aBody, { "", "000028", "000002", "000015", "000016", ""	   , "Q6.1", "QUIMICO - AERODISPERSOIDES - POEIRAS", "" } )
	aAdd( aBody, { "", "000029", "000002", "000015", "000017", ""	   , "Q6.2", "QUIMICO - AERODISPERSOIDES - FUMOS", "" } )
	aAdd( aBody, { "", "000030", "000002", "000015", "000018", ""	   , "Q6.3", "QUIMICO - AERODISPERSOIDES - FUMACAS", "" } )
	aAdd( aBody, { "", "000031", "000002", "000015", "000019", ""	   , "Q6.4", "QUIMICO - AERODISPERSOIDES - NEVOA", "" } )
	aAdd( aBody, { "", "000032", "000002", "000015", "000020", ""	   , "Q6.5", "QUIMICO - AERODISPERSOIDES - NEBLINA", "" } )
	aAdd( aBody, { "", "000033", "000002", "000016", ""	   	 , ""	   , "Q7", "QUIMICO - OUTROS", "" } )
	aAdd( aBody, { "", "000034", "000003", "000017", ""	   	 , ""	   , "B1", "BIOLOGICO - BACTERIA", "" } )
	aAdd( aBody, { "", "000035", "000003", "000018", ""	   	 , ""	   , "B2", "BIOLOGICO - FUNGO", "" } )
	aAdd( aBody, { "", "000036", "000003", "000019", ""	   	 , ""	   , "B3", "BIOLOGICO - PROTOZOARIO", "" } )
	aAdd( aBody, { "", "000037", "000003", "000020", ""	   	 , ""	   , "B4", "BIOLOGICO - PARASITAS", "" } )
	aAdd( aBody, { "", "000038", "000003", "000021", ""	   	 , ""	   , "B5", "BIOLOGICO - VIRUS", "" } )
	aAdd( aBody, { "", "000039", "000003", "000022", ""	   	 , ""	   , "B6", "BIOLOGICO - CULTURAS DE CELULAS", "" } )
	aAdd( aBody, { "", "000040", "000003", "000023", ""	   	 , ""	   , "B7", "BIOLOGICO - TOXINAS", "" } )
	aAdd( aBody, { "", "000041", "000003", "000024", ""	   	 , ""	   , "B8", "BIOLOGICO - PRIONS", "" } )
	aAdd( aBody, { "", "000042", "000003", "000025", ""	   	 , ""	   , "B9", "BIOLOGICO - OUTRAS", "" } )
	aAdd( aBody, { "", "000043", "000004", "000026", "000021", ""	   , "E1.1", "ERGONOMICOS - BIOMECANICOS - IMPOSICAO DE RITMOS EXCESSIVOS", "" } )
	aAdd( aBody, { "", "000044", "000004", "000026", "000022", ""	   , "E1.2", "ERGONOMICOS - BIOMECANICOS - ESFORCO FISICO INTENSO", "" } )
	aAdd( aBody, { "", "000045", "000004", "000026", "000023", ""	   , "E1.3", "ERGONOMICOS - BIOMECANICOS - LEVANTAMENTO E TRANSPORTE MANUAL DE PESO", "" } )
	aAdd( aBody, { "", "000046", "000004", "000026", "000024", ""	   , "E1.4", "ERGONOMICOS - BIOMECANICOS - EXIGENCIA DE POSTURA INADEQUADA", "" } )
	aAdd( aBody, { "", "000047", "000004", "000026", "000025", ""	   , "E1.5", "ERGONOMICOS - BIOMECANICOS - OUTROS", "" } )
	aAdd( aBody, { "", "000048", "000004", "000027", "000026", ""	   , "E2.1", "ERGONOMICOS - ORGANIZACIONAIS, INCLUSIVE PSICOSSOCIAIS - TRABALHO EM TURNO E NOTURNO", "" } )
	aAdd( aBody, { "", "000049", "000004", "000027", "000027", ""	   , "E2.2", "ERGONOMICOS - ORGANIZACIONAIS, INCLUSIVE PSICOSSOCIAIS - MONOTONIA E REPETIVIDADE", "" } )
	aAdd( aBody, { "", "000050", "000004", "000027", "000028", ""	   , "E2.3", "ERGONOMICOS - ORGANIZACIONAIS, INCLUSIVE PSICOSSOCIAIS - SITUACOES DE STRESS", "" } )
	aAdd( aBody, { "", "000051", "000004", "000027", "000029", ""	   , "E2.4", "ERGONOMICOS - ORGANIZACIONAIS, INCLUSIVE PSICOSSOCIAIS - CONTROLE RIGIDO DE PRODUTIVIDADE", "" } )
	aAdd( aBody, { "", "000052", "000004", "000027", "000030", ""	   , "E2.5", "ERGONOMICOS - ORGANIZACIONAIS, INCLUSIVE PSICOSSOCIAIS - OUTROS", "" } )
	aAdd( aBody, { "", "000053", "000005", "000028", ""	   	 , ""	   , "M1", "MECANICO/ACIDENTES - TRABALHO EM ALTURA", "" } )
	aAdd( aBody, { "", "000054", "000005", "000029", ""	   	 , ""	   , "M2", "MECANICO/ACIDENTES - ILUMINACAO INADEQUADA", "" } )
	aAdd( aBody, { "", "000055", "000005", "000030", ""	   	 , ""	   , "M3", "MECANICO/ACIDENTES - CHOQUE ELETRICO", "" } )
	aAdd( aBody, { "", "000056", "000005", "000031", ""	   	 , ""	   , "M4", "MECANICO/ACIDENTES - CHOQUE MECANICO", "" } )
	aAdd( aBody, { "", "000057", "000005", "000032", ""	   	 , ""	   , "M5", "MECANICO/ACIDENTES - ARRANJO FISICO INADEQUADO", "" } )
	aAdd( aBody, { "", "000058", "000005", "000033", ""	   	 , ""	   , "M6", "MECANICO/ACIDENTES - INCENDIO E EXPLOSAO (PROBABILIDADE)", "" } )
	aAdd( aBody, { "", "000059", "000005", "000034", ""	   	 , ""	   , "M7", "MECANICO/ACIDENTES - MAQUINAS E EQUIPAMENTOS SEM PROTECAO", "" } )
	aAdd( aBody, { "", "000060", "000005", "000035", ""	   	 , ""	   , "M8", "MECANICO/ACIDENTES - ARMAZENAMENTO INADEQUADO", "" } )
	aAdd( aBody, { "", "000061", "000005", "000036", ""	   	 , ""	   , "M9", "MECANICO/ACIDENTES - ANIMAIS PECONHENTOS", "" } )
	aAdd( aBody, { "", "000062", "000005", "000037", ""	   	 , ""	   , "M10", "MECANICO/ACIDENTES - FERRAMENTAS INADEQUADAS OU DEFEITUOSAS", "" } )
	aAdd( aBody, { "", "000063", "000005", "000038", ""	   	 , ""	   , "M11", "MECANICO/ACIDENTES - SOTERRAMENTO", "" } )
	aAdd( aBody, { "", "000064", "000005", "000039", ""	   	 , ""	   , "M12", "MECANICO/ACIDENTES - CORTES E PERFURACOES", "" } )
	aAdd( aBody, { "", "000065", "000005", "000040", ""	   	 , ""	   , "M13", "MECANICO/ACIDENTES - QUEIMADURAS", "" } )
	aAdd( aBody, { "", "000066", "000005", "000041", ""	   	 , ""	   , "M14", "MECANICO/ACIDENTES - ACIDENTES DE TRANSITO", "" } )
	aAdd( aBody, { "", "000067", "000005", "000042", ""	   	 , ""	   , "M15", "MECANICO/ACIDENTES - OUTRAS SITUACOES DE RISCO"			 , "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )
