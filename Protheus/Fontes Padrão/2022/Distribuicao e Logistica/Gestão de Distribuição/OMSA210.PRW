#INCLUDE "OMSA210.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "DBTREE.CH"
#Include "FWMVCDEF.CH"


#DEFINE  aPos   {  2,  2, 110, 306 }

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OMSA210  ณ Rev.  ณ Henry Fila            ณ Data ณ 19.07.2001ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Programa de Unitizacao da Carga                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ Void OMSA210(void)                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generico                                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Inclui registros no Bancos de Dados                   ณ
//ณ    4 - Altera o registro corrente                            ณ
//ณ    5 - Remove o registro corrente do Banco de Dados          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู


Function OMSA210()
Local oBrowse := Nil

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias("DBN")
	oBrowse:SetMenuDef("OMSA210")   // Nome do fonte onde esta a fun็ใo MenuDef
	oBrowse:SetDescription(STR0001) // Servico x Tarefa
	oBrowse:SetAmbiente(.F.)        // Desabilita op็ใo Ambiente do menu A็๕es Relacionadas
	oBrowse:SetWalkThru(.F.)        // Desabilita op็ใo WalkThru do menu A็๕es Relacionadas
	oBrowse:Activate()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Marco Bianchi         ณ Data ณ01/09/2006ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ    1 - Pesquisa e Posiciona em um Banco de Dados           ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function MenuDef()
Private aRotina := {}

	ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"    OPERATION 1 ACCESS 0 // Pesquisar
	ADD OPTION aRotina TITLE STR0003 ACTION "Da210Assoc" OPERATION 3 ACCESS 0 // Associacao
	ADD OPTION aRotina TITLE STR0004 ACTION "Da210Estor" OPERATION 5 ACCESS 0 // Estorno

If ExistBlock("OM210MNU")
	ExecBlock("OM210MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDa210AssocบAutor  ณHenry Fila          บ Data ณ  02/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Associa carga a um caminhao calculando volumes, peso e     บฑฑ
ฑฑบ          ณ pontos de entrega                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5Dl                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Da210Assoc(cAlias,nReg,nOpcx)
Local oDlg
Local cCaminhao   := Criavar("DA3_COD",.F.)
Local aArrayCarga := {}
Local aArrayCam   := {}
Local oNoMarked   := LoadBitmap( GetResources(), "LBNO" )
Local oMarked     := LoadBitmap( GetResources(), "LBOK" )
Local oEnable     := LoadBitmap( GetResources(), "ENABLE" )
Local oDisable    := LoadBitmap( GetResources(), "DISABLE" )
Local aSize       := MsAdvSize( .T. )
Local aPosObj1    := {}
Local aObjects    := {}
Local aButtons    := { { "PARAMETROS" , { || Pergunte("OMS210",.T.) }, OemtoAnsi(STR0005),OemtoAnsi(STR0048) } } //"Parametros da unitizacao"##"Param."

Local lProcessa   := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCarrego parametros da palletizacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Pergunte("OMS210",.F.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonto os arrays a serem apresentados no Listboxณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If !Da210List(aArrayCarga,aArrayCam,oMarked,oNoMarked,oEnable,oDisable)
	Help(" ",1,"OMS210NCG") //Nao existem cargas ou caminhoes disponiveis para o processo
	lProcessa := .F.
	Return
EndIf

If lProcessa
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Resolve as dimensoes dos objetos da parte esquerda da tela          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aObjects := {}
	AAdd( aObjects, { 100, 100, .t., .t., .t. } )
	AAdd( aObjects, { 100, 100, .t., .t., .t. } )

	aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3  }
	aPosObj1 := MsObjSize( aInfo, aObjects, ,.T. )


	DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE OemtoAnsi(STR0007) OF oMainWnd PIXEL //"Unitizacao"

		@ aPosObj1[1,1]+2,aPosObj1[1,2] Say OemtoAnsi(STR0041) Of oDlg PIXEL //"Cargas"
		@ aPosObj1[2,1]+2,aPosObj1[2,2] Say OemtoAnsi(STR0042) Of oDlg PIXEL //"Veiculos"

		@ aPosObj1[1,1]+10,aPosObj1[1,2] LISTBOX oCargas VAR cVar ;
												Fields HEADER " "," ",;
														OemToAnsi(STR0008),; //"Codigo"
														OemToAnsi(STR0050),; //"Sequencia"
														OemtoAnsi(STR0009),; //"Peso"
														OemtoAnsi(STR0010),; //"Volume"
														OemtoAnsi(STR0011),; //"Valor"
														OemtoAnsi(STR0012) ; //"Ptos. Entrega"
														On DblClick Oms210TrCg(1,aArrayCarga,aArrayCam,oMarked,oNoMarked,oEnable,oDisable) ;
														SIZE aPosObj1[1,3],aPosObj1[1,4]-10 OF oDlg PIXEL

		oCargas:nFreeze := 1
		oCargas:SetArray(aArrayCarga)
		oCargas:bLine:={ ||{	aArrayCarga[oCargas:nAT,1],;
								aArrayCarga[oCargas:nAT,2],;
								aArrayCarga[oCargas:nAT,3],;
								aArrayCarga[oCargas:nAT,4],;
								aArrayCarga[oCargas:nAT,5],;
								aArrayCarga[oCargas:nAT,6],;
								aArrayCarga[oCargas:nAT,7],;
								aArrayCarga[oCargas:nAT,8]}}

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณMonto ListBox de Caminhoesณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		@ aPosObj1[2,1]+10,aPosObj1[2,2] LISTBOX oCaminhao VAR cVar ;
												Fields HEADER " "," ",;
														OemToAnsi(STR0008),; //Codigo
														OemtoAnsi(STR0013),;  //"Descricao"
														OemtoAnsi(STR0014),; //"Capac. Kg"
														OemtoAnsi(STR0015),; //"Capac. Vol."
														OemtoAnsi(STR0016),; //"Capac. Ptos."
														OemtoAnsi(STR0017) ; //"Motorista"
														On DblClick Oms210TrCg(2,aArrayCarga,aArrayCam,oMarked,oNoMarked,oEnable,oDisable) ;
														SIZE aPosObj1[2,3],aPosObj1[2,4]-10 OF oDlg PIXEL

		oCaminhao:nFreeze := 1
		oCaminhao:SetArray(aArrayCam)
		oCaminhao:bLine:={ ||{	aArrayCam[oCaminhao:nAT,1],;
								aArrayCam[oCaminhao:nAT,2],;
								aArrayCam[oCaminhao:nAT,3],;
								aArrayCam[oCaminhao:nAT,4],;
								aArrayCam[oCaminhao:nAT,5],;
								aArrayCam[oCaminhao:nAT,6],;
								aArrayCam[oCaminhao:nAT,7],;
								aArrayCam[oCaminhao:nAT,8]}}

	ACTIVATE MSDIALOG  oDlg ON INIT EnchoiceBar( oDlg,	{ || Oms210Prep(aArrayCarga,aArrayCam,oMarked,oNoMarked,oEnable,oDisable,oCargas,oCaminhao)},;
														{||oDlg:End()},,aButtons) CENTERED

EndIf

DAK->(RetIndex("DAK"))
DAK->(dbClearFilter())

DAK->(RetIndex("DA3"))
DAK->(dbClearFilter())

dbSelectArea("DAK")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOms210TrCgบAutor  ณHenry Fila          บ Data ณ  02/14/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTroca marca do array de cargas e dos caminhoes              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Oms210TrCg(nOpcao,aArrayCarga,aArrayCam,oMarked,oNoMarked,oEnable,oDisable)
Local nPosCam   := oCaminhao:nAt
Local nPosMark  := 0
Local nTotPeso  := nTotVol:= nTotPto := 0
Local nC        := 0
Local lMarca    := .T.
Local lRestricao:= .F.
Local cCpoCapac := IIf(SuperGetMV("MV_OMSCAPA",.F.,"1")=="1","DA3_CAPACN","DA3_CAPACM")
Local nCapac    := 0

If	nOpcao == 1

	If	aArrayCarga[oCargas:nAt,2] == oEnable

		lMarca := Iif(aArrayCarga[oCargas:nAt,1] == oMarked,.F., .T. )

		oObjMark := Iif(lMarca, oMarked, oNoMarked )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณBusco se a carga ja estava associada a um caminhao naณ
		//ณgeracao de carga, e caso esteja marco automaticamenteณ
		//ณo mesmo                                              ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		DAK->(dbSetOrder(1)) //DAK_FILIAL+DAK_COD+DAK_SEQCAR
		If	DAK->(MsSeek(xFilial("DAK")+aArrayCarga[oCargas:nAt,3]) )

			If !Empty(DAK->DAK_CAMINH)

				nPosCam := Ascan(aArrayCam,{|x| x[3] == DAK->DAK_CAMINH})
				If	nPosCam > 0

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifico se ja existe um caminhao associado e se o mesmo eh dife-  ณ
					//ณrente do da carga associada                                        ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

					nPosMark := Ascan(aArrayCam,{|x| x[1] == oMarked})
					If ( nPosMark > 0 ) .And. ( oObjMark == oMarked ) .And. ;
							aArrayCam[nPosMark][3] <> DAK->DAK_CAMINH
						Help(" ",1,"DLA210EXIST") //Existe outro caminhao associado a esta carga
						oObjMark := oNoMarked
					ElseIf ( nPosMark == 0 ) .And. ( oObjMark == oMarked )
						aArrayCam[nPosCam,1] := oMarked
						oObjMark             := oMarked
					EndIf

				EndIf

			EndIf

		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifico se ja existe algum caminhao marcadoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nPosCam := Ascan(aArrayCam,{|x| x[1] == oMarked})
		If	nPosCam > 0 .And. lMarca

			DA3->(dbSetOrder(1)) //DA3_FILIAL+DA3_COD
			If	DA3->(MsSeek(xFilial("DA3")+aArrayCam[nPosCam,3]) )

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณInicio as variaveis com o peso da carga marcada para acumularณ
				//ณcom as ja selecionadas, caso existam                         ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nTotPeso := Val(aArrayCarga[oCargas:nAt,5])
				nTotVol  := Val(aArrayCarga[oCargas:nAt,6])
				nTotPto  := Val(aArrayCarga[oCargas:nAt,8])

				For nC := 1 to Len(aArrayCarga)
					If	aArrayCarga[nC,1] == oMarked
						nTotPeso += Val(aArrayCarga[nC,5])
						nTotVol  += Val(aArrayCarga[nC,6])
						nTotPto  += Val(aArrayCarga[nC,8])
					EndIf
				Next

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณVerifico se ha restricoes a necessito marcarณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nCapac := DA3->(FieldGet(FieldPos(cCpoCapac)))
				If ((nTotPeso > nCapac).Or. (nTotVol > DA3->DA3_VOLMAX).Or. (nTotPto > DA3->DA3_LIMMAX )) .And. lMarca
					lRestricao := .T.
				EndIf

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณConsisto as possibilidades de marcacaoณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				Do case
					Case lRestricao .And. lMarca
						If	MsgYesNo(OemtoAnsi(STR0018), OemtoAnsi(STR0019)) //"O caminhao escolhido nao suporta a carga selecionada. Confirma mesmo assim ?"###"Aviso"
							oObjMark := oMarked
						EndIf
					Case !lRestricao .And. lMarca
						oObjMark    := oMarked
					Case !lMarca
						oObjMarked  := oNoMarked
				EndCase

			EndIf

		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDepois das consistencias gravo marcado ou naoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		aArrayCarga[oCargas:nAt,1] := oObjMark

	EndIf

ElseIf nOpcao == 2

	lMarca := Iif(aArrayCam[oCaminhao:nAt,1] == oMarked,.F., .T. )

	DA3->(dbSetOrder(1))
	If	DA3->(MsSeek(xFilial("DA3")+aArrayCam[oCaminhao:nAt,3]) )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAcumula total das cargas selecionadasณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		For nC := 1 to Len(aArrayCarga)
			If	aArrayCarga[nC,1] == oMarked
				nTotPeso += Val(aArrayCarga[nC,5])
				nTotVol  += Val(aArrayCarga[nC,6])
				nTotPto  += Val(aArrayCarga[nC,8])
			EndIf
		Next

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifico se ha restricoes a necessito marcarณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		nCapac := DA3->(FieldGet(FieldPos(cCpoCapac)))
		If ((nTotPeso > nCapac).Or. (nTotVol > DA3->DA3_VOLMAX).Or. (nTotPto > DA3->DA3_LIMMAX )) .And. ;
			lMarca
			lRestricao := .T.
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณConsisto as possibilidades de marcacaoณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Do case
			Case lRestricao .And. lMarca
				If MsgYesNo(OemtoAnsi(STR0018), OemtoAnsi(STR0019)) //"O caminhao escolhido nao suporta a carga selecionada. Confirma mesmo assim ?"###"Aviso"
					aArrayCam[oCaminhao:nAt,1] := oMarked
				EndIf
			Case !lRestricao .And. lMarca
				aArrayCam[oCaminhao:nAt,1] := oMarked
			Case !lMarca
				aArrayCam[oCaminhao:nAt,1] := oNoMarked
		EndCase

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณDesmarco os outros itensณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nC := 1 to Len(aArrayCam)
		If nC != nPosCam
			aArrayCam[nC,1] := oNoMarked
		EndIf
	Next

EndIf

oCaminhao:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDA210LIST บAutor  ณHenry Fila          บ Data ณ  02/14/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta listbox das cargas e dos caminhoes a serem gerados   บฑฑ
ฑฑบ          ณ a paletizacao                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5Dl                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Da210List(aArrayCarga,aArrayCam,oMarked,oNoMarked,oEnable,oDisable)
Local aArea     := GetArea()
Local lQuery    := .F.
Local cCondicao := ""
Local lRet      := .F.
Local cPict     := "@E 9999999.99"

cQry := "SELECT DAK.DAK_COD,DAK_SEQCAR,DAK.DAK_PESO,DAK.DAK_PTOENT,DAK.DAK_CAPVOL,DAK.DAK_VALOR "
cQry := cQry + " FROM "+RetSqlName('DAK')+" DAK"
cQry := cQry + " WHERE DAK.DAK_FILIAL = '"+xFilial('DAK')+"'"
cQry := cQry + " AND DAK.D_E_L_E_T_ = ' '"
cQry := cQry + " AND DAK.DAK_FEZNF  = '2'"
cQry := cQry + " AND DAK.DAK_ACECAR = '2'"
cQry := cQry + " AND DAK.DAK_ACEFIN = '2'"
cQry := cQry + " AND DAK.DAK_FLGUNI = '2'"
cQry := cQry + " ORDER BY DAK.DAK_COD"
cQry := ChangeQuery(cQry)
dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQry),"TMPCAR",.f.,.t.)

lQuery := .T.
cAliasCG := "TMPCAR"


cQry := "SELECT * "
cQry := cQry + " FROM "+RetSqlName('DA3')+" DA3"
cQry := cQry + " WHERE DA3.DA3_FILIAL = '"+xFilial('DA3')+"'"
cQry := cQry + " AND DA3.D_E_L_E_T_ = ' '"
cQry := cQry + " AND DA3.DA3_ATIVO = '1'"
cQry := cQry + " ORDER BY DA3.DA3_COD "
cQry := ChangeQuery(cQry)
dBUseArea(.t.,"TOPCONN",TCGENQRY(,,cQry),"TMPCAM",.f.,.t.)

lQuery := .T.
cAliasCG := "TMPCAR"
cAliasCm := "TMPCAM"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonto array de cargasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea(cAliasCg)
dbGotop()

While !Eof()

	Aadd(aArrayCarga,{oNoMarked,oEnable,(cAliasCg)->DAK_COD,(cAliasCg)->DAK_SEQCAR,Transform((cAliasCg)->DAK_PESO,cPict),;
										Transform((cAliasCg)->DAK_CAPVOL,cPict),;
										Transform((cAliasCg)->DAK_VALOR,cPict),;
										StrZero((cAliasCg)->DAK_PTOENT,6) })

	dbSelectArea(cAliasCg)
	dbSkip()

EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonto array de caminhoesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

dbSelectArea(cAliasCm)
dbGotop()

While !Eof()

	Aadd(aArrayCam,{oNoMarked,Iif((cAliasCm)->DA3_ATIVO == "2",oDisable,oEnable),(cAliasCm)->DA3_COD,(cAliasCm)->DA3_DESC,;
									Transform((cAliasCm)->DA3_CAPACN,cPict),;
									Transform((cAliasCm)->DA3_VOLMAX,cPict),;
									Transform((cAliasCm)->DA3_LIMMAX,cPict),;
									(cAliasCm)->DA3_MOTORI })

	dbSelectArea(cAliasCm)
	dbSkip()

EndDo

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico se existe pelo menos uma cara e um caminhao aณ
//ณser paletizado                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If Len(aArrayCarga) > 0 .And. Len(aArrayCam) > 0
	lRet := .T.
EndIf

If lQuery
	dbSelectArea("TMPCAM")
	dbCloseArea()

	dbSelectArea("TMPCAR")
	dbCloseArea()
EndIf

RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDLA170PREPบAutor  ณHenry Fila          บ Data ณ  02/16/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Prepara os arrays para a chamada da unitizacao             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5Dl                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Oms210Prep(aArrayCarga,aArrayCam,oMarked,oNoMarked,oEnable,oDisable,oCargas,oCaminhao)

Local aArrayPal := {}
Local aUnitiza  := {}

Local cCodUni   := 0
Local nOpcao    := 0
Local nQtdeUni  := 0
Local nPosCam   := Ascan(aArrayCam, {|x| x[1] == oMarked })
Local nC        := 0

Local oDlg
Local oTempTable := Nil

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonto array somente com as cargas selecionadasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

For nC := 1 to Len(aArrayCarga)
	If aArrayCarga[nC,1] == oMarked
		Aadd(aArrayPal,{aArrayCarga[nC,3],aArrayCarga[nC][4]})
	EndIf
Next

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifico se existe alguma associacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If ( nPosCam == 0 ) .Or. ( Len(aArrayPal) == 0 )
	Help(" ",1,"OMS210ASSO") //Nao existem cargas ou caminhoes associados
Else

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณConfirmacao do calculoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If MsgYesNo(OemtoAnsi(STR0021)) //"Confirma calculo da unitizacao ?"
		DA3->(dbSetOrder(1))
		If DA3->(DbSeek(xFilial("DA3")+aArrayCam[nPosCam,3]))
			cCodUni  := DA3->DA3_UNITIZ
			nQtdeUni := DA3->DA3_QTDUNI
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณChamo a tela de unitizador padrao para caso o usuario       ณ
		//ณqueira trocar o tipo e a qtde do mesmo se for por cliente   ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0040) From 0,0 To 100,235 OF oMainWnd PIXEL //"Unitizador padrao "

			@ 005,005 Say OemtoAnsi(STR0040) Of oDlg PIXEL SIZE 45,10 //"Qtde Unitizadores "
			@ 005,060 MSGET nQtdeUni  Of oDlg PIXEL SIZE 34,10 Picture "999999"

			@ 020,005 Say OemtoAnsi(STR0025) Of oDlg PIXEL SIZE 45,10 //"Unitizador "
			@ 020,060 MSGET cCodUni F3 "DC1" Valid ExistCpo("DC1",cCodUni) Of oDlg PIXEL SIZE 34,10

			DEFINE SBUTTON FROM 035, 005 TYPE 1 ENABLE OF oDlg ACTION( nOpcao := 1,oDlg:End())
			DEFINE SBUTTON FROM 035, 035 TYPE 2 ENABLE OF oDlg ACTION( oDlg:End())

		ACTIVATE DIALOG oDlg Centered

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณChamo a funcao de unitizacao                                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		If nOpcao == 1

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCalcula o volume e peso maximo da carga por unitizadorณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			aUnitiza := Ds210Uni(nQtdeUni,cCodUni,aArrayPal,aArrayCam[nPosCam,3])

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณProcessa a paletizacao                                ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Processa({ || Oms210Unt(aArrayPal,aArrayCam[nPosCam,3],@oTempTable, mv_par01,nQtdeUni,aUnitiza[1],aUnitiza[2] ) } )

			If Oms210Tree(aArrayPal,aArrayCam[nPosCam,3],nQtdeUni,cCodUni)
				For nC := 1 to Len(aArrayCarga)
					If aArrayCarga[nC,1] == oMarked
						aArrayCarga[nC,1] := oNoMarked
						aArrayCarga[nC,2] := oDisable

						aArrayCam[nPosCam,1] := oNoMarked
						aArrayCam[nPosCam,2] := oDisable

					EndIf
				Next
			EndIf

			If oTempTable != Nil
				oTempTable:Delete()
			EndIf

		EndIf

	EndIf

EndIf

dbSelectArea("DAK")

oCaminhao:Refresh()
oCargas:Refresh()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOms210Unt บAutor  ณHenry Fila          บ Data ณ  02/16/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula unitizacaoo                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ ExpA1- Array com o codigo das cargas                       บฑฑ
ฑฑบ          ณ ExpC2- Caminhao a ser carregado                            บฑฑ
ฑฑบ          ณ ExpC3- Por Cliente / 2 Por Produto                         บฑฑ
ฑฑบ          ณ ExpN4- 1 Por Cliente / 2 Por Produto                       บฑฑ
ฑฑบ          ณ ExpN5- Quantidade de unitizadores                          บฑฑ
ฑฑบ          ณ ExpN6- Peso por Unitizador                                 บฑฑ
ฑฑบ          ณ ExpN7- Volume por Unitizador                               บฑฑ
ฑฑบ          ณ ExpL7- Se retorna somente o excedente a numero desejado    บฑฑ
ฑฑบ          ณ        de unitizadores     (DEFAULT) .F.                   บฑฑ
ฑฑบ          ณ        .T. - Somente o excedente .F. - Todos               บฑฑ
ฑฑบ          ณ ExpL7- Se quebra por cliente quando o pedido nao couber no บฑฑ
ฑฑบ          ณ        caminhao            (DEFAULT) .F.                   บฑฑ
ฑฑบ          ณ        .T. - Somente o excedente .F. - Todos               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Oms210Unt(aCargas,cCaminhao,oTempTable,nTipo,nQtdeUni,nPesoUnit,nVolUnit,lExcede,lQuebCli)

Local aCampos    := {}
Local aRetEst    := {}

Local cPedido    := ""
Local cFilPv     := ""
Local cCondicao  := ""
Local nTotPeso   := 0
Local nTotVol    := 0
Local nSeqPal    := 0
Local nTipoOper  := OsVlEntCom()
Local nC         := 0
Local nPallet    := 0
Local lEstVol    := .F.
Local lEstPeso   := .F.
Local lRetPE     := .F.
Local nTamCod    := TamSx3("B1_COD")[1]
Local lOM210UNT  := ExistBlock("OM210UNT")

DEFAULT lExcede   := .F.
DEFAULT lQuebCli  := .F.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalcula quebras por unitizador e consiste se os cadastrosณ
//ณestao consistentes para a geracao.                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If nPesoUnit == 0 .Or. nVolUnit == 0
	Help(" ",1,"OMS210UNIT") //Verificacao de unitizadores imcompleta
	Return
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCrio arquivo de trabalhoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Pergunte("OMS210",.F.)

If oTempTable == Nil
	Aadd(aCampos,{"TRB_CARGA"  ,"C",06,0})
	Aadd(aCampos,{"TRB_SEQCAR" ,"C",02,0})
	Aadd(aCampos,{"TRB_PALLET" ,"C",06,0})
	Aadd(aCampos,{"TRB_CLIENT" ,"C",06,0})
	Aadd(aCampos,{"TRB_LOJA"   ,"C",02,0})
	Aadd(aCampos,{"TRB_SEQUEN" ,"C",06,0})
	Aadd(aCampos,{"TRB_FILPV"  ,"C",FWGETTAMFILIAL,0})
	Aadd(aCampos,{"TRB_PEDIDO" ,"C",06,0})
	Aadd(aCampos,{"TRB_ITEM"   ,"C",03,0})
	Aadd(aCampos,{"TRB_CODPRO" ,"C",nTamCod,0})
	Aadd(aCampos,{"TRB_SEQPAL" ,"C",03,0})
	Aadd(aCampos,{"TRB_QTDE"   ,"N",12,3})
	Aadd(aCampos,{"TRB_PESO"   ,"N",12,3})
	Aadd(aCampos,{"TRB_VOLUME" ,"N",12,3})
	Aadd(aCampos,{"TRB_PESPAL" ,"N",12,3})
	Aadd(aCampos,{"TRB_VOLPAL" ,"N",12,3})
	Aadd(aCampos,{"TRB_VEICUL" ,"C",08,2})
	Aadd(aCampos,{"TRB_RECNO"  ,"N",08,0})

	oTempTable := FWTemporaryTable():New( "TRB" )
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("01", {"TRB_CARGA","TRB_SEQCAR","TRB_PALLET","TRB_CLIENT","TRB_LOJA","TRB_SEQUEN"} )
	oTempTable:Create()
Else
	// Apenas apaga os registros da temporแria
	cQry := "DELETE FROM "+oTempTable:GetRealName()
	TcSQLExec(cQry)
EndIf

cAlias := "TRBSC9"
cQry := "SELECT SC9.C9_FILIAL,SC9.C9_CARGA,SC9.C9_SEQCAR,SC9.C9_SEQENT,SC9.C9_PEDIDO,SC9.C9_ITEM ,SC9.C9_PRODUTO,SC9.C9_QTDLIB, "
cQry += " SC9.C9_PRCVEN,SC9.C9_SEQUEN,SC9.C9_CLIENTE,SC9.C9_LOJA,SC9.C9_TPCARGA,SC9.R_E_C_N_O_  RECNO "
cQry += " FROM "+RetSqlName('SC9')+" SC9 "
cQry += " WHERE "
If nTipoOper == 1
	cQry += "SC9.C9_FILIAL = '"+xFilial('SC9')+"' AND  "
EndIf
cQry += " SC9.C9_BLCRED = '  ' AND "
cQry += " SC9.C9_BLEST  = '  ' AND "
cQry += " SC9.C9_TPCARGA= '1'  AND "
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAcumulo do filtro as cargas que a serem unitizadasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
For nC := 1 to Len(aCargas)
	cQry += Iif(nC == 1," (", " OR ")+ "SC9.C9_CARGA = '"+aCargas[nC][1]+"' AND SC9.C9_SEQCAR = '"+aCargas[nC][2]+"' "+Iif(nC == Len(aCargas),") AND ","")
Next
cQry += " SC9.D_E_L_E_T_ = ' ' "
If	nTipo == 1
	cQry += " ORDER BY SC9.C9_CARGA,SC9.C9_SEQENT,SC9.C9_CLIENTE,SC9.C9_LOJA DESC"
Else
	cQry += " ORDER BY SC9.C9_CARGA,SC9.C9_SEQENT,SC9.C9_PRODUTO"
EndIf
cQry := ChangeQuery(cQry)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAlias,.F.,.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicio a contagem dos palletsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPallet := 1

ProcRegua((cAlias)->(LastRec()))
(cAlias)->(dbGotop())

While (cAlias)->(!Eof())

	IncProc()
	lEstVol  := .F.
	lEstPeso := .F.

	If lQuebCli
		If (cAlias)->C9_PEDIDO != cPedido .Or. (cAlias)->C9_FILIAL != cFilPv
			DAI->(dbSetOrder(1)) //DAI_FILIAL+DAI_COD+DAI_SEQCAR+DAI_SEQUEN+DAI_PEDIDO
			If DAI->(MsSeek(xFilial("DAI")+(cAlias)->(C9_CARGA+C9_SEQCAR+C9_SEQENT+C9_PEDIDO+C9_FILIAL)))
				If ((nTotPeso + DAI->DAI_PESO) >= nPesoUnit) .Or. ( (nTotVol + DAI->DAI_CAPVOL) >= nVolUnit)
					nTotPeso := 0
					nTotVol  := 0
					cPedido  := (cAlias)->C9_PEDIDO
					cFilPv   := (cAlias)->C9_FILIAL
					nPallet++
				EndIf
			EndIf
		EndIf
	EndIf

	//-- Ponto de Entrada usado para quebras no unitizador
	If lOM210UNT
		lRetPE := ExecBlock("OM210UNT",.F.,.F.,{(cAlias)->C9_CLIENTE, (cAlias)->C9_LOJA, (cAlias)->C9_PRODUTO})
		lRetPE := If(ValType(lRetPE)<>"L",.F.,lRetPE)
		If	lRetPE
			nTotPeso := 0
			nTotVol  := 0
			nPallet++
		EndIf
	EndIf

	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	If SB1->(MSseek(OsFilial("SB1",(cAlias)->(C9_FILIAL))+(cAlias)->(C9_PRODUTO)))

		//-- Calculo peso do item do pedido
		nPesoProd := OsPesoProd((cAlias)->C9_PRODUTO,(cAlias)->C9_FILIAL)
		nPesoProd := (nPesoProd * (cAlias)->C9_QTDLIB)
		//-- Calcula capacidade volumetrica
		nCapArm := OsPrCapArm((cAlias)->C9_PRODUTO,(cAlias)->C9_FILIAL)
		nCapVol := ( nCapArm * (cAlias)->C9_QTDLIB )

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifico quebra de pallet por peso e volumeณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ( nTotPeso + nPesoProd ) >= nPesoUnit
			lEstPeso := .T.
		EndIf
		If ( nTotVol + nCapVol ) >= nVolUnit
			lEstVol  := .T.
		EndIf

		If ( lEstVol .Or. lEstPeso ) //.And. ( nTipo == 1 )

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณArmazeno a qtde liberada para acumular com a quebraณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nQtdeQueb := 0
			nSeqPal   := 0

			While nQtdeQueb < (cAlias)->C9_QTDLIB

				nSeqPal++

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAcho quanto falta de espaco ou peso no palletณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nDifPeso := nPesoUnit - nTotPeso
				nDifVol  := nVolUnit - nTotVol

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAcho a diferenca entre o paletizado e o a paletizarณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				nQtdePal := ( (cAlias)->C9_QTDLIB - nQtdeQueb )

				//-- Calculo peso do item do pedido
				nPesoProd := OsPesoProd((cAlias)->C9_PRODUTO,(cAlias)->C9_FILIAL)
				nPesoProd := (nPesoProd * nQtdePal)
				//-- Calcula capacidade volumetrica
				nCapArm := OsPrCapArm((cAlias)->C9_PRODUTO,(cAlias)->C9_FILIAL)
				nCapVol := ( nCapArm * nQtdePal )

				aRetEst := Oms210Vol((cAlias)->C9_FILIAL,(cAlias)->C9_PRODUTO,nDifVol,nDifPeso,nPesoProd,nCapVol,nQtdePal,lEstPeso,lEstVol)

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณSe retornou 0 quer dizer que o que sobrou nao cabe outro ณ
				//ณproduto, por isso abro outro pallet                      ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				If aRetEst[1] == 0
					nTotPeso := 0
					nTotvol  := 0
					nPallet++

					nDifPeso := nPesoUnit - nTotPeso
					nDifVol  := nVolUnit - nTotVol

					aRetEst := Oms210Vol((cAlias)->C9_FILIAL,(cAlias)->C9_PRODUTO,nDifVol,nDifPeso,nPesoProd,nCapVol,nQtdePal,lEstPeso,lEstVol)

				EndIf

				nQtdeQueb += aRetEst[1]

				If !lExcede .Or. ( lExcede .And. nPallet > nQtdeUni )
					RecLock("TRB",.T.)
					TRB->TRB_CARGA   := (cAlias)->C9_CARGA
					TRB->TRB_SEQCAR  := (cAlias)->C9_SEQCAR
					TRB->TRB_PALLET  := StrZero(nPallet,6)
					TRB->TRB_CLIENT  := (cAlias)->C9_CLIENTE
					TRB->TRB_LOJA    := (cAlias)->C9_LOJA
					TRB->TRB_SEQUEN  := (cAlias)->C9_SEQUEN
					TRB->TRB_FILPV   := (cAlias)->C9_FILIAL
					TRB->TRB_PEDIDO  := (cAlias)->C9_PEDIDO
					TRB->TRB_ITEM    := (cAlias)->C9_ITEM
					TRB->TRB_CODPRO  := (cAlias)->C9_PRODUTO
					TRB->TRB_SEQPAL  := StrZero(nSeqPal,3)
					TRB->TRB_QTDE    := aRetEst[1]
					TRB->TRB_PESO    := aRetEst[2]
					TRB->TRB_VOLUME  := aRetEst[3]
					TRB->TRB_PESPAL  := nPesoUnit
					TRB->TRB_VOLPAL  := nVolUnit
					TRB->TRB_VEICUL  := DA3->DA3_COD
					TRB->TRB_RECNO   := (cAlias)->RECNO
				EndIf

				If ( nTotPeso + aRetEst[2] ) >= nPesoUnit .Or. ( nTotVol + aRetEst[3] ) >= nVolUnit
					nTotPeso := 0
					nTotVol  := 0
					nPallet++
				Else
					nTotPeso += aRetEst[2]
					nTotVol  += aRetEst[3]
				EndIf

			EndDo
			(cAlias)->(dbSkip())
			Loop
		EndIf

		nTotPeso += nPesoProd
		nTotVol  += nCapVol

		If !lExcede .Or. ( lExcede .And. nPallet > nQtdeUni )
			RecLock("TRB",.T.)
			TRB->TRB_CARGA   := (cAlias)->C9_CARGA
			TRB->TRB_SEQCAR  := (cAlias)->C9_SEQCAR
			TRB->TRB_PALLET  := StrZero(nPallet,6)
			TRB->TRB_CLIENT  := (cAlias)->C9_CLIENTE
			TRB->TRB_LOJA    := (cAlias)->C9_LOJA
			TRB->TRB_SEQUEN  := (cAlias)->C9_SEQUEN
			TRB->TRB_FILPV   := (cAlias)->C9_FILIAL
			TRB->TRB_PEDIDO  := (cAlias)->C9_PEDIDO
			TRB->TRB_ITEM    := (cAlias)->C9_ITEM
			TRB->TRB_CODPRO  := (cAlias)->C9_PRODUTO
			TRB->TRB_SEQPAL  := StrZero(nSeqPal)
			TRB->TRB_QTDE    := (cAlias)->C9_QTDLIB
			TRB->TRB_PESO    := nPesoProd
			TRB->TRB_VOLUME  := nCapVol
			TRB->TRB_PESPAL  := nPesoUnit
			TRB->TRB_VOLPAL  := nVolUnit
			TRB->TRB_VEICUL  := DA3->DA3_COD
			TRB->TRB_RECNO   := (cAlias)->RECNO
		EndIf
	EndIf
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOms210VOL บAutor  ณHenry Fila          บ Data ณ  02/19/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna a qtde  do produto para a quebra do pallet          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณcProduto  = Produto a ser calculado                         บฑฑ
ฑฑบ          ณnQtdeVol  = Qtde em volume que falta no pallet              บฑฑ
ฑฑบ          ณnQtdePEso = Qtde em Kg que falta no pallet                  บฑฑ
ฑฑบ          ณnVolume   = Volume total do pallet                          บฑฑ
ฑฑบ          ณnPeso     = Peso Total do Pallet                            บฑฑ
ฑฑบ          ณnQtde     = Qtde do SC9 a ser calculada                     บฑฑ
ฑฑบ          ณlEstPeso  = Se estourou por peso                            บฑฑ
ฑฑบ          ณlEstVol   = Se estourou por volume                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Oms210Vol(cFilPv, cProduto, nQtdeVol, nQtdePeso, nPeso, nVolume, nQtde, lEstPeso, lEstVol)

Local nQtdeRet  := 0
Local nQtdeRet1 := 0
Local nQtdeRet2 := 0
Local nCapvol   := 0
Local nPesoProd := 0
Local nCapArm   := 0
Local aRet      := {}

If SB1->(MsSeek(OsFilial("SB1",cFilPv)+cProduto))

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe estourou por volumeณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If lEstVol
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifico se a qtde pode ser quebradaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Do Case
			Case SB1->B1_TIPODEC $ "NA" //Normal
				nQtdeRet1 := (nQtde*nQtdeVol) / nVolume
			Case SB1->B1_TIPODEC ==	 "I" //Incrementa
				nQtdeRet1 := Int((nQtde*nQtdeVol) / nVolume ) + 1
			Case SB1->B1_TIPODEC == "T"
				nQtdeRet1 := Int((nQtde*nQtdeVol) / nVolume )
		EndCase
		If nQtde < nQtdeRet1 //.Or. (nQtdeRet1 == 0)
			nQtdeRet1 := nQtde
		ElseIf nQtdeRet1 == 0
			nQtdeRet1 := 1
		EndIf
		//-- Calculo peso do item do pedido
		nPesoProd := OsPesoProd(cProduto,cFilPv)
		nPesoProd := (nPesoProd * nQtdeRet1)
		//-- Calcula capacidade volumetrica
		nCapArm := OsPrCapArm(cProduto,cFilPv)
		nCapVol := ( nCapArm * nQtdeRet1 )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCalculo baseado pela nova qtdeณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nPesoProd > nQtdePeso
			Do Case
				Case SB1->B1_TIPODEC $ "NA" //Normal
					nQtdeRet2 := (nQtde*nQtdePeso) / nPeso
				Case SB1->B1_TIPODEC ==	 "I" //Incrementa
					nQtdeRet2 := Int((nQtde*nQtdePeso) / nPeso ) + 1
				Case SB1->B1_TIPODEC == "T"
					nQtdeRet2 := Int((nQtde*nQtdePeso) / nPeso )
			EndCase
			If nQtde < nQtdeRet2 //.Or. (nQtdeRet2 == 0)
				nQtdeRet2 := nQtde
			ElseIf nQtdeRet2 == 0
				nQtdeRet2 := 1
			EndIf
			//-- Calculo peso do item do pedido
			nPesoProd := OsPesoProd(cProduto,cFilPv)
			nPesoProd := (nPesoProd * nQtdeRet2)
			//-- Calcula capacidade volumetrica
			nCapArm := OsPrCapArm(cProduto,cFilPv)
			nCapVol := ( nCapArm * nQtdeRet2 )
		EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณSe estourou por pesoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ElseIf lEstPeso
		Do Case
			Case SB1->B1_TIPODEC $ "NA" //Normal
				nQtdeRet2 := (nQtde*nQtdePeso) / nPeso
			Case SB1->B1_TIPODEC ==	 "I" //Incrementa
				nQtdeRet2 := Int((nQtde*nQtdePeso) / nPeso ) + 1
			Case SB1->B1_TIPODEC == "T"
				nQtdeRet2 := Int((nQtde*nQtdePeso) / nPeso )
		EndCase
		If nQtde < nQtdeRet2 //.Or. (nQtdeRet2 == 0)
			nQtdeRet2 := nQtde
		ElseIf nQtdeRet2 == 0
			nQtdeRet2 := 1
		EndIf
		//-- Calculo peso do item do pedido
		nPesoProd := OsPesoProd(cProduto,cFilPv)
		nPesoProd := (nPesoProd * nQtdeRet2)
		//-- Calcula capacidade volumetrica
		nCapArm := OsPrCapArm(cProduto,cFilPv)
		nCapVol := ( nCapArm * nQtdeRet2 )
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCalculo baseado pela nova qtdeณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nCapVol > nQtdeVol
			Do Case
				Case SB1->B1_TIPODEC $ "NA" //Normal
					nQtdeRet1 := (nQtde*nQtdeVol) / nVolume
				Case SB1->B1_TIPODEC ==	 "I" //Incrementa
					nQtdeRet1 := Int((nQtde*nQtdeVol) / nVolume ) + 1
				Case SB1->B1_TIPODEC == "T"
					nQtdeRet1 := Int((nQtde*nQtdeVol) / nVolume )
			EndCase
			If nQtde < nQtdeRet1 //.Or. ( nQtdeRet1 == 0 )
				nQtdeRet1 := nQtde
			ElseIf nQtdeRet1 == 0
				nQtdeRet1 := 1
			EndIf
			//-- Calculo peso do item do pedido
			nPesoProd := OsPesoProd(cProduto,cFilPv)
			nPesoProd := (nPesoProd * nQtdeRet2)
			//-- Calcula capacidade volumetrica
			nCapArm := OsPrCapArm(cProduto,cFilPv)
			nCapVol := ( nCapArm * nQtdeRet1 )
		EndIf
	EndIf
	If nQtdeRet1 > nQtdeRet2
		nQtdeRet := nQtdeRet1
	Else
		nQtdeRet := nQtdeRet2
	EndIf
	//-- Calculo peso do item do pedido
	nPesoProd := OsPesoProd(cProduto,cFilPv)
	nPesoProd := (nPesoProd * nQtdeRet)
	//-- Calcula capacidade volumetrica
	nCapArm := OsPrCapArm(cProduto,cFilPv)
	nCapVol := ( nCapArm * nQtdeRet )
	Aadd(aRet,nQtdeRet)
	Aadd(aRet,nPesoProd)
	Aadd(aRet,nCapVol)
EndIf
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOms210TREEบAutor  ณHenry Fila          บ Data ณ  02/20/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra o tree com os pallets criados                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Oms210Tree(aArrayPal,cCaminhao,nQtdUni,cCodUni)

Local aSize     := MsAdvSize( .T. )
Local aPosObj1  := {}
Local aObjects  := {}
Local aButtons  := {{ "RELATORIO"  , { || Da210Leg() }, OemtoAnsi(STR0045), OemtoAnsi(STR0045)} } //"Legenda"

Local cDescri   := ""
Local cResource := ""
Local cPallet   := ""
Local cNome     := ""

Local nPesoPad  := 0
Local nVolPad   := 0
Local nOpcao    := 0
Local nPallet   := 0
Local nVolume   := 0
Local nPeso     := 0
Local nPerPal   := 0
Local nPerPeso  := 0
Local nPerVol   := 0

Local oDlg
Local oTree
Local oSayPed,oSayCli,oSayQuebra,oSayQtde,oSayPeso,oSayVolume

If Select("TRB") == 0
	Help(" ",1,"OMS210CALC") //Calculo de unitizacao ainda nao foi executado
	Return
EndIf

aObjects := {}
AAdd( aObjects, { 100,  50, .t., .f. } )
AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, { 100,  50, .t., .f. } )

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj1 := MsObjSize( aInfo, aObjects)

dbSelectArea("TRB")
dbGotop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณBusco caracteristicas do caminhaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

DEFINE MSDIALOG oDlg FROM aSize[7],000 TO aSize[6],aSize[5] TITLE OemtoAnsi(STR0007) PIXEL //Unitizacao

	@ aPosObj1[1,1], aPosObj1[1,2] TO  aPosObj1[1,3], aPosObj1[1,4] LABEL  OemToAnsi(STR0022)   OF oDlg PIXEL   //"Dados da Unitizacao"
	@ aPosObj1[3,1], aPosObj1[3,2] TO  aPosObj1[3,3], aPosObj1[3,4] LABEL  OemToAnsi(STR0023)   OF oDlg PIXEL   //"Visualizacao"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Definicao do DbTree.                                         ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE DBTREE oTree FROM aPosObj1[2,1],aPosObj1[2,2] TO aPosObj1[2,3],aPosObj1[2,4] CARGO OF oDlg
	oTree:bChange := {|| Oms210Msg(oTree,oSayPed,oSayCli,oSayQuebra,oSayQtde,oSayPeso,oSayVolume) }

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณContador de pallets ocupadosณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

		nPallet := 0

		While TRB->(!Eof())

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAcumulo Carga ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			cCarga   := TRB->TRB_CARGA
			nPesoPad := TRB->TRB_PESPAL
			nVolPad  := TRB->TRB_VOLPAL

			cPrompt := PadR(STR0024+TRB->TRB_CARGA,120) //"Carga :"
			DBADDTREE oTree PROMPT cPrompt RESOURCE "F5_NULL","F6_NULL" CARGO Replicate("0",6)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAcumulo palletณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

			While !Eof() .And. ( TRB->TRB_CARGA == cCarga )

				nPallet++

				cPrompt := PadR(STR0025+TRB->TRB_PALLET,120) //"Pallet "
				DBADDTREE oTree PROMPT cPrompt RESOURCE "F5_NULL","F6_NULL" CARGO Replicate("0",6)
				cPallet := TRB->TRB_CARGA+TRB->TRB_PALLET

				While !Eof() .And. ( TRB->TRB_CARGA+TRB->TRB_PALLET == cPallet )

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe unitizacao por clienteณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

					If mv_par01 == 1

						cCliente := TRB->TRB_CARGA+TRB->TRB_PALLET+TRB_CLIENTE+TRB->TRB_LOJA

						SA1->(dbSetOrder(1))
						If SA1->(MsSeek(OsFilial("SA1",TRB->TRB_FILPV)+TRB->TRB_CLIENTE+TRB->TRB_LOJA) )
							cNome := SA1->A1_NOME
						EndIf


						cPrompt := PadR(STR0026+cNome,120) //"Cliente :"
						DBADDTREE oTree PROMPT cPrompt RESOURCE "F5_NULL","F6_NULL" CARGO Replicate("0",6)

						While !Eof() .And. TRB->TRB_CARGA+TRB->TRB_PALLET+TRB_CLIENTE+TRB->TRB_LOJA == cCliente

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณPego descricao do produtoณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

							SB1->(dbSetOrder(1))
							If SB1->(MsSeek(OsFilial("SB1",TRB->TRB_FILPV)+TRB->TRB_CODPRO))
								cDescri := SB1->B1_DESC
							EndIf

							cPrompt := Pad(TRB->TRB_CODPRO+cDescri+ ;
										STR0027+ Alltrim(Transform(TRB->TRB_QTDE,"@E 99,999.999") ),120) //" Qtde :"
							cCargo  := StrZero(TRB->(Recno()),6)

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณSe for quebra, mudo a cor do folderณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

							If nPallet <= nQtdUni
								cResource := Iif(Val(TRB->TRB_SEQPAL) > 1,"F5_AZUL", "F5_VERD" )
							Else
								cResource := "F5_VERM"
							Endif
							DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณAcumulo peso do palletณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

							nPeso   += TRB->TRB_PESO
							nVolume += TRB->TRB_VOLUME

							TRB->(dbSkip())

						EndDo

						DBENDTREE oTree

					Else

						cProduto := TRB->TRB_CARGA+TRB->TRB_PALLET+TRB_CODPRO

						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณPego descricao do produtoณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

						SB1->(dbSetOrder(1))
						If SB1->(MsSeek(OsFilial("SB1",TRB->TRB_FILPV)+TRB->TRB_CODPRO))
							cDescri := SB1->B1_DESC
						EndIf

						cPrompt := PadR(STR0028+TRB->TRB_CODPRO+"-"+cDescri,120) //"Produto :"
						DBADDTREE oTree PROMPT cPrompt RESOURCE "F5_NULL","F6_NULL" CARGO Pad("0 ",120)

						While !Eof() .And. TRB->TRB_CARGA+TRB->TRB_PALLET+TRB_CODPRO == cProduto

							cPrompt := PadR(STR0027+ Alltrim(Transform(TRB->TRB_QTDE,"@E 99,999.999") ),120)
							cCargo  := StrZero(TRB->(Recno()),6)

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณSe for quebra, mudo a cor do folderณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

							If nPallet <= nQtdUni
								cResource := Iif(Val(TRB->TRB_SEQPAL) > 1,"F5_AZUL", "F5_VERD" )
							Else
								cResource := "F5_VERM"
							Endif

							DBADDITEM oTree PROMPT cPrompt RESOURCE cResource CARGO cCargo

							//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
							//ณAcumulo peso do palletณ
							//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

							nPeso   += TRB->TRB_PESO
							nVolume += TRB->TRB_VOLUME

							TRB->(dbSkip())

						EndDo

						DBENDTREE oTree


					EndIf

				EndDo
				DBENDTREE oTree
			EndDo

			DBENDTREE oTree

		EndDo

	nPerPal  := ( nPallet / nQtdUni ) * 100
	nPerPeso := ( nPeso   / DA3->DA3_CAPACN ) * 100
	nPerVol  := ( nVolume / DA3->DA3_VOLMAX ) * 100

	cUniOcu  := StrZero(nPallet,3) + " de " + StrZero(nQtdUni,3) + " - " + Transform(nPerPal,"@E 99999.99 %")
	cPesoOcu := Alltrim(Transform(nPeso,"@E 999,999.9999")) + " de " + ;
				Alltrim(Transform(DA3->DA3_CAPACN,"@E 999,999.9999")) + ;
				" - " + Transform(nPerPeso,"@E 99999.99 %") + ;
				OemtoAnsi(STR0029)+Transform(nPesoPad,"@E 999999.999 Kg") //" - Peso por Unitizador: "


	cVolOcu  := Alltrim(Transform(nVolume,"@E 999,999.9999")) + " de " + ;
				Alltrim(Transform(DA3->DA3_VOLMAX,"@E 999,999.9999")) + " - " + ;
				Transform(nPerVol,"@E 99999.99 %") + ;
				OemtoAnsi(STR0030)+Transform(nVolPad,"@E 99999.9999 m3") //" - Volume por Unitizador: "

	@ aPosObj1[1,1]+05,05 Say OemtoAnsi(STR0031) of oDlg PIXEL //"Unitizadores Ocupados :"
	@ aPosObj1[1,1]+05,If(cPaisLoc=="BRA",90,105) Say cUniOcu of oDlg PIXEL
	@ aPosObj1[1,1]+20,05 Say OemtoAnsi(STR0032) OF oDlg PIXEL  //"Ocupacao do Veiculo em Kg :"
	@ aPosObj1[1,1]+20,If(cPaisLoc=="BRA",90,105) Say cPesoOcu of oDlg PIXEL
	@ aPosObj1[1,1]+35,05 Say OemtoAnsi(STR0033) OF oDlg PIXEL //"Ocupacao do Veiculo em Volume :"
	@ aPosObj1[1,1]+35,If(cPaisLoc=="BRA",90,105) Say cVolOcu OF oDlg PIXEL

	@ aPosObj1[3,1]+10,05  Say OemtoAnsi(STR0034)	SIZE 040,08 Of oDlg PIXEL //"Nr. Pedido: "
	@ aPosObj1[3,1]+10,40  Say oSayPed Prompt ""	SIZE 040,08 Of oDlg PIXEL

	@ aPosObj1[3,1]+10,70  Say OemtoAnsi(STR0026)	SIZE 040,08 Of oDlg PIXEL //"Cliente :"
	@ aPosObj1[3,1]+10,105 Say oSayCli Prompt ""	SIZE 100,08 Of oDlg PIXEL

	@ aPosObj1[3,1]+20,05  Say OemtoAnsi(STR0037)	SIZE 060,08 Of oDlg PIXEL  //"Quebra por unitizador : "
	@ aPosObj1[3,1]+20,70  Say oSayQuebra Prompt ""	SIZE 040,08 Of oDlg PIXEL

	@ aPosObj1[3,1]+30,05  Say OemtoAnsi(STR0038)	SIZE 060,08 Of oDlg PIXEL //"Quantidade : "
	@ aPosObj1[3,1]+30,40  Say oSayQtde Prompt ""	SIZE 040,08 Of oDlg PIXEL

	@ aPosObj1[3,1]+30,100 Say OemtoAnsi(STR0039)	SIZE 060,08 Of oDlg PIXEL //"Peso : "
	@ aPosObj1[3,1]+30,130 Say oSayPeso Prompt ""	SIZE 040,08 Of oDlg PIXEL

	@ aPosObj1[3,1]+30,170 Say OemtoAnsi(STR0035)	SIZE 060,08 Of oDlg PIXEL //"Volume : "
	@ aPosObj1[3,1]+30,200 Say oSayVolume Prompt ""	SIZE 040,08 Of oDlg PIXEL

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || Processa({||Ds210Gera(aArrayPal,cCodUni)}),nOpcao := 1,oDlg:End()}, {||oDlg:End()},,aButtons) CENTERED

Return(Iif(nOpcao == 1, .T.,.F.))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDS210UNI  บAutor  ณMicrosiga           บ Data ณ  02/22/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula Volume e peso por unitizador de acordo com a carga บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cCaminha - Caminhao a ser baseado o calculo                บฑฑ
ฑฑบ          ณ aCargas  - Array com o numero das cargas                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRetUni[1] - Peso Unitario por Pallet                      บฑฑ
ฑฑบ          ณ aRetUni[2] - Peso Unitario por Pallet em relacao a carga   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Ds210Uni(nQtdeUni,cCodUni,aCargas,cVeiculo)
Local aRetUni    := Array(2)
Local nPesoCarga := 0
Local nC         := 0

DEFAULT nQtdeUni := 1
aRetUni[1] := 0
aRetUni[2] := 0
For nC := 1 to Len(aCargas)
	DAK->(dbSetOrder(1))
	If DAK->(MsSeek(xFilial("DAK")+aCargas[nC][1]+aCargas[nC][2]))
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCalculo peso e volume por unitizador ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(cVeiculo)
			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial("DA3")+cVeiculo))
				aRetUni[2] += ( DA3->DA3_VOLMAX / nQtdeUni )
			Else
				aRetUni[2] += ( DAK->DAK_CAPVOL / nQtdeUni )
			EndIf
		Else
			aRetUni[2] += ( DAK->DAK_CAPVOL / nQtdeUni )
		EndIf
//		aRetUni[2] += ( DAK->DAK_CAPVOL / nQtdeUni )
		nPesoCarga += ( DAK->DAK_PESO   / nQtdeUni )
	EndIf
Next
nPesoCarga := nPesoCarga * ( ( mv_par02 / 100 ) + 1)
aRetUni[2] := aRetUni[2] * ( ( mv_par02 / 100 ) + 1)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณComparo para ver qual sera a menor quebra, a da carga ouณ
//ณa cadastrada no pallet                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DC1->(dbSetOrder(1))
If DC1->(MsSeek(xFilial("DC1")+cCodUni))
	aRetUni[1] := Iif(DC1->DC1_CAPMAX < nPesoCarga,DC1->DC1_CAPMAX, nPesoCarga)
EndIf
Return(aRetUni)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOms210MSG บAutor  ณHenry Fila          บ Data ณ  02/22/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra mensagem na tela dos itens do dbtree                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5Dl                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Oms210Msg(oTree,oSayPed,oSayCli,oSayQuebra,oSayQtde,oSayPeso,oSayVolume)

Local cSayCli  := ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosiciono no registro correspondente ao Treeณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

TRB->(dbGoto(Val(oTree:GetCargo())))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualizao mensagem na tela com os dadosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

oSayPed:SetText(TRB->TRB_PEDIDO)
oSayQuebra:SetText(TRB->TRB_SEQPAL)
oSayQtde:SetText(TRB->TRB_QTDE)
oSayPeso:SetText(Alltrim(Transform(TRB->TRB_PESO,"@E 99,999.9999 Kg") ) )
oSayVolume:SetText(Alltrim(Transform(TRB->TRB_VOLUME,"@E 99,999.9999 M3") ) )

SA1->(dbSelectArea("SA1"))
If SA1->(MsSeek(OsFilial("SA1",TRB->TRB_FILPV)+TRB->TRB_CLIENT+TRB->TRB_LOJA) )
	cSayCli	:= TRB->TRB_CLIENT+"-"+TRB->TRB_LOJA+" "+SA1->A1_NOME
	oSayCli:SetText(cSayCli)
Else
	oSayCli:SetText()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDS210GERA บAutor  ณHenry Fila          บ Data ณ  03/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera unitizacao nos arquivo DBN                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5Dl                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function DS210Gera(aCargas,cCodUni)

Local cCodUniSeq := ""
Local nSeqEntr   := 0
Local nSaveSx8   := GetSx8Len()
Local nC         := 0
Local lGera      := .F.
Local lOM210GRV  := ExistBlock("OM210GRV")

cCodUniSeq := GetSx8Num("DBN","DBN_CODUNI")

dbSelectArea("TRB")
ProcRegua(LastRec())
dbGotop()

Begin Transaction

While TRB->(!Eof())

	IncProc()

	lGera := .T.
	cCaminhao := TRB->TRB_VEICUL

	nSeqEntr++

	RecLock("DBN",.T.)
		DBN->DBN_FILIAL := xFilial("DBN")
		DBN->DBN_CODUNI := cCodUniSeq
		DBN->DBN_DATA   := dDatabase
		DBN->DBN_CODCLI := TRB->TRB_CLIENT
		DBN->DBN_LOJA   := TRB->TRB_LOJA
		DBN->DBN_PEDIDO := TRB->TRB_PEDIDO
		DBN->DBN_ITEM   := TRB->TRB_ITEM
		DBN->DBN_SEQUEN := TRB->TRB_SEQUEN
		DBN->DBN_CODPRO := TRB->TRB_CODPRO
		DBN->DBN_CARGA  := TRB->TRB_CARGA
		DBN->DBN_SEQCAR := TRB->TRB_SEQCAR
		DBN->DBN_SEQENT := StrZero(nSeqEntr,Len(DBN->DBN_SEQENT))
		DBN->DBN_UNITIZ := TRB->TRB_PALLET
		DBN->DBN_SEQUNI := TRB->TRB_SEQPAL
		DBN->DBN_QTDE   := TRB->TRB_QTDE
		DBN->DBN_PESO   := TRB->TRB_PESO
		DBN->DBN_VOLUME := TRB->TRB_VOLUME
	MsUnlock()

	//-- Ponto de Entrada apos gravacao da unitizacao.
	If lOM210GRV
		ExecBlock("OM210GRV",.F.,.F.,{cCodUni})
	EndIf
	TRB->(dbSkip())

EndDo

If lGera

	DA3->(dbSetOrder(1))
	If DA3->(MsSeek(xFilial("DA3")+cCaminhao))

		For nC := 1 to Len(aCargas)

			DAK->(dbSetOrder(1))
			If DAK->(MsSeek(xFilial("DAK")+aCargas[nC][1]+aCargas[nC][2]))

				RecLock("DAK",.F.)
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณSe nao havia sido associado a um caminhaoณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

					If Empty(DAK->DAK_CAMINH)

						DAK->DAK_CAMINH := DA3->DA3_COD

						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณBusco motorista e ajudantes defaultณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

						DA4->(dbSetOrder(1))
						If DA4->(MsSeek(xFilial("DA4")+DA3->DA3_MOTORI ))

							DAK->DAK_MOTORI := DA4->DA4_COD
							DAK->DAK_AJUDA1 := DA4->DA4_AJUDA1
							DAK->DAK_AJUDA2 := DA4->DA4_AJUDA2
							DAK->DAK_AJUDA3 := DA4->DA4_AJUDA3

						EndIf

					EndIf

				MsUnlock()


				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณAtualiza Flags de unitizacao                                   ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

				OsAvalDAK("DAK",3)

			EndIf

		Next

		While (GetSx8Len() > nSaveSx8 )
			ConfirmSX8()
		EndDo

	EndIf

EndIf

End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDS210ESTORบAutor  ณHenry Fila          บ Data ณ  03/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Estorna unitizacao                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5Dl                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Da210Estor()
Local aArea := GetArea()
Local aDAK  := {}

aDAK :=  DAK->(GetArea())
DAK->(DbSetOrder(1))
DAK->(DbSeek(xFilial("DAK") + DBN->DBN_CARGA))
If DAK->DAK_FEZNF == "2"
	If MsgYesNo(OemtoAnsi(STR0036)) //"Confirma estorno da unitizacao ?"
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณEstorna unitizacao                                          ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		OsAvalDAK("DAK",4)
	EndIf
Else
	Aviso('SIGAOMS', STR0049, {'Ok'}) //"O estorno nao sera permitido pois ja foi emitida nota fiscal para essa carga."
Endif
RestArea(aDAK)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgram   ณ Da200Leg ณ Autor ณ Henry Fila    a       ณ Data ณ23/01/2001ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriฦo ณ Exibe a legenda das quebras de carga                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nil                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Nenhum                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Da210Leg()

BrwLegenda( STR0001, OemToAnsi( "Status" ),{ { "F5_NULL", OemToAnsi( STR0046) },; //"Niveis de Quebra"
								{ "F5_VERD"  , OemToAnsi( STR0043 ) },; //"Inicio do item"
								{ "F5_AZUL"  , OemToAnsi( STR0044) },;
								{ "F5_VERM"  , OemToAnsi( STR0047) } },32) //"Paletes Extras"
