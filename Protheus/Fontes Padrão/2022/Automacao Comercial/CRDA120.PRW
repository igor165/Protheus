#INCLUDE "CRDA120.ch"
#INCLUDE "PROTHEUS.CH"
                             
#DEFINE LIBERADO	"3"
#DEFINE REJEITADO	"4"               
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CRDA120   º Autor ³ Fernando Salvatori º Data ³  28/08/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Monitor para identificar o Status dos caixas ref. a        º±±
±±º          ³ utilizacao dos creditos.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GENERICO                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndre Veiga   ³03/09/05³Della ³Alterado o botao de refresh para descon-º±±
±±º              ³        ³Via   ³siderar o parametro de refresh automati-º±±
±±º              ³        ³      ³co e para utilizar o mesmo bloco de     º±±
±±º              ³        ³      ³codigo para esta finalidade.            º±±
±±ºAndrea Farias ³08/09/05³Della ³Implementacao Continua. Revisao do fonteº±±
±±º              ³        ³Via   ³                                        º±±
±±ºMachima       ³22/10/05³Itapua³Permitir a consulta de orcamentos de    º±±
±±º              ³        ³      ³contratos rejeitados                    º±±
±±ºMarcos Roberto³22/06/06³Itapua³Informar ao usuario que a consulta e    º±±
±±º              ³        ³      ³referente a pasta de CONTRATOS          º±±
±±ºConrado Q.    ³26/02/07³119542³Retirada o ajuste de dicionário.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CRDA120
	Processa({||CA120TELA()}, STR0001, STR0002, .F. ) //"Aguarde... "###"Efetuando atualizacao dos dados..."
Return

Function CA120TELA()
Local oDlg                                 //Dialogo Principal
Local aSize       := MsAdvSize()      	   //Size da tela.
Local aObjects    := {}                    //Objetos da tela
Local aObjects2   := {}                    //Objetos da tela
Local aObjects3   := {}                    //Objetos da tela
Local aObjects4   := {}                    //Objetos da tela
Local nY          := 0                     //Contador do sistema
Local nX          := 0                     //Contador do sistema
Local nLenHeader  := 0                     //Len do aHeader
Local nPosStatus  := 0                     //Posicao do Status na tabela MAH
Local oVerde 	  := LoadBitmap(GetResources(), "BR_VERDE")      //Desenho do ListBox
Local oVermelho   := LoadBitmap(GetResources(), "BR_VERMELHO")   //Desenho do ListBox
Local oAmarelo    := LoadBitmap(GetResources(), "BR_AMARELO")    //Desenho do ListBox
Local oAzul       := LoadBitmap(GetResources(), "BR_AZUL")       //Desenho do ListBox
Local oMagenta    := LoadBitmap(GetResources(), "BR_PINK")       //Desenho do ListBox
Local oPreto      := LoadBitmap(GetResources(), "BR_PRETO")      //Desenho do ListBox
Local oTimer                               //Objeto para o Timer
Local nMoedaCor   := 1                     //Moeda usada no sistema
Local cSimbMoeda  := ""                    //Simbolo da Moeda
Local bRefresh    := {|| Nil }             //Refresh para o Timer
Local nTempo      := 0                     //Tempo escolhido no parametro
Local nBloque     := 0                     //Status do Bloqueio

Local nQtdPerLib  := 0                     //Quantidade de Contrato em Percentual Liberado
Local nQtdPerRej  := 0                     //Quantidade de Contrato em Percentual Rejeitado
Local nQtdPerCrd  := 0                     //Quantidade de Contrato em Percentual no crediario
Local nQtdPerBlq  := 0                     //Quantidade de Contrato em Percentual pendente de liberacao
Local nQtdLib     := 0                     //Quantidade de Contrato Liberado
Local nQtdRej     := 0                     //Quantidade de Contrato Rejeitado
Local nQtdCrd     := 0                     //Quantidade de Contrato no crediario
Local nQtdBlq     := 0                     //Quantidade de Contrato pendente de liberacao
Local nVlrPerLib  := 0                     //Valor de Contrato em Percentual Liberado
Local nVlrPerRej  := 0                     //Valor de Contrato em Percentual Rejeitado
Local nVlrPerCrd  := 0                     //Valor de Contrato em Percentual no crediário
Local nVlrPerBlq  := 0                     //Valor de Contrato em Percentual pendente de liberacao
Local nVlrLib     := 0                     //Valor de Contrato Liberado
Local nVlrRej     := 0                     //Valor de Contrato Rejeitado
Local nVlrCrd     := 0                     //Valor de Contrato Rejeitado
Local nVlrBlq     := 0                     //Valor de Contrato pendente

Local oQtdPerLib                           //Objeto de Quantidade de Contrato em Percentual Liberado
Local oQtdPerRej                           //Objeto de Quantidade de Contrato em Percentual Rejeitado
Local oQtdPerCrd                           //Objeto de Quantidade de Contrato em Percentual Crediario
Local oQtdPerBlq                           //Objeto de Quantidade de Contrato em Percentual Pendente de liberacao
Local oQtdLib                              //Objeto de Quantidade de Contrato Liberado
Local oQtdRej                              //Objeto de Quantidade de Contrato Rejeitado
Local oQtdCrd                              //Objeto de Quantidade de Contrato Crediario
Local oQtdBlq                              //Objeto de Quantidade de Contrato Pendente de liberacao
Local oVlrPerLib                           //Objeto de Valor de Contrato em Percentual Liberado
Local oVlrPerRej                           //Objeto de Valor de Contrato em Percentual Rejeitado
Local oVlrPerCrd                           //Objeto de Valor de Contrato em Percentual Crediario
Local oVlrPerBlq                           //Objeto de Valor de Contrato em Percentual pendente de liberacao
Local oVlrLib                              //Objeto de Valor de Contrato Liberado
Local oVlrRej                              //Objeto de Valor de Contrato Rejeitado
Local oVlrCrd                              //Objeto de Valor de Contrato Crediario
Local oVlrBlq                              //Objeto de Valor de Contrato Pendente de liberacao

Local cLineMAH    := ""                    //Linha do ListBox MAH
Local aLineMAH    := {}                    //Array do ListBox MAH
Local oListMAH                             //Objeto para o ListBox MAH
Local aHeaderMAH  := {}                    //aHeader para o MAH
Local aCpoMAH     := {}                    //Caption da LIstBox

Local cLineMA7    := ""                    //Linha do ListBox MA7
Local aLineMA7    := {}                    //Array do ListBox MA7
Local oListMA7                             //Objeto para o ListBox MA7
Local aHeaderMA7  := {}                    //aHeader para o MA7
Local aCpoMA7     := {}                    //Caption da LIstBox

Local aPosObj     := {}                    //Posicoes do objeto
Local aPosObj2    := {}                    //Posicoes do objeto
Local aPosObj3    := {}                    //Posicoes do objeto
Local aPosObj4    := {}                    //Posicoes do objeto

Local aInfo       := {}                    //Posicoes do objeto
Local aInfo2      := {}                    //Posicoes do objeto
Local aInfo3      := {}                    //Posicoes do objeto
Local aInfo4      := {}                    //Posicoes do objeto

Local aButtons    := {}                    //Botoes da EnchoiceBar
Local oFolder                              //Folder Principal
Local oPanel                               //Panel do Sistema

Local oGetMA3							   //GetDados para o MA3
Local aColsMA3   := {}                     //aCols para o MA3
Local aHeaderMA3 := {}                     //aHeader para o MA3

Local oFntTit                              //Objeto para Fonte
Local oFntPer                              //Objeto para Fonte
Local lR5        := GetRpoRelease("R5")    // Indica se o release e 11.5
Local nTamTela1  := 0                      //Variável que adiciona valor a posicao do objeto Versão11.5
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros:         ³
//³                    ³
//³MV_PAR01 -> Data de ³
//³MV_PAR02 -> Data ate³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! Pergunte( "CRD120" , .T. )
	Return Nil
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inconsistencia do parametro                                				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( Empty( MV_PAR01 ) .OR. Empty( MV_PAR02 ) .OR. MV_PAR03 <= 0 .OR. MV_PAR04 <= 0)
	MsgStop( STR0003, STR0004 ) //"Verifique os parâmetros informados"###"Parâmetros inválidos"
	Return Nil
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³CodeBlock para o Refresh                                   				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bRefresh := {|| CA120Refresh(	nPosStatus,		oFolder,		oVerde,			oVermelho,;
								oAmarelo,		oAzul,			cLineMAH,		@aLineMAH,;
								@oListMAH,		aHeaderMAH,		aCpoMAH,		cLineMA7,;
								@aLineMA7,		@oListMA7,		@aHeaderMA7,	@aCpoMA7,;	
								@oGetMA3,		@aColsMA3,		aHeaderMA3,		oMagenta,;
								nBloque,		oPreto),;                               
                CA120CalcValor(	aLineMAH,		aHeaderMAH,		@nQtdPerLib,	@nQtdPerRej,;
                				@nQtdPerCrd,	@nQtdPerBlq,	@nQtdLib,		@nQtdRej,;
                				@nQtdCrd,		@nQtdBlq,		@nVlrPerLib,	@nVlrPerRej,;
                				@nVlrPerCrd,	@nVlrPerBlq,	@nVlrLib,		@nVlrRej,;
                				@nVlrCrd,		@nVlrBlq,		@oQtdPerLib,	@oQtdPerRej,;
                				@oQtdPerCrd,	@oQtdPerBlq,	@oQtdLib,		@oQtdRej,;
                				@oQtdCrd,		@oQtdBlq,		@oVlrPerLib,	@oVlrPerRej,;
                				@oVlrPerCrd,	@oVlrPerBlq,	@oVlrLib,      	@oVlrRej,;
                				@oVlrCrd,		@oVlrBlq),oFolder:SetOption(1)}

ProcRegua(6)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao de botoes da EnchoiceBar                      				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aButtons, {"AUTOM" 	, bRefresh ,STR0005,STR0047 }) 																//"Refresh... (F5)"
AAdd(aButtons, {STR0006 	, {|| CA120Consulta(cLineMAH,aLineMAH,oListMAH,aHeaderMAH,aCpoMAH, oFolder:nOption) }  ,STR0007,STR0046 }) 	//"ANALITICO"###"Consultar Contrato... (F7)"
AAdd(aButtons, {"BR_PRETO" 	, {|| CA120Legenda() }  ,STR0008,STR0025 }) 												//"Legenda... (F6)"

IncProc()	// Atualiza a Regua de Processamento

If ExistBlock( "CRD120BUT" )
	aButtons := aClone( ExecBlock( "CRD120BUT",.F.,.F.,{aButtons} ))
	If ValType( aButtons ) <> "A"
		MsgStop( STR0009,STR0010 ) //"Retorno do ponto de entrada CRD120BUT inválido"###"Atenção"
		Return Nil
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retiro o simbolo da moeda para exibir no titulo de valor   				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSimbMoeda := SuperGetMv("MV_SIMB"+AllTrim(Str(nMoedaCor)) )

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Medidor de tempo para o refresh caso seja selecionado      				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR04 == 1
	nTempo := 060
ElseIf MV_PAR04 == 2
	nTempo := 120
ElseIf MV_PAR04 == 3
	nTempo := 180
ElseIf MV_PAR04 == 3
	nTempo := 240
Else
	nTempo := 300
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao de Header do ListBox/GetDados                 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeaderMAH := A610CriaHeader("MAH")//aClone( ApBuildHeader("MAH") )
aHeaderMA7 := A610CriaHeader("MA7", "MA7_NOME  ")//aClone( ApBuildHeader("MA7") )
aHeaderMA3 := A610CriaHeader("MA3")//aClone( ApBuildHeader("MA3") )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posicao do campo Status da base de dados                   				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPosStatus := GdFieldPos( "MAH_STATUS", aHeaderMAH ) 
nBloque    := GdFieldPos( "MA7_BLOQUE", aHeaderMA7 ) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Colunas da ListBox MAH                                     				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLineMAH := "{|| {"
nLenHeader := Len( aHeaderMAH )

For nX := 0 To nLenHeader
	If nX == 0
		cLineMAH += "IIf( Substr(aLineMAH[oListMAH:nAt][nPosStatus],1,1) == '1', oVerde, "
		cLineMAH += "IIf( Substr(aLineMAH[oListMAH:nAt][nPosStatus],1,1) == '2', oAmarelo, "
		cLineMAH += "IIf( Substr(aLineMAH[oListMAH:nAt][nPosStatus],1,1) == '3', oAzul, "
		cLineMAH += "IIf( Substr(aLineMAH[oListMAH:nAt][nPosStatus],1,1) == '4', oVermelho,NIL)))), "
		
		Loop
	Endif
	
	cLineMAH += "aLineMAH[oListMAH:nAt,"+AllTrim(Str(nX))+"]"+IIf(nX < nLenHeader,",","")
Next nX

cLineMAH += "}}"

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o caso de existir campos de combobox.                 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SX3" )
DbSetOrder( 2 )
For nX := 1 To nLenHeader
	DbSeek( aHeaderMAH[nX][2] )
	If !Empty( X3Cbox() )
		For nY := 1 to Len( aLineMAH )
			If !Empty(aLineMAH[nY][nX ])
				aSx3Box := aClone(RetSx3Box( X3Cbox(),,,1 ))
				aLineMAH[nY][nX ] := aSx3Box[aScan( aSx3Box, { |aBox| aBox[2] == aLineMAH[nY][nX ] } )][3]// descricao da situacao.
			Endif
		Next nY
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Colunas da ListBox MA7                                     				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cLineMA7 := "{|| {"
nLenHeader := Len( aHeaderMA7 )


For nX := 0 To nLenHeader
	If nX == 0
		cLineMA7 += "IIf( CA120Bloqueio(aLineMA7[oListMA7:nAt]["+AllTrim(Str(GDFieldPos("MA7_CODCLI",aHeaderMA7)))+"],aLineMA7[oListMA7:nAt]["+AllTrim(Str(GDFieldPos("MA7_LOJA",aHeaderMA7)))+"]) == '4', oMagenta,"
		cLineMA7 += "IIf( CA120Bloqueio(aLineMA7[oListMA7:nAt]["+AllTrim(Str(GDFieldPos("MA7_CODCLI",aHeaderMA7)))+"],aLineMA7[oListMA7:nAt]["+AllTrim(Str(GDFieldPos("MA7_LOJA",aHeaderMA7)))+"]) == '1', oPreto,NIL)), "

		Loop
	Endif
	
	cLineMA7 += "aLineMA7[oListMA7:nAt,"+AllTrim(Str(nX))+"]"+IIf(nX < nLenHeader,",","")
Next nX
                     

cLineMA7 += "}}"

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da GetDados e Paineis.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, {  100, 050, .T., .T. } ) //Folder
AAdd( aObjects, {  100, 050, .T., .T. } ) //Panel + GetDados

AAdd( aObjects2, { 50, 100, .T., .T. } )  //Panel
AAdd( aObjects2, { 50, 100, .T., .T. } )  //GetDados

AAdd( aObjects3, { 100, 100, .T., .T. } ) //GetDados dentro do Folder 1

aInfo 	 := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj  := MsObjSize( aInfo, aObjects, .T. , .F. )

aInfo2 	 := { aSize[ 1 ], aPosObj[ 2 ][ 1 ], aSize[ 3 ], aPosObj[ 2 ][ 3 ], 2, 2 }
aPosObj2  := MsObjSize( aInfo2, aObjects2, .T. , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³LR5 = Verifica se utiliza versão 11.5                            ³
//³Caso Utilize 11.5 adiciona +10 Posicoes no (segundo) 2ºParametro.³
//³ Realiza ajuste da posicao do Objeto na tela                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lR5
	nTamTela1 := 10
EndIf
aInfo3 	 := { aPosObj[ 1 ][ 2 ], aPosObj[ 1 ][ 1 ]+nTamTela1, aPosObj[ 1 ][ 4 ], aPosObj[ 1 ][ 3 ], 2, 2 }
aPosObj3  := MsObjSize( aInfo3, aObjects3, .T. , .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula as posicoes dos objetos dentro do Panel                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )
AAdd( aObjects4, {100,10,.T.,.T.} )

aInfo4    := { 0, 0, aPosObj2[1,4]-aPosObj2[1,2], aPosObj2[1,3]-aPosObj2[1,1], 3, 3 }
aPosObj4  := MsObjSize( aInfo4, aObjects4, .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nome das colunas do ListBox, retirado do aHeader.          				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCpoMAH, " " )
aEval( aHeaderMAH,{ |ExpA1| AAdd(aCpoMAH,ExpA1[1] ) } )
AAdd( aCpoMA7, " " )
aEval( aHeaderMA7,{ |ExpA1| AAdd(aCpoMA7,ExpA1[1] ) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao de Keys para o Monitor                        				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F5, IIf(MV_PAR03 == 2, bRefresh, NIL ) )
SetKey(VK_F6,{|| CA120Legenda()} )
SetKey(VK_F7,{|| CA120Consulta(cLineMAH,aLineMAH,oListMAH,aHeaderMAH,aCpoMAH, oFolder:nOption)} )

INCLUI := .F.

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem da tela.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0011 FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Monitor"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao das fontes                                       				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFntTit NAME "MS Sans Serif"   SIZE 0, -9 BOLD //Titulo

If aSize[5] < 1000
	DEFINE FONT oFntPer NAME "Times New Roman" BOLD SIZE 6,12      //Valor Porcentagem
Else
	DEFINE FONT oFntPer NAME "Times New Roman" BOLD SIZE 11,20      //Valor Porcentagem
Endif             

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Painel                                        				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel := TPanel():New(aPosObj2[1][1],aPosObj2[1][2],"",oDlg,NIL,.T.,.F.,NIL,NIL,aPosObj2[1][4]-aPosObj2[1][2],aPosObj2[1][3]-aPosObj2[1][1],.T.,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao das mensagens para consulta dos valores do Credito			    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@aPosObj4[1][1], 005 SAY STR0012 FONT oFntTIT SIZE 154,18 OF oPanel PIXEL //"Quantidade de Vendas Bloqueadas: "
@aPosObj4[2][1], 005 SAY oQtdPerLib VAR StrZero(nQtdPerLib,3,0)+ STR0013              FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HBLUE PIXEL //"% Liberadas"
@aPosObj4[3][1], 005 SAY oQtdPerRej VAR StrZero(nQtdPerRej,3,0)+ STR0014             FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HRED   PIXEL //"% Rejeitadas"
@aPosObj4[4][1], 005 SAY oQtdPerCrd VAR StrZero(nQtdPerCrd,3,0)+ STR0015           FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_MAGENTA   PIXEL //"% Crediário"
@aPosObj4[5][1], 005 SAY oQtdPerBlq VAR StrZero(nQtdPerBlq,3,0)+ STR0016           FONT oFntPer SIZE 154,18 OF oPanel    PIXEL //COLOR 59110 //"% Bloqueado"

@aPosObj4[6][1], 005 SAY STR0017 FONT oFntTIT SIZE 154,18 OF oPanel PIXEL //"Valor das Vendas Bloqueadas: "
@aPosObj4[7][1], 005 SAY oVlrPerLib VAR StrZero(nVlrPerLib,3,0)+ STR0013              FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HBLUE PIXEL //"% Liberadas"
@aPosObj4[8][1], 005 SAY oVlrPerRej VAR StrZero(nVlrPerRej,3,0)+ STR0014             FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HRED   PIXEL //"% Rejeitadas"
@aPosObj4[9][1], 005 SAY oVlrPerCrd VAR StrZero(nVlrPerCrd,3,0)+ STR0015           FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_MAGENTA  PIXEL //"% Crediário"
@aPosObj4[10][1], 005 SAY oVlrPerBlq VAR StrZero(nVlrPerBlq,3,0)+ STR0016           FONT oFntPer SIZE 154,18 OF oPanel   PIXEL//COLOR 59110  //"% Bloqueado"

@aPosObj4[2][1], 110 SAY oQtdLib VAR AllTrim(Str(nQtdLib))+ STR0018  FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HBLUE PIXEL //" Venda(s)"
@aPosObj4[3][1], 110 SAY oQtdRej VAR AllTrim(Str(nQtdRej))+ STR0018  FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HRED   PIXEL //" Venda(s)"
@aPosObj4[4][1], 110 SAY oQtdCrd VAR AllTrim(Str(nQtdCrd))+ STR0018  FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_MAGENTA   PIXEL //" Venda(s)"
@aPosObj4[5][1], 110 SAY oQtdBlq VAR AllTrim(Str(nQtdBlq))+ STR0018  FONT oFntPer SIZE 154,18 OF oPanel  PIXEL//COLOR 59110 //" Venda(s)"

@aPosObj4[7][1], 110 SAY oVlrLib VAR AllTrim(cSimbMoeda+TransForm(nVlrLib,"@E 999,999.99")) FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HBLUE PIXEL
@aPosObj4[8][1], 110 SAY oVlrRej VAR AllTrim(cSimbMoeda+TransForm(nVlrRej,"@E 999,999.99")) FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_HRED   PIXEL
@aPosObj4[9][1], 110 SAY oVlrCrd VAR AllTrim(cSimbMoeda+TransForm(nVlrCrd,"@E 999,999.99")) FONT oFntPer SIZE 154,18 OF oPanel COLOR CLR_MAGENTA   PIXEL
@aPosObj4[10][1], 110 SAY oVlrBlq VAR AllTrim(cSimbMoeda+TransForm(nVlrBlq,"@E 999,999.99")) FONT oFntPer SIZE 154,18 OF oPanel    PIXEL//COLOR 59110

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao da Folder (guias)                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@aPosObj[1][1],aPosObj[1][2] FOLDER oFolder OF oDlg PROMPTS STR0019, STR0020 SIZE aPosObj[1][4],aPosObj[1][3]-12 PIXEL //"&Contratos"###"&Bloqueados/Crediário"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao da MsNEWGetDados                                 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetMA3 := MsNEWGetDados():New(aPosObj2[2][1],aPosObj2[2][2],aPosObj2[2][3],aPosObj2[2][4]+2,,,,,,,,,,,oDlg,aHeaderMA3,aColsMA3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao das ListBox de Contrato e Parcelas               				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListMAH := TWBrowse():New( aPosObj3[1][1]-10,aPosObj3[1][2],aPosObj3[1][4]-10,aPosObj3[1][3]-35,,aCpoMAH,,oFolder:aDialogs[1],,,,,,,,,,,,,,.T.)
oListMAH:bLDblClick := {|| CA120Consulta(cLineMAH,aLineMAH,oListMAH,aHeaderMAH,aCpoMAH, oFolder:nOption) }

oListMA7 := TWBrowse():New( aPosObj3[1][1]-10,aPosObj3[1][2],aPosObj3[1][4]-10,aPosObj3[1][3]-35,,aCpoMA7,,oFolder:aDialogs[2],,,,,,,,,,,,,,.T.)
oListMA7:bLDblClick := {|| CA120Consulta(cLineMAH,aLineMAH,oListMAH,aHeaderMAH,aCpoMAH, oFolder:nOption) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao da selecao da Folder.                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFolder:bSetOption := {|| CA120Folder(aHeaderMAH,aLineMAH,oListMAH,@cLineMA7,@aLineMA7,@oListMA7,@aHeaderMA7,@aCpoMA7, oMagenta, oPreto) }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Timer para Refresh dos dados (caso seja selecionado         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR03 == 1
	DEFINE TIMER oTimer INTERVAL (nTempo * 1000) ACTION ( Eval( bRefresh )) OF oDlg
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executo o 1 refresh da tela, para carregar as informacoes padroes        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval( bRefresh )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ativacao do DIALOG                                         				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT ( EnchoiceBar( oDlg, {|| NIL }, {|| IIf(MV_PAR03 == 1,oTimer:DeActivate(),NIL),oDlg:End() },,aButtons ), IIf(MV_PAR03 == 1,oTimer:Activate(),NIL))


IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpando as Keys usadas pelo Monitor                       				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F5,Nil )
SetKey(VK_F6,Nil )
SetKey(VK_F7,Nil )

INCLUI := NIL

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120RefreºAutor  ³Fernando Salvatori  º Data ³ 28/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Refresh da tela.                                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA120Refresh(	nPosStatus,		oFolder,		oVerde,			oVermelho,;
								oAmarelo,		oAzul,			cLineMAH,		aLineMAH,;
								oListMAH,		aHeaderMAH,		aCpoMAH,		cLineMA7,;
								aLineMA7,		oListMA7,		aHeaderMA7,		aCpoMA7,;
								oGetMA3,		aColsMA3,		aHeaderMA3,		oMagenta,;
								nBloque, 		oPreto)

Processa({||CA120F5(	nPosStatus,		oFolder,		oVerde,			oVermelho,;
						oAmarelo,		oAzul,			cLineMAH,		aLineMAH,;
						oListMAH,		aHeaderMAH,		aCpoMAH,		cLineMA7,;
						aLineMA7,		oListMA7,		aHeaderMA7,		aCpoMA7,;
						oGetMA3,		aColsMA3,		aHeaderMA3,		oMagenta,;
						nBloque, 		oPreto)},;
						 STR0001, STR0002, .F. ) //"Aguarde... "###"Efetuando atualizacao dos dados..."
	
Return
                              

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120F5   ºAutor  ³Microsiga           º Data ³  09/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza o refresh da tela.                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA120                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea Farias ³09/09/05³Della ³- Ajuste no array aLineMAH. Carregar a  º±±
±±º              ³        ³Via   ³opcao e descricao do combobox existente º±±
±±º              ³        ³      ³nos campos Status e Transacao da tabela º±±
±±º              ³        ³      ³MAH.                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CA120F5(	nPosStatus,	oFolder,	oVerde,		oVermelho,;
							oAmarelo,	oAzul,		cLineMAH, 	aLineMAH,;
							oListMAH,	aHeaderMAH,	aCpoMAH,	cLineMA7,;
							aLineMA7,	oListMA7, 	aHeaderMA7,	aCpoMA7,;
							oGetMA3,	aColsMA3,	aHeaderMA3,	oMagenta,;
							nBloque,  	oPreto)

Local aArea      := GetArea()   //Area do Sistema
Local nX         := 0           //Contador do Sistema
Local nY         := 0           //Contador do Sistema
Local nLenHeader := 0           //Len dos dados do MAH

ProcRegua(9)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego as informacoes da tabela MAH para o ListBox        				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("SL1")
DbSetOrder(10)

DbSelectArea( "MAH" )
DbSetOrder( 4 )

IncProc()	// Atualiza a Regua de Processamento

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³O cadastro de contratos MAH por definicao nao precisa do tratamento para varias filiais, pois e compartilhado.³
//³Carrega apenas os contratos com status 3 e 4 - Liberado ou Rejeitado (Bloqueado) respectivamente.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aLineMAH   := aClone( a610CriaCols("MAH", aHeaderMAH, xFilial( "MAH" )+DtoS( MV_PAR01 ), ;
                     {||MAH->MAH_FILIAL + DtoS( MAH->MAH_EMISSA ) <= xFilial( "MAH" ) + DtoS( MV_PAR02 )}, ;
                     {|| MAH->MAH_STATUS $ "3/4"}) [1] )


nLenHeader := Len( aHeaderMAH ) //Qtd de campos da tabela MAH

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o caso de existir campos de combobox.                 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SX3" )
DbSetOrder( 2 )
For nX := 1 To nLenHeader
	DbSeek( aHeaderMAH[nX][2] )
	If !Empty( X3Cbox() )
		For nY := 1 to Len( aLineMAH )
			If !Empty(aLineMAH[nY][nX ])
				aSx3Box := aClone(RetSx3Box( X3Cbox(),,,1 ))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Se o X3_BOX estiver preenchido carrego a opcao e a descricao do combobox³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aLineMAH[nY][nX ] := aSx3Box[aScan( aSx3Box, { |aBox| aBox[2] == aLineMAH[nY][nX ] } )][1] 
			Endif
		Next nY
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrego as informacoes da tabela MA3 para o MsNewGetdados  				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "MA3" )
DbSetOrder( 2 )

IncProc()	// Atualiza a Regua de Processamento
// ------------------------------------------------------------------------------------------------
// O cadastro MA3 por definicao nao precisa do tratamento para varias filiais, pois e compartilhado
// ------------------------------------------------------------------------------------------------

aColsMA3   := aClone( a610CriaCols("MA3", aHeaderMA3, xFilial( "MA3" )+DtoS( MV_PAR01 ), ;
                      {||MA3->MA3_FILIAL + DtoS( MA3->MA3_DATA ) <= xFilial( "MA3" ) + DtoS( MV_PAR02 )}, Nil)[1] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da tabela MA7 como default.                  				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "MA7" )
DbSetOrder( 2 )

// ------------------------------------------------------------------------------------------------
// O cadastro MA7 por definicao nao precisa do tratamento para varias filiais, pois e compartilhado
// ------------------------------------------------------------------------------------------------

IncProc()	// Atualiza a Regua de Processamento
aLineMA7 := aClone( a610CriaCols("MA7", aHeaderMA7, xFilial( "MA7" )+ "1" ,, ;
					{|| MA7->MA7_BLOQUE $ "1/4" .AND. dtos(MA7->MA7_DATABL) >= dtos(MV_PAR01) .AND. dtos(MA7->MA7_DATABL) <= dtos(MV_PAR02)})[1] )


nLenHeader := Len( aHeaderMA7 ) //Qtd de campos da tabela MA7

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o caso de existir campos de combobox.                 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SX3" )
DbSetOrder( 2 )
For nX := 1 To nLenHeader
	DbSeek( aHeaderMA7[nX][2] )
	If !Empty( X3Cbox() )
		For nY := 1 to Len( aLineMA7 )
			If !Empty(aLineMA7[nY][nX ])
				aSx3Box := aClone(RetSx3Box( X3Cbox(),,,1 ))
				aLineMA7[nY][nX ] := aSx3Box[aScan( aSx3Box, { |aBox| aBox[2] == aLineMA7[nY][nX ] } )][3]// descricao da situacao.
			Endif
		Next nY
	Endif
Next nX

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao da Listbox de Contrato.                       				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListMAH:SetArray( aLineMAH )
oListMAH:bLine := &cLineMAH
If Len( aLineMAH ) < oListMAH:nAt
	oListMAH:nAt   := Len( aLineMAH )
Endif

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao da Listbox das parcelas.                      				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListMA7:SetArray( aLineMA7 )
oListMA7:bLine := &cLineMA7
If Len( aLineMA7 ) < oListMA7:nAt
	oListMA7:nAt   := Len( aLineMA7 )
Endif

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao da MsNewGetDados.                             				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetMA3:aCols := aClone( aColsMA3 )
If Len( aColsMA3 ) < oGetMA3:nAt
	oGetMA3:nAt := Len( aColsMA3 )
Endif

IncProc()	// Atualiza a Regua de Processamento
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Refresh final de todos os objetos acima.                   				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListMAH:Refresh()
oListMA7:Refresh()
oGetMA3:oBrowse:Refresh()

RestArea( aArea )           //Recupera Area do sistema

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120FoldeºAutor  ³Fernando Salvatori  º Data ³ 28/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a troca do Folder.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA120Folder(	aHeaderMAH,	aLineMAH,	oListMAH,	cLineMA7,;
								aLineMA7,	oListMA7,	aHeaderMA7,	aCpoMA7,;
								oMagenta, 	oPreto)

Local lRet       := .T.                                  //Retorno da Funcao
Local aArea      := GetArea()                            //Area do sistema
//Local nPosContra := GDFieldPos( "MAH_CONTRA",aHeaderMAH) //Posicao do Contrato
//Local cContrato  := aLineMAH[oListMAH:nAt][nPosContra]   //Numero do contrato
Local nLenHeader := 0                                    //Header da tabela MA7
Local nX         := 0                                    //Contador do Sistema
Local nY         := 0                                    //Contador do Sistema

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procuro por informacoes das parcelas e carrego na Grade da ListBox       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "MA7" )
DbSetOrder( 2 )

// ------------------------------------------------------------------------------------------------
// O cadastro MA7 por definicao nao precisa do tratamento para varias filiais, pois e compartilhado
// ------------------------------------------------------------------------------------------------
aLineMA7 := aClone( a610CriaCols("MA7", aHeaderMA7, xFilial( "MA7" )+ "1" ,, ;
					{|| MA7->MA7_BLOQUE $ "1/4" .AND. dtos(MA7->MA7_DATABL) >= dtos(MV_PAR01) .AND. dtos(MA7->MA7_DATABL) <= dtos(MV_PAR02)})[1] )

nLenHeader := Len( aHeaderMA7 ) //Qtd de campos da tabela MA7

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Para o caso de existir campos de combobox.                 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SX3" )
DbSetOrder( 2 )
For nX := 1 To nLenHeader
	DbSeek( aHeaderMA7[nX][2] )
	If !Empty( X3Cbox() )
		For nY := 1 to Len( aLineMA7 )
			If !Empty(aLineMA7[nY][nX ])
				aSx3Box := aClone(RetSx3Box( X3Cbox(),,,1 ))
				aLineMA7[nY][nX ] := aSx3Box[aScan( aSx3Box, { |aBox| aBox[2] == aLineMA7[nY][nX ] } )][3]// descricao da situacao.
			Endif
		Next nY
	Endif
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao e atualizacao da tabela MA7                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oListMA7:SetArray( aLineMA7 )
oListMA7:bLine := &cLineMA7
oListMA7:Refresh()

RestArea( aArea )                              //Recuperando area do sistema
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120LegenºAutor  ³Fernando Salvatori  º Data ³ 29/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊ0ÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Legenda do Sistema                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA120Legenda()
Local aCores := {}                 //Cores do sistema

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpo o SetKey do sistema.                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F6,Nil )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao das cores para legenda.                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aCores, {"BR_PRETO"    , STR0021} ) //"Contrato Bloqueados"
AAdd( aCores, {"BR_AZUL"     , STR0022} ) //"Contrato Liberado"
AAdd( aCores, {"BR_VERMELHO" , STR0023} ) //"Contrato Rejeitado"
AAdd( aCores, {"BR_PINK"     , STR0024} ) //"Contrato Crediario"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chamada da funcao de Legenda.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BrwLegenda(STR0011,STR0025,aCores) //"Monitor"###"Legenda"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recupero o Key do sitema.                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F6,{|| CA120Legenda()} )

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120ConsuºAutor  ³Fernando Salvatori  º Data ³ 29/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consulta de dados de Contrato (Analitico) para o Monitor   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA120                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CA120Consulta(	cLineMAH,	aLineMAH,	oListMAH,	aHeaderMAH,;
								aCpoMAH, 	nFolder)
								
Local aSize       := MsAdvSize()      							//Size da tela.
Local aObjects    := {}               							//Objetos da tela
Local aPosObj     := {}               							//Posicoes do objeto
Local aInfo       := {}               							//Posicoes do objeto
Local oEnchoice                       							//Enchoice Principal
Local oGetDados                       							//GetDados principal
Local oDlg                            							//Dialogo principal
Local nPosContra  := GDFieldPos( "MAH_CONTRA",aHeaderMAH)  		//Posicao do Contrato
Local aCols     := {}                 							//Var. para GetDados
Local aHeader   := {}                 							//Var. para GetDados
Local aButtons  := {}                 							//Botoes da EnchoiceBar
Local aTemp     := {}
Private aTela[0][0],aGets[0]          							//Variaveis para validacao da enchoice

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o contrato estiver em branco, retorno ao menu principal              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( oListMAH:aArray[ oListMAH:nAt ][ nPosContra ] )
	Return .F.
Endif
                                                                                                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informa o usuario que o contrato a ser exibido e da pasta contratos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nFolder == 2                            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³"Consulta de contratos" + "Esta consulta se refere ao contrato selecionado na pasta contratos." + "OK"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aviso (STR0026, STR0048, { STR0049 } ) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracao dos botoes da EnchoiceBar                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd(aButtons, {"BUDGET" , {||CA120Orcam( oListMAH:aArray[oListMAH:nAt][nPosContra] ,aLineMAH  ,aHeaderMAH ) }  , STR0045 , STR0032}) // "Consultar orçamento...(F8)"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Limpo o SetKey para evitar duplicidade de execucao.                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey( VK_F7, Nil )
//SetKey( VK_F8,{||CA120Orcam(oListMAH:aArray[ oListMAH:nAt ][ nPosContra ]) })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define as posicoes da GetDados e Paineis.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AAdd( aObjects, {  050, 050, .T., .T. } ) //Enchoice
AAdd( aObjects, {  050, 050, .T., .T. } ) //MsGetDados

aInfo 	 := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
aPosObj  := MsObjSize( aInfo, aObjects, .T. , .F. )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego as variaveis de memoria para o MAH para serem carregadas na Ench³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "MAH" )
DbSetOrder( 1 )
DbSeek( xFilial( "MAH" ) + oListMAH:aArray[ oListMAH:nAt ][ nPosContra ] )

RegToMemory( "MAH", .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrego variaveis aHeader e aCols para o sistema.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "MA7" )
DbSetOrder( 1 )
aHeader := aClone( APBuildHeader( "MA7" ) )
aCols := aClone( a610CriaCols("MA7",aHeader, xFilial( "MA7" )+MAH->MAH_CODCLI+MAH->MAH_LOJA , {|| MA7->MA7_FILIAL+MA7->MA7_CODCLI+MA7->MA7_LOJA == xFilial( "MAH" )+MAH->MAH_CODCLI+MAH->MAH_LOJA }  )[1] )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dialogo do Sistema.                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE STR0026 FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL //"Consulta de Contrato - Monitor"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Enchoice para a tabela MAH (visualizacao apenas)                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchoice := Enchoice( "MAH",MAH->(Recno()),2,,,,,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MsNewGetDados.                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetDados := MsNEWGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4]+2,,,,,,,,,,,oDlg,aHeader,aCols)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativacao do Dialog                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| oDlg:End() } , {|| oDlg:End() },,aButtons) CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno as configuracoes de KEY para o sistema                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey(VK_F7,{|| CA120Consulta(cLineMAH,aLineMAH,oListMAH,aHeaderMAH,aCpoMAH, oFolder:nOption)} )
SetKey(VK_F8, Nil )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120OrcamºAutor  ³Fernando Salvatori  º Data ³ 29/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua a consulta do orcamento.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³CA120Orcam( ExpC1, ExpA2, ExpA3 )							  º±±
±±º			 ³ExpC1 - numero do contrato                                  º±±
±±º			 ³ExpA2 - linhas do arquivo MAH apresentadas no monitor		  º±±
±±º			 ³ExpA3 - aHeader com os campos do MAH						  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA120                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea Farias ³08/09/05³Della ³- Restaurar o aRotina na saida.         º±±
±±º              ³        ³Via   ³- Apresentar o tooltip na descricao do  º±±
±±º              ³        ³      ³botao.                                  º±±
±±º              ³        ³      ³- Pesquisar se o orcamento foi feito    º±±
±±º              ³        ³      ³pelo Televendas ou pela Venda Assistida.º±±
±±ºMarcos Roberto³21/09/05³Della ³- Alteracao para pegar a filial do campoº±±
±±º              ³        ³Via   ³MAH_LJTRN quando for consultar o orca-  º±± 
±±º              ³        ³      |mento em vez de usar xfilial.           º±±
±±ºMarcos Roberto³20/07/06³103196³Inclusao do parametro filial na funcao  º±±
±±º              ³        ³      |LJ7Venda para visualizar orcamentos de  º±±
±±º              ³        ³      |de outras filiais                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA120Orcam( cContrato  ,aLineMAH   ,aHeaderMAH )

Local lRet			:= .F.													// Retorno da funcao
Local lAchouDoc     := .F.													// Controla se encontrou documento(orcamento, pedido etc.) que originou o contrato
Local aArea 		:= GetArea()                       						// Area do Sistema
Local aRots			:= If( Type("aRotina") 	  == "U",Nil,aClone(aRotina))	// Salva o aRotinas atual	
Local cCad			:= If( Type("cCadastro") == "U",Nil,cCadastro) 		// Salva o cCadastro atual
Local nPosContra	:= 0                                                 	// Posicao do contrato no array aLineMAH
Local nPosChave     := 0                                                    // Posicao da chave de pesquisa do documento origem do contrato
Local nTamOrcSL1    := TamSX3("L1_NUM")[1]                                  // Tamanho do campo L1_NUM
Local nTamOrcSUA    := TamSX3("UA_NUM")[1]                                  // Tamanho do campo UA_NUM
Local cPdv  		:= ""													// Serie do PDV que realizou a analise e criou o contrato
Local cCaixa        := ""   												// Codigo do caixa que realizou a analise e criou o contrato
Local cFilContra    := xFilial( "SL1" )
Local cChaveMAH     := ""  													//Chave de pesquisa do documento origem
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seta as teclas de funcao para a venda assistida³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local bF5   		:= {|| NIL } 											
Local bF6   		:= {|| NIL }
Local bF7   		:= {|| NIL }
Local bF8   		:= {|| NIL }


If Len(aLineMAH) > 0
	nPosContra	:= Ascan(aLineMAH,{|x| AllTrim(x[2]) == cContrato})
	nPosChave	:= Ascan(aHeaderMAH,{|x| Trim(x[2]) == "MAH_CHAVE"})	
	If nPosContra > 0
		cPdv 		:= aLineMAH[nPosContra][11]
		cCaixa     	:= aLineMAH[nPosContra][12]
		cFilContra	:= Substr(aLineMAH[nPosContra][13],4,2)
	    If nPosChave > 0
	       cChaveMAH  := aLineMAH[nPosContra][nPosChave]
	    Endif			
	Endif
Endif

Private cCadastro := STR0027         								// Variavel padrao do nome do cadastro //"Venda Assistida"

Private aRotina   := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Considero que quando os campos Caixa e PDV estao preenchidos o contrato      ³
//³ foi gerado pelo SIGALOJA. Pois ainda nao existe outra forma de identifica-lo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If IIf(!Empty(cChaveMAH),Substr(cChaveMAH,1,3)=="SL1",!Empty(cCaixa) .AND. !Empty(cPdv))

	DbSelectArea( "SL1" )
	DbSetOrder( 10 )
	lAchouDoc  := DbSeek( cFilContra + cContrato )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O campo MAH_CHAVE eh composto por: Alias(3)+Filial(2)+Num. Doc. Origem(15)    ³
	//³ Se o contrato nao for encontrado no SL1, significa que foi rejeitado. Neste   ³	
	//³ caso, utiliza o campo MAH_CHAVE, que contem o numero do documento que o origi-³		
	//³ nou(orcamento, pedido etc.)  												  ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !lAchouDoc .AND. !Empty(cChaveMAH)
	   DbSetOrder( 1 )	
	   lAchouDoc  := DbSeek( Substr(cChaveMAH,4,2+nTamOrcSL1)  )	      
	Endif
	
	If lAchouDoc
	    lRet:= .T.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Efetuo um BackUp das teclas de atalho pertencentes ao Monitor           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		bF5 := SetKey(VK_F5)
		bF6 := SetKey(VK_F6)
		bF7 := SetKey(VK_F7)
		bF8 := SetKey(VK_F8)
	                             
		//Funcao utilizada no programa LOJA701
		LJ7Venda( 	"SL1"	,;		//01 Tabela	
					Recno()	,; 		//02 Nro do registro
					2		,;     	//03 Opcao (Visualizacao)
					Nil		,;    	//04 Enchoice
					Nil		,; 		//05 Codigo do cliente	
					Nil		,;     	//06 Loja
					cFilContra )	//07 Filial do contrato 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorno do Backup                                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SetKey(VK_F5,bF5)
		SetKey(VK_F6,bF6)
		SetKey(VK_F7,bF7)
		SetKey(VK_F8,bF8)
	Endif
		
Else

	DbSelectArea("SUA")
	DbSetOrder(10)  //Filial + Contrato
	lAchouDoc  := DbSeek(xFilial("SUA")+cContrato)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O campo MAH_CHAVE eh composto por: Alias(3)+Filial(2)+Num. Doc. Origem(15)    ³
	//³ Se o contrato nao for encontrado no SUA, significa que foi rejeitado. Neste   ³	
	//³ caso, utiliza o campo MAH_CHAVE, que contem o numero do documento que o origi-³		
	//³ nou(orcamento, pedido etc.)  												  ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	If !lAchouDoc .AND. !Empty(cChaveMAH)
	   DbSetOrder( 1 )	
	   lAchouDoc  := DbSeek( Substr(cChaveMAH,4,2+nTamOrcSUA)  )	      
	Endif	
	If lAchouDoc
	    lRet:= .T.
		cCadastro	:= "Televendas"
		aRotina	:= {	{ "Pesquisar"  	,"AxPesqui"        ,0,1 },;	//"Pesquisar"
						{ "Visualizar" 	,"TK271CallCenter" ,0,2 },;	//"Visualizar"
						{ "Incluir"  	,"TK271CallCenter" ,0,3 },;	//"Incluir"
						{ "Alterar"  	,"TK271CallCenter" ,0,4 }} 	//"Alterar"
		TK271CallCenter("SUA", SUA->( Recno() ) , 2 )			
	Endif

Endif

If !lRet
	MsgStop( STR0033, STR0010 ) //"Não existe orçamento cadastrado para este contrato ou nao pertence a Filial selecionada."###"Atenção"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o aRotina e o cCadastro			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("cCadastro") <> "U" .AND. Type("aRotina") <> "U" 
	cCadastro	:= cCad
	aRotina  	:= AClone(aRots)
Endif

RestArea( aArea )     
Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MenuDef  ³ Autor ³ Conrado Q. Gomes      ³ Data ³ 13.12.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CRDA120                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {	{ STR0028	,"AxPesqui"		,0	,1	,0	,.F.	}	,; 			// "Pesquisar"
						{ STR0029	,"LJ7Venda"		,0	,2	,0	,.T.	}	,; 			// "Visualização"
						{ STR0030	,"Lj7Venda"		,0	,3	,0	,.T.	}	,; 			// "Atendimento"
						{ STR0031	,"Lj7Venda"		,0	,4	,0	,.T.	}	,; 			// "Finaliza Venda"
						{ STR0032	,"LJ7Orcam"		,0	,4	,0	,.T.	}	,; 			// "Orçamento"
						{ STR0025	,"Lj7Legenda"	,0	,8	,0	,.T.	}	} 			// Rotinas utilizadas //"Legenda"
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120CalcVºAutor  ³Fernando Salvatori  º Data ³ 30/08/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Efetua o calculo dos percentuais e valores da tela princi- º±±
±±º          ³ pal do monitor                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA120                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea Farias ³08/09/05³Della ³- Obter o valor financiado atraves da   º±±
±±º              ³        ³Via   ³tabela MAH.                             º±±
±±ºHanna Caroline³29/09/05³Della ³Validacao se o arquivo MAH eh comparti- º±±
±±º              ³        ³Via   ³lhado, caso seja o seek serah com o     º±±
±±º              ³        ³      ³DbSeek do MAH.                          º±±
±±º              ³        ³      ³No Seek do MA7 foi incluida a funcao    º±±
±±º              ³        ³      ³CA120ProcMA7, para enviar a filial cor- º±±
±±º              ³        ³      ³reta na funcao.                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA120CalcValor(	aLineMAH,		aHeaderMAH,		nQtdPerLib,		nQtdPerRej,;
								nQtdPerCrd,		nQtdPerBlq,		nQtdLib,		nQtdRej,;
								nQtdCrd,		nQtdBlq,		nVlrPerLib,		nVlrPerRej,;
								nVlrPerCrd,		nVlrPerBlq,		nVlrLib,		nVlrRej,;
								nVlrCrd,		nVlrBlq,		oQtdPerLib,		oQtdPerRej,;
								oQtdPerCrd,		oQtdPerBlq,		oQtdLib,		oQtdRej,;
								oQtdCrd,		oQtdBlq,		oVlrPerLib,		oVlrPerRej,;
								oVlrPerCrd,		oVlrPerBlq,		oVlrLib,		oVlrRej,;
								oVlrCrd, 		oVlrBlq)

Local nX         	:= 0                                    	// Contador do Sistema
Local nZ         	:= 0                                    	// Contador do Sistema
Local nPosContra 	:= GDFieldPos( "MAH_CONTRA"	,aHeaderMAH)  	// Posicao do Contrato
Local nPosStatus 	:= GDFieldPos( "MAH_STATUS"	,aHeaderMAH)  	// Posicao do Contrato
Local nPosCliente	:= GDFieldPos( "MAH_CODCLI"	,aHeaderMAH)  	// Posicao do Codigo do Cliente
Local nPosLoja		:= GDFieldPos( "MAH_LOJA"	,aHeaderMAH)   	// Posicao da Loja do Cliente
Local nTotal  		:= 0                                       	// Percentual/Valor total
Local aFilVal		:= {}										// Array contendo as filiais da empresa atual
Local nPosReg													// Armazena o ponteiro atual do cadastro de filiais
Local lMAHComp		:= .F.										// Verifica se o MAH eh compartilhado
Local lMA7Comp		:= .F.										// Verifica se o MA7 eh compartilhado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificara as filiais validas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SM0")  
nPosReg := Recno()
DbGotop()
While !Eof()
	If M0_CODIGO == cEmpAnt
		aadd(aFilVal,FWGETCODFILIAL)
	Endif
	DbSkip()
End
DbGoto(nPosReg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faco a limpeza das variaveis para um novo recalculo                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nQtdPerLib := 0
nQtdPerRej := 0
nQtdPerCrd := 0
nQtdPerBlq := 0
nQtdLib    := 0
nQtdRej    := 0
nQtdCrd    := 0
nQtdBlq    := 0
nVlrPerLib := 0
nVlrPerRej := 0
nVlrPerCrd := 0
nVlrPerBlq := 0

nVlrLib    := 0
nVlrRej    := 0
nVlrCrd    := 0
nVlrBlq    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se os arquivos sao compartilhado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( xFilial("MAH") )
	lMAHComp	:= .T.
Endif
If Empty( xFilial("MA7") )
	lMA7Comp	:= .T.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Faco o varredura do array para obter os valores financiados afim de     ³
//³ efetuar o calculo da media das vendas Liberadas e Rejeitadas.           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("MAH")
DbSetOrder(2) //Filial + Cliente + Loja + Contrato

For nX := 1 To Len( aLineMAH )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se o MAH for compartilhado ou o parametro for pela filial,³
	//³procura pelo xFilial ("MAH")								 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If MV_PAR05 == 2 .OR. lMAHComp
		If DbSeek( xFilial( "MAH" ) + aLineMAH[nX][nPosCliente] + aLineMAH[nX][nPosLoja] + aLineMAH[nX][nPosContra] )
			If Substr(aLineMAH[nX][nPosStatus],1,1) 	 == LIBERADO	   
				nQtdLib ++
				nVlrLib += MAH->MAH_VLRFIN			//Valor financiado
			ElseIf Substr(aLineMAH[nX][nPosStatus],1,1) == REJEITADO
				nVlrRej += MAH->MAH_VLRFIN
				nQtdRej ++
			Endif
		Endif
	Else
		For nZ:=1 to Len(aFilVal)
			If DbSeek( aFilVal[nZ] + aLineMAH[nX][nPosCliente] + aLineMAH[nX][nPosLoja] + aLineMAH[nX][nPosContra] )
				If Substr(aLineMAH[nX][nPosStatus],1,1) == LIBERADO 
					nQtdLib ++
					nVlrLib += MAH->MAH_VLRFIN 		//Valor financiado
				ElseIf Substr(aLineMAH[nX][nPosStatus],1,1) == REJEITADO
					nVlrRej += MAH->MAH_VLRFIN
					nQtdRej ++
				Endif
			Endif
		Next nZ
	Endif
	DbSelectArea( "MAH" ) 
	
Next nX
 
DbSelectArea("MA7")
DbSetOrder(2)

If MV_PAR05 == 2 .OR. lMA7Comp
	DbSeek( xFilial("MA7") + "4" )
	CA120ProcMA7(	xFilial("MA7"),	@nQtdCrd,	@nVlrCrd,	@nQtdBlq,;
					@nVlrBlq )
Else
	For nZ:=1 to Len(aFilVal)
		DbSeek( aFilVal[nZ] + "4" )
		CA120ProcMA7(	aFilVal[nZ],	@nQtdCrd,	@nVlrCrd,	@nQtdBlq,;
						@nVlrBlq)
	Next nZ
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abaixo eh feita o calculo de porcentagem e valor dos Lib. e Rej.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotal := nQtdLib + nQtdRej + nQtdCrd + nQtdBlq//100%

nQtdPerLib := NoRound(( nQtdLib * 100 ) / nTotal,2) //Percentual de Liberados
nQtdPerRej := NoRound(( nQtdRej * 100 ) / nTotal,2) //Percentual de Rejeitados
nQtdPerCrd := NoRound(( nQtdCrd * 100 ) / nTotal,2) //Percentual de enviados ao crediario
nQtdPerBlq := NoRound(( nQtdBlq * 100 ) / nTotal,2) //Percentual de pendentes de liberacao

nTotal := nVlrLib + nVlrRej + nVlrCrd + nVlrBlq//100%                                   

nVlrPerLib := NoRound(( nVlrLib * 100 ) / nTotal,2) //Percentual de Liberados
nVlrPerRej := NoRound(( nVlrRej * 100 ) / nTotal,2) //Percentual de Rejeitados
nVlrPerCrd := NoRound(( nVlrCrd * 100 ) / nTotal,2) //Percentual de enviado ao credito
nVlrPerBlq := NoRound(( nVlrBlq * 100 ) / nTotal,2) //Percentual de pendente de liberacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetuo um Refresh das informacoes de tela do Monitor.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oQtdPerLib:Refresh()
oQtdPerRej:Refresh()
oQtdPerCrd:Refresh()
oQtdPerBlq:Refresh()
oQtdLib   :Refresh()
oQtdRej   :Refresh()
oQtdCrd   :Refresh()
oQtdBlq   :Refresh()
oVlrPerLib:Refresh()
oVlrPerRej:Refresh()
oVlrPerCrd:Refresh()
oVlrPerBlq:Refresh()
oVlrLib   :Refresh()
oVlrRej   :Refresh()
oVlrCrd   :Refresh()
oVlrBlq   :Refresh()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120ProcMA7  ºAutor  ³Hanna Caroline  º Data ³  29/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Procura de acordo com as filiais escolhidas no parametro   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CRDA030                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CA120ProcMA7(	cFilialMA7,	nQtdCrd,	nVlrCrd,	nQtdBlq,;
								nVlrBlq)
Local lFoundContrato := .F.

While !Eof() .and. MA7->MA7_FILIAL = cFilialMA7 .and. MA7->MA7_BLOQUE = '4'
	If MA7_DATABL >= MV_PAR01 .and. MA7_DATABL <= MV_PAR02

		DbSelectArea("MAL")
		DbSetOrder(1)

		If DbSeek( cFilialMA7 + MA7->MA7_CONTRA )
			nQtdCrd ++
			While !Eof() .AND. cFilialMA7 == MAL->MAL_FILIAL .and. MAL->MAL_CONTRA == MA7->MA7_CONTRA
				nVlrCrd += MAL->MAL_VALOR	 //Valor financiado
		   		DbSkip()
			End
		Else		
			DbSelectArea("MAK")
			DbSetOrder(1)

			If DbSeek( cFilialMA7 + MA7->MA7_CODCLI + MA7->MA7_LOJA )
				While !eof() .and. MAK->MAK_FILIAL + MAK_CODCLI+ MAK->MAK_LOJA == cFilialMA7 + MA7->MA7_CODCLI + MA7->MA7_LOJA
					If MAK_CONTRA == MA7->MA7_CONTRA
						If !lFoundContrato // Na primeira ocorrencia incrementa contador do contrato
							nQtdCrd ++
							lFoundContrato := .t.
						Endif
						nVlrCrd += MAK->MAK_VALOR	 //Valor no crediario
					Endif
					Dbskip()
				End
			Endif
		Endif
	Endif
	DbSelectArea("MA7")
	DbSkip()
End

DbSelectArea("MA7")
DbSetOrder(2)
DbSeek( cFilialMA7 + "1")
While !Eof() .and. MA7->MA7_FILIAL = cFilialMA7 .and. MA7->MA7_BLOQUE = '1'

	If MA7_DATABL >= MV_PAR01 .and. MA7_DATABL <= MV_PAR02
		nQtdBlq ++
		
		DbSelectArea("MAL")
		DbSetOrder(1)
		DbSeek( cFilialMA7 + MA7->MA7_CONTRA )
		
		While !Eof() .and. cFilialMA7 == MAL->MAL_FILIAL .and. MAL->MAL_CONTRA == MA7->MA7_CONTRA
			nVlrBlq += MAL->MAL_VALOR 	//Valor financiado - bloqueado
		   	DbSkip()
		End
	Endif
    DbSelectArea("MA7")
	DbSkip()
End

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CA120BloqueioºAutor  ³Microsiga        º Data ³  09/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o status da situacao de bloqueio do MA7             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ VENDA ASSISTIDA                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CA120Bloqueio(cCliente,cLoja)
Local aArea := GetArea()
Local cRet  := ""

DbSelectArea( "MA7" )
DbSetOrder( 1 )
If DbSeek( xFilial("MA7")+cCliente+cLoja )
	cRet := MA7->MA7_BLOQUE
Endif
                        
RestArea( aArea )
Return cRet                      
