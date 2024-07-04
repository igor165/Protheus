#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH" 
#INCLUDE "AJTQIE04.CH"
#DEFINE PULALINHA CHR(13)+CHR(10)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    | AJTQIE04 � Autor � Paulo Fco. Cruz Neto  � Data � 19.02.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Ajuste de tabela para atualizacao do conteudo dos campos	  ���
���			 � QER_NISERI e QEL_NISERI quando alterado o tamanho dos 	  ���
���			 � campos QEK_NTFISC, QEK_SERINF e QEK_ITEMNF				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIE                  								  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function AJTQIE04()

Local lGravouLog := .F.
Local oOk        := LoadBitmap( GetResources(), "LBOK" )
Local oNOk       := LoadBitmap( GetResources(), "LBNO" )
Local oList
Local aLoadSM0   := {}
Local nX         := 0

Private __cInterNet	:= Nil
Private aArqUpd  	:= {}                                                       
Private aEmpr    	:= {}

Private cTitulo    	:= STR0001 //"Update AJTQIE04"
Private cAcao      	:= STR0002 //"Atualizar os dados de tabelas do SIGAQIE"
Private cArqEmp    	:= 'SIGAMAT.EMP'
Private cApresenta 	:= ''
Private cItemAju   	:= STR0003 //"Andamento do ajuste de cada tabela:"
Private cTerAceite 	:= ''
Private cLogUpdate 	:= ''
Private cEscEmp    	:= STR0004 //"Aten��o: para que o ajuste possa ser efetuado NENHUM usu�rio pode estar utilizando o sistema!"
Private cEmpAtu    	:= ''

Private lConcordo  	:= .F.

Private nTela      	:= 0
Private nAtuTotal  	:= 0
Private nAtuParci  	:= 0

Private oTitulo
Private oAcao

Private oEmpAtu
Private oSelEmp

Private oMemo1
Private oMemo2
Private oMemo3
Private oMemo4

Private oDlgUpd

Private oPanel1
Private oPanel2
Private oPanel3
Private oPanel4
Private oPanel5

Private oMtTotal
Private oMtParci
Private oItemAju

Private oAtuTotal

Private oAtuParc1
Private oAtuParc2
Private oAtuParc3

Private oApresenta

Private oTerAceite
Private oChkAceite

Private oBtnAvanca
Private oBtnCancelar

cApresenta := STR0005			//"Ser� feita a atualiza��o dos dados utilizados na rotina de resultados de inspe��es de entrada para contemplar altera��es no tamanho do campo de numera��o de nota fiscal."
cApresenta += PULALINHA+PULALINHA
cApresenta += STR0006			//"Ser�o ajustados os dados dos campos QER_NISERI e QEL_NISERI para adequar ao tamanho do campo QEK_NTFISC."

cTerAceite := STR0007+PULALINHA	//"Antes que sua atualiza��o inicie, voc� deve ler e aceitar os termos e as condi��es a seguir. Ap�s aceit�-los, voc� pode prosseguir com a atualiza��o."
cTerAceite += PULALINHA
cTerAceite += STR0008+PULALINHA	//"ATEN��O: LEIA COM ATEN��O ANTES DE PROSSEGUIR COM A ATUALIZA��O"
cTerAceite += PULALINHA
cTerAceite += STR0009+PULALINHA	//"ACORDO DE LICEN�A DE SOFTWARE PARA USU�RIO FINAL ('ACORDO')"
cTerAceite += PULALINHA
cTerAceite += STR0010+PULALINHA //"TERMOS E CONDI��ES"
cTerAceite += PULALINHA
cTerAceite += STR0011+PULALINHA	//"ADVERT�NCIAS LEGAIS: AO CLICAR NA OP��O 'SIM, LI E ACEITO O TERMO ACIMA' NO FINAL DESTA JANELA, VOC� INDICA QUE LEU E CONCORDOU COM TODOS OS TERMOS DESTE ACORDO E QUE CONSENTE EM SER REGIDO POR ESTE ACORDO E TORNAR-SE PARTE DELE.  A MICROSIGA EST� DISPOSTA A DISPONIBILIZAR ESTE AJUSTE PARA VOC� APENAS SOB A CONDI��O DE QUE VOC� CONCORDE COM TODOS OS TERMOS CONTIDOS NESTE ACORDO.  SE VOC� N�O CONCORDA COM TODOS OS TERMOS DESTE ACORDO, CLIQUE NO BOT�O 'CANCELAR' E N�O PROSSIGA COM O AJUSTE."
cTerAceite += PULALINHA
cTerAceite += STR0012+PULALINHA	//"O ACORDO A SEGUIR � UM ACORDO LEGAL ENTRE VOC� (O USU�RIO FINAL, SEJA UM INDIV�DUO OU ENTIDADE), E A MICROSIGA S/A. (PROPRIAMENTE DITA OU SUAS LICENCIADAS). "
cTerAceite += PULALINHA
cTerAceite += STR0013+PULALINHA	//"ESTE SOFTWARE � LICENCIADO PELA MICROSIGA PARA VOC�, E QUALQUER RECEPTOR SUBSEQ�ENTE DO SOFTWARE, SOMENTE PARA USO SEGUNDO OS TERMOS ESTABELECIDOS NESTE DOCUMENTO. "
cTerAceite += PULALINHA
cTerAceite += STR0014			//"PREMISSAS DE UTILIZA��O: Antes de executar esta rotina � obrigat�ria a realiza��o de uma c�pia de seguran�a geral do sistema Protheus (bin�rio, RPO, dicion�rios SXs e banco de dados). Fa�a testes de performance e planeje-se antes de executar esta atualiza��o, pois ela requer acesso exclusivo �s tabelas do sistema (ou seja: nenhum usu�rio poder� acessar o sistema) "
cTerAceite += STR0015+PULALINHA	//	"durante toda a sua execu��o, que pode demorar v�rias horas para ser finalizada! Depois de iniciada esta rotina n�o poder� ser interrompida! Qualquer tipo de interrup��o (ex.: falta de energia, problemas de hardware, problemas de rede, etc.) poder� danificar todo o sistema! Neste caso deve-se realizar a restaura��o da c�pia de seguran�a feita imediatamente antes do inicio da atualiza��o antes de execut�-la novamente."
cTerAceite += PULALINHA
cTerAceite += STR0016+PULALINHA	//"CONCESS�O DE LICEN�A: A Microsiga lhe concede uma licen�a limitada, n�o-exclusiva e revog�vel para usar a vers�o de c�digo execut�vel da Atualiza��o do m�dulo de gest�o de contratos denominada GCTUPD16, eximindo-se de qualquer dado resultante da utiliza��o deste."
cTerAceite += PULALINHA
cTerAceite += STR0017+PULALINHA	//"DIREITOS AUTORAIS: O Software � propriedade da Microsiga e est� protegido por leis de direitos autorais do Brasil e disposi��es de tratados internacionais.  Voc� reconhece que n�o lhe ser� transferido qualquer direito a qualquer propriedade intelectual do Software. "
cTerAceite += PULALINHA
cTerAceite += STR0018			//"LIMITA��ES: Exceto se explicitamente disposto em contr�rio neste Acordo, voc� n�o pode: a) modificar o Software ou criar trabalhos derivados do mesmo; b) descompilar, desmontar, fazer engenharia reversa, ou de outras maneiras tentar alterar o c�digo-fonte do Software; c) copiar (exceto para fazer uma c�pia de backup), redistribuir, impedir, vender, alugar, arrendar, sublicenciar, atribuir ou de outras maneiras transferir seus direitos ao Software; ou "
cTerAceite += STR0019+PULALINHA	//"d) remover ou alterar qualquer marca registrada, logotipo, registro ou outras advert�ncias propriet�rias no Software.  Voc� pode transferir todos os seus direitos ao Software regidos por este Acordo para outra pessoa transferindo-lhe, permanentemente, o computador pessoal no qual o Software est� instalado, contanto que voc� n�o retenha nenhuma c�pia do Software e que o receptor concorde com todos os termos deste Acordo. "
cTerAceite += PULALINHA
cTerAceite += STR0020			//"ATIVIDADES DE ALTO RISCO: O Software n�o � tolerante a falhas e n�o foi projetado, fabricado ou desenvolvido para uso em ambientes perigosos que requerem desempenho � prova de falhas, como na opera��o de instala��es nucleares, navega��o de aeronaves ou sistemas de comunica��o, controle de tr�fego a�reo, dispositivos m�dicos implantados em seres humanos, m�quinas externas de suporte � vida humana, "
cTerAceite += STR0021+PULALINHA	//"dispositivos de controle de explosivos, submarinos, sistemas de armas ou controle de opera��o de ve�culos motorizados nos quais a falha do Software poderia levar diretamente � morte, danos pessoais ou danos f�sicos ou ambientais graves ('Atividades de Alto Risco'). Voc� concorda em n�o usar o Software em Atividades de Alto Risco. "
cTerAceite += PULALINHA
cTerAceite += STR0022+PULALINHA	//"REN�NCIA �S GARANTIAS: A Microsiga n�o garante que o Software satisfar� suas exig�ncias, que a opera��o do mesmo ser� ininterrupta ou livre de erros, ou que todos os erros de Software ser�o corrigidos.  Todo o risco no que se refere � qualidade e ao desempenho do Software decorre por sua conta. "
cTerAceite += PULALINHA
cTerAceite += STR0023+PULALINHA	//"O SOFTWARE � FORNECIDO 'COMO EST�' E SEM GARANTIAS DE QUALQUER TIPO, EXPRESSAS OU IMPL�CITAS, INCLUINDO, MAS N�O SE LIMITANDO A, GARANTIAS DE T�TULOS, N�O-VIOLA��O, COMERCIALIZA��O E ADEQUA��O PARA UMA FINALIDADE EM PARTICULAR.  NENHUMA INFORMA��O OU CONSELHO VERBAL OU POR ESCRITO, FORNECIDOS PELA MICROSIGA, SEUS FUNCION�RIOS, DISTRIBUIDORES, REVENDEDORES OU AGENTES AUMENTAR�O O ESCOPO DAS GARANTIAS ACIMA OU CRIAR�O QUALQUER GARANTIA NOVA. "
cTerAceite += PULALINHA
cTerAceite += STR0024+PULALINHA	//"LIMITA��O DE RESPONSABILIDADE: MESMO QUE QUALQUER SOLU��O FORNECIDA NA GARANTIA FALHE EM SEU PROP�SITO ESSENCIAL, EM NENHUM EVENTO A MICROSIGA TER� OBRIGA��ES POR QUALQUER DANO ESPECIAL, CONSEQ�ENTE, INDIRETO OU SEMELHANTE, INCLUINDO PERDA DE LUCROS OU DADOS, DERIVADOS DO USO OU INABILIDADE DE USAR O SOFTWARE, OU QUAISQUER DADOS FORNECIDOS, MESMO QUE A MICROSIGA OU OUTRA PARTE TENHA SIDO AVISADA DA POSSIBILIDADE DE TAL DANO, OU EM QUALQUER REIVINDICA��O DE QUALQUER OUTRA PARTE. "
cTerAceite += PULALINHA
cTerAceite += STR0025+PULALINHA	//"ALGUMAS JURISDI��ES N�O PERMITEM A LIMITA��O OU EXCLUS�O DE RESPONSABILIDADE POR DANOS INCIDENTAIS OU CONSEQ�ENTES; PORTANTO, A LIMITA��O OU EXCLUS�O ACIMA PODE N�O SE APLICAR AO SEU CASO. "
cTerAceite += PULALINHA
cTerAceite += STR0026+PULALINHA	//"TERMO: Este Acordo � v�lido at� ser terminado.  Este Acordo terminar�, e a licen�a concedida a voc� por este Acordo ser� revogada, imediatamente, sem qualquer advert�ncia da Microsiga, se voc� n�o obedecer a qualquer disposi��o deste Acordo.  Ao t�rmino do mesmo, voc� dever� destruir o Software. "
cTerAceite += PULALINHA
cTerAceite += STR0027+PULALINHA	//"ACORDO INTEGRAL: Este Acordo constitui o acordo integral entre voc� e a Microsiga, no que se refere ao Software licenciado, e substitui todas as comunica��es, as representa��es, as compreens�es e os acordos anteriores, verbais ou por escrito, entre voc� e a Microsiga relativos a este Software.  Este Acordo n�o pode ser modificado ou renunciado, exceto por escrito e assinado por uma autoridade ou outro representante autorizado de cada parte."
cTerAceite += PULALINHA
cTerAceite += STR0028+PULALINHA	//"Se qualquer disposi��o for considerada inv�lida, todas as outras permanecer�o v�lidas, a menos que impe�a o prop�sito de nosso Acordo.  A falha de qualquer parte em refor�ar qualquer direito concedido neste documento, ou em entrar em a��o contra a outra parte no caso de qualquer viola��o, n�o ser� considerada uma desist�ncia � subseq�ente execu��o dos direitos ou � subseq�ente a��o no caso de futuras viola��es."

SET DELETED ON                                    

aLoadSM0 := FWLoadSM0()
For nX := 1 to Len(aLoadSM0)
	If !Empty(aLoadSM0[nX][1]) .And. aScan(aEmpr, {|x| x[2] == aLoadSM0[nX][1]}) == 0
		aAdd(aEmpr, {.F., aLoadSM0[nX][1], aLoadSM0[nX][6], aLoadSM0[nX][2], aLoadSM0[nX][7]})
	EndIf
Next

DEFINE DIALOG oDlgUpd TITLE STR0030 FROM 0, 0 TO 22, 75 SIZE 550, 350 PIXEL//"SIGAQIE - Update"
@ 000,000 BITMAP oBmp RESNAME 'Login' OF oDlgUpd SIZE 095, oDlgUpd:nBottom NOBORDER WHEN .F. PIXEL
@ 005,070 SAY oTitulo         VAR cTitulo OF oDlgUpd PIXEL FONT (TFont():New('Arial',0,-13,.T.,.T.))
@ 015,070 SAY oAcao           VAR cAcao   OF oDlgUpd PIXEL
@ 155,140 BUTTON oBtnCancelar PROMPT STR0031 SIZE 60,14 ACTION If(oBtnCancelar:cCaption == STR0031,oDlgUpd:End(),GravaLog(.T.,cLogUpdate,@lGravouLog)) OF oDlgUpd PIXEL//"Cancelar"
@ 155,210 BUTTON oBtnAvanca   PROMPT STR0032 SIZE 60,14 ACTION If(oBtnAvanca:cCaption  == STR0046,(GravaLog(.F.,cLogUpdate,lGravouLog),oDlgUpd:End()),SelePanel(@nTela)) OF oDlgUpd PIXEL//"Avancar" //"Finalizar"
oDlgUpd:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

oPanel1 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 002,005 SAY oApresenta VAR STR0033 OF oPanel1 FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL//"Bem-Vindo!"
@ 015,005 GET oMemo1     VAR cApresenta  OF oPanel1 MEMO PIXEL SIZE 180,100 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
oMemo1:lReadOnly := .T.

oPanel2 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 002,005 SAY oTerAceite VAR STR0034 OF oPanel2 FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL//"Leia com atencao!"
@ 015,005 GET oMemo2     VAR cTerAceite  OF oPanel2 MEMO PIXEL SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
@ 109,125 CheckBox oChkAceite VAR lConcordo PROMPT STR0035 SIZE 80,10 Of oPanel2 PIXEL //"Li e estou ciente."
oMemo2:lReadOnly   := .T.
oChkAceite:bChange := {|| Concordo(lConcordo)}

oPanel3 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )

oList := TWBrowse():New( 10, 07, 150, 65,,{ "", STR0036, STR0037 },,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"C�digo"##"Empresa"
oList:SetArray(aEmpr)
oList:bLine      := { || { If( aEmpr[oList:nAT,1], oOk, oNOK ), aEmpr[oList:nAt,2], aEmpr[oList:nAT,3] } }
oList:bLDblClick := { || aEmpr[oList:nAt,1] := !aEmpr[oList:nAt,1] } 
@ 095,005 GET oMemo3 VAR cEscEmp OF oPanel3 MEMO PIXEL SIZE 180,20 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
oMemo3:lReadOnly := .T.
                              
oPanel4 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 010,000 SAY oSay       VAR STR0038	OF oPanel4        PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.))//"Processamento total do ajuste:"
@ 050,000 SAY oItemAju   VAR cItemAju	OF oPanel4        PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.))
@ 037,000 SAY oAtuTotal  VAR Space(40)	OF oPanel4        PIXEL
@ 077,000 SAY oAtuParc1  VAR Space(40)	OF oPanel4        PIXEL
@ 087,000 SAY oAtuParc2  VAR Space(40)	OF oPanel4        PIXEL
@ 097,000 SAY oAtuParc3  VAR Space(40)	OF oPanel4        PIXEL
@ 020,000 METER oMtTotal VAR nAtuTotal /*TOTAL 1000*/  SIZE 190, 15 OF oPanel4 UPDATE PIXEL
@ 060,000 METER oMtParci VAR nAtuParci /*TOTAL 1000*/  SIZE 190, 15 OF oPanel4 UPDATE PIXEL

oPanel5 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 002,005 SAY oLogUpdate VAR STR0039	OF oPanel5 FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL//"Atualiza��es realizadas:"
@ 015,005 GET oMemo4     VAR cLogUpdate	OF oPanel5 MEMO PIXEL SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
oMemo4:lReadOnly   := .T.

ACTIVATE DIALOG oDlgUpd CENTER ON INIT SelePanel(@nTela)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | SelePanel � Autor � Microsiga         � Data �  01.22.07   ���
�������������������������������������������������������������������������͹��
���Descricao � Controla a atualizacao das interfaces visuais              ���
�������������������������������������������������������������������������͹��
���Uso       � AJTQIE04                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function SelePanel(nTela)
Local lRet := .T.
//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
oTitulo:nLeft           := 120; oTitulo:Refresh()
oAcao:nLeft             := 120; oAcao:Refresh()
oBmp:lVisibleControl    := .T.
oPanel1:lVisibleControl := .F.
oPanel2:lVisibleControl := .F.
oPanel3:lVisibleControl := .F.
oPanel4:lVisibleControl := .F.
oPanel5:lVisibleControl := .F.
                                       
Do Case
	Case nTela == 0 //-- Apresentacao
		oPanel1:lVisibleControl := .T.
	Case nTela == 1 //-- Termo de aceite
		oPanel2:lVisibleControl := .T.
		oBtnAvanca:lActive      := .F.
	Case nTela == 2 //-- Selecao da empresa
		oPanel3:lVisibleControl := .T.
	Case nTela == 3 //-- Execucao do ajuste
	   If (aScan(aEmpr,{|x| x[1]}) > 0)
			cAcao                   := STR0040; oAcao:Refresh()	   		//"Execucao do ajuste"
			oPanel4:lVisibleControl := .T.
			oBtnCancelar:lActive    := .F. //-- A partir deste ponto nao pode mais ser cancelado
			oBtnAvanca:lActive      := .F.
			AjustaQIE()
			cItemAju                := STR0041; oItemAju:Refresh()		//"Processamento parcial do ajuste:" 
			oAtuTotal:cCaption      := STR0042; oAtuTotal:Refresh()		//"Ajuste finalizado!"
			oAtuParc1:cCaption      := STR0043; oAtuParc1:Refresh()		//"Ajuste das tabelas finalizado!"
			oAtuParc2:cCaption      := ''; oAtuParc2:Refresh()
			oAtuParc3:cCaption      := ''; oAtuParc3:Refresh()
			oBtnAvanca:lActive      := .T.
		Else
			lRet := .F.
			oPanel3:lVisibleControl := .T.
			Alert(STR0044)//"Selecione a empresa"
		EndIf
	Case nTela == 4
		cAcao                   := STR0042; oAcao:Refresh()//"Ajuste finalizado!"
		oPanel5:lVisibleControl := .T.
		oBtnCancelar:cCaption   := STR0045	//"&Salvar Log"
		oBtnCancelar:lActive    := .T.
		oBtnAvanca:cCaption     := STR0046	//"&Finalizar"
EndCase

If lRet
	nTela ++
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � AjustaQIE � Autor �Paulo Fco. Cruz Neto	� Data � 19.02.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao principal do AJT						              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AJTQIE04                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AjustaQIE()
Local aFilSB8    := {}
Local aFilSD5    := {}
Local aFilSBJ    := {}
Local aRecnoSM0  := {}
Local aRecnoSX7  := {}
Local cTexto     := ''
Local lRet       := .T.
Local lIncluiSX7 := .F.
Local nX         := 0
Local nEmp       := 0
Local lFirst     := .T.
Local aArrPV	 := {}
Local cJaProc    := ""

Private __LPYME    := .F.
Private cModulo    := 'QIE'
Private lMsFinalAut:= .F.
Private nModulo    := 21 //SIGAQIE
Private oMemoLog

For nEmp := 1 to Len(aEmpr)
	If aEmpr[nEmp,1]//Verifica se a empresa deve ser atualizada
		cEmpAtu := aEmpr[nEmp,2]

		If !Empty(aEmpr[nEmp][2])
			oAtuParc3:cCaption := STR0048+AllTrim(aEmpr[nEmp][2]+' - '+aEmpr[nEmp][3])//"Executando compatibilizador para a empresa: "  
		
			MsgRun(STR0049+AllTrim(aEmpr[nEmp][2]+' - '+aEmpr[nEmp][3])+'...',STR0050,{|| CursorWait(), AbreEmpre(aEmpr[nEmp][2], aEmpr[nEmp][4], cModulo) ,CursorArrow()})//"Inicializando ambiente para a empresa "##"Aguarde..."
			
			cFilAnt := aEmpr[nEmp][4]	//-- Seta para a filial atual a variavel utilizada pela funcao xFilial()
			lMsHelpAuto := .F.			//-- Seta variavel para forcar a exibicao dos HELPs na tela
			
			//�����������������������
			//� LOG - Secao inicial �          
			//�����������������������
			If lFirst
				cTexto += STR0051+DtoC(Date())+STR0052+SubStr(Time(), 1, 5)+PULALINHA//>> Ajuste iniciado em "##", as "
				cTexto += PULALINHA
				cTexto += STR0053+"AJTQIE04"+PULALINHA//"LOG do update " 
				lFirst := .F.
			EndIf
			cTexto += '======================'+PULALINHA
			cTexto += STR0054+AllTrim(aEmpr[nEmp][2]+' - '+aEmpr[nEmp][3])	//"Empresa: "
			cTexto += PULALINHA+PULALINHA
			cTexto += STR0055	//"Resultado final da execu��o do UPD:"
			cTexto += PULALINHA+PULALINHA
			
			oAtuTotal:cCaption := STR0056	//"Atualizando..."
			cTexto += AtuQIE()
			
			//����������������������������������                                          
			//� LOG - Secao referente a filial �
			//����������������������������������
			cTexto += STR0057+AllTrim(aEmpr[nEmp][4]+' - '+aEmpr[nEmp][5])+PULALINHA//"*Ajuste feito nas tabelas da empresa "
			cTexto += PULALINHA
				
			MsgRun(STR0058+AllTrim(aEmpr[nEmp][2]+'-'+aEmpr[nEmp][3]),STR0050,{|| RpcClearEnv()})//"Aguarde... Finalizando Ambiente da Empresa "##"Aguarde..."
		EndIf
	EndIf
Next nEmp

//�����������������������Ŀ
//� Exibe o LOG do ajuste �
//�������������������������
cLogUpdate := cTexto

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | AbreEmpre � Autor � Microsiga         � Data �  01.18.07   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao que abre conexao para a empresa selecionada         ���
�������������������������������������������������������������������������͹��
���Parametros� cCodEmp: Codigo da empresa								  ���
���			 � cCodFil: Codigo da filial								  ���
���			 � cModulo: Modulo								  			  ���
�������������������������������������������������������������������������͹��
���Uso       � AJTQIE04                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AbreEmpre(cCodEmp, cCodFil, cModulo)

RpcSetType(3) //-- Nao consome licensas
RpcSetEnv(cCodEmp, cCodFil,,,cModulo) //-- Inicializa as variaveis genericas e abre a empresa/filial

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | Concordo � Autor � Microsiga          � Data �  01.18.07   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para controlar a marcacao do checkbox				  ���
�������������������������������������������������������������������������͹��
���Parametros� lConcordo: indica se o checkbox esta marcado ou nao		  ���
�������������������������������������������������������������������������͹��
���Uso       � AJTQIE04                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Concordo(lConcordo)

If lConcordo
	oBtnAvanca:lActive := .T.
Else
	oBtnAvanca:lActive := .F.
EndIf

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  | GravaLog � Autor � Microsiga          � Data �  01.26.07   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao para gerar o arquivo de log do update.			  ���
�������������������������������������������������������������������������͹��
���Parametros� lSalvaUsu: indica se abre dialog para o usuario digitar	  ���
���			 � cTexto: texto a ser gravado no arquivo					  ���
���			 � lRet: indica se o log ja foi gerado pelo usuario			  ���
�������������������������������������������������������������������������͹��
���Uso       � AJTQIE04                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function GravaLog(lSalvaUsu, cTexto, lRet)
Local cFile  := ''
Local cMask	 := STR0059	//"Arquivos de Log (*.LOG) |*.log|"
Local nOcorr := 0

If !lRet
	If lSalvaUsu
		cFile := cGetFile(cMask, '')
	EndIf	
	If Empty(cFile)
		cFile := 'QIE04'+Right(CriaTrab(, .F.), 3)+'.LOG'
		Do While File(cFile)
			cFile := 'QIE04'+Right(CriaTrab(, .F.), 3)+'.LOG'
		EndDo
		nOcorr := 1
	ElseIf !(Upper(Right(cFile, 3))=='.LOG')	
		cFile += '.LOG'
		nOcorr := 2
	EndIf
	
	lRet := MemoWrite(cFile, cTexto)
	
	If nOcorr == 1
		Aviso('AJTQIE04', STR0060+cFile+'.' , {'Ok'})//"Este LOG foi salvo automaticamente como "##.
	ElseIf nOcorr == 2
		Aviso('AJTQIE04', STR0061+cFile+').', {'Ok'})//"A extencao '.LOG' foi adicionada ao arquivo, que foi salvo do diretorio escolhido ("
	EndIf
EndIf	

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � QIEAtu    � Autor � Paulo Fco. Cruz Neto � Data � 19.02.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza os dados das tabelas QER e QEL	                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � AJTQIE04                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AtuQIE()
Local cTexto  	:= ""
Local cNota		:= "" // Numero da Nota
Local cSerItem	:= "" // Serie + Item
Local cIndice	:= ""

//Local nI		:= 0
Local nQEL		:= 0
Local nQER		:= 0
Local nTamNF	:= TamSx3("QEK_NTFISC")[1]
Local nTamSerIt	:= SerieNfId('QEK',6,"QEK_SERINF")+ TamSx3("QEK_ITEMNF")[1] // Tamanho dos campos Serie + Item
Local nIndice	:= 0

Local aItens	:= {}

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
nAtuTotal := 0
nAtuParci := 0
oMtTotal:nTotal := 2
oMtParci:nTotal := 1

dbSelectArea("QEL")
dbSelectArea("QER")
dbSelectArea("QEK")

cIndice := CriaTrab(Nil,.F.)

#IFDEF TOP
	nIndice := RetIndex("QEK") + 1
#ELSE
	nIndice := 1
#ENDIF

IndRegua("QEK",cIndice,"QEK_FILIAL+QEK_FORNEC+QEK_LOJFOR+QEK_PRODUT+QEK_NTFISC+QEK_SERINF+QEK_ITEMNF+DTOS(QEK_DTENTR)+QEK_LOTE")

#IFNDEF TOP
	QEK->(DbSetIndex(cIndice+OrdBagExt()))
#ENDIF

QEK->(DbSetOrder(nIndice))

//����������������������������������Ŀ
//� Atualizando a tabela QEL         �
//������������������������������������
QEL->(dbGoTop())

While QEL->(!Eof())
	If !Empty(QEL->QEL_NISERI)
		If QEK->(!DbSeek(xFilial("QEK")+QEL->(QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+QEL_NISERI+DTOS(QEL_DTENTR)+QEL_LOTE)))
		
			cNota	:= AllTrim(QEL->QEL_NISERI)

			If Len(cNota) < 13
				cNota := PadR(cNota,13)
			EndIf
			
			cSerItem:= SubStr(cNota,(Len(cNota)-nTamSerIt)+1,Len(cNota))
			cNota	:= SubStr(cNota,1,Len(cNota)-nTamSerIt)
			cNota	:= PadR(cNota,nTamNF)
			cNota	:= cNota + cSerItem
			
			If QEK->(DbSeek(xFilial("QEK")+QEL->(QEL_FORNEC+QEL_LOJFOR+QEL_PRODUT+cNota+DTOS(QEL_DTENTR)+QEL_LOTE)))
				
				RecLock("QEL",.F.)
				QEL->QEL_NISERI := cNota + cSerItem
				QEL->(MsUnlock())
				
				nQEL += 1
				
			Else
				aAdd(aItens,{"QEL",QEL->(Recno())})
			EndIf
		EndIf
	EndIf
	
	QEL->(DbSkip())
EndDo

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
oMtParci:Set(++nAtuParci); SysRefresh()
oMtTotal:Set(++nAtuTotal); SysRefresh()
nAtuParci := 0

//����������������������������������Ŀ
//� Atualizando a tabela QER         �
//������������������������������������
QER->(dbGoTop())

While QER->(!Eof())
	If !Empty(QER->QER_NISERI)
		If QEK->(!DbSeek(xFilial("QEK")+QER->(QER_FORNEC+QER_LOJFOR+QER_PRODUT+QER_NISERI+DTOS(QER_DTENTR)+QER_LOTE)))
		
			cNota	:= AllTrim(QER->QER_NISERI)

			If Len(cNota) < 13
				cNota := PadR(cNota,13)
			EndIf
			
			cSerItem:= SubStr(cNota,(Len(cNota)-nTamSerIt)+1,Len(cNota))
			cNota	:= SubStr(cNota,1,Len(cNota)-nTamSerIt)
			cNota	:= PadR(cNota,nTamNF)
			cNota	:= cNota + cSerItem
			
			If QEK->(DbSeek(xFilial("QEK")+QER->(QER_FORNEC+QER_LOJFOR+QER_PRODUT+cNota+DTOS(QER_DTENTR)+QER_LOTE)))
				
				RecLock("QER",.F.)
				QER->QER_NISERI := cNota + cSerItem
				QER->(MsUnlock())
				
				nQER += 1
				
			Else
				aAdd(aItens,{"QER",QER->(Recno())})
			EndIf
		EndIf
	EndIf
	
	QER->(DbSkip())
EndDo

//����������������������������������������Ŀ
//� Atualiza variaveis da janela principal �
//������������������������������������������
oMtParci:Set(++nAtuParci); SysRefresh()
oMtTotal:Set(++nAtuTotal); SysRefresh()

cTexto += STR0062 + AllTrim(Str(nQEL)) + ' ' + STR0063 + PULALINHA	//"Foram atualizados "##" registros na tabela QEL
cTexto += STR0062 + AllTrim(Str(nQER)) + ' ' + STR0064 + PULALINHA	//"Foram atualizados "##" registros na tabela QER
cTexto += PULALINHA
/*
If !Empty(aItens)
	ConOut(OemToAnsi("Itens N�o Tratados"))
	ConOut(OemToAnsi("TAB - RECNO"))
	For nI := 1 To Len(aItens)
		ConOut(OemToAnsi(aItens[nI,1]+" - "+Str(aItens[nI,2])))
	Next
	ConOut(OemToAnsi(Replicate("*",10)))	
EndIf
*/
Return cTexto