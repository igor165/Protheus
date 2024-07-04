#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "UPDEST45.CH"

#DEFINE PULALINHA CHR(13)+CHR(10)

//------------------------------------------------------
/*/{Protheus.doc} UDCLES06 
Update para migrar o conteúdo das tabelas do Template DCL para as novas tabelas no produto padrão
Após realizada tal migração, o processo é irreversível
@author jose.eulalio
@version P12
@since 15/03/2014
/*/
//------------------------------------------------------
User Function UDCLES06()

Local lGravouLog     := .F.
Local oOk            := LoadBitmap( GetResources(), "LBOK" )
Local oNOk           := LoadBitmap( GetResources(), "LBNO" )
Local oList

Private __cInterNet    := Nil
Private aArqUpd        := {}
Private aEmpr           := {}

Private cTitulo        := "Update UDCLES06" //STR0001    //"Update UPDEST45"
Private cAcao          := "Migração do Template DCL" //STR0002    //"Ajuste do módulo de Estoque e Custos"
Private cItemAju       := STR0003    //"Andamento do ajuste de cada tabela:"
Private cEscEmp        := STR0004    //"Atenção: Para que o Ajuste possa ser efetuado NENHUM usuario pode estar utilizando o sistema!"
Private cArqEmp        := 'SIGAMAT.EMP'
Private cApresenta     := ''
Private cTerAceite     := ''
Private cLogUpdate     := ''
Private cEmpAtu        := ''

Private lConcordo      := .F.

Private nTela          := 0
Private nAtuTotal      := 0
Private nAtuParci      := 0

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
                                             
If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

cApresenta := "A rotina de atualização irá ajustar o dicionário de dados para migração dos dados do Template DCL para o produto padrão. As novas tabelas referentes ao DCL estão disponíveis a partir da versão 12.1.16 do Protheus. Estas novas tabelas deverão estar com seu conteúdo vazio, ou seja, sem registros para que os dados sejam migrados com sucesso." + PULALINHA    //
cApresenta += PULALINHA

cTerAceite := STR0006+PULALINHA    //"Antes que sua atualização inicie, você deve ler e aceitar os termos e as condições a seguir. Após aceitá-los, você pode prosseguir com a atualização."
cTerAceite += PULALINHA
cTerAceite += STR0007+PULALINHA    //"ATENÇÃO: LEIA COM ATENÇÃO ANTES DE PROSSEGUIR COM A ATUALIZAÇÃO"
cTerAceite += PULALINHA
cTerAceite += STR0008+PULALINHA    //"ACORDO DE LICENÇA DE SOFTWARE PARA USUÁRIO FINAL ('ACORDO')"
cTerAceite += PULALINHA
cTerAceite += STR0009+PULALINHA    //"TERMOS E CONDIÇÕES"
cTerAceite += PULALINHA
cTerAceite += STR0010+PULALINHA    //"ADVERTÊNCIAS LEGAIS: AO CLICAR NA OPÇÃO 'SIM, LI E ACEITO O TERMO ACIMA' NO FINAL DESTA JANELA, VOCÊ INDICA QUE LEU E CONCORDOU COM TODOS OS TERMOS DESTE ACORDO E QUE CONSENTE EM SER REGIDO POR ESTE ACORDO E TORNAR-SE PARTE DELE.  A TOTVS ESTÁ DISPOSTA A DISPONIBILIZAR ESTE AJUSTE PARA VOCÊ APENAS SOB A CONDIÇÃO DE QUE VOCÊ CONCORDE COM TODOS OS TERMOS CONTIDOS NESTE ACORDO.  SE VOCÊ NÃO CONCORDA COM TODOS OS TERMOS DESTE ACORDO, CLIQUE NO BOTÃO 'CANCELAR' E NÃO PROSSIGA COM O AJUSTE."
cTerAceite += PULALINHA
cTerAceite += STR0011+PULALINHA    //"O ACORDO A SEGUIR É UM ACORDO LEGAL ENTRE VOCÊ (O USUÁRIO FINAL, SEJA UM INDIVÍDUO OU ENTIDADE), E A TOTVS S/A. (PROPRIAMENTE DITA OU SUAS LICENCIADAS). "
cTerAceite += PULALINHA
cTerAceite += STR0012+PULALINHA    //"ESTE SOFTWARE É LICENCIADO PELA TOTVS PARA VOCÊ, E QUALQUER RECEPTOR SUBSEQÜENTE DO SOFTWARE, SOMENTE PARA USO SEGUNDO OS TERMOS ESTABELECIDOS NESTE DOCUMENTO. "
cTerAceite += PULALINHA
cTerAceite += STR0013            //"PREMISSAS DE UTILIZAÇÃO: Antes de executar esta rotina é obrigatória a realização de uma cópia de segurança geral do sistema Protheus (binário, RPO, dicionários SXs e banco de dados). Faça testes de performance e planeje-se antes de executar esta atualização, pois ela requer acesso exclusivo às tabelas do sistema (ou seja: nenhum usuário poderá acessar o sistema) "
cTerAceite += STR0014+PULALINHA    //"durante toda a sua execução, que pode demorar várias horas para ser finalizada! Depois de iniciada esta rotina não poderá ser interrompida! Qualquer tipo de interrupção (ex.: falta de energia, problemas de hardware, problemas de rede, etc.) poderá danificar todo o sistema! Neste caso deve-se realizar a restauração da cópia de segurança feita imediatamente antes do inicio da atualização antes de executá-la novamente."
cTerAceite += PULALINHA
cTerAceite += STR0015+PULALINHA    //"CONCESSÃO DE LICENÇA: A TOTVS lhe concede uma licença limitada, não-exclusiva e revogável para usar a versão de código executável da Atualização do módulo de gestão de contratos denominada UPDEST45, eximindo-se de qualquer dado resultante da utilização deste."
cTerAceite += PULALINHA
cTerAceite += STR0016+PULALINHA    //"DIREITOS AUTORAIS: O Software é propriedade da TOTVS e está protegido por leis de direitos autorais do Brasil e disposições de tratados internacionais.  Você reconhece que não lhe será transferido qualquer direito a qualquer propriedade intelectual do Software. "
cTerAceite += PULALINHA
cTerAceite += STR0017            //"LIMITAÇÕES: Exceto se explicitamente disposto em contrário neste Acordo, você não pode: a) modificar o Software ou criar trabalhos derivados do mesmo; b) descompilar, desmontar, fazer engenharia reversa, ou de outras maneiras tentar alterar o código-fonte do Software; c) copiar (exceto para fazer uma cópia de backup), redistribuir, impedir, vender, alugar, arrendar, sublicenciar, atribuir ou de outras maneiras transferir seus direitos ao Software; ou "
cTerAceite += STR0018+PULALINHA    //"d) remover ou alterar qualquer marca registrada, logotipo, registro ou outras advertências proprietárias no Software.  Você pode transferir todos os seus direitos ao Software regidos por este Acordo para outra pessoa transferindo-lhe, permanentemente, o computador pessoal no qual o Software está instalado, contanto que você não retenha nenhuma cópia do Software e que o receptor concorde com todos os termos deste Acordo. "
cTerAceite += PULALINHA
cTerAceite += STR0019            //"ATIVIDADES DE ALTO RISCO: O Software não é tolerante a falhas e não foi projetado, fabricado ou desenvolvido para uso em ambientes perigosos que requerem desempenho à prova de falhas, como na operação de instalações nucleares, navegação de aeronaves ou sistemas de comunicação, controle de tráfego aéreo, dispositivos médicos implantados em seres humanos, máquinas externas de suporte à vida humana, "
cTerAceite += STR0020+PULALINHA    //"dispositivos de controle de explosivos, submarinos, sistemas de armas ou controle de operação de veículos motorizados nos quais a falha do Software poderia levar diretamente à morte, danos pessoais ou danos físicos ou ambientais graves ('Atividades de Alto Risco'). Você concorda em não usar o Software em Atividades de Alto Risco. "
cTerAceite += PULALINHA
cTerAceite += STR0021+PULALINHA    //"RENÚNCIA ÀS GARANTIAS: A TOTVS não garante que o Software satisfará suas exigências, que a operação do mesmo será ininterrupta ou livre de erros, ou que todos os erros de Software serão corrigidos.  Todo o risco no que se refere à qualidade e ao desempenho do Software decorre por sua conta. "
cTerAceite += PULALINHA
cTerAceite += STR0022+PULALINHA    //"O SOFTWARE É FORNECIDO 'COMO ESTÁ' E SEM GARANTIAS DE QUALQUER TIPO, EXPRESSAS OU IMPLÍCITAS, INCLUINDO, MAS NÃO SE LIMITANDO A, GARANTIAS DE TÍTULOS, NÃO-VIOLAÇÃO, COMERCIALIZAÇÃO E ADEQUAÇÃO PARA UMA FINALIDADE EM PARTICULAR.  NENHUMA INFORMAÇÃO OU CONSELHO VERBAL OU POR ESCRITO, FORNECIDOS PELA TOTVS, SEUS FUNCIONÁRIOS, DISTRIBUIDORES, REVENDEDORES OU AGENTES AUMENTARÃO O ESCOPO DAS GARANTIAS ACIMA OU CRIARÃO QUALQUER GARANTIA NOVA. "
cTerAceite += PULALINHA
cTerAceite += STR0023+PULALINHA    //"LIMITAÇÃO DE RESPONSABILIDADE: MESMO QUE QUALQUER SOLUÇÃO FORNECIDA NA GARANTIA FALHE EM SEU PROPÓSITO ESSENCIAL, EM NENHUM EVENTO A TOTVS TERÁ OBRIGAÇÕES POR QUALQUER DANO ESPECIAL, CONSEQÜENTE, INDIRETO OU SEMELHANTE, INCLUINDO PERDA DE LUCROS OU DADOS, DERIVADOS DO USO OU INABILIDADE DE USAR O SOFTWARE, OU QUAISQUER DADOS FORNECIDOS, MESMO QUE A TOTVS OU OUTRA PARTE TENHA SIDO AVISADA DA POSSIBILIDADE DE TAL DANO, OU EM QUALQUER REIVINDICAÇÃO DE QUALQUER OUTRA PARTE. "
cTerAceite += PULALINHA
cTerAceite += STR0024+PULALINHA    //"ALGUMAS JURISDIÇÕES NÃO PERMITEM A LIMITAÇÃO OU EXCLUSÃO DE RESPONSABILIDADE POR DANOS INCIDENTAIS OU CONSEQÜENTES; PORTANTO, A LIMITAÇÃO OU EXCLUSÃO ACIMA PODE NÃO SE APLICAR AO SEU CASO. "
cTerAceite += PULALINHA
cTerAceite += STR0025+PULALINHA    //"TERMO: Este Acordo é válido até ser terminado.  Este Acordo terminará, e a licença concedida a você por este Acordo será revogada, imediatamente, sem qualquer advertência da TOTVS, se você não obedecer a qualquer disposição deste Acordo.  Ao término do mesmo, você deverá destruir o Software. "
cTerAceite += PULALINHA
cTerAceite += STR0026+PULALINHA    //"ACORDO INTEGRAL: Este Acordo constitui o acordo integral entre você e a TOTVS, no que se refere ao Software licenciado, e substitui todas as comunicações, as representações, as compreensões e os acordos anteriores, verbais ou por escrito, entre você e a TOTVS relativos a este Software.  Este Acordo não pode ser modificado ou renunciado, exceto por escrito e assinado por uma autoridade ou outro representante autorizado de cada parte."
cTerAceite += PULALINHA
cTerAceite += STR0027+PULALINHA    //"Se qualquer disposição for considerada inválida, todas as outras permanecerão válidas, a menos que impeça o propósito de nosso Acordo.  A falha de qualquer parte em reforçar qualquer direito concedido neste documento, ou em entrar em ação contra a outra parte no caso de qualquer violação, não será considerada uma desistência à subseqüente execução dos direitos ou à subseqüente ação no caso de futuras violações."

SET DELETED ON

//Abre o arquivo de Empresas de forma compartilhada ³
If !OpenSM0(.T.)
    Final(STR0028)//"SIGAMAT.EMP com problemas!" 
EndIf
SM0->(DbGotop())
Do While ! SM0->(Eof())
    If !Empty(SM0->M0_CODIGO) .And. aScan(aEmpr, {|x| x[2] == SM0->M0_CODIGO}) == 0
        aAdd(aEmpr, {.F.,SM0->M0_CODIGO,SM0->M0_NOME})
    EndIf
    SM0->(DbSkip())
EndDo

//DIALOG PRINCIPAL
DEFINE DIALOG oDlgUpd TITLE STR0029 FROM 0, 0 TO 22, 75 SIZE 550, 350 PIXEL//"SIGAEST - Update"
@ 000,000 BITMAP oBmp RESNAME 'Login' OF oDlgUpd SIZE 120, oDlgUpd:nBottom NOBORDER WHEN .F. PIXEL
@ 005,070 SAY oTitulo         VAR cTitulo OF oDlgUpd PIXEL FONT (TFont():New('Arial',0,-13,.T.,.T.))
@ 015,070 SAY oAcao           VAR cAcao   OF oDlgUpd PIXEL
@ 155,140 BUTTON oBtnCancelar PROMPT STR0030  SIZE 60, 14 ACTION If(oBtnCancelar:cCaption==STR0030  , oDlgUpd:End(), GravaLog(.T., cLogUpdate, @lGravouLog))                          OF oDlgUpd PIXEL    //"Cancelar"
@ 155,210 BUTTON oBtnAvanca   PROMPT STR0031  SIZE 60, 14 ACTION If(oBtnAvanca:cCaption  =='&Finalizar' , (GravaLog(.F., cLogUpdate, lGravouLog), oDlgUpd:End()), SelePanel(@nTela)) OF oDlgUpd PIXEL        //"Avancar"
oDlgUpd:nStyle := nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PAINEL 1                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel1 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 002,005 SAY oApresenta VAR STR0032     OF oPanel1                             FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL//"Bem-Vindo!"
@ 015,005 GET oMemo1     VAR cApresenta OF oPanel1 MEMO PIXEL SIZE 180,100    FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
oMemo1:lReadOnly := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PAINEL 2                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel2 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 002,005 SAY oTerAceite         VAR STR0033     OF oPanel2                             FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL//"Leia com atencao!"
@ 015,005 GET oMemo2             VAR cTerAceite  OF oPanel2 MEMO PIXEL     SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
@ 107,107 CheckBox oChkAceite     VAR lConcordo PROMPT STR0034             SIZE 80,10 Of oPanel2 PIXEL//"Sim, li e aceito o termo acima."
oMemo2:lReadOnly   := .T.
oChkAceite:bChange := {|| Concordo(lConcordo)}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PAINEL 3                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel3 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
oList := TWBrowse():New( 15, 10, 170, 65,,{ "", STR0080, STR0081 },,oPanel3,,,,,,,,,,,,.F.,,.T.,,.F.,,,)//"Código"##"Empresa"
oList:SetArray(aEmpr)
oList:bLine      := { || { If( aEmpr[oList:nAT,1], oOk, oNOk ), aEmpr[oList:nAt,2], aEmpr[oList:nAT,3] } }
oList:bLDblClick := { || aEmpr[oList:nAt,1] := !aEmpr[oList:nAt,1] } 

@ 080,005 GET oMemo3 VAR cEscEmp          OF oPanel3 MEMO PIXEL SIZE 180,80 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
oMemo3:lReadOnly := .T.
                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PAINEL 4                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel4 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 010,000 SAY oSay       VAR STR0036                              OF oPanel4        PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.))//"Atualizações Realizadas:" 
@ 050,000 SAY oItemAju   VAR cItemAju                           OF oPanel4        PIXEL FONT (TFont():New('Arial',0,-11,.T.,.T.))
@ 037,000 SAY oAtuTotal  VAR Space(40)                          OF oPanel4        PIXEL
@ 077,000 SAY oAtuParc1  VAR Space(40)                          OF oPanel4        PIXEL
@ 087,000 SAY oAtuParc2  VAR Space(40)                          OF oPanel4        PIXEL
@ 097,000 SAY oAtuParc3  VAR Space(40)                          OF oPanel4        PIXEL
@ 020,000 METER oMtTotal VAR nAtuTotal TOTAL 1000  SIZE 190, 15    OF oPanel4 UPDATE PIXEL
@ 060,000 METER oMtParci VAR nAtuParci TOTAL 1000  SIZE 190, 15    OF oPanel4 UPDATE PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PAINEL 5                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel5 := TPanel():New( 028, 072, ,oDlgUpd, , , , , , 200, 120, .F.,.T. )
@ 002,005 SAY oLogUpdate VAR STR0037     OF oPanel5                          FONT (TFont():New('Arial',0,-13,.T.,.T.))PIXEL//"Atualizações realizadas:"
@ 015,005 GET oMemo4     VAR cLogUpdate    OF oPanel5 MEMO PIXEL SIZE 180,90 FONT (TFont():New('Verdana',,-12,.T.)) NO BORDER
oMemo4:lReadOnly   := .T.

ACTIVATE DIALOG oDlgUpd CENTER ON INIT SelePanel(@nTela)

Return Nil

//------------------------------------------------------
/*/{Protheus.doc} SelePanel
Funcao utilizada para selecao atraves de painel
@version P12
@since 03/03/09
/*/
//------------------------------------------------------
Static Function SelePanel(nTela)
Local lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza variaveis da janela principal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
            cAcao                   := STR0038; oAcao:Refresh()//"Execucao do ajuste"
            oPanel4:lVisibleControl := .T.
            oBtnCancelar:lActive    := .F. //-- A partir deste ponto nao pode mais ser cancelado
            oBtnAvanca:lActive      := .F.
            AjustaTabs()
            cItemAju                := STR0039; oItemAju:Refresh()    //"Andamento do ajuste de cada tabela:" 
            oAtuTotal:cCaption      := STR0040; oAtuTotal:Refresh()    //"Ajuste finalizado!"
            oAtuParc1:cCaption      := STR0041; oAtuParc1:Refresh()    //"Ajuste das tabelas finalizado!"
            oAtuParc2:cCaption      := ''; oAtuParc2:Refresh()
            oAtuParc3:cCaption      := ''; oAtuParc3:Refresh()
            oBtnAvanca:lActive      := .T.
        Else
            lRet := .F.
            oPanel3:lVisibleControl := .T.
            Alert(STR0082)//"Selecione a empresa"
        EndIf
    Case nTela == 4
        cAcao                   := STR0040; oAcao:Refresh()    //"Ajuste finalizado!"
        oPanel5:lVisibleControl := .T.
        oBtnCancelar:cCaption   := STR0042    //"&Salvar Log"
        oBtnCancelar:lActive    := .T.
        oBtnAvanca:cCaption     := STR0043    //"&Finalizar"
EndCase

If lRet
    nTela ++
EndIf

Return Nil

//------------------------------------------------------
/*/{Protheus.doc} AjustaTabs
Funcao de processamento do ajuste das tabelas 
@version P12
@since 03/03/09
/*/
//------------------------------------------------------
Static Function AjustaTabs()

Local cTexto     := ''
Local lRet       := .T.
Local lFirst     := .T.
Local nX         := 0
Local nEmp       := 0

Private cModulo    := 'EST'
Private lMsFinalAut:= .F.
Private nModulo    := 4 //-- SIGAEST
Private oMemoLog


For nEmp:=1 to len(aEmpr)
    If aEmpr[nEmp,1]    //Verifica se a empresa deve ser atualizada
        cEmpAtu := aEmpr[nEmp,2]

        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Atualiza variaveis da janela principal ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        nAtuTotal       := 0
        oMtTotal:nTotal := 3
        
        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        //³ Abre o arquivo de Empresas de forma exclusiva e alimenta array com todas as Filiais que terao o ajuste processado ³
        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        If !OpenSM0(.F.)
            Final(STR0044)//"SIGAMAT.EMP em uso!"
        EndIf

        SM0->(dbGotop())
        Do While !SM0->(Eof())
            If SM0->M0_CODIGO == SubStr(cEmpAtu,1,2)
                Exit
            EndIf
            SM0->(dbSkip())
        EndDo
        
        If !Empty(SM0->M0_CODIGO)
            oAtuParc3:cCaption := STR0078+AllTrim(SM0->M0_CODIGO+' - '+SM0->M0_NOME)//"Executando compatibilizador para a empresa: "  
        
            MsgRun(STR0045+AllTrim(SM0->M0_CODIGO+' - '+SM0->M0_NOME)+'...',STR0046,{|| CursorWait(), AbreEmpre(SM0->M0_CODIGO, SM0->M0_CODFIL, cModulo) ,CursorArrow()})    
               
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ LOG - Secao inicial ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            If lFirst
                cTexto += STR0047+DtoC(Date())+STR0048+SubStr(Time(), 1, 5)+PULALINHA
                cTexto += PULALINHA
                cTexto += "LOG do update UDCLES06" + PULALINHA//"LOG do update UPDEST43" 
                cTexto += '======================'+PULALINHA
                lFirst := .F.
            EndIf
            cTexto += PULALINHA
            cTexto += AllTrim(SM0->M0_CODIGO+' - '+SM0->M0_NOME)
            cTexto += PULALINHA
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Atualizando Dicionario SX3              ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            oAtuTotal:cCaption := STR0052
            cLogUpdate := cTexto
            cTexto += UpdDclEs06(cTexto) + PULALINHA
            oMtTotal:Set(++nAtuTotal); SysRefresh()
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Atualizando Estrutura do banco de dados ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            oAtuTotal:cCaption := STR0054
            If Len(aArqUpd) > 0
                nAtuParci       := 1
                oMtParci:nTotal := Len(aArqUpd)+1
            Else
                oMtParci:nTotal := 2
                oMtParci:Set(++nAtuParci); SysRefresh()
            EndIf
            __SetX31Mode(.F.)
            cTexto += STR0055+PULALINHA//"Atualizado estrutura física dos arquivos:"
            For nX := 1 To Len(aArqUpd)
                oMtParci:Set(++nAtuParci)
                oAtuParc1:cCaption := STR0056+aArqUpd[nX]//"Atualizando estrutura física do arquivo "  
                cTexto += aArqUpd[nX]+PULALINHA
                If Select(aArqUpd[nX])>0
                    dbSelecTArea(aArqUpd[nX])
                    dbCloseArea()
                EndIf
                X31UpdTable(aArqUpd[nX])
                If __GetX31Error()
                    Alert(__GetX31Trace())
                    cTexto += STR0057+aArqUpd[nX]+PULALINHA//"Falha ao atualizar estrutura física do arquivo "
                EndIf
            Next nY
            
            lMsHelpAuto := .F.             //-- Seta variavel para forcar a exibicao dos HELPs na tela
            cFilAnt := SM0->M0_CODFIL     //-- Seta para a filial atual a variavel utilizada pela funcao xFilial()
        
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ LOG - Secao referente a filial ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            cTexto += STR0058+AllTrim(SM0->M0_CODFIL+' - '+SM0->M0_FILIAL)+':'+PULALINHA    //"*Ajuste feito nas tabelas da filial"
            
            //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Atualiza variaveis da janela principal ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            oAtuTotal:cCaption := STR0059+AllTrim(SM0->M0_CODIGO+' - '+SM0->M0_NOME)+STR0060+AllTrim(SM0->M0_CODFIL+' - '+SM0->M0_FILIAL); oAtuTotal:Refresh()//"Empresa: "##" / Filial: "
            
            MsgRun(STR0079+AllTrim(SM0->M0_CODIGO+'-'+SM0->M0_NOME),STR0046,{|| RpcClearEnv()})//"Aguarde... Finalizando Ambiente da Empresa "
        EndIf
        
        cTexto += PULALINHA
    EndIf
Next
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exibe o LOG do ajuste ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLogUpdate := cTexto

Return Nil

//------------------------------------------------------
/*/{Protheus.doc} OpenSM0
Efetua a abertura do SM0 exclusivo
@version P12
@since 03/03/09
/*/
//------------------------------------------------------
Static Function OpenSM0(lCompart)

Local lOpen      := .F.
Local nLoop      := 0

If Select('SM0') > 0
    dbSelectArea('SM0')
    dbCloseArea()
EndIf

For nLoop := 1 To 20
    OpenSM0Excl()
    If Select('SM0') > 0
        lOpen := .T.
        dbSetOrder(1)
        Exit
    EndIf
    Sleep(500)
Next nLoop

Return lOpen

//------------------------------------------------------
/*/{Protheus.doc} AbreEmpre
Efetua a abertura da Empresa
@version P12
@since 03/03/09
/*/
//------------------------------------------------------
Static Function AbreEmpre(cCodEmp, cCodFil, cModulo)

//-- Nao consome licensas
RpcSetType(3) 
//-- Inicializa as variaveis genericas e abre a empresa/filial
RpcSetEnv(cCodEmp, cCodFil,,,cModulo) 

Return Nil

//------------------------------------------------------
/*/{Protheus.doc} Concordo
Termo de Aceite  
@version P12
@since 03/03/09
/*/
//------------------------------------------------------
Static Function Concordo(lConcordo)

If lConcordo
    oBtnAvanca:lActive    := .T.
Else
    oBtnAvanca:lActive    := .F.
EndIf

Return Nil

//------------------------------------------------------
/*/{Protheus.doc} GravaLog
Funcao utilizada para gravacao do Log 
@version P12
@since 03/03/09
/*/
//------------------------------------------------------
Static Function GravaLog(lSalvaUsu, cTexto, lRet)

Local cFile := ''
Local cMask      := STR0061    //"Arquivos de Log (*.LOG) |*.log|"
Local nOcorr     := 0

If !lRet

    If lSalvaUsu
        cFile := cGetFile(cMask, '')
    EndIf    
    
    If Empty(cFile)
        cFile := 'UPDCL6'+Right(CriaTrab(, .F.), 4)+'.LOG'
        Do While File(cFile)
            cFile := 'UPDCL6'+Right(CriaTrab(, .F.), 4)+'.LOG'
        EndDo
        nOcorr := 1
    ElseIf !(Upper(Right(cFile, 4))=='.LOG')    
        cFile += '.LOG'
        nOcorr := 2
    EndIf
    
    lRet := MemoWrite(cFile, cTexto)
    
    If nOcorr == 1
        Alert(STR0062+cFile+STR0063)    //"Este LOG foi salvo automaticamente como "##" no diretorio dos SXs."
    ElseIf nOcorr == 2
        Alert(STR0064+cFile+').')        //"A extencao '.LOG' foi adicionada ao arquivo, que foi salvo do diretorio escolhido ("
    EndIf
    
EndIf    

Return Nil

//------------------------------------------------------
/*/{Protheus.doc} UpdDclEs06
Migração das tabelas do Template DCL
@author jose.eulalio
@version P12
@since 03/03/17
/*/
//------------------------------------------------------
Static Function UpdDclEs06(cTexto)
Local lRet			:= .T.
Local cQuery		:= ""
Local cPoLocal	:= ""
Local cPoQtd		:= ""
Local cCong		:= ""
Local cRet			:= "Atualização realizada com sucesso!"
Local nTotCampos	:= 0
Local nX			:= 0
Local nTam			:= 0
Local cLogTab		:= ""
Local aValEmp		:= {}
Local aCpoLbz 	:= {}
Local aTabsOld	:= {"LBW","LJ1","LBS","LBA","LBB","LB5","LI2","LJN","LB6","LBC","LJ7","LI0","LHZ","LHY","LB4","LBT","LHW","LI1","LDH","LBY"} //Tabelas antigas que podem ou não terem sido criadas em updates anteriores 
Local aTabsNew	:= {	"DH3",;//Itens Documento de Saida DCL
							"DH4",;//Itens Documento de Entrada DCL
							"DH5",;//Complemento de Produto DCL
							"DH6",;//Tanques x Produtos
							"D30",;//Complemento Fornecedor DCL
							"DH7",;//MEDICOES DIARIAS
							"DH8",;//Lacres
							"DH9",;//RECEBIMENTO ANTECIPADO
							"D3D",;//RATEIO RECEBIMENTO ANTECIPADO
							"DHA",;//Checklist de Caminhoes
							"DHB",;//Cadastro de Motoristas
							"DHC",;//Fatores Conversao a 20 graus
							"DHD",;//Carac. Fisica-Quimica Produtos //AUTOCONTIDA
							"DHE",;//Relacao Prod x Car. Fis. Quim.
							"DHF",;//COMPARTIMENTOS
							"DHG",;//ARQUEACAO DE TANQUES
							"DHH",;//Produtos I-SIMP ANP //AUTOCONTIDA
							"D31",;//Cadastro de Embarcacoes ANP //AUTOCONTIDA
							"D32",;//Dutos ANP
							"D33",;//Tabela de ARIs i-SIMP //AUTOCONTIDA
							"D34",;//ANP 45 Detalhado
							"D35",;//Dados de Cessionárias
							"D36",;//Tabela de Instalações SIMP //AUTOCONTIDA
							"D37",;//Tabela de Arq. Texto SIMP
							"D38",;//Itens Fat. Cessionarias
							"D39",;//ANP 45 Resumo
							"D3A",;//Faixas Horarias
							"D3B",;//CARGAS X COMPARTIMENTOS
							"D3C"} //OPERACOES ANP (SIMP) //AUTOCONTIDA
/*
OBS.: 	Deve-se verificar se as tabelas do Template DCL estão criadas, pois,
		algumas tabelas foram criadas em updates anteriores (UDCLES01,UDCLES02,UDCLES03,UDCLES04,UDCLES05),
		como também devem ser verifados alguns campos que foram criados na mesma situação. Ex.: B1_ANP45
*/

//Valida Gestão de Empresas das tabelas referentes (DCL Template e novo)
aValEmp := ValidEmpresa(aTabsNew)

lRet := aValEmp[1] 

If lRet
	//Abre todos os Alias para garantir a criação das tabelas
	For nX := 1 To Len(aTabsNew)
		DbSelectArea(aTabsNew[nX])
	Next nX
	
	//Verifica se a tabela existe e cria a área
	For nX := 1 To Len(aTabsOld)
		If AliasIndic(aTabsOld[nX])
			DbSelectArea(aTabsOld[nX])
		EndIf
	Next nX
EndIf

//Realiza a carga nas tabelas novas do DCL
Begin Transaction

//Itens Documento de Saida DCL
If lRet .And. !(DH3->(DbSeek(xFilial("DH3")))) .and. Msfile(RetSqlName('SD2'))

	DbSelectArea("SD2")
	
	cQuery	:= "INSERT INTO " + RetSqlName("DH3") 
	cQuery	+= "("
	cQuery	+= "	DH3_FILIAL,DH3_DOCD2,DH3_SERIE,DH3_CLIENT,DH3_LOJA,DH3_ITEM, " 
	cQuery	+= "	DH3_LAUDO, DH3_RET20G, DH3_GEROU, DH3_DOCD3, "
	cQuery	+= "	DH3_QTD1, DH3_QTD2, DH3_QTD3, DH3_REGRA, "
	cQuery	+= "	DH3_TANQ1, DH3_TANQ2, DH3_TANQ3 "
	cQuery	+= ")
	cQuery	+= "SELECT " 
	cQuery	+= "	D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_ITEM, " 
	cQuery	+= "	D2_LAUDO, "
	If SD2->(FieldPos("D2_RET20G")) > 0
		cQuery	+= "	D2_RET20G, "
	Else
		cQuery	+= "	0 D2_RET20G," 
	EndIf 
	cQuery	+= "	D2_T_GEROU, D2_X_DOCD3, " 
	cQuery	+= "	D2_X_QTD1, D2_X_QTD2, D2_X_QTD3, D2_X_REGRA, " 
	cQuery	+= "	D2_X_TQ1, D2_X_TQ2, D2_X_TQ3 "
	cQuery	+= "FROM " + RetSqlName("SD2") + " "
	cQuery	+= "WHERE "
	cQuery	+= "	(D2_LAUDO <> '"+Space(tamsx3('D2_LAUDO')[1])+"' OR " 
	If SD2->(FieldPos("D2_RET20G")) > 0
		cQuery	+= 	"	D2_RET20G <> '"+Space(tamsx3('D2_RET20G')[1])+"' OR "
	EndIf 
	cQuery	+= "	D2_T_GEROU <> '"+Space(tamsx3('D2_T_GEROU')[1])+"' OR "
	cQuery	+= "	D2_X_DOCD3 <> '"+Space(tamsx3('D2_X_DOCD3')[1])+"' OR "
	cQuery	+= "	D2_X_QTD1 <> 0 OR "
	cQuery	+= "	D2_X_QTD2 <> 0 OR "
	cQuery	+= "	D2_X_QTD3 <> 0 OR "
	cQuery	+= "	D2_X_REGRA <> '"+Space(tamsx3('D2_X_REGRA')[1])+"' OR "
	cQuery	+= "	D2_X_TQ1 <> '"+Space(tamsx3('D2_X_TQ1')[1])+"' OR "
	cQuery	+= "	D2_X_TQ2 <> '"+Space(tamsx3('D2_X_TQ2')[1])+"' OR "
	cQuery	+= "	D2_X_TQ3 <> '"+Space(tamsx3('D2_X_TQ3')[1])+"' )"
	cQuery	+= "	AND D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DH3") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Itens Documento de Entrada DCL
If lRet .And. !(DH4->(DbSeek(xFilial("DH4")))) .And. Msfile(RetSqlName('SD1'))

	cQuery	:= " INSERT INTO " + RetSqlName("DH4") 
	cQuery	+= " ("
	cQuery	+= "	DH4_FILIAL,DH4_DOC,DH4_SERIE,DH4_FORNEC,DH4_LOJA,DH4_ITEM,DH4_CODPRO, "
	cQuery	+= 	"	DH4_DUTO,DH4_DENSID,DH4_DECIMP,DH4_DCPROV,DH4_CODEMB,DH4_NLCIMP,DH4_MASSA,DH4_MODANP,DH4_SRVIMP,DH4_TMPAMO,DH4_TMPTAQ,DH4_CODVGL, "
	cQuery	+= 	"	DH4_QTDAPU,DH4_ATUTNQ,DH4_DTENT,DH4_FATCOR,DH4_QTD20G,DH4_TANQUE,DH4_TRANS,DH4_TDCARG "
	cQuery	+= " ) "
	cQuery	+= " SELECT " 
	cQuery	+= "	D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM,D1_COD, "
	cQuery	+= "	D1_DUTO,D1_T_DENSA,D1_T_DI,D1_T_DPROV,D1_T_EMBAR,D1_T_LI,D1_T_MASSA,D1_T_MODAL,D1_T_SERVI,D1_T_TEMPA,D1_T_TEMPT,D1_T_VGLP, "
	cQuery	+= "	D1_X_APUR,D1_X_ATUTQ,D1_X_ENT,D1_X_FAT,D1_X_QTD1,D1_X_TQ,D1_X_TRANS,D1_X_VIA  "
	cQuery	+= " FROM " + RetSqlName("SD1") + " "
	cQuery	+= " WHERE "
	cQuery	+= "	D1_DUTO <> '"+Space(tamsx3('D1_DUTO')[1])+"' OR " 
	cQuery	+= "	D1_T_DENSA <> 0 OR " 
	cQuery	+= "	D1_T_DI <> '"+Space(tamsx3('D1_T_DI')[1])+"' OR  "
	cQuery	+= "	D1_T_DPROV <> '"+Space(tamsx3('D1_T_DPROV')[1])+"' OR " 
	cQuery	+= "	D1_T_EMBAR <> '"+Space(tamsx3('D1_T_EMBAR')[1])+"' OR "
	cQuery	+= "	D1_T_LI <> '"+Space(tamsx3('D1_T_LI')[1])+"' OR "
	cQuery	+= "	D1_T_MASSA <> 0 OR "
	cQuery	+= "	D1_T_MODAL <> '"+Space(tamsx3('D1_T_MODAL')[1])+"' OR "
	cQuery	+= "	D1_T_SERVI <> '"+Space(tamsx3('D1_T_SERVI')[1])+"' OR "
	cQuery	+= "	D1_T_TEMPA <> 0 OR "
	cQuery	+= "	D1_T_TEMPT <> 0 OR "
	cQuery	+= "	D1_T_VGLP <> '"+Space(tamsx3('D1_T_VGLP')[1])+"' OR "
	cQuery	+= "	D1_X_APUR <> 0 OR "
	cQuery	+= "	D1_X_ATUTQ <> '"+Space(tamsx3('D1_X_ATUTQ')[1])+"' OR " 
	cQuery	+= "	D1_X_ENT <> '"+Space(tamsx3('D1_X_ENT')[1])+"' OR "
	cQuery	+= "	D1_X_FAT <> 0 OR "
	cQuery	+= "	D1_X_QTD1 <> 0 OR "
	cQuery	+= "	D1_X_TQ <> '"+Space(tamsx3('D1_X_TQ')[1])+"' OR "
	cQuery	+= "	D1_X_TRANS <> '"+Space(tamsx3('D1_X_TRANS')[1])+"' OR " 
	cQuery	+= "	D1_X_VIA <> '"+Space(tamsx3('D1_X_VIA')[1])+"' "
	cQuery	+= "	AND D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DH4") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf


//Complemento de Produto DCL
If lRet .And. !(DH5->(DbSeek(xFilial("DH5")))) .and. Msfile(RetSqlName('SB5'))

	DbSelectArea("SB1")
	
	cQuery	:= " INSERT INTO " + RetSqlName("DH5") 
	cQuery	+= " ( "
	cQuery	+= "	DH5_FILIAL,DH5_COD,DH5_CODONU,DH5_RISCO,DH5_CODSIM,DH5_CLTRIB,DH5_CODIF,DH5_PRCPE,DH5_PREQUI,DH5_PPMAX "
	If SB1->(FieldPos("B1_ANP45")) > 0
		cQuery	+= "	,DH5_ANP45 "
	EndIf
	cQuery	+= "	,DH5_SIMPAN	,DH5_CONVDC	,DH5_TCONDC "	
	cQuery	+= " ) "
	cQuery	+= " SELECT " 
	cQuery	+= "	SB1.B1_FILIAL,SB1.B1_COD,SB1.B1_X_ONU,SB1.B1_X_RISCO,SB1.B1_CODSIMP,SB1.B1_X_CT,SB1.B1_CODIF,SB1.B1_X_PRCPE,SB1.B1_X_REQUI,SB1.B1_T_PMAX "
	If SB1->(FieldPos("B1_ANP45")) > 0
		cQuery	+= "	,SB1.B1_ANP45 "
	EndIf
	cQuery	+= "	,"+MATIsNull()+"(SB5.B5_SIMPANT,'')	,"+MATIsNull()+"(SB5.B5_CONVDCL,0)	,"+MATIsNull()+"(SB5.B5_TCONDCL,'') "
	cQuery	+= " FROM " + RetSqlName("SB1") + " SB1 "
	cQuery	+= " LEFT OUTER JOIN " + RetSqlName("SB5") + " SB5 "
	cQuery	+= " ON "
	cQuery	+= "	SB1.B1_FILIAL = SB5.B5_FILIAL AND "
	cQuery	+= "	SB1.B1_COD = SB5.B5_COD "
	cQuery	+= " WHERE "
	cQuery	+= "	(SB1.B1_X_ONU <> '"+Space(tamsx3('B1_X_ONU')[1])+"' OR " 
	cQuery	+= "	SB1.B1_X_RISCO <> '"+Space(tamsx3('B1_X_RISCO')[1])+"' OR " 
	cQuery	+= "	SB1.B1_CODSIMP <> '"+Space(tamsx3('B1_CODSIMP')[1])+"' OR  "
	cQuery	+= "	SB1.B1_X_CT <> '"+Space(tamsx3('B1_X_CT')[1])+"' OR "
	cQuery	+= "	SB1.B1_CODIF <> '"+Space(tamsx3('B1_CODIF')[1])+"' OR "
	cQuery	+= "	SB1.B1_X_PRCPE <> 0 OR "
	cQuery	+= "	SB1.B1_X_REQUI <> '"+Space(tamsx3('B1_X_REQUI')[1])+"' OR " 
	cQuery	+= "	SB1.B1_T_PMAX <> 0 OR "
	cQuery	+= "	SB5.B5_SIMPANT <> '"+Space(tamsx3('B5_SIMPANT')[1])+"' OR " 
	cQuery	+= "	SB5.B5_TCONDCL <> '"+Space(tamsx3('B5_TCONDCL')[1])+"' OR "
	cQuery	+= "	SB5.B5_CONVDCL <> 0 "
	If SB1->(FieldPos("B1_ANP45")) > 0 
		cQuery	+= "	OR SB1.B1_ANP45  <> '"+Space(tamsx3('B1_ANP45')[1])+"' "
	EndIf
	cQuery	+= ")	AND SB1.D_E_L_E_T_ = ' ' "
	cQuery	+= "	AND SB5.D_E_L_E_T_ = ' ' "

	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DH5") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Complemento Fornecedor DCL
If lRet .And. !(D30->(DbSeek(xFilial("D30")))) .and. Msfile(RetSqlName('SA2'))

	cQuery	:= " INSERT INTO " + RetSqlName("D30") 
	cQuery	+= " ( D30_FILIAL,D30_CODFOR,D30_LOJFOR,D30_ATVSIM,D30_CODSIM,D30_INSTSI,D30_MUNSIM,D30_PAISIM) "
	cQuery	+= " SELECT A2_FILIAL,A2_COD,A2_LOJA,A2_T_ATVSI,A2_T_CODSI,A2_T_INST,A2_T_MUNSI,A2_T_PAISI FROM " + RetSqlName("SA2") + " "
	cQuery	+= " WHERE "
	cQuery	+= "	A2_T_ATVSI <> '"+Space(tamsx3('A2_T_ATVSI')[1])+"' OR "
	cQuery	+= "	A2_T_CODSI <> '"+Space(tamsx3('A2_T_CODSI')[1])+"' OR "
	cQuery	+= "	A2_T_INST <> '"+Space(tamsx3('A2_T_INST')[1])+"' OR "
	cQuery	+= "	A2_T_MUNSI <> '"+Space(tamsx3('A2_T_MUNSI')[1])+"' OR "
	cQuery	+= "	A2_T_PAISI <> '"+Space(tamsx3('A2_T_PAISI')[1])+"' "
	cQuery	+= "	AND D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D30") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Tanques x Produtos
If lRet .And. AliasIndic("LB2") .And. !(DH6->(DbSeek(xFilial("DH6")))) .and. Msfile(RetSqlName('LB2'))

	cQuery	:= " INSERT INTO " + RetSqlName("DH6") 
	cQuery	+= " (DH6_FILIAL,DH6_TANQUE,DH6_CODPRO,DH6_ABERTU,DH6_CAPTOT,DH6_VDISPO,DH6_TRECEB,DH6_SAIDA,DH6_VOLTUB) "
	cQuery	+= " SELECT LB2_FILIAL,LB2_TANQUE,LB2_COD,LB2_ABERTU,LB2_CAPTOT,LB2_DISPO,LB2_RECEB,LB2_SAIDA,LB2_VOLTUB FROM  " + RetSqlName("LB2")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' " 
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DH6") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//MEDICOES DIARIAS
If lRet .And. AliasIndic("LB3") .And. !(DH7->(DbSeek(xFilial("DH7")))) .and. Msfile(RetSqlName('LB3'))

	cQuery	:= " INSERT INTO " + RetSqlName("DH7") 
	cQuery	+= " (DH7_ALTPRO,DH7_ALTAGU,DH7_VOLPRO,DH7_VOLAGU,DH7_TEMP1,DH7_TEMP2,DH7_SOBRA, "
	cQuery	+= " DH7_VOLAMB,DH7_VOL20,DH7_ENTRAD,DH7_SAIDA,DH7_ETRANS,DH7_STRANS,DH7_TEMP3, "
	cQuery	+= " DH7_TEMP,DH7_AMTEMP,DH7_AMDENS,DH7_DENS20,DH7_FATCOR,DH7_FILIAL,DH7_DATAME, "
	cQuery	+= " DH7_TANQUE,DH7_CODPRO,DH7_OBS) "
	cQuery	+= " SELECT  "
	cQuery	+= " LB3_ALTPRO,LB3_ALTAGU,LB3_VOLPRO,LB3_VOLAGU,LB3_TEMP1,LB3_TEMP2,LB3_SOBRA, "
	cQuery	+= " LB3_VOLAMB,LB3_VOL20,LB3_ENTRAD,LB3_SAIDA,LB3_ETRANS,LB3_STRANS,LB3_TEMP3, "
	cQuery	+= " LB3_TEMP,LB3_AMTEMP,LB3_AMDENS,LB3_DENS20,LB3_FATCOR,LB3_FILIAL,LB3_DATA, "
	cQuery	+= " LB3_TANQUE,LB3_COD,LB3_OBS "
	cQuery	+= " FROM " + RetSqlName("LB3")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DH7") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Lacres
If lRet .And. AliasIndic("LBU") .And. !(DH8->(DbSeek(xFilial("DH8")))) .and. Msfile(RetSqlName('LBU'))

	cQuery	:= " INSERT INTO " + RetSqlName("DH8") 
	cQuery	+= " ( DH8_FILIAL,DH8_NROLAC,DH8_CORLAC,DH8_STATUS,DH8_MOTIVO,DH8_CDSIMP,DH8_CDINST ) "
	cQuery	+= " SELECT LBU_FILIAL,LBU_NROLAC,LBU_CORLAC,LBU_STATUS,LBU_MOTIVO,LBU_CDSIMP,LBU_CDINST FROM " + RetSqlName("LBU")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DH8") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//RECEBIMENTO ANTECIPADO
If lRet .And. AliasIndic("LBZ") .And. !(DH9->(DbSeek(xFilial("DH9")))) .and. Msfile(RetSqlName('LBZ'))

	cQuery	:= " INSERT INTO " + RetSqlName("DH9") "
	cQuery	+= " ( "
	cQuery	+= " 	DH9_QTDSOL,DH9_TEMPTI,DH9_TEMPI,DH9_DENSI,DH9_ALTI,DH9_FATCOI,DH9_FATCOF, "
	cQuery	+= " 	DH9_VO20GF,DH9_VO20GI,DH9_TEMPTF,DH9_TEMPF,DH9_DENSF,DH9_ALTF,DH9_FILIAL, "
	cQuery	+= " 	DH9_CODIGO,DH9_DATA,DH9_TANQUE,DH9_CODPRO,DH9_FORNEC,DH9_LOJA,DH9_OBS,DH9_TIPO "
	cQuery	+= " ) "
	cQuery	+= " SELECT "
	cQuery	+= " 	LBZ_QTDSOL,LBZ_TEMPTI,LBZ_TEMPI,LBZ_DENSI,LBZ_ALTI,LBZ_FATCOI,LBZ_FATCOF, "
	cQuery	+= " 	LBZ_VO20GF,LBZ_VO20GI,LBZ_TEMPTF,LBZ_TEMPF,LBZ_DENSF,LBZ_ALTF,LBZ_FILIAL, "
	cQuery	+= " 	LBZ_CODIGO,LBZ_DATA,LBZ_TANQUE,LBZ_COD,LBZ_FORNEC,LBZ_LOJA,LBZ_OBS,LBZ_TIPO "
	cQuery	+= " FROM " + RetSqlName("LBZ") 
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DH9") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//RATEIO RECEBIMENTO ANTECIPADO
If lRet .And. AliasIndic("LBZ") .And. !(D3D->(DbSeek(xFilial("D3D"))))
	
	nTotCampos := 0
	
	cPoLocal	:= "LBZ_LOCA" 
	cPoQtd		:= "LBZ_QTLO"
	cCong		:= "LBZ_CONG"
		
	While SX3->(dbSeek(cPoLocal))
	    
	    nTotCampos++
	    AADD(aCpoLbz,{SX3->X3_CAMPO})
	    
	    If SX3->(dbSeek(cPoQtd))
	    	AADD(aCpoLbz[nTotCampos],SX3->X3_CAMPO)
	    EndIf
	    
	    If SX3->(dbSeek(cCong)) 
	    	AADD(aCpoLbz[nTotCampos],SX3->X3_CAMPO)
	    EndIf
		
		SX3->(dbSkip())
		 
	EndDo
	
	LBZ->(DbGotop())
	While !LBZ->(Eof())
		For nX := 1 To Len(aCpoLbz)
			
			RecLock("D3D",.T.)
			D3D->D3D_FILIAL	:= LBZ->LBZ_FILIAL
			D3D->D3D_CODIGO	:= LBZ->LBZ_CODIGO
			D3D->D3D_LOCAL	:= LBZ->(&(aCpoLbz[nX][1]))
			D3D->D3D_CONGEN	:= LBZ->(&(aCpoLbz[nX][2]))
			D3D->D3D_QTDLOC	:= LBZ->(&(aCpoLbz[nX][3]))
			D3D->(MsUnlock())	
			
		Next nX
		LBZ->(DbSkip())
	EndDo

EndIf

//Checklist de Caminhoes
If lRet .And. AliasIndic("LBW") .And. !(DHA->(DbSeek(xFilial("DHA")))) .and. Msfile(RetSqlName('LBW'))	 
	
	nTotCampos := 1
	
	cCong		:= "LBW_CONP01"
		
	While SX3->(dbSeek(cCong)) 
	    cCong		:= "LBW_CONP" + STRZERO(nTotCampos,2)
	    nTotCampos++
	EndDo

	cQuery	:= " INSERT INTO " + RetSqlName("DHA") 
	cQuery	+= " ( "
	For nX := 1 To nTotCampos
		cQuery	+= " 	DHA_COMP"+ STRZERO(nTotCampos,2) + ","
	Next nX
	cQuery	+= " 	DHA_CAPTOT,DHA_FILIAL,DHA_TIPO,DHA_PLACA,DHA_UF,DHA_MUNVEI,DHA_MARCA,DHA_NOMMOT, "
	cQuery	+= " 	DHA_PRXVIS,DHA_DTLIMI,DHA_ITEMDE,DHA_HISLIB,DHA_RESLIB,DHA_CPFMOT,DHA_DESCRI, "
	cQuery	+= " 	DHA_TFRETE,DHA_RENAVA,DHA_VLAFER,DHA_CODTRA,DHA_ANOFAB,DHA_ULTVIS  "
	cQuery	+= " ) "
	cQuery	+= " SELECT "
	For nX := 1 To nTotCampos
		cQuery	+= " 	LBW_COMP"+ STRZERO(nTotCampos,2) + ","
	Next nX
	cQuery	+= " 	LBW_CAPTOT,LBW_FILIAL,LBW_TIPO,LBW_PLACA,LBW_UF,LBW_MUN,LBW_MARCA,LBW_NOMMOT, "
	cQuery	+= " 	LBW_PRXVIS,LBW_DTLIMI,LBW_ITEMDE,LBW_HISLIB,LBW_RESLIB,LBW_CPFMOT,LBW_DESCRI, "
	cQuery	+= " 	LBW_TFRETE,LBW_RENAVA,LBW_VLAFER,LBW_TRANSP,LBW_ANOFAB,LBW_ULTVIS "
	cQuery	+= " FROM " + RetSqlName("LBW")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHA") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Cadastro de Motoristas
If lRet .And. AliasIndic("LBY") .And. !(DHB->(DbSeek(xFilial("DHB")))) .and. Msfile(RetSqlName('LBY'))

	cQuery	:= " INSERT INTO " + RetSqlName("DHB")
	cQuery	+= " ( "
	cQuery	+= " 	DHB_FILIAL,DHB_CPFMOT,DHB_NUMCNH,DHB_DTVALE,DHB_CATEGO, "
	cQuery	+= " 	DHB_DTVIST,DHB_ITEMDE,DHB_OBS,DHB_HISLIB,DHB_RESLIB,DHB_DTNASC, "
	cQuery	+= " 	DHB_REGIST,DHB_EXPCNH,DHB_DTCNH1,DHB_VENCTO,DHB_DTREV "
	cQuery	+= " ) "
	cQuery	+= " SELECT " 	
	cQuery	+= " 	LBY_FILIAL,LBY_CPF,	LBY_NUMCNH,LBY_DTVALE,LBY_CATEGO, "
	cQuery	+= " 	LBY_DTVIST,LBY_ITEMDE,LBY_OBS,LBY_HISLIB,LBY_RESLIB,LBY_DTNASC, "
	cQuery	+= " 	LBY_REGIST,LBY_EXPED,LBY_DTCNH1,LBY_VENCTO,LBY_DTREV "
	cQuery	+= "  FROM " + RetSqlName("LBY")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHB") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Fatores Conversao a 20 graus
If lRet .And. AliasIndic("LDH") .And. !(DHC->(DbSeek(xFilial("DHC")))) .and. Msfile(RetSqlName('LDH'))

	cQuery	:= " INSERT INTO " + RetSqlName("DHC") 
	cQuery	+= " 	( 		DHC_FILIAL,DHC_CODPRO,	DHC_TEMPTQ,DHC_TEMPAM,DHC_AMBDEN,DHC_DENS20,DHC_FATCOR ) "
	cQuery	+= "  SELECT 	LDH_FILIAL,LDH_COD,		LDH_TEMPTQ,LDH_TEMPAM,LDH_DENSID,LDH_DENS20,LDH_FATCOR FROM " + RetSqlName("LDH") + " " 
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHC") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Carac. Fisica-Quimica Produtos //AUTOCONTIDA
If lRet .And. AliasIndic("LI1") .And. !(DHD->(DbSeek(xFilial("DHD")))) .and. Msfile(RetSqlName('LI1'))

	cQuery	:= " INSERT INTO " + RetSqlName("DHD") 
	cQuery	+= " ( DHD_FILIAL,DHD_CODIGO,DHD_CARACT,DHD_UNMEDI ) "
	cQuery	+= " SELECT LI1_FILIAL,LI1_CODIGO,LI1_CARACT,LI1_UNMEDI FROM " + RetSqlName("LI1") + " LI1 "
	cQuery	+= " WHERE NOT EXISTS (SELECT DHD_FILIAL,DHD_CODIGO,DHD_CARACT,DHD_UNMEDI FROM " + RetSqlName("DHD") + " DHD WHERE DHD.D_E_L_E_T_ = ' ') AND "
	cQuery	+= " LI1.D_E_L_E_T_ = ' ' "
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHD") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Relacao Prod x Car. Fis. Quim.
If lRet .And. AliasIndic("LHW") .And. !(DHE->(DbSeek(xFilial("DHE")))) .and. Msfile(RetSqlName('LHW'))

	cQuery	:= " INSERT INTO " + RetSqlName("DHE") 
	cQuery	+= " ( 		DHE_FILIAL,DHE_LAUDO,DHE_CODPRO,DHE_CODCAR,DHE_MAFER,DHE_VALOR,DHE_MASSA ) "
	cQuery	+= " SELECT	LHW_FILIAL,LHW_LAUDO,LHW_CODPRO,LHW_CODCAR,LHW_MAFER,LHW_VALOR,LHW_MASSA FROM " + RetSqlName("LHW")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHE") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//COMPARTIMENTOS
If lRet .And. AliasIndic("LBT") .And. !(DHF->(DbSeek(xFilial("DHF")))) .and. Msfile(RetSqlName('LBT'))

	cQuery	:= " INSERT INTO " + RetSqlName("DHF") 
	cQuery	+= " ( 		DHF_FILIAL,DHF_CAPAC,DHF_CODVEI,DHF_NROCOM,DHF_NROLAC ) "
	cQuery	+= " SELECT 	LBT_FILIAL,LBT_CAPAC,LBT_CODVEI,LBT_NROCOM,LBT_NROLAC FROM " + RetSqlName("LBT")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHF") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//ARQUEACAO DE TANQUES
If lRet .And. AliasIndic("LB4") .And. !(DHG->(DbSeek(xFilial("DHG")))) .and. Msfile(RetSqlName('LB4'))

	cQuery	:= " INSERT INTO " + RetSqlName("DHG") 
	cQuery	+= " ( DHG_FILIAL,DHG_TANQUE,DHG_CODPRO,	DHG_LASTRO,DHG_CMINI,DHG_CMFIM,DHG_FATOR,DHG_ACUM ) "
	cQuery	+= " SELECT LB4_FILIAL,LB4_TANQUE,LB4_COD,LB4_LASTRO,LB4_CMINI,LB4_CMFIM,LB4_FATOR,LB4_ACUM FROM " + RetSqlName("LB4")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHG") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Produtos I-SIMP ANP //AUTOCONTIDA
If lRet .And. AliasIndic("LHY") .And. !(DHH->(DbSeek(xFilial("DHH")))) .and. Msfile(RetSqlName('LHY'))

	cQuery	:= " INSERT INTO " + RetSqlName("DHH") 
	cQuery	+= " ( 		DHH_FILIAL,DHH_CODIGO,DHH_PRODES,DHH_UNGRAN,DHH_UNMED,DHH_FAMIL,DHH_GRUPO,DHH_SUBGRP,DHH_SSGRP ) "
	cQuery	+= " SELECT 	LHY_FILIAL,LHY_CODIGO,LHY_PRODUT,LHY_UNGRAN,LHY_UNMED,LHY_FAMIL,LHY_GRUPO,LHY_SUBGRP,LHY_SSGRP FROM " + RetSqlName("LHY") + " LHY "
	cQuery	+= " WHERE NOT EXISTS (SELECT DHH.DHH_FILIAL,DHH.DHH_CODIGO,DHH.DHH_PRODES,DHH.DHH_UNGRAN,DHH.DHH_UNMED,DHH.DHH_FAMIL,DHH.DHH_GRUPO,DHH.DHH_SUBGRP,DHH.DHH_SSGRP FROM " + RetSqlName("DHH") + " DHH WHERE DHH.D_E_L_E_T_ = ' ') AND "
	cQuery	+= " LHY.D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("DHH") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Cadastro de Embarcacoes ANP //AUTOCONTIDA
If lRet .And. AliasIndic("LHZ") .And. !(D31->(DbSeek(xFilial("D31")))) .and. Msfile(RetSqlName('LHZ'))

	cQuery	:= " INSERT INTO " + RetSqlName("D31") 
	cQuery	+= " ( 		D31_TPB,D31_CALMAX,D31_FILIAL,D31_EMBCOD,D31_EMBNOM,	D31_ANAVEG,D31_TIPEMB,D31_NROIMO,D31_ARQBRU,D31_LOA ) "
	cQuery	+= " SELECT 	LHZ_TPB,LHZ_CALMAX,LHZ_FILIAL,LHZ_CODIGO,LHZ_NOME,	LHZ_ANAVEG,LHZ_TP_EMB,LHZ_NR_IMO,LHZ_ARQBRU,LHZ_LOA FROM " + RetSqlName("LHZ") + " LHZ "
	cQuery	+= " WHERE NOT EXISTS (SELECT D31_TPB,D31_CALMAX,D31_FILIAL,D31_EMBCOD,D31_EMBNOM,D31_ANAVEG,D31_TIPEMB,D31_NROIMO,D31_ARQBRU,D31_LOA FROM " + RetSqlName("D31") + " D31 WHERE D31.D_E_L_E_T_ = ' ') AND "
	cQuery	+= " LHZ.D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D31") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Dutos ANP
If lRet .And. AliasIndic("LI0") .And. !(D32->(DbSeek(xFilial("D32")))) .and. Msfile(RetSqlName('SA2'))

	cQuery	:= " INSERT INTO " + RetSqlName("D32") 
	cQuery	+= " ( 		D32_FILIAL,D32_CODDUT,D32_SIGLA,D32_CODPRO,D32_PROFOR,D32_PROLOJ,	"
	cQuery	+= " 			D32_OPEFOR,D32_OPELOJ, "
	cQuery	+= " 			D32_TIPDUT,	D32_INSORI,D32_MUNORI,D32_UFORIG,	D32_INSDES, "
	cQuery	+= " 			D32_MUNDES,D32_UFDEST,D32_DIAPOL,D32_EXTENS,D32_ANOOPE ) "
	cQuery	+= " SELECT 	LI0_FILIAL,LI0_CODDUT,LI0_SIGLA,LI0_PRODUT,LI0_PROPRI,"
	cQuery	+= " 			"+MATIsNull()+"((SELECT SA2A.A2_LOJA FROM " + RetSqlName("SA2") + " SA2A WHERE LI0_PROPRI = SA2A.A2_COD AND SA2A.D_E_L_E_T_ = ' '),' ') ,"
	cQuery	+= " 			LI0_OPERAD, "
	cQuery	+= " 			"+MATIsNull()+"((SELECT SA2B.A2_LOJA FROM " + RetSqlName("SA2") + " SA2B WHERE LI0_OPERAD = SA2B.A2_COD AND SA2B.D_E_L_E_T_ = ' '),' ') ,"
	cQuery	+= "			LI0_TIPO,		LI0_INSORI,LI0_MUNORI,LI0_UF,		LI0_INSDES, "
	cQuery	+= "			LI0_MUNDES,LI0_UF_DES,LI0_DIAPOL,LI0_EXTENS,LI0_ANOOPE FROM " + RetSqlName("LI0") + " LI0 "
	cQuery	+= " WHERE LI0.D_E_L_E_T_ = ' ' "  
		
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D32") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Tabela de ARIs i-SIMP //AUTOCONTIDA
If lRet .And. AliasIndic("LJ7") .And. !(D33->(DbSeek(xFilial("D33")))) .and. Msfile(RetSqlName('LJ7'))

	cQuery	:= " INSERT INTO " + RetSqlName("D33") 
	cQuery	+= " ( D33_FILIAL,D33_CDSIMP,D33_CNPJRA,D33_RAZSOC,D33_TIPAGN ) "
	cQuery	+= " SELECT LJ7_FILIAL,LJ7_CDSIMP,LJ7_CNPJRA,LJ7_RAZSOC,LJ7_TP_AGT FROM " + RetSqlName("LJ7") + " LJ7 "
	cQuery	+= " WHERE NOT EXISTS (SELECT D33_FILIAL,D33_CDSIMP,D33_CNPJRA,D33_RAZSOC,D33_TIPAGN FROM " + RetSqlName("D33") + " D33 WHERE D33.D_E_L_E_T_ = ' ') AND "
	cQuery	+= " LJ7.D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D33") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//ANP 45 Detalhado
If lRet .And. AliasIndic("LBC") .And. !(D34->(DbSeek(xFilial("D34")))) .and. Msfile(RetSqlName('LBC'))

	//Necessário criar campo de cod unico e alterar chave unica
	
	nTam := TamSx3("D34_CODITE")[1] // tamanho do campo de controle
	
	cQuery	:= " INSERT INTO " + RetSqlName("D34") 
	cQuery	+= " (			D34_CODITE, " 		
	cQuery	+= "			D34_FILIAL,D34_FILORI,D34_NATURE,D34_CODREG,D34_INST1,D34_INST2,D34_LOCMNT,D34_CODPRO,D34_ANOREF,	D34_DATA,D34_SEMANA,D34_LASTRO,D34_VOLLOC,D34_VOLTRA ) "
	cQuery	+= " SELECT 	"
	cQuery	+= " 			REPLICATE('0'," + STR(nTam) + " - Len(ROW_NUMBER() over (ORDER BY LBC.LBC_FILIAL))) + CAST(ROW_NUMBER() over (ORDER BY LBC.LBC_FILIAL)AS NVARCHAR) AS 'Seq', " 
	cQuery	+= " 			LBC_FILIAL,LBC_FILORI,LBC_NATURE,LBC_CODREG,LBC_INST1,LBC_INST2,LBC_LOCMNT,LBC_CODPRO,LBC_ANO,		LBC_DATA,LBC_SEMANA,LBC_LASTRO,LBC_VOLLOC,LBC_VOLTRA FROM " + RetSqlName("LBC") + " LBC "
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D34") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Dados de Cessionárias
If lRet .And. AliasIndic("LB6") .And. !(D35->(DbSeek(xFilial("D35")))) .and. Msfile(RetSqlName('LB6'))

	//Necessário criar campo D35_VOL2

	cQuery	:= " INSERT INTO " + RetSqlName("D35") 
	cQuery	+= " ( 		D35_ALUGUE,D35_SEGURO,D35_VOL1,D35_VAL1,D35_VAL2, "
	cQuery	+= " 			D35_VOL2, " //Criar este campo
	cQuery	+= " 			D35_VOL3,D35_VAL3,D35_FILIAL,D35_CODCON,	D35_LOJCON,D35_NREDUZ,D35_LOCAL,D35_SAALUG,D35_SAPERD,D35_RET20G,D35_MAXIMO ) "
	cQuery	+= " SELECT 	LB6_ALUGUE,LB6_SEGURO,LB6_VOL1,LB6_VAL1,LB6_VAL2, "
	cQuery	+= " 			LB6_VOL2,	"
	cQuery	+= " 			LB6_VOL3,LB6_VAL3,LB6_FILIAL,LB6_COD,		LB6_LOJA,	LB6_NREDUZ,LB6_LOCAL,LB6_SAALUG,LB6_SAPERD,LB6_RET20G,LB6_MAXIMO FROM " + RetSqlName("LB6")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D35") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Tabela de Instalações SIMP //AUTOCONTIDA
If lRet .And. AliasIndic("LJN") .And. !(D36->(DbSeek(xFilial("D36")))) .and. Msfile(RetSqlName('LJN'))

	cQuery	:= " INSERT INTO " + RetSqlName("D36") 
	cQuery	+= " ( D36_FILIAL,D36_CDINST,D36_CNPJIN, "	
	cQuery	+= " 	D36_RAZSOC, " //Alterar para tamanho 100
	cQuery	+= " 	D36_CEPINS,	D36_ENDER,D36_TPINST,D36_COMPL,D36_BAIRRO,D36_MUNIC,D36_UFINS,	D36_AUTOR,D36_STATUS ) "
	cQuery	+= " SELECT LJN_FILIAL,LJN_CDINST,LJN_CNPJ, "		
	cQuery	+= " 	LJN_RAZSOC, "
	cQuery	+= " 	LJN_CEP,		LJN_ENDER,LJN_TPINST,LJN_COMPL,LJN_BAIRRO,LJN_MUNIC,LJN_UF,		LJN_AUTOR,LJN_STATUS FROM " + RetSqlName("LJN") + " LJN "
	cQuery	+= " WHERE NOT EXISTS (SELECT D36_FILIAL,D36_CDINST,D36_CNPJIN, "	
	cQuery	+= " 	D36_RAZSOC, " //Alterar para tamanho 100
	cQuery	+= " 	D36_CEPINS,	D36_ENDER,D36_TPINST,D36_COMPL,D36_BAIRRO,D36_MUNIC,D36_UFINS,	D36_AUTOR,D36_STATUS FROM " + RetSqlName("D36") + " D36 WHERE D36.D_E_L_E_T_ = ' ') AND "
	cQuery	+= " LJN.D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D36") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Tabela de Arq. Texto SIMP
If lRet .And. AliasIndic("LI2") .And. !(D37->(DbSeek(xFilial("D37")))) .and. Msfile(RetSqlName('LI2'))

	//Necessário criar campo de cod unico e alterar chave unica

	nTam := TamSx3("D37_CODSIM")[1] // tamanho do campo de controle

	cQuery	:= " INSERT INTO " + RetSqlName("D37") 
	cQuery	+= " (			D37_CODSIM, "
	cQuery	+= "  			D37_FILIAL,D37_ARI,D37_MES,D37_ANOREF,	D37_OPERAC,D37_INST1,D37_INST2,D37_CODPRD,D37_QTDPRD,	D37_QTDEKG,D37_MODAL, "
	cQuery	+= "  			D37_VEICUL,D37_TERCEI,D37_MUNIC,D37_ATIVEC,D37_PAIS,D37_LICIMP,	D37_DECIMP,	D37_NF,D37_SERIE,D37_DATAOP,D37_SERVIC, "
	cQuery	+= "  			D37_CFISQU,	D37_METAFE,D37_UNMCFQ,D37_VALOR,D37_PROOPE,D37_MASSA,D37_RECGLP,D37_IDENT,D37_CHVNFE ) "
	cQuery	+= " SELECT 	"
	cQuery	+= " 			REPLICATE('0'," + STR(nTam) + " - Len(ROW_NUMBER() over (ORDER BY LI2.LI2_FILIAL))) + CAST(ROW_NUMBER() over (ORDER BY LI2.LI2_FILIAL)AS NVARCHAR) AS 'Seq', " 
	cQuery	+= "			LI2_FILIAL,LI2_ARI,LI2_MES,LI2_ANO,		LI2_OPERAC,LI2_INST1,LI2_INST2,LI2_PRODUT,LI2_QTDE,		LI2_QTDEKG,LI2_MODAL, "
	cQuery	+= "			LI2_VEICUL,LI2_TERCEI,LI2_MUNIC,LI2_ATIVEC,LI2_PAIS,LI2_LI,		LI2_DI,		LI2_NF,LI2_SERIE,LI2_DATAOP,LI2_SERVIC, "
	cQuery	+= "			LI2_CFQP,	LI2_METAFE,LI2_UM_CFQ,LI2_VALOR,LI2_PROOPE,LI2_MASSA,LI2_RECGLP,LI2_IDENT,LI2_CHVNFE FROM " + RetSqlName("LI2") + " LI2 "
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D37") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Itens Fat. Cessionarias
If lRet .And. AliasIndic("LB5") .And. !(D38->(DbSeek(xFilial("D38")))) .and. Msfile(RetSqlName('LB5'))

	cQuery	:= " INSERT INTO " + RetSqlName("D38") 
	cQuery	+= " ( 		D38_FILIAL,D38_DATA,D38_TIPO,D38_LOCAL,D38_CESSI,D38_CODPRO,D38_QUANT,D38_VALOR,D38_MOTIVO ) "
	cQuery	+= " SELECT 	LB5_FILIAL,LB5_DATA,LB5_TIPO,LB5_LOCAL,LB5_CESSI,LB5_COD,	LB5_QUANT,LB5_VALOR,LB5_MOTIVO FROM " + RetSqlName("LB5")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D38") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//ANP 45 Resumo
If lRet .And. AliasIndic("LBB") .And. !(D39->(DbSeek(xFilial("D39")))) .and. Msfile(RetSqlName('LBB'))

	cQuery	:= " INSERT INTO " + RetSqlName("D39") 
	cQuery	+= " ( 		D39_FILIAL,D39_CODPRO,D39_CODREG,D39_ESDMOB,D39_ESMD,D39_INST1,D39_INST2,D39_LOCMNT,D39_NATURE,D39_SEMANA,D39_ANOREF,	D39_MES,D39_OBS ) "
	cQuery	+= " SELECT 	LBB_FILIAL,LBB_CODPRO,LBB_CODREG,LBB_ESDMOB,LBB_ESMD,LBB_INST1,LBB_INST2,LBB_LOCMNT,LBB_NATURE,LBB_SEMANA,LBB_ANO,		LBB_MES,LBB_OBS FROM " + RetSqlName("LBB")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D39") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//Faixas Horarias
If lRet .And. AliasIndic("LBA") .And. !(D3A->(DbSeek(xFilial("D3A")))) .and. Msfile(RetSqlName('LBA'))

	cQuery	:= " INSERT INTO " + RetSqlName("D3A") 
	cQuery	+= " ( D3A_FILIAL,D3A_DATA,D3A_CODPRO,D3A_TANQUE,D3A_HORAFI,D3A_HORAIN,D3A_TEMPTQ,D3A_TEMPAM,D3A_DENSID,D3A_FATOR,D3A_ITEM ) "
	cQuery	+= " SELECT LBA_FILIAL,LBA_DATA,LBA_COD	,LBA_TANQUE,LBA_HORAFI,LBA_HORAIN,LBA_TEMP	,LBA_TEMPAM,LBA_DENSID,LBA_FATOR,LBA_ITEM FROM " + RetSqlName("LBA")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D3A") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//CARGAS X COMPARTIMENTOS
If lRet .And. AliasIndic("LBS") .And. !(D3B->(DbSeek(xFilial("D3B")))) .and. Msfile(RetSqlName('LBS'))

	cQuery	:= " INSERT INTO " + RetSqlName("D3B") 
	cQuery	+= " ( 		D3B_FILIAL,D3B_CDINST,D3B_CDSIMP,D3B_CODCAR,D3B_CODPRO,D3B_LACANT,D3B_LACRES,D3B_MOTINU,D3B_NROCOM,D3B_NROENV,D3B_PEDIDO,D3B_QTDPED,D3B_SEQCAR ) "
	cQuery	+= " SELECT 	LBS_FILIAL,LBS_CDINST,LBS_CDSIMP,LBS_CODCAR,LBS_CODPRO,LBS_LACANT,LBS_LACRES,LBS_MOTINU,LBS_NROCOM,LBS_NROENV,LBS_PEDIDO,LBS_QTDPED,LBS_SEQCAR FROM " + RetSqlName("LBS")
	cQuery	+= " WHERE D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D3B") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

//OPERACOES ANP (SIMP) //AUTOCONTIDA
If lRet .And. AliasIndic("LJ1") .And. !(D3C->(DbSeek(xFilial("D3C")))) .and. Msfile(RetSqlName('LJ1'))

	cQuery	:= " INSERT INTO " + RetSqlName("D3C") 
	cQuery	+= " ( D3C_FILIAL,D3C_CDOPSI,D3C_DESCRI,D3C_TIPOPE,	D3C_FINAL,D3C_CLASSE ) "
	cQuery	+= " SELECT LJ1_FILIAL,LJ1_COD_SI,LJ1_DESCRI,LJ1_TIPO,	LJ1_FINAL,LJ1_CLASSE FROM " + RetSqlName("LJ1") + " LJ1 "
	cQuery	+= " WHERE NOT EXISTS (SELECT D3C.D3C_FILIAL,D3C.D3C_CDOPSI,D3C.D3C_DESCRI,D3C.D3C_TIPOPE,D3C.D3C_FILIAL,D3C.D3C_CLASSE FROM " + RetSqlName("D3C") + " D3C WHERE D3C.D_E_L_E_T_ = ' ') AND "
	cQuery	+= " LJ1.D_E_L_E_T_ = ' ' "  
	
	If ( TCSqlExec( cQuery ) < 0)
		cLogTab := RetSqlName("D3C") +  ' ' +  TCSQLError()
		lRet := .F.
		DisarmTransaction()
	EndIf

EndIf

End Transaction

If !lRet 
	cRet := "Ocorreu um erro na importação de dados. Seus dados não foram alterados." + PULALINHA
	cRet += aValEmp[2]
	cTexto +=  PULALINHA+ cRet + PULALINHA
	If !Empty (cLogTab) 
		cTexto += ' ' + cLogTab 
	EndIf
	GravaLog(.F., cTexto, .F.)
	Final("Erro na importação de dados! Verifique o arquivo de log.")
EndIf

//Fecha as áreas das tabelas novas
For nX := 1 To Len(aTabsNew)
	(aTabsNew[nX])->(DbCloseArea())
Next nX

//Verifica se a tabela existe e fecha a área
For nX := 1 To Len(aTabsOld)
	If AliasIndic(aTabsOld[nX])
		(aTabsOld[nX])->(DbCloseArea())
	EndIf
Next nX

Return cRet

//------------------------------------------------------
/*/{Protheus.doc} ValidEmpresa
//Valida Gestão de Empresas das tabelas referentes (DCL Template e novo)
@author jose.eulalio
@version P12
@since 08/05/17
/*/
//------------------------------------------------------
Static Function ValidEmpresa(aTabsNew)
Local lRet			:= .F.
Local cRet			:= ""
Local cTabRef		:= ""
Local cModNew		:= ""
Local cModUnNew	:= ""
Local cModEmpNew	:= ""
Local cModRef		:= ""
Local cModUnRef	:= ""
Local cModEmpRef	:= ""
Local aRetDiv		:= {}
Local nX			:= 0
Local cModAux		:= ''

For nX := 1 To Len(aTabsNew)
	Do Case
		Case aTabsNew[nX] == "DH3"//Itens Documento de Saida DCL
			cTabRef := "SD2"
			cTabDes := "Itens Documento de Saida DCL"
		Case aTabsNew[nX] == "DH4"//Itens Documento  de Entrada DCL
			cTabRef := "SD1"
			cTabDes := "Itens Documento de Entrada DCL "
		Case aTabsNew[nX] == "DH5"//Complemento de Produto DCL
			cTabRef := "SB1"
			cTabDes := "Complemento de Produto DCL "
		Case aTabsNew[nX] == "DH6"//Tanques x Produtos
			cTabRef := "LB2"
			cTabDes := "Tanques x Produtos "
		Case aTabsNew[nX] == "D30"//Complemento Fornecedor DCL
			cTabRef := "SA2"
			cTabDes := "Complemento Fornecedor DCL "
		Case aTabsNew[nX] == "DH7"//MEDICOES DIARIAS
			cTabRef := "LB3"
			cTabDes := "MEDICOES DIARIAS "
		Case aTabsNew[nX] == "DH8"//Lacres
			cTabRef := "LBU"
			cTabDes := "Lacres "
		Case aTabsNew[nX] == "DH9" //RECEBIMENTO ANTECIPADO
			cTabRef := "LBZ"
			cTabDes := "RECEBIMENTO ANTECIPADO "
		Case aTabsNew[nX] == "D3D" //RATEIO RECEBIMENTO ANTECIPADO
			cTabRef := "LBZ"
			cTabDes := "RATEIO RECEBIMENTO ANTECIPADO "
		Case aTabsNew[nX] == "DHA" //Checklist de Caminhoes
			cTabRef := "LBW"
			cTabDes := "Checklist de Caminhoes "
		Case aTabsNew[nX] == "DHB" //Cadastro de Motoristas
			cTabRef := "LBY"
			cTabDes := "Cadastro de Motoristas "
		Case aTabsNew[nX] == "DHC" //Fatores Conversao a 20 graus
			cTabRef := "LDH"
			cTabDes := "Fatores Conversao a 20 graus "
		Case aTabsNew[nX] == "DHD" //Carac. Fisica-Quimica Produtos
			cTabRef := "LI1"
			cTabDes := "Carac. Fisica-Quimica Produtos "
		Case aTabsNew[nX] == "DHE" //Relacao Prod x Car. Fis. Quim.
			cTabRef := "LHW"
			cTabDes := "Relacao Prod x Car. Fis. Quim. "
		Case aTabsNew[nX] == "DHF" //COMPARTIMENTOS
			cTabRef := "LBT"
			cTabDes := "COMPARTIMENTOS "
		Case aTabsNew[nX] == "DHG" //ARQUEACAO DE TANQUES
			cTabRef := "LB4"
			cTabDes := "ARQUEACAO DE TANQUES "
		Case aTabsNew[nX] == "DHH" //Produtos I-SIMP ANP
			cTabRef := "LHY"
			cTabDes := "Produtos I-SIMP ANP "
		Case aTabsNew[nX] == "D31" //Cadastro de Embarcacoes ANP
			cTabRef := "LHZ"
			cTabDes := "Cadastro de Embarcacoes ANP "
		Case aTabsNew[nX] == "D32" //Dutos ANP
			cTabRef := "LI0"
			cTabDes := "Dutos ANP "
		Case aTabsNew[nX] == "D33" //Tabela de ARIs i-SIMP
			cTabRef := "LJ7"
			cTabDes := "Tabela de ARIs i-SIMP "
		Case aTabsNew[nX] == "D34" //ANP 45 Detalhado
			cTabRef := "LBC"
			cTabDes := "ANP 45 Detalhado "
		Case aTabsNew[nX] == "D35" //Dados de Cessionárias
			cTabRef := "LB6"
			cTabDes := "Dados de Cessionárias "
		Case aTabsNew[nX] == "D36" //Tabela de Instalações SIMP 
			cTabRef := "LJN"
			cTabDes := "Tabela de Instalações SIMP "
		Case aTabsNew[nX] == "D37" //Tabela de Arq. Texto SIMP
			cTabRef := "LI2"
			cTabDes := "Tabela de Arq. Texto SIMP "
		Case aTabsNew[nX] == "D38" //Itens Fat. Cessionarias
			cTabRef := "LB5"
			cTabDes := "Itens Fat. Cessionarias "
		Case aTabsNew[nX] == "D39" //ANP 45 Resumo
			cTabRef := "LBB"
			cTabDes := "ANP 45 Resumo "
		Case aTabsNew[nX] == "D3A" //Faixas Horarias
			cTabRef := "LBA"
			cTabDes := "Faixas Horarias "
		Case aTabsNew[nX] == "D3B" //CARGAS X COMPARTIMENTOS
			cTabRef := "LBS"
			cTabDes := "CARGAS X COMPARTIMENTOS "
		Case aTabsNew[nX] == "D3C" //OPERACOES ANP / SIMP
			cTabRef := "LJ1"
			cTabDes := "OPERACOES ANP / SIMP "
		
	EndCase
	
	If !empty(RETSQLNAME(aTabsNew[nX]))  
		cModNew		:= FwModeAccess (aTabsNew[nX],3)
		cModUnNew	:= FwModeAccess (aTabsNew[nX],2)
		cModEmpNew	:= FwModeAccess (aTabsNew[nX],1)
		lRet		:= .T.
		If !empty(RETSQLNAME(cTabRef))
			cModRef		:= FwModeAccess (cTabRef,3)
			cModAux		:= FwModeAccess (cTabRef,2)
			cModUnRef	:= iIf(cModAux==' ','E',iIf(cModRef == 'E' .and. cModAux == 'C','E', cModAux))
			cModAux		:= FwModeAccess (cTabRef,1)
			cModEmpRef	:= iIf(cModAux==' ','E',iIf(cModRef == 'E' .and. cModAux == 'C','E', cModAux))
		Else
			lRet		:= .F.
		EndIf
	EndIf
	
	If lRet
		lRet := cModNew == cModRef .And. cModUnNew	== cModUnRef .And. cModEmpNew == cModEmpRef
	EndIf
	
	If !lRet
		aAdd(aRetDiv,cTabDes + "(" + aTabsNew[nX] + "/" + cTabRef + ")" )  
	EndIf
		
Next nX

If Len(aRetDiv) > 0
	cRet := "Verifique o Modo de Compartilhamento das tabelas abaixo: " + PULALINHA
	For nX := 1 To Len(aRetDiv)
		cRet += aRetDiv[nX] + PULALINHA
	Next nX 
EndIf

Return {lRet,cRet}

