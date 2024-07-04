#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA228.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA228

Cadastro MVC da Descricao da Natureza da Lesao do eSocial

@author Felipe C. Seolin
@since 09/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA228()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Cadastro da Descrição da Natureza da Lesão"
oBrw:SetAlias("C8M")
oBrw:SetMenuDef("TAFA228")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Felipe C. Seolin
@since 09/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA228"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Felipe C. Seolin
@since 09/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruC8M := FwFormStruct(1,"C8M")
Local oModel   := MpFormModel():New("TAFA228")

oModel:AddFields("MODEL_C8M",/*cOwner*/,oStruC8M)
oModel:GetModel("MODEL_C8M"):SetPrimaryKey({"C8M_FILIAL","C8M_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Felipe C. Seolin
@since 09/08/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA228")
Local oStruC8M := FwFormStruct(2,"C8M")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_C8M",oStruC8M,"MODEL_C8M")

oView:EnableTitleView("VIEW_C8M",STR0001) //"Cadastro da Descrição da Natureza da Lesão"
oView:CreateHorizontalBox("FIELDSC8M",100)
oView:SetOwnerView("VIEW_C8M","FIELDSC8M")

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

nVerAtu := 1026.10

If nVerEmp < nVerAtu
	aAdd( aHeader, "C8M_FILIAL" )
	aAdd( aHeader, "C8M_ID" )
	aAdd( aHeader, "C8M_CODIGO" )
	aAdd( aHeader, "C8M_DESCRI" )
	aAdd( aHeader, "C8M_VALIDA" )

	aAdd( aBody, { "", "000001", "702000000", "LESAO IMEDIATA", "" } )
	aAdd( aBody, { "", "000002", "702005000", "ESCORIACAO, ABRASAO (FERIMENTO SUPERFICIAL)", "" } )
	aAdd( aBody, { "", "000003", "702010000", "CORTE, LACERACAO, FERIDA CONTUSA, PUNCTURA (FERIDA ABERTA)", "" } )
	aAdd( aBody, { "", "000004", "702015000", "CONTUSAO, ESMAGAMENTO (SUPERFICIE CUTANEA INTACTA)", "" } )
	aAdd( aBody, { "", "000005", "702020000", "DISTENSAO, TORCAO", "" } )
	aAdd( aBody, { "", "000006", "702025000", "INFLAMACAO DE ARTICULACAO, TENDAO OU MUSCULO - INCLUI SINOVITE, TENOSSIONOVITE, ETC. NAO INCLUI DISTENSAO, TORCAO OU SUAS CONSEQUENCIAS", "" } )
	aAdd( aBody, { "", "000007", "702030000", "LUXACAO", "" } )
	aAdd( aBody, { "", "000008", "702035000", "FRATURA", "" } )
	aAdd( aBody, { "", "000009", "702040000", "QUEIMADURA OU ESCALDADURA - EFEITO DE TEMPERATURA ELEVADA. EFEITO DO CONTATO COM SUBSTANCIA QUENTE. INCLUI QUEIMADURA POR ELETRICIDADE,", "" } )
	aAdd( aBody, { "", "000010", "702042000", "QUEIMADURA QUIMICA (LESAO DE TECIDO PROVOCADA PELA ACAO CORROSIVA DE PRODUTO QUIMICO, SUAS EMANACOES, ETC.)", "" } )
	aAdd( aBody, { "", "000011", "702045000", "EFEITO DE RADIACAO (IMEDIATO) - QUEIMADURA DE SOL E TODA FORMA DE LESAO DE TECIDO, OSSO OU FLUIDO ORGANICO, POR EXPOSICAO A RADIACAO", "" } )
	aAdd( aBody, { "", "000012", "702048000", "CONGELAMENTO, GELADURA E OUTROS EFEITOS DA EXPOSICAO A BAIXA TEM PERATURA", "" } )
	aAdd( aBody, { "", "000013", "702050000", "ASFIXIA, ESTRANGULAMENTO, AFOGAMENTO", "" } )
	aAdd( aBody, { "", "000014", "702055000", "INTERMACAO, INSOLACAO, CAIBRA, EXAUSTAO E OUTROS EFEITOS DA TEMPERATURA AMBIENTE ELEVADA - NAO INCLUI QUEIMADURA DE SOL OU OUTROS EFEIT", "" } )
	aAdd( aBody, { "", "000015", "702060000", "CHOQUE ELETRICO E ELETROPLESSAO (ELETROCUSSAO)", "" } )
	aAdd( aBody, { "", "000016", "702065000", "HERNIA DE QUALQUER NATUREZA, RUPTURA", "" } )
	aAdd( aBody, { "", "000017", "702070000", "AMPUTACAO OU ENUCLEACAO", "" } )
	aAdd( aBody, { "", "000018", "702075000", "PERDA OU DIMINUICAO DE SENTIDO (AUDICAO, VISAO, OLFATO, PALADAR E TATO, DESDE QUE NAO SEJA SEQUELA DE OUTRA LESAO)", "" } )
	aAdd( aBody, { "", "000019", "702080000", "CONCUSSAO CEREBRAL", "" } )
	aAdd( aBody, { "", "000020", "702090000", "LESAO IMEDIATA, NIC", "" } )
	aAdd( aBody, { "", "000021", "704020000", "DOENCA CONTAGIOSA OU INFECCIOSA (TUBERCULOSE, BRUCELOSE, ETC.)", "" } )
	aAdd( aBody, { "", "000022", "704030000", "PNEUMOCONIOSE (SILICOSE, ASBESTOSE, ETC.)", "" } )
	aAdd( aBody, { "", "000023", "704040000", "DERMATOSE (ERUPCAO, INFLAMACAO DA PELE, INCLUSIVE FURUNCULO, ETC.). GERALMENTE PROVOCADA PELO CONTATO DIRETO COM SUBSTANCIAS OU AGENTES", "" } )
	aAdd( aBody, { "", "000024", "704050000", "ENVENENAMENTO SISTEMICO - CONDICAO MORBIDA SISTEMICA PROVOCADA POR INALACAO, INGESTAO OU ABSORCAO CUTANEA DE SUBSTANCIA TOXICA, QUE AFE", "" } )
	aAdd( aBody, { "", "000025", "704060000", "PERDA OU DIMINUICAO MEDIATAS DE SENTIDO (AUDICAO, VISAO, OLFATO, PALADAR E TATO, DESDE QUE NAO SEJA SEQUELA DE OUTRA LESAO)", "" } )
	aAdd( aBody, { "", "000026", "704070000", "EFEITO DE RADIACAO (MEDIATO) - QUEIMADURA DO SOL E TODA FORMA DE LESAO DE TECIDO, OSSO, OU FLUIDO ORGANICO POR EXPOSICAO A RADIACAO", "" } )
	aAdd( aBody, { "", "000027", "704090000", "DOENCA, NIC", "" } )
	aAdd( aBody, { "", "000028", "706050000", "LESOES MULTIPLAS", "" } )
	aAdd( aBody, { "", "000029", "706090000", "OUTRAS LESOES, NIC", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )