#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "EECCAD02.CH"
#Include "EEC.CH"
#Include "FileIO.ch"

#Define SENHACOMPRESS "X"

/*
Programa   : EECCAD02.PRW.
Objetivo   : Agrupar todas funções de manipulação de dados do SIGAEEC. (Continuação EECCAD01).
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 13/09/05 às 14:40
Obs        : As funções de Exportação e Importação de documentos foram transportadas do EECCAD01
             por causa do Estouro de Defines. Algumas delas tem ao lado a função do EECCAD01 que a chama.
             Todas as functions (as Static não) transportadas tiveram "2" adicionado após o prefixo
             ("Av","Mark" ou "EEC") do nome, para não haver problemas de compilação.
*/

/*
Funcao     : Av2SelectDoc()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Gerar markBrow para marcação dos Relatório/Documentos que serão exportados
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 16/06/05 - 11:40
Revisao    :
Obs.       :
*/

*---------------------*
Function Av2SelectDoc() //AvSelectDoc()
*---------------------*
Private cCadastro := STR0002 //"Exportação de Documentos"

Private aRotina  := MenuDef("AVSELECTDO")

Private aCampos := { {"EEA_MARCA" ,," X "},;
                     {"EEA_COD"   ,,AvSx3("EEA_COD"   ,AV_TITULO) },;
                     {"EEA_TITULO",,AvSx3("EEA_TITULO",AV_TITULO) },;
                     {{|| AllTrim(Tabela("ID",Left(EEA->EEA_IDIOMA,6),.f.))},,AvSx3("EEA_IDIOMA",AV_TITULO) } }

Private cMarca := GetMark()
Private nTotal := 0

Begin Sequence

   DbSelectArea("EEA")

   // Só são visualizados os registros que não sejam "Atividade" (Tipo 4)
   DbSetFilter({|| Left(EEA_TIPDOC, 1) <> "4" }, "Left(EEA_TIPDOC, 1) <> '4'" )

   MarkBrow( "EEA", "EEA_MARCA",, aCampos,, cMarca,"Processa({|| Mark2AllEEA() })",,,,"Mark2EEA()", )

   EEA->(DbClearFilter())

End Sequence

Return Nil


/*

Função    : Mark2EEA
Objetivo  : Marcar registro no EEA com cMarca
Autor     : João Pedro Macimiano Trabbold
Data/Hora : 16/06/05 - 10:56
Obs.:     :
*/
Function Mark2EEA()

Begin Sequence

   RecLock("EEA",.F.)

   If IsMark("EEA_MARCA", cMarca)

      EEA_MARCA := Space(2)
      nTotal--

   Else

      EEA_MARCA := cMarca
      nTotal++

   EndIf

   MsUnLock()

End Sequence

Return Nil

/*
Função    : Mark2AllEEA
Objetivo  : Marcar todos os registros do EEA com cMarca
Autor     : João Pedro Macimiano Trabbold
Data/Hora : 16/06/05 - 10:56
Obs.:     :
*/
Function Mark2AllEEA()

Local lMarcar := .f.

Begin Sequence

   ProcRegua(LastRec()*0.25)

   DbGoTop()
   While !EoF()
      If !IsMark("EEA_MARCA", cMarca)
         lMarcar := .t.
         Exit
      EndIf
      DbSkip()
   EndDo

   DbGoTop()
   While !EoF()
      IncProc()
      RecLock("EEA",.F.)
      If lMarcar
         If !IsMark("EEA_MARCA", cMarca)
            nTotal++
         EndIf
      Else
         If IsMark("EEA_MARCA", cMarca)
            nTotal--
         EndIf
      EndIf

      EEA_MARCA := If(lMarcar,cMarca,Space(2))
      MsUnlock()
      DbSkip()
   EndDo

   DbGoTop()

End Sequence

Return Nil

/*
Funcao     : Av2DocExport()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Exportar dados de documentos do EEA
             Possíveis dados -  Geral     : Registro do EEA, Arquivo Crystal - RPT
                                AvTelaGets: campos do EG4 e SX3, consultas, gatilhos
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 15/06/05 - 10:30
Revisao    :
Obs.       :
*/

*---------------------*
Function Av2DocExport()
*---------------------*
Local aDir, i,oDlg, lOk := .f., n
Local aOrd, aSave := {"EEA"}
Local cMsg        := ""
Local bOk     := {|| If(DocExpValid(),(lOk := .t., oDlg:End()),) },;
      bCancel := {|| lOk := .f., oDlg:End() }
Local cRpt := ""
Local nInc
Local aArqCpy := {}
Local nCpoEEA, nHdlEEA
Private aArquivos := {}

Private lCriadoEEA := .f.,;
        lCriadoEG4 := .f.,cCposEG4 := "",;
        lCriadoSX3 := .f.,;
        lCriadoSX7 := .f.,;
        lCriadoSXB := .f.,cCposSXB := "",;
        lCriadoSXA := .f.,cCposSXA := ""

Private cFolder
Private lDicDocs   := EECRotinas("DIC_DOCS")
Private cArquivo   := Space(50)

If lDicDocs
   AAdd(aSave,"EG4")
   AAdd(aSave,"SX3")
   AAdd(aSave,"SXB")
   AAdd(aSave,"SX7")
   AAdd(aSave,"SXA")
EndIf
aOrd := SaveOrd(aSave)

Begin Sequence
   If nTotal = 0
      MsgInfo(STR0005,STR0043) // "Nenhum registro foi selecionado para a geração dos dados.","Atenção"
      Break
   EndIf

   // procura o diretório crystal
   Private cDirCrystal := EasyGParam("MV_CRYSTAL")
   IF Empty(cDirCrystal)
      Help(" ",1,"MV_CRYSTAL")
      Break
   Endif
   cDirCrystal := AllTrim(cDirCrystal)
   cDirCrystal := IF(Right(cDirCrystal,1)="\",Left(cDirCrystal,Len(cDirCrystal)-1),cDirCrystal)
   If !lIsDir(cDirCrystal)
      MsgStop(STR0001,STR0044)// "O diretório informado no parâmetro MV_CRYSTAL está incorreto. A exportação de dados não poderá ser realizada.", "Aviso"
      Break
   EndIf

   // Entrada do nome do arquivo a ser gerado
   DEFINE MSDIALOG oDlg TITLE cCadastro FROM 1,1 To 191,376 OF oMainWnd Pixel

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 11/09/2015 - Ajustes Tela P12.
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      @ 14,4 to 43,185 Label STR0006 PIXEL OF oPanel //"Digite o nome desejado para o arquivo a ser gerado (sem a extensão):"

      @ 25,12 MsGet cArquivo Size 140,07 Pixel OF oPanel

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) Centered

   If !lOk
      Break
   EndIf

   n := 0
   //Pasta do arquivo novo
   cFolder  := cDirCrystal + "\" + AllTrim(cArquivo) + StrZero(n,3)

   While lIsDir(cFolder)
      n++
      cFolder := cDirCrystal + "\" + AllTrim(cArquivo) + StrZero(n,3)
   EndDo

   MakeDir(cFolder) // Cria pasta do arquivo que está sendo exportado atualmente

   //Caminho do arquivo novo
   cArquivo := cDirCrystal + "\" + AllTrim(cArquivo) + ".ERU"

   /* RMD - 30/05/18 - Passa a exportar em TXT
   //Cria arquivo .DBF do EEA
   If !(lCriadoEEA := EEA->(CriaArquivo()) )
      Break
   EndIf
   */
   If (nHdlEEA := EasyCreateFile(cFolder + "\EEAEXPORT.TXT")) =0
      Break
   EndIf
   aAdd(aArquivos, cFolder + "\EEAEXPORT.TXT")
   cLine := ""
   For nCpoEEA := 1 To EEA->(FCount())
      If nCpoEEA <> 1
         cLine += ";"
      EndIf
      cLine += EEA->(FieldName(nCpoEEA))
   Next
   FWrite(nHdlEEA, cLine + ENTER)

   /* RMD - 30/05/18
   If lDicDocs
      SX3->(DbSetOrder(2))
      SX7->(DbSetOrder(1))
      SXA->(DbSetOrder(1))
      SXB->(DbSetOrder(1))
   EndIf
   */

   ProcRegua(nTotal+1)
   IncProc(STR0007)//"Gerando dados dos documentos selecionados..."

   //EEA->(DbGoTop())
   EEA->(DbSeek(xFilial("EEA")))

   While EEA->(!EoF()) .And. EEA->EEA_FILIAL == xFilial("EEA")

      // Só gera se estiver marcado
      If EEA->EEA_MARCA <> cMarca
         EEA->(DbSkip())
         Loop
      EndIf

      EEA->(RecLock("EEA",.f.),EEA_MARCA := "  ",MsUnlock())
      nTotal--

      IncProc()

      If EEA->(FieldPos("EEA_ARQADI")) > 0
         aArqCpy := AA100Split(EEA->EEA_ARQADI)
      EndIf
      aAdd(aArqCpy, EEA->EEA_ARQUIV)

      For nInc := 1 To Len(aArqCpy)

         // caminho do .RPT
         cRpt := cFolder+"\"+aArqCpy[nInc]

         If AScan(aArquivos,cRpt) = 0 //Para que não tenha que copiar os Rpts mais de uma vez
            // Se não existir o .RPT informado no EEA, guarda uma mensagem na string pra mostrar no final.
            If !File(cDirCrystal+"\"+AllTrim(aArqCpy[nInc]))
               cMsg += EEA->(" - " + AllTrim(EEA_COD) + " - " + AllTrim(EEA_TITULO) + "("+AllTrim(Tabela("ID",Left(EEA_IDIOMA,6),.f.))+")" + ENTER)
               EEA->(DbSkip())
               Loop
            EndIf

            // Copia da pasta Crystal para a pasta de destino
            AvCpyFile(cDirCrystal+"\"+aArqCpy[nInc],cRpt,.t.)
            //Adiciona no array de arquivos gerados, para compactação depois
            AAdd(aArquivos, cRpt)
         EndIf
      Next

      /* RMD - 30/05/18 - Exporta em TXT
      NewEEA->(DbAppend())
      AvReplace("EEA","NewEEA")
      NewEEA->EEA_CODMEM := ""
      */
      cLine := ""
      For nCpoEEA := 1 To EEA->(FCount())
         If nCpoEEA <> 1
            cLine += ";"
         EndIf
         If EEA->(FieldName(nCpoEEA)) == "EEA_CODMEM"
            cLine += "  "
         Else
            cLine += StrTran(AvConvert(AvSx3(EEA->(FieldName(nCpoEEA)),AV_TIPO),"C",,(EEA->&(FieldName(nCpoEEA)))), ";", ",")
         EndIf
      Next
      FWrite(nHdlEEA, cLine + ENTER)

      /* RMD - 30/05/18 - A utilização de dicionário de documentos no EG4 foi descontinuada
      If lDicDocs .And. EEA->EEA_DOCAUT $ cSim
         If !lCriadoEG4
            If !(lCriadoEG4 := EG4->(CriaArquivo()) ) //Cria DBF do EG4
               Break
            EndIf
         EndIf
         EG4->(DbSetOrder(1))

         If !lCriadoSX3
            If !(lCriadoSX3 := SX3->(CriaArquivo()) ) //Cria DBF do SX3
               Break
            EndIf
         EndIf

         EG4->(DbSeek( xFilial()+EEA->EEA_COD ))
         While EG4->(!EoF()) .And. (xFilial()+EEA->EEA_COD) == EG4->(EG4_FILIAL+EG4_CODEEA)

            If EG4->EG4_CMPSX3 $ cCposEG4 // para o campo não ser copiado mais de uma vez
               Exit
            EndIf

            If SX3->(DbSeek(EG4->EG4_CMPSX3))
               NewEG4->(DbAppend())
               SimpleReplace("EG4","NewEG4")
               cCposEG4 += EG4->EG4_CMPSX3+"\" // para o campo não ser copiado mais de uma vez

               NewSX3->(DbAppend())
               SimpleReplace("SX3","NewSX3")

               If !Empty(SX3->X3_TRIGGER) .And. SX3->X3_TRIGGER = "S"

                  If SX7->(DbSeek(SX3->X3_CAMPO)) //se houver gatilho no campo do EG4/SX3
                     If !lCriadoSX7
                        If !(lCriadoSX7 := SX7->(CriaArquivo()) )
                           Break
                        EndIf
                     EndIf
                  EndIf

                  While SX7->(!EoF()) .And. SX3->X3_CAMPO == SX7->X7_CAMPO
                     NewSX7->(DbAppend())
                     SimpleReplace("SX7","NewSX7")
                     SX7->(DbSkip())
                  EndDo

               EndIf

               //se houver folder no campo do EG4/SX3 e não for uma pasta padrão
               If !Empty(SX3->X3_FOLDER) .And. !(SX3->X3_FOLDER $ "1/2")

                  If !(SX3->X3_FOLDER $ cCposSXA) .And. SXA->(DbSeek("EG4"+SX3->X3_FOLDER))
                     If !lCriadoSXA
                        If !(lCriadoSXA := SXA->(CriaArquivo()) )
                           Break
                        EndIf
                     EndIf
                     NewSXA->(DbAppend())
                     SimpleReplace("SXA","NewSXA")
                     cCposSXA += SX3->X3_FOLDER+"\"
                  EndIf

               EndIf

               If !Empty(SX3->X3_F3) //se houver consulta no campo do EG4/SX3

                  If !(SX3->X3_F3 $ cCposSXB) .And. SXB->(DbSeek(SX3->X3_F3))
                     If !lCriadoSXB
                        If !(lCriadoSXB := SXB->(CriaArquivo()) )
                           Break
                        EndIf
                     EndIf

                     cCposSXB += SX3->X3_F3

                     While SXB->(!EoF()) .And. SX3->X3_F3 == SXB->XB_ALIAS
                        NewSXB->(DbAppend())
                        SimpleReplace("SXB","NewSXB")
                        SXB->(DbSkip())
                     EndDo

                  EndIf

               EndIf

            EndIf
            EG4->(DbSkip())
         EndDo
      EndIf
      */

      EEA->(DbSkip())
   EndDo

   FClose(nHdlEEA)

   // Compacta os arquivos gerados
   If Empty(MsCompress(aArquivos, cArquivo , SENHACOMPRESS )) //se retornar uma string em branco, então a compressão não foi realizada
      MsgStop(STR0008,STR0044)// "Os arquivos gerados não puderam ser compactados.","Aviso"
      Break
   EndIf

   If !Empty(cMsg) //mensagem caso algum registro não possa ser gerado.
      cMsg := STR0009 + "," + ; //"Os dados foram gerados com sucesso"
              STR0010 + ENTER + cMsg + ENTER +; //" exceto pelos seguintes documentos não puderam ser gerados:"
              STR0011 + ENTER +; //"Possíveis motivos: "
              Space(3) + STR0012 //"- O arquivo para a geração de documentos (.RPT ou .EXE) especificado no cadastro de Documentos não existe."

      EECView(cMsg,STR0044) //"Aviso"
   Else
      MsgInfo(STR0009 + "!",STR0013)//"Os dados foram gerados com sucesso","Sucesso"
   EndIf

End Sequence

cMsg := ""

For i := 1 to Len(aArquivos) //Apaga os arquivos, pois já foram compactados
   If FErase(aArquivos[i]) = -1
      cMsg += " - " + aArquivos[i] + ENTER
   EndIf
Next

If !Empty(cMsg) // se não conseguiu apagar algum arquivo temporário...
   cMsg := STR0014 + ENTER + cMsg + ENTER +;//"Os seguintes arquivos temporários não puderam ser apagados:"
           STR0015 + cFolder //"Faça a exclusão manual dos mesmos. Local: "
   EECView(cMsg,STR0044)  //"Aviso"
Else
   If lIsDir(cFolder)
      DirRemove(cFolder)
   EndIf
EndIf

RestOrd(aOrd,.t.)

Return Nil

/*
Função    : SimpleReplace
Objetivo  : Executar replace de todos os campos de um alias para outro, considerando que tenham estruturas iguais
Autor     : João Pedro Macimiano Trabbold
Data/Hora : 17/06/05 - 09:23
Obs.:     :
*/
Static Function SimpleReplace(cOrigem,cDestino)
//Local i

Begin Sequence

   /*
   For i := 1 to (cOrigem)->(FCount())
      (cDestino)->&((cOrigem)->(FieldName(i))) := (cOrigem)->&((cOrigem)->(FieldName(i)))
   Next
   */

   AvReplace(cOrigem,cDestino)

End Sequence

Return Nil

/*
Função    : DocExpValid
Objetivo  : Validação do nome do arquivo que será gerado
Autor     : João Pedro Macimiano Trabbold
Data/Hora : 16/06/05 - 13:44
Obs.:     :
*/
Static Function DocExpValid()

If Empty(cArquivo)
   MsgInfo(STR0016,STR0044) //"Informe o nome do arquivo","Aviso"
   Return .f.
EndIf
// \/:*?"<>|
If At("\",cArquivo) > 0 .Or. At("/",cArquivo) > 0 .Or.;
   At(":",cArquivo) > 0 .Or. At("*",cArquivo) > 0 .Or.;
   At("?",cArquivo) > 0 .Or. At('"',cArquivo) > 0 .Or.;
   At("<",cArquivo) > 0 .Or. At(">",cArquivo) > 0 .Or.;
   At("|",cArquivo) > 0

   MsgInfo(STR0017 + ' \ / : * ? " < > | ',STR0044)//"O nome do arquivo não pode conter os seguintes caracteres: " ## ,"Aviso"
   Return .f.
EndIf

// Esta deve ser a última validação!!!
If File(cDirCrystal + "\" + AllTrim(cArquivo) + ".ERU")
   If MsgYesNo(STR0018) //"O nome de arquivo informado já existe. Deseja apagá-lo e gerar novamente?"
      If FErase(cDirCrystal + "\" + AllTrim(cArquivo) + ".ERU") = -1
         MsgStop(STR0019 + AllTrim(Str(FError()))) //"O arquivo não pôde ser apagado. Erro: "
         Return .f.
      EndIf
   Else
      Return .f.
   EndIf
EndIf

Return .t.

/*
Funcao     : Av2DocImport()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Importar dados de documentos do EEA
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 17/06/05 - 14:00
Revisao    :
Obs.       :
*/
*---------------------*
Function Av2DocImport() //AvDocImport()
*---------------------*
Local oDlg, aButtons
Local bOk     := {|| If( (Len(aCols) > 0 .And. !Empty(aCols[1][1]) ) ,(oDlg:End(),lOk := .t.),lOk := .f.) },;
      bCancel := {|| oDlg:End() }
Local lOk := .f.
Local x,n,i,j, cArquivoERU := ""

Local aSave := {"EEA"}, aOrd, cArq
Local cDRVOpen
Local lErroArq := .F.

Private cTempFolder, cArquivo, aHeader := {}, aCols := {}, aColsAcento := {}//a MsGetDados tira os acentos do aCols
Private lDicDocs  := EECRotinas("DIC_DOCS")
Private aRotina := MenuDef("AVDOCIMPOR")
Private oMsGet, cLastPath := "C:\"
Private cMsgGeral  := ""
Private aImported := {}
Private lDeleta := .f.
Private lTodos  := .f.
Private aResumoOk := {}, aResumoNaoOk := {}, aMsg := {}

/* RMD - 30/05/18
If lDicDocs
   AAdd(aSave,"EG4")
   AAdd(aSave,"SX3")
   AAdd(aSave,"SXB")
   AAdd(aSave,"SX7")
   AAdd(aSave,"SXA")
EndIf
aOrd := SaveOrd(aSave)
*/

Begin Sequence
   // procura o diretório crystal
   Private cDirCrystal := EasyGParam("MV_CRYSTAL")
   IF Empty(cDirCrystal)
      Help(" ",1,"MV_CRYSTAL")
      Break
   Endif
   cDirCrystal := AllTrim(cDirCrystal)
   cDirCrystal := IF(Right(cDirCrystal,1)="\",Left(cDirCrystal,Len(cDirCrystal)-1),cDirCrystal)
   If !lIsDir(cDirCrystal)
      MsgStop(STR0001,STR0044)//"O diretório informado no parâmetro MV_CRYSTAL está incorreto. A exportação de dados não poderá ser realizada.","Aviso"
      Break
   EndIf

   aButtons := {{ "BMPINCLUIR" /*"Adicionar_001"*/,{ || AddFile() }, STR0038 + " <F3>", STR0039 }} //"Adicionar arquivo" ## "Adicionar"

   aHeader := {{"Arquivo","ARQUIVO","@!",200,0,".t.",nil,"C",nil,nil } ,;
               {"Data"   ,"DATA"   ,"@!",8  ,0,".t.",nil,"C",nil,nil } ,;
               {"Hora"   ,"HORA"   ,"@!",10 ,0,".t.",nil,"C",nil,nil } }

   // escolha do arquivo a ser importado
   DEFINE MSDIALOG oDlg TITLE STR0020 FROM 1,1 To 320,470 OF oMainWnd Pixel //"Importação de dados"

      oMSGet:= MSGetDados():New(1, 1, 1, 1, 1,,,"",.T.,{},,,500,,,,"EEC2DelImp")
      oMsGet:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

      oMSGet:ForceRefresh()

      SetKey(VK_F3,{|| AddFile() })

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) Centered

   SetKey(VK_F3,Nil)

   If !lOk
      Break
   EndIf

   For i := 1 to Len(aCols)
      aCols[i][1] := aColsAcento[i]
   Next

   // ordena por data e hora, para que os últimos (mais recentes) sobreponham os mais antigos no caso de haverem registros do EEA repetidos
   aSort(aCols,,, {|x, y| DToS(x[2])+x[3] < DToS(y[2])+y[3] })

   For j := 1 to Len(aCols)

      // desconsidera se estiver deletado
      If aCols[j][Len(aCols[j])]
         Loop
      EndIf

      cArquivo := AllTrim(aCols[j][1])

      // ** Cria a pasta temporária.
      x := Left(cArquivo,Len(cArquivo)-4)
      x := cDirCrystal + SubStr(x,RAt("\",x))
      n := 0
      cTempFolder := x + StrZero(n,3)
      While lIsDir(cTempFolder)
         n++
         cTempFolder := x + StrZero(n,3)
      EndDo

      MakeDir(cTempFolder)
      // **

      /*
      cArquivo    - Arquivo ERU com caminho completo, informado pelo usuário (ex: c:\update\relatorios.eru)
      cArquivoERU - Arquivo ERU com caminho relativo, copiado para a pasta temporária
         Foi usado o cArquivoERU pois a função de descompressão (MsDecomp) só trata tipos
         de origem e destinos iguais (absoluto ou relativo)
      */

      cArquivoERU := cTempFolder + "\" + SubStr(cArquivo,RAt("\",cArquivo))
      AvCpyFile(cArquivo,cArquivoERU,.t.)
      // Descompacta os arquivos na pasta temporária criada
      If !MsDecomp(cArquivoERU, cTempFolder + "\" , SENHACOMPRESS )
         MsgStop(STR0022,STR0044) //"Os arquivos necessários para a importação de dados não puderam ser descompactados.","Aviso"
         Break
      EndIf

      // Início do processamento
      Processa({|| AuxDocImport() })

      If lIsDir(cTempFolder) //se existir a pasta
         //Remove todos os arquivos da pasta temporária
         AEval(Directory(cTempFolder+"\*.*"), { |aFile| FErase(cTempFolder+"\"+aFile[1]) })

         // Remove a pasta temporária
         DirRemove(cTempFolder)
      EndIf

   Next

   // monta a mensagem para o usuário
   For j := 1 to Len(aCols)

      If aCols[j][Len(aCols[j])] //se estiver deletado
         Loop
      EndIf

      cArquivo := AllTrim(aCols[j][1])

      cMsgFinal := ""

      If (n := AScan(aResumoOk, {|x| x[1] == cArquivo})) > 0
         cMsgFinal += Space(3) + STR0024 + ENTER //"Registros importados com sucesso:"
         While n <= Len(aResumoOk) .And. aResumoOk[n][1] == cArquivo
            cMsgFinal += Space(6) + aResumoOk[n][3]
            n++
         EndDo
         cMsgFinal += ENTER
      Else
         cMsgFinal += Space(3) + STR0025 + Repl(ENTER,2) //"Nenhum registro foi importado com sucesso."
      EndIf

      If (n := AScan(aResumoNaoOk, {|x| x[1] == cArquivo})) > 0
         cMsgFinal += Space(3) + STR0026 + ENTER //"Registros cancelados pelo usuário:"
         While n <= Len(aResumoNaoOk) .And. aResumoNaoOk[n][1] == cArquivo
            cMsgFinal += Space(6) + aResumoNaoOk[n][3]
            n++
         EndDo
         cMsgFinal += ENTER
      EndIf

      If (n := AScan(aMsg, {|x| x[1] == cArquivo})) > 0
         cMsgFinal += Space(3) + STR0027 + ENTER //"Registros não importados por erro na cópia de arquivos:"
         While n <= Len(aMsg) .And. aMsg[n][1] == cArquivo
            cMsgFinal += Space(6) + aMsg[n][3]
            n++
         EndDo
         cMsgFinal += STR0028 + ENTER //"Motivo: arquivo Crystal (.RPT) já existente na pasta Crystal não pôde ser apagado."
         cMsgFinal += "Verifique se o mesmo não está marcado com o atributo 'Somente Leitura'." + ENTER //"Motivo: arquivo Crystal (.RPT) já existente na pasta Crystal não pôde ser apagado."
      EndIf

      cMsgGeral += cArquivo + ":" + ENTER + cMsgFinal + ENTER

   Next

   EECView(cMsgGeral,STR0029,STR0030) //##,"Operação Concluída","Resumo do Processamento:"

End Sequence

If lIsDir(cTempFolder) //se existir a pasta
   //Remove todos os arquivos da pasta temporária
   AEval(Directory(cTempFolder+"\*.*"), { |aFile| FErase(cTempFolder+"\"+aFile[1]) })

   // Remove a pasta temporária
   DirRemove(cTempFolder)
EndIf

Return Nil

/*
Funcao     : EEC2DelImp()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Validar UNDELETE da linha da msgetdados
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 29/08/05 - 15:10
Revisao    :
Obs.       :
*/
*-------------------*
Function EEC2DelImp()
*-------------------*
Local i

If !aCols[n][Len(aCols[n])]
   For i := 1 to Len(aCols)
      If !aCols[i][Len(aCols[i])] .And. Upper(aColsAcento[n]) == Upper(aColsAcento[i]) .And. i <> n
         MsgInfo(STR0040,STR0044) // "O arquivo já está especificado.","Aviso"
         aCols[n][Len(aCols[n])] := .t.
         oMsGet:oBrowse:Refresh()
         Return .f.
      EndIf
   Next
EndIf

Return .t.

/*
Funcao     : AddFile()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Escolha do arquivo .ERU pelo usuário
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 29/08/05 - 13:30
Revisao    :
Obs.       :
*/
*-----------------------*
Static Function AddFile()
*-----------------------*
Local oDlg, oFont, oSay
Local lOk := .f.
Local bOk     := {|| If(DocImpValid(),(oDlg:End(),lOk := .t.),lOk := .f.) },;
      bCancel := {|| oDlg:End() }
Local aDir, i, j
Local bOld, oArquivo
Private bFileAction := {|| cArquivo := ChooseFile()}, cArquivo := Space(200)

Begin Sequence

   // escolha do arquivo a ser importado
   DEFINE MSDIALOG oDlg TITLE STR0020 FROM 1,1 To 135,375 OF oMainWnd Pixel //"Importação de dados"

      @ 31,4 to 60,185 Label STR0021 PIXEL //"Escolha o arquivo a ser importado:"

      @ 42,12 MsGet oArquivo Var cArquivo Size 150,07 Pixel Of oDlg

      @ 42,162 Button "..." Size 10,10 Pixel OF oDlg Action .t. Of oDlg

      oDlg:aControls[3]:bAction := bFileAction

      Define Font oFont Name "Arial" SIZE 0,-10 //BOLD

      @ 43,175 Say oSay Var "(F3)" Size 10,10 Pixel Of oDlg Color CLR_GRAY
      oSay:oFont := oFont

      bOld := SetKey(VK_F3)
      SetKey(VK_F3,bFileAction)

   Activate MsDialog oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,) Centered

   SetKey(VK_F3,bOld)

   If !lOk
      Break
   EndIf

   If Type("aCols[1][1]") <> "U" .And. Empty(aCols[1][1])
      ADel(aCols,1)
      ASize(aCols,Len(aCols)-1)
   EndIf

   cArquivo := Upper(AllTrim(cArquivo))

   cFolder  := If(Right(cArquivo,1) = "\",cArquivo,SubStr(cArquivo,1,RAt("\",cArquivo)))

   cArquivo += If(!File(cArquivo),"*.ERU","")//caso o usuário informe apenas a pasta.

   aDir := Directory(cArquivo)

   Private cArq

   For i := 1 to Len(aDir)
      cArq := AllTrim(Upper(cFolder+aDir[i][1]))
      lLoop := .f.
      For j := 1 To Len(aColsAcento)
         If aColsAcento[j] == cArq .And. !aCols[j][Len(aCols[j])]
            lLoop := .t.
            Exit
         EndIf
      Next
      If lLoop
         Loop
      EndIf
      aAdd(aCols, Array( Len(aHeader)+1 ) )
      n := Len(aCols)
      aCols[n][Len(aCols[n])] := .f.
      aCols[n][1] := IncSpace(cArq,aHeader[1][4],.f.)       //nome do arquivo
      aCols[n][2] := aDir[i][3]                             //data
      aCols[n][3] := IncSpace(aDir[i][4],aHeader[1][4],.f.) //hora
      AAdd(aColsAcento,cArq)
   Next

   oMsGet:oBrowse:Refresh()

End Sequence

Return Nil

/*
Funcao     : AuxDocImport()
Parametros : Nenhum
Retorno    : Nil
Objetivos  : Auxiliar AvDocImport() na importação de dados de documentos
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 17/06/05 - 17:17
Revisao    :
Obs.       :
*/
*----------------------------*
Static Function AuxDocImport()
*----------------------------*
Local cCodEEA, cChave, lFound
Local nInc, nCpoEEA
Local cCposEG4 := "", cCposSXA := "", cCposSXB := ""
Local cOrigem, cDestino
Local aArqImp := {}
Local cEEARegs := ""
Private aVerificados := {}

Begin Sequence
   EEA->(DbSetOrder(1))
   /* RMD - 30/05/18
   If lDicDocs
      SX3->(DbSetOrder(2))
      SX7->(DbSetOrder(1))
      SXA->(DbSetOrder(1))
      SXB->(DbSetOrder(1))
      EG4->(DbSetOrder(1))
   EndIf
   */

   FT_FUSE(cTempFolder+"\EEAEXPORT.TXT")
   FT_FGOTOP()

   ProcRegua(FT_FLastRec())
   IncProc(STR0023 + AllTrim(SubStr(cArquivo,RAt("\",cArquivo)+1))) //"Arquivo: "

   cEEALinha  := FT_FREADLN()
   aEEACpos := StrTokArr(cEEALinha, ";")
   FT_FSKIP()

   Begin Transaction

      While !FT_FEOF()
         
         cEEALinha  := FT_FREADLN()
         aEEALinha := StrTokArr(cEEALinha, ";")
         FT_FSKIP()
         For nCpoEEA := 1 To Len(aEEACpos)
            &("M->"+aEEACpos[nCpoEEA]) := AvConvert("C", AvSx3(aEEACpos[nCpoEEA],AV_TIPO),,aEEALinha[nCpoEEA])
         Next

         cChave := M->(EEA_FILIAL+EEA_COD+EEA_TIPDOC+EEA_IDIOMA)

         If (nPos := AScan(aImported,{|x| x[1] == cChave})) = 0
            AAdd(aImported,{cChave,lDeleta})
         EndIf

         If (lFound := EEA->(DbSeek(cChave))) //se já existir o registro atual

            If !((lTodos .Or. If(nPos = 0,(aImported[Len(aImported)][2] := CanDelEEA()),aImported[nPos][2])) .And. lDeleta)
               If (nPos := AScan(aResumoNaoOk, {|x| x[2] == cChave} ) ) > 0
                  ADel(aResumoNaoOk,nPos)
                  ASize(aResumoNaoOk,Len(aResumoNaoOk)-1)
               EndIf

               AAdd(aResumoNaoOk, {cArquivo,cChave,M->(" - " + AllTrim(EEA_COD) + " - " + AllTrim(EEA_TITULO) +;
                                                      "(" + AllTrim(Tabela("ID",Left(EEA_IDIOMA,6),.f.))+")" + ENTER) } )

               IncProc()
               Loop
            EndIf
         EndIf

         If EEA->(FieldPos("EEA_ARQADI")) > 0
            aArqImp := AA100Split(M->EEA_ARQADI)
         EndIf
         aAdd(aArqImp, M->EEA_ARQUIV)

         lErroArq := .F.

         For nInc := 1 To Len(aArqImp)
            cOrigem  := cTempFolder + "\" + AllTrim(aArqImp[nInc])
            cDestino := cDirCrystal + "\" + AllTrim(aArqImp[nInc])

            If File(cDestino)
               If FErase(cDestino) = -1
                  AAdd(aMsg, {cArquivo,cChave,M->(" - " + AllTrim(EEA_COD) + " - " + AllTrim(EEA_TITULO) + "("+AllTrim(Tabela("ID",Left(EEA_IDIOMA,6),.f.))+")" + StrTran("/Arquivo 'XXX'.", "XXX", cDestino) + ENTER) })
                  //NewEEA->(DbSkip()) - RMD-26/11/12 - Faz o Skip/Loop do While fora do FOR
                  lErroArq := .T.
                  IncProc()
                  Loop
               EndIf
            EndIf

            AvCpyFile(cOrigem,cDestino,.t.)
         Next

         //RMD - 26/11/12 - Segue ao próximo registro quando houver erro na cópia de arquivos
         If lErroArq
         	Loop
         EndIf

         If lFound
            EEA->(RecLock("EEA",.f.),DbDelete(),MsUnlock(),DbSkip())
         EndIf

         /*
         If lDicDocs
            // ** Exclui os registros já existentes
            cCodEEA := AvKey(NewEEA->EEA_COD,"EG4_CODEEA")
            EG4->(DbSeek(xFilial()+cCodEEA))
            While EG4->(EG4_FILIAL+EG4_CODEEA) == xFilial("EG4")+cCodEEA
               If SX3->(DbSeek(EG4->EG4_CMPSX3))
                  If SX7->(DbSeek(SX3->X3_CAMPO)) //se houver gatilho no campo do EG4/SX3
                     While SX7->(!EoF()) .And. SX3->X3_CAMPO == SX7->X7_CAMPO
                        SX7->(RecLock("SX7",.f.),DbDelete(),MsUnlock())
                        SX7->(DbSkip())
                     EndDo
                  EndIf
                  While SX3->(!Eof()) .And. SX3->X3_CAMPO == EG4->EG4_CMPSX3
                     SX3->(RecLock("SX3",.f.),DbDelete(),MsUnlock(),DbSkip())
                  EndDo
               EndIf
               EG4->(RecLock("EG4",.f.),DbDelete(),MsUnlock())
               EG4->(DbSkip())
            EndDo
            // **

         EndIf
         */

         EEA->(RecLock("EEA",.t.))
         //AvReplace("NewEEA","EEA") //RMD - 30/05/18
         AvReplace("M","EEA")
         EEA->(MsUnlock())

         /*
         If lDicDocs .And. NewEEA->(FieldPos("EEA_DOCAUT")) > 0 .And. NewEEA->EEA_DOCAUT $ cSim .And. Select("NewEG4") > 0
            NewEG4->(DbSeek(xFilial("EG4")+NewEEA->EEA_COD))
            While NewEG4->(EG4_FILIAL+EG4_CODEEA) == xFilial("EG4")+NewEEA->EEA_COD

               If !(NewEG4->EG4_CMPSX3 $ cCposEG4) .And. NewSX3->(DbSeek(NewEG4->EG4_CMPSX3))
                  If EG4->(DbSeek(NewEG4->&(EG4->(IndexKey()))))
                     EG4->(RecLock("EG4",.f.),DbDelete(),MsUnlock())
                  EndIf
                  EG4->(RecLock("EG4",.t.))
                  SimpleReplace("NewEG4","EG4")
                  EG4->(MsUnlock())
                  cCposEG4 += NewEG4->EG4_CMPSX3+"\" // para o campo não ser copiado mais de uma vez

                  If SX3->(DbSeek(NewSX3->&(SX3->(IndexKey()))))
                     SX3->(RecLock("SX3",.f.),DbDelete(),MsUnlock())
                  EndIf
                  SX3->(RecLock("SX3",.t.))
                  SimpleReplace("NewSX3","SX3")
                  SX3->(MsUnlock())

                  If Select("NewSX7") > 0
                     NewSX7->(DbSeek(NewSX3->X3_CAMPO)) //se houver gatilho no campo do EG4/SX3
                     While NewSX7->(!EoF()) .And. NewSX3->X3_CAMPO == NewSX7->X7_CAMPO
                        If SX7->(DbSeek(NewSX7->&(SX7->(IndexKey()))))
                           SX7->(RecLock("SX7",.f.),DbDelete(),MsUnlock())
                        EndIf
                        SX7->(RecLock("SX7",.t.))
                        SimpleReplace("NewSX7","SX7")
                        SX7->(MsUnlock())
                        NewSX7->(DbSkip())
                     EndDo
                  EndIf

                  If Select("NewSXA") > 0 .And. !Empty(NewSX3->X3_FOLDER) //se houver folder no campo do EG4/SX3

                     If !(NewSX3->X3_FOLDER $ cCposSXA) .And. NewSXA->(DbSeek("EG4"+NewSX3->X3_FOLDER))
                        If SXA->(DbSeek(NewSXA->&(SXA->(IndexKey()))))
                           SXA->(RecLock("SXA",.f.),DbDelete(),MsUnlock())
                        EndIf

                        SXA->(RecLock("SXA",.t.))
                        SimpleReplace("NewSXA","SXA")
                        SXA->(MsUnLock())
                        cCposSXA += NewSX3->X3_FOLDER+"\"
                     EndIf

               	   EndIf

                  If Select("NewSXB") > 0 .And. !Empty(NewSX3->X3_F3) //se houver consulta no campo do EG4/SX3

                     If !(NewSX3->X3_F3 $ cCposSXB) .And. NewSXB->(DbSeek(NewSX3->X3_F3))
                        cCposSXB += NewSX3->X3_F3
                        SXB->(DbSeek(NewSX3->X3_F3))
                        While SXB->(!EoF()) .And. SXB->XB_ALIAS == NewSX3->X3_F3
                           SXB->(RecLock("SXB",.f.),DbDelete(),MsUnLock())
                           SXB->(DbSkip())
                        EndDo

                        While NewSXB->(!EoF()) .And. NewSX3->X3_F3 == NewSXB->XB_ALIAS
                           SXB->(RecLock("SXB",.t.))
                           SimpleReplace("NewSXB","SXB")
                           SXB->(MsUnLock())
                           NewSXB->(DbSkip())
                        EndDo
                     EndIf
                  EndIf
               EndIf
               NewEG4->(DbSkip())
            EndDo
         EndIf
         */

         If (nPos := AScan(aResumoOk, {|x| x[2] == cChave} ) ) > 0
            ADel(aResumoOk,nPos)
            ASize(aResumoOk,Len(aResumoOk)-1)
         EndIf

         AAdd(aResumoOk, {cArquivo, cChave,;
                          M->(" - " + AllTrim(EEA_COD) + " - " + AllTrim(EEA_TITULO) +;
                          "(" + AllTrim(Tabela("ID",Left(EEA_IDIOMA,6),.f.))+")" + ENTER) } )

         IncProc()
      EndDo
      FT_FUSE()

   End Transaction

End Sequence

Return Nil

/*
Funcao     : CanDelEEA()
Parametros : Nenhum
Retorno    : .t.,.f.
Objetivos  : Exibir tela para o usuário optar se deseja substituir os dados já existentes para cada documento importado
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 20/06/05 - 09:07
Revisao    :
Obs.       :
*/
*-------------------------*
Static Function CanDelEEA()
*-------------------------*
Local oDlg, oTodos, oSay
Local cTexto := STR0031 + AllTrim(SubStr(EEA->EEA_TIPDOC,3)) + " " + AllTrim(EEA->EEA_COD) +; //"O "
                " (" + AllTrim(Tabela("ID",Left(EEA->EEA_IDIOMA,6),.f.)) + ") " +;
                STR0032//" já se encontra cadastrado no sistema. Deseja substituí-lo?"
Local nRecNo := EEA->(RecNo())
Private cCadastro := ""
Private aMemos  := { {"EEA_CODMEM","EEA_OBS"}}
Private aRotina := MenuDef("CANDELEEA") 

// #ifdef ENGLISH //quando é em inglês, o adjetivo vem antes do substantivo...
if FwRetIdiom() == "en"
   cCadastro := STR0033 + AllTrim(SubStr(EEA->EEA_TIPDOC,3)) //"Atual"
else
   cCadastro := AllTrim(SubStr(EEA->EEA_TIPDOC,3)) + " " + STR0033//"Atual"
endif


Begin Sequence

   DEFINE MSDIALOG oDlg TITLE STR0020 FROM 1,1 To 100,310 STYLE nOR(DS_MODALFRAME, WS_DLGFRAME) OF oMainWnd Pixel //"Importação de dados"

      oDlg:lEscClose := .F.

      AvBorda(oDlg)

      @ 08,8 Say oSay Var cTexto Size 140,50 Pixel Of oDlg

      @ 33,010 Button "&"+STR0046 Size 30,10 Pixel Action (lDeleta := .t.,oDlg:End()) Of oDlg //"Sim"
      @ 33,045 Button "&"+STR0047 Size 30,10 Pixel Action (lDeleta := .f.,oDlg:End()) Of oDlg //"Não"
      @ 33,080 Button "&"+STR0048 Size 30,10 Pixel Action (EEA->(DbGoTo(nRecNo)),;            //"Detalhes"
                      AxVisual("EEA",nRecNo,1,,,,"EEC2VarMemImp"),EEA->(DbGoTo(nRecNo))) Of oDlg

      @ 33,115 CheckBox oTodos VAR lTodos Prompt "&"+STR0034 Size 30, 10 Pixel Of oDlg //"Todos?"

   Activate MsDialog oDlg Centered

End Sequence

Return lDeleta

/*
Função    : EEC2VarMemImp
Objetivos : Carregar variáveis de memória para AxVisual
Autor     : João Pedro Macimiano Trabbold - 21/06/05 às 14:00
*/
Function EEC2VarMemImp
Local i
For i := 1 to EEA->(FCount())
   //Private M->&(EEA->(FieldName(i))) := EEA->(FieldGet(i))
   M->&(EEA->(FieldName(i))) := EEA->(FieldGet(i))
Next
Return Nil

/*
Funcao     : DocImpValid()
Parametros : Nenhum
Retorno    : .t./.f.
Objetivos  : Validar o arquivo informado para importação de dados
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 17/06/05 - 14:40
Revisao    :
Obs.       :
*/
*---------------------------*
Static Function DocImpValid()
*---------------------------*
Local i, cArq := AllTrim(Upper(cArquivo))

If Empty(cArq)
   MsgInfo(STR0035,STR0044) //"Informe o caminho e o nome do arquivo","Aviso"
   Return .f.
EndIf

If Right(cArq,4) <> ".ERU" .And. Right(cArq,1) <> "\"
   cArq += "\"
EndIf

If !File(cArq)

   If !lIsDir(cArq)
      MsgStop(STR0036,STR0044) //"O arquivo especificado não existe.","Aviso"
      Return .f.
   EndIf

   If Len(Directory(cArq+"*.ERU")) = 0
      MsgStop(STR0041,STR0044) //"Não há arquivos .ERU no diretório especificado.","Aviso"
      Return .f.
   EndIf

ElseIf (Len(aCols) <> 1 .Or. !Empty(aCols[1][1]) ) //A msgetdados inclui uma linha no acols automaticamente....
   For i := 1 to Len(aCols)
      If AllTrim(Upper(aColsAcento[i])) == cArq .And. !aCols[i][Len(aCols[i])]
         MsgStop(STR0042,STR0044) // "O arquivo especificado já foi escolhido.","Aviso"
         Return .f.
      EndIf
   Next
EndIf

cArquivo := cArq

Return .t.

/*
Funcao     : ChooseFile()
Parametros : Nenhum
Retorno    : cFile - Arquivo selecionado
Objetivos  : Abrir tela para escolha do arquivo a ser importado
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 17/06/05 - 14:41
Revisao    :
Obs.       : Baseado na função ChoseFile()(ecsmp01_rdm.prw) - Customização S.Magalhães - por JBJ
*/

*--------------------------*
Static Function ChooseFile()
*--------------------------*
Local cTitle:= STR0020 //"Importação de dados"
Local cMask := STR0037+"(Easy Report Update)|*.eru" //"Formato ERU " ##
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := cLastPath
Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE

SetKey(VK_F3,Nil)

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions)

If Empty(cFile)
   SetKey(VK_F3,bFileAction)
   Return cArquivo
EndIf

cLastPath := SubStr(cFile,1,RAt("\",cFile))

SetKey(VK_F3,bFileAction)

Return IncSpace(cFile,200,.f.)


/*
Função      : EECVia
Objetivo    : Posiciona e retorna .T./.F. se encontrar uma via que indica ser cadastrada pelo modulo SIGAEEC.
Parametro   : cChave = Chave de localização da via na tabela SYR.
                       Onde a chave completa é formada por Via + Origem + Destino + Tipo de transporte.
Autor       : Alexsander Martins dos Santos
Data e Hora : 06/02/2006 às 17:44.
*/
*---------------------*
Function EECVia(cChave)
*---------------------*

Local lRet     := .F.
Local aSaveOrd := SaveOrd("SYR", 1)
Local cVar     := AllTrim(readvar())
Local lEEC_VIA, lW6_VIA_TRA

SYR->(dbSetOrder(1))//YR_FILIAL+YR_VIA+YR_ORIGEM+YR_DESTINO+YR_TIPTRAN

Begin Sequence

   lEEC_VIA:= Type("M->EEC_VIA") != "U"
   lW6_VIA_TRA:= Type("M->W6_VIA_TRA") != "U" 

   // JPM
   SYR->(dbSeek(xFilial()+cChave))
   While SYR->(!EoF() .And. xFilial()+cChave == Left(&(IndexKey()),Len(xFilial()+cChave)))
      If (cModulo == "EEC" .OR. nModulo == 29 .OR. cVar == "M->EE7_VIA") .And. !Empty(SYR->YR_PAIS_DE)
         lRet := .T.
         Exit
      EndIf
      //If cModulo == "EIC" .And. Empty(SYR->YR_PAIS_DE)
      If (cModulo == "EIC" .OR. nModulo == 17 .OR. cVar == "M->W2_TIPO_EM") .And. !Empty(SYR->YR_PAIS_OR)
         lRet := .T.
         Exit
      EndIf
      //** PLB 16/10/06
      If (cModulo == "EDC" .OR. nModulo == 50)  .And.  ;
         ( (lEEC_VIA .And. !Empty(SYR->YR_PAIS_DE)) .Or. (lW6_VIA_TRA .And. !Empty(SYR->YR_PAIS_OR)) )
         lRet := .T.
         Exit
      EndIf
      //**
      SYR->(DbSkip())
   EndDo


End Sequence

//RestOrd(aSaveOrd,.T.) //MCF - 11/05/2015

Return(lRet)

/*
Funcao     : EECValidFolder()
Parametros : Objeto da enchoice
Retorno    : Referência ao objeto
Objetivos  : Forçar validação na troca de folder na Enchoice.
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 27/03/06 - 15:00
*/

*---------------------------*
Function EECValidFolder(oEnc)
*---------------------------*
Local i

If !Left(AllTrim(GetVersao(.F.)),2) == "12" //Não funciona na 12

   Begin Sequence

      _SetOwnerPrvt("nOpcFldFunc",1) // Contém o folder atual
      _SetOwnerPrvt("cGetFldFunc",Space(10)) // variável dos gets criados em cada pasta
      _SetOwnerPrvt("oEncFldFunc",oEnc)

      For i := 1 To Len(oEnc:oBox:aDialogs)
         _SetOwnerPrvt("oGet"+AllTrim(Str(i)),Nil)
         @ 999,999 MSGET &("oGet"+AllTrim(Str(i))) VAR cGetFldFunc OF oEnc:oBox:aDialogs[i]
      Next

      oEnc:oBox:bSetOption := {||&("oGet"+AllTrim(Str(nOpcFldFunc))):SetFocus(), ret := AllTrim(Upper(readvar())) == "CGETFLDFUNC",;
                              If(ret,EECFldSetF(nOpcFldFunc),), ret  } // codeblock que valida a mudança de folders
      oEnc:oBox:bChange    := {|j,i| nOpcFldFunc := j} //atualiza a variável de folder atual.

   End Sequence

EndIf

Return oEnc

//Função para determinar qual destes objetos esta dando erro (o erro é intermitente).
Static Function EECFldSetF(nOpcFldFunc)
Local o1 := oEncFldFunc
Local o2 := oEncFldFunc:oBox
Local o3 := oEncFldFunc:oBox:aDialogs[nOpcFldFunc]
Local o3 := oEncFldFunc:oBox:aDialogs[nOpcFldFunc]:Cargo
Local o4 := oEncFldFunc:oBox:aDialogs[nOpcFldFunc]:Cargo:Cargo[1]

Return oEncFldFunc:oBox:aDialogs[nOpcFldFunc]:Cargo:Cargo[1]:SetFocus()

/*
Função     : EECMontaMsg()
Objetivos  : Monta mensagem para EECView()
Parâmetros : 1 -> aHeader  - array com as informações de cabeçalho
             2 -> aDetail  - array com o conteúdo da mensagem, de acordo com o aHeader
             3 -> nSpc     - espaço entre cada coluna (padrão = 2)
             4 -> lTracoCpoVazio - Se .T., coloca um traço nos campos vazios. Padrão: .T.
             5 -> aLinhasVazias - Array com linhas do aDetail que não devem ser impressas.
Retorno    : Mensagem pronta para EECView em forma de Cabeçalho e Detalhes
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 30/09/05 às 17:00
Obs.       : aHeader por posição: aHeader[i][1] - Campo (se informado, os demais campos serão considerados com base no SX3, exceto os que forem informados.)
                                  aHeader[i][2] - Tipo
                                  aHeader[i][3] - Título
                                  aHeader[i][4] - Tamanho da Coluna
                                  aHeader[i][5] - Se .T., alinha à esquerda, se .F., alinha à direita
                                  aHeader[i][6] - Picture (se houver)
             aDetail[i][j] -> i == Linha; j == Coluna; aDetail[i][j] é o conteúdo do campo. j = 1 até Len(aHeader). i = 1 até "total de linhas".
             Utiliza o mesmo esquema do aHeader e aCols da MsGetDados.
Revisão    : Rodrigo Mendes Diaz - 10/05/06
Obs        : Ajustes para compatibilização da função com a versão 811.
*/
*----------------------------------------------------------------------------*
Function EECMontaMsg(aHeaderx, aDetailx, nSpc, lTracoCpoVazio, aLinhasVazias)
*----------------------------------------------------------------------------*
Local cMsg := "", i, j, lFound := .f.
Local nPosHeader := 6, x, nLen, nLenData := Len(AllTrim((DToC(AvCToD("01/01/01")))))

Default nSpc := 2
Default lTracoCpoVazio := .T.
Default aLinhasVazias  := {}

// para que não altere o array passado por parâmetro, caso seja utilizado novamente.
aHeader := aClone(aHeaderx)
aDetail := aClone(aDetailx)

Begin Sequence

   // Acerta aHeader, se informar caracter para cada aHeader[i]
   For i := 1 To Len(aHeader)
      If ValType(aHeader[i]) = "C"
         aHeader[i] := {aHeader[i]}
      EndIf
   Next

   // Acerta aHeader, para sempre tenha as 6 posições
   For i := 1 To Len(aHeader)
      If Len(aHeader[i]) < nPosHeader
         For j := 1 To (nPosHeader - Len(aHeader[i]))
            AAdd(aHeader[i],Nil)
         Next
      EndIf
   Next

   SX3->(DbSetOrder(2))

   // ** Constrói cabeçalho da mensagem
   For i := 1 To Len(aHeader)
      lFound := .f.

      If !Empty(aHeader[i][1]) // se informou o campo do SX3
         For j := 2 to Len(aHeader[i])
            If Empty(aHeader[i][j])
               lFound := SX3->(DbSeek(aHeader[i][1])) // Procura o campo no SX3, para pegar os dados que faltam
               Exit
            EndIf
         Next
      EndIf

      If lFound
         // Se não informou Tipo, Título, tamanho ou Picture, preenche de acordo com o SX3
         If Empty(aHeader[i][2]) //Tipo
            aHeader[i][2] := SX3->X3_TIPO
         EndIf

         If Empty(aHeader[i][3]) //Título
            aHeader[i][3] := SX3->X3_TITULO
         EndIf

         If Empty(aHeader[i][4]) //Tamanho
            aHeader[i][4] := SX3->X3_TAMANHO
         EndIf

         If Empty(aHeader[i][6]) //Picture
            aHeader[i][6] := SX3->X3_PICTURE
         EndIf
      Else
         // Se não foi informado o campo do SX3, assume tipo de acordo com o 1º "registro" do aDetail para esta coluna
         If Empty(aHeader[i][2]) //Tipo
            aHeader[i][2] := ValType(aDetail[1][i])
         EndIf

         // Se o tamanho não foi informado, pega o tamanho do maior registro do detalhe para esta coluna
         If Empty(aHeader[i][4]) //Tamanho
            nTam := 0
            For j := 1 To Len(aDetail)
               x := aDetail[j][i]
               nLen := 0
               If ValType(x) $ "C/M" .And. Len(x) > nTam
                  nLen := Len(AllTrim(x))
               ElseIf ValType(x) = "N"
                  nLen := Len(AllTrim(Str(x)))
               ElseIf ValType(x) = "D"
                  nLen := nLenData
               EndIf
               If nLen > nTam
                  nTam := nLen
               EndIf
            Next

            aHeader[i][4] := nTam
         EndIf

         If Empty(aHeader[i][6]) //Picture
            aHeader[i][6] := ""
         EndIf
      EndIf

      // Se o alinhamento não foi informado, preenche: se for numérico, alinha à direita, do contrário, alinha à direita
      If ValType(aHeader[i][5]) <> "L" //Alinhamento
         aHeader[i][5] := If(aHeader[i][2] = "N",.f.,.t.)
      EndIf

      // se é um campo numérico, conta os pontos e vírgulas da picture para redimensionar a coluna
      If aHeader[i][2] = "N"
         If !Empty(aHeader[i][6])
            aHeader[i][4] += ContaPontoVirgula(aHeader[i][6]) //para considerar os pontos e vírgula
         EndIf
      ElseIf aHeader[i][2] = "C"
         If !Empty(aHeader[i][6])
            If (nTam := Len(Transf(Repl("X",aHeader[i][4]),aHeader[i][6]))) > aHeader[i][4]
               aHeader[i][4] := nTam
            EndIf
         EndIf
      EndIf

      aHeader[i][3] := AllTrim(aHeader[i][3])
      aHeader[i][6] := AllTrim(aHeader[i][6])

      If Len(aHeader[i][3]) > aHeader[i][4] //Se o tamanho do título for maior que o tamanho da coluna, então redimensiona a coluna
         aHeader[i][4] := Len(aHeader[i][3])
      EndIf

      cMsg += IncSpace(aHeader[i][3],aHeader[i][4],!aHeader[i][5]) + Space(nSpc)

   Next

   cMsg += ENTER

   // ** Constrói separação entre cabeçalho e detalhes
   For i := 1 to Len(aHeader)
      cMsg += Repl("-",aHeader[i][4]) + Space(nSpc)
   Next

   cMsg += ENTER

   // ** Constrói os detalhes, de acordo com as informações do header
   For i := 1 To Len(aDetail)
      If AScan(aLinhasVazias,i) = 0
         For j := 1 to Len(aHeader)//'For' no aHeader e não no aDetail, para pegar os dados de formatação
            If (aHeader[j][1] == 'EXA_QTDE') //LGS-12/05/2014 - Troco a picture para não arredondar na hora de mostrar a diferença
               cAux := AllTrim(Transform(aDetail[i][j],/*"@E 9,999,999,999.999"*/AVSX3("EE9_SLDINI",6)  ))//NCF - 21/02/2016 - precisa ser compativel com a picture
            Else                                                                                          //                   do saldo de item a embarcar
               cAux := AllTrim(Transform(aDetail[i][j],aHeader[j][6]))
            EndIf
            If aHeader[j][2] = "D" .And. Empty(aDetail[i][j])
               If lTracoCpoVazio
                  cAux := Space(2) + cAux
               Else
                  cAux := ""
               EndIf
            EndIf
            If Len(cAux) = 0 .And. lTracoCpoVazio
               cAux := " - "
            EndIf
            cMsg += IncSpace(cAux,aHeader[j][4],!aHeader[j][5]) + Space(nSpc)
         Next
      EndIf
      cMsg += ENTER
   Next

End Sequence

Return cMsg

/*
Função     : ContaPontoVirgula()
Parametros : c -> String a ser verificada
Retorno    : n -> Número de pontos e de virgulas.
Objetivo   : Contar pontos e vírgula em uma string
Autor      : João Pedro Macimiano Trabbold
Data/Hora  :
*/
Static Function ContaPontoVirgula(c)
Local n := 0, nOld := 1

Begin Sequence

   While nOld <> n
      nOld := n
      If At(".",c) > 0
         n++
         c := StrTran(c,".","",,1)
      EndIf
      If At(",",c) > 0
         n++
         c := StrTran(c,",","",,1)
      EndIf
   EndDo

End Sequence

Return n

/*
Função     : EECAddLine()
Objetivos  : Adiciona linha no Detail da EECMontaMsg
Parâmetros : 1 -> aHeader  - array com as informações de cabeçalho
             2 -> aDetail  - array com o conteúdo da mensagem, de acordo com o aHeader
             3 -> Alias    - Alias do qual serão puxados os dados
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 24/01/06 às 8:50
Obs.       : só serão carregados as posições do array que possuem nome de campo do SX3
*/
*-----------------------------------------*
Function EECAddLine(aHeaderx,aDetail,cAlias)
*-----------------------------------------*
Local aHeader := AClone(aHeaderx), n, i

Default cAlias := Alias()

Begin Sequence

   // Acerta aHeader, se informar caracter para cada aHeader[i]
   For i := 1 To Len(aHeader)
      If ValType(aHeader[i]) = "C"
         aHeader[i] := {aHeader[i]}
      EndIf
   Next

   AAdd(aDetail,Array(Len(aHeader)))
   n := Len(aDetail)
   For i := 1 To Len(aHeader)
      If Type(cAlias+"->"+aHeader[i][1]) <> "U"
         aDetail[n][i] := &(cAlias+"->"+aHeader[i][1])
      EndIf
   Next

End Sequence

Return Nil

/*
Função     : EECMontaHeader()
Objetivos  : Monta aHeader para MsGetDados() e/ou MsGetDb()
Parâmetros : 1 -> xParam
             2 -> lNewGetDados
Retorno    : aHeader
Autor      : João Pedro Macimiano Trabbold
Data/Hora  : 11/10/05 às 9:25
Obs.       : se xParam for:
               1 - Caracter, será considerado como o Alias da Tabela.
               2 - Array, será considerado como a lista de campos do SX3.
                   Cada posição do array pode conter ou um caracter ou outro array:
                      1 - Caracter - quando o campo existir no SX3, pegará os dados de lá;
                      2 - Array - quando o campo não existir no SX3, deve informar os dados do aHeader para este campo.
*/

Function EECMontaHeader(xParam,lNewGetDados)
Local lAlias, aHeader := {}, i := 1, lC, lA

Default lNewGetDados := .f.

Begin Sequence

   If ValType(xParam) = "C"
      lAlias := .t.
      lC := .t.
   ElseIf ValType(xParam) = "A"
      lAlias := .f.
   Else
      Break
   EndIf

   If lAlias
      SX3->(DbSetOrder(1))
      SX3->(DbSeek(xParam))
   Else
      SX3->(DbSetOrder(2))
   EndIf

   While If(lAlias, SX3->(!Eof()) .and. SX3->X3_ARQUIVO == xParam,;
                    i <= Len(xParam))
      If !lAlias
         lC := .f.
      EndIf
      lA := .f.
      If If(lAlias, X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL,;
                    If(ValType(xParam[i]) = "C" .And. SX3->(DbSeek(IncSpace(xParam[i],10,.f.))),(lC := .t.),(lA := ValType(xParam[i]) = "A") ) )

         If lC
            If lNewGetDados
               SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_f3,x3_context,x3_cbox,x3_relacao,".T."}))
            Else
               SX3->(Aadd(aHeader,{Trim(X3Titulo()),x3_Campo,x3_picture,x3_tamanho,x3_decimal,x3_valid,x3_usado,x3_tipo,x3_arquivo,x3_context}))
            EndIf
         ElseIf lA
            SX3->(Aadd(aHeader,xParam[i]))
         EndIf

      EndIf

      If lAlias
         SX3->(DbSkip())
      Else
         i++
      EndIf

   EndDo

End Sequence

Return aHeader

/*
Função     : EECSaveFilter()
Objetivos  : Salvar o filtro do Alias atual, para retorná-lo depois com EECRestFilter()
Parâmetros : Nenhum - Salva o filtro do alias atual;  ou
             Caracter com o Alias a ser salvo; ou
             Array com os Alias dos quais os filtros serão salvos
Retorno    : aFilter -> parâmetro para ser passado para a EECRestFilter
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 24/10/05 às 9:30
*/
*----------------------------*
Function EECSaveFilter(xAlias)
*----------------------------*
Local aAlias := {}, aFilter := {}, cFilter, bFilter, i

Begin Sequence

   If ValType(xAlias) = "C"
      AAdd(aAlias,xAlias)
   ElseIf ValType(xAlias) = "A"
      aAlias := AClone(xAlias)
   Else
      AAdd(aAlias,Alias())
   EndIf

   For i := 1 To Len(aAlias)
      cFilter := (aAlias[i])->(DbFilter())
      cFilter := If(Empty(cFilter),".t.",cFilter)
      bFilter := &("{|| " + cFilter + "}")
      AAdd(aFilter,{aAlias[i],bFilter,cFilter})
   Next

End Sequence

Return aFilter

/*
Função     : EECRestFilter()
Objetivos  : Restaurar filtros dos alias salvos por EECSaveFilter()
Parâmetros : aFilter -> Array retornado por EECSaveFilter()
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 24/10/05 às 9:39
*/
*-----------------------------*
Function EECRestFilter(aFilter)
*-----------------------------*
Local i

Begin Sequence

   For i := 1 To Len(aFilter)
      If aFilter[i][3] <> ".t."
         (aFilter[i][1])->(DbClearFilter())
         (aFilter[i][1])->(DbSetFilter(aFilter[i][2],aFilter[i][3]))
      Else
         (aFilter[i][1])->(DbClearFilter())
      EndIf
   Next

End Sequence

Return Nil

/*
Função     : EECGDAppend()
Objetivos  : "Appendar" linha no aCols
Parâmetros : aCols e aHeader que estão sendo utilizados (no caso de MsNewGetDados)
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 25/10/05 às 14:04
*/
*-----------------------------------*
Function EECGDAppend(aColsx,aHeaderx)
*-----------------------------------*
Default aColsx   := aCols
Default aHeaderx := aHeader
Begin Sequence
   AAdd(aColsx,Array(Len(aHeaderx)+1))
End Sequence
Return Nil

/*
Função     : EECGDReplace()
Objetivos  : Executar replace de um registro de um arquivo para uma linha do aCols (e vice versa)
Parâmetros : Alias do arquivo
             aCols e aHeader que estão sendo utilizados (no caso de MsNewGetDados)
             laCols - Se .t., origem  = arquivo e destino = aCols
                    - Se .f., destino = arquivo e origem  = aCols
             x      - posição do aCols na qual será appendado o registro, no caso de laCols = .t., default -> ultima posição
Retorno    : Nil
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 25/10/05 às 14:04
*/
*----------------------------------------------------*
Function EECGDReplace(cAlias,aColsx,aHeaderx,laCols,x)
*----------------------------------------------------*
Local i, cCpo
Default cAlias   := Alias()
Default aColsx   := aCols
Default aHeaderx := aHeader
Default laCols   := .t.
Default x        := Len(aColsx)

Begin Sequence

   For i := 1 To Len(aHeaderx)
      cCpo := AllTrim(aHeaderx[i][2])
      If Type(cAlias+"->"+cCpo) <> "U"
         If laCols
            aColsx[x][i] := &(cAlias+"->"+cCpo)
         Else
            &(cAlias+"->"+cCpo) := aColsx[x][i]
         EndIf
      EndIf
   Next
   aColsx[x][i] := .f.

End Sequence

Return Nil

/*
Função     : EECCposEnchoice()
Objetivos  : Gera array com os campos para a Enchoice, considerando o X3_USADO do campo.
Parâmetros : Alias do Arquivo
             Array com campos que não devem ser incluídos
Retorno    : Array com campos para a Enchoice
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 17/11/05 às 10:28
*/
*------------------------------------*
Function EECCposEnchoice(cAlias,aCpos)
*------------------------------------*
Local aOrd := SaveOrd({"SX3"}), aEnc := {}

Default aCpos := {}

If ValType(aCpos) = "C"
   aCpos := {aCpos}
EndIf

Begin Sequence
   SX3->(DbSetOrder(1))
   SX3->(DbSeek(cAlias))
   While SX3->(!EoF()) .And. SX3->X3_ARQUIVO == cAlias
      If X3Uso(SX3->X3_USADO) .And. AScan(aCpos,AllTrim(SX3->X3_CAMPO)) = 0
         AAdd(aEnc,AllTrim(SX3->X3_CAMPO))
      EndIf
      SX3->(DbSkip())
   EndDo
End Sequence

RestOrd(aOrd,.T.)

Return aEnc

/*
Função     : EECAClone(a,aNotCopy)
Objetivos  : Copia array unidimensional para outro sem os campos do 2º parâmetro
Parâmetros : Array a ser copiado
             Array com campos que não serão copiados, ou string com um campo apenas.
Retorno    : Array
Autor      : João Pedro Macimiano Trabbold
Data e Hora: 17/11/05 às 10:55
*/
*----------------------------*
Function EECAClone(a,aNotCopy)
*----------------------------*
Local i, aRet := {}
Default aNotCopy := {}
If ValType(aNotCopy) = "C"
   aNotCopy := {aNotCopy}
EndIf
For i := 1 To Len(a)
   If AScan(aNotCopy,a[i]) = 0
      AAdd(aRet,a[i])
   EndIf
Next
Return aRet

/*
Função     : EECBrkLine()
Parametros : cStr -> String a ser convertida
             nLineSize -> Tamanho da linha
Retorno    : cStr -> String já convertida
Objetivo   : Quebra uma string em várias linhas, sem cortar as palavras ao meio.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 11/05/06 - 15:45
*/
Function EECBrkLine(cStr, nLineSize)
Local nPos
Default nLineSize := 68
   nPos := nLineSize
   Do While nPos < Len(cStr) .And. nPos > 0
      If SubStr(cStr, nPos, 1) <> " "
         nPos--
      Else
         cStr := Left(cStr, nPos) + ENTER + Right(cStr, Len(cStr)-nPos)
         nPos += (nLineSize + Len(ENTER))
      EndIf
   EndDo
Return cStr

/*
Funcao    : EECQUAL100()
Parametros: Nenhum
Objetivos : Permitir manutenção na tabela EXW(Cadastro de Qualidades)
Autor     : Rodrigo Mendes Diaz
Data/Hora : 06/10/05 11:00
Revisão    : Clayton Fernandes - 29/03/2011
Obs        : Adaptação do Codigo para o padrão MVC
*/
Function EECQUAL100()
Local lRet:=.T.,cOldArea:=select()
Private aMemos:={{"EXW_QUADES","EXW_DSCQUA"}}

If !EasyCallMVC("MVC_EECCAD02",1)
   Begin Sequence
      AxCadastro("EXW",STR0050)
   End Sequence
EndIf

dbselectarea(cOldArea)

Return lRet

/*
Funcao    : EECPEN100()
Parametros: Nenhum
Objetivos : Permitir manutenção na tabela EXX(Cadastro de Peneiras)
Autor     : Rodrigo Mendes Diaz
Data/Hora : 06/10/05 11:00
*/
Function EECPEN100()

Local lRet:=.T.,cOldArea:=select()

If !EasyCallMVC("MVC_PEN100EEC",1)//CRF
    Begin Sequence
       AxCadastro("EXX",STR0051,,"EECPEN100VALID()")
    End Sequence
    dbselectarea(cOldArea)
EndIf

Return lRet

/*
Funcao    : EECPEN100VALID()
Parametros: Nenhum
Objetivos : Validação do cadastro de peneiras
Autor     : Fabio Justo Hildebrand
Data/Hora : 26/12/05 13:55
*/

Function EECPEN100VALID()
Local lRet      :=.T.
Private cVar1   := ""
Private cVar2   := ""

cVar1+= "!Empty(M->EXX_P18)   .or. !Empty(M->EXX_P17) .or."
cVar1+= "!Empty(M->EXX_P16)   .or. !Empty(M->EXX_P15) .or."
cVar1+= "!Empty(M->EXX_P1413) .or. !Empty(M->EXX_MOK)"
cVar2+= "M->EXX_P18+M->EXX_P17+M->EXX_P16+M->EXX_P15+M->EXX_P1413+M->EXX_MOK <> 100"

IF(EasyEntryPoint("EECCAD02"),Execblock("EECCAD02",.F.,.F.,"VALID_EECPEN"),)  //igor chiba 22/01/2010


If ValType(M->EXX_P18) <> "U" .and. ValType(M->EXX_P17) <> "U" .and. ValType(M->EXX_P16) <> "U" .and. ;
   ValType(M->EXX_P15) <> "U" .and. ValType(M->EXX_MOK) <> "U" .and. ValType(M->EXX_P1413) <> "U"
   //if ( !Empty(M->EXX_P18) .or. !Empty(M->EXX_P17) .or. !Empty(M->EXX_P16) .or. !Empty(M->EXX_P15) .or. ;
   //     !Empty(M->EXX_P1413) .or. !Empty(M->EXX_MOK) ) .and. cValid;
   //   M->EXX_P18+M->EXX_P17+M->EXX_P16+M->EXX_P15+M->EXX_P1413+M->EXX_MOK <> 100

   If ( &(cVar1) ) .and. &(cVar2) //igor chiba 22/01/2010  variáveis para serem alteradas no ponto de entrada
      MsgInfo(STR0060,STR0043) // "A soma das porcentagens dos padrões deve totalizar 100","Atenção"
      lRet := .F.
   Endif
Endif

Return lRet

/*
Funcao    : EECTIP100()
Parametros: Nenhum
Objetivos : Permitir manutenção na tabela EXY(Cadastro de Tipos de Café)
Autor     : Rodrigo Mendes Diaz
Data/Hora : 06/10/05 11:00
*/
Function EECTIP100()

Local lRet:=.T.,cOldArea:=select()
If !EasyCallMVC("MVC_TIP100EEC",1) // CRF
    Begin Sequence
       AxCadastro("EXY",STR0052)
    End Sequence
    dbselectarea(cOldArea)
EndIf
Return lRet

/*
Funcao    : EECREJ100()
Parametros: Nenhum
Objetivos : Permitir manutenção na tabela EY1(Cadastro de Tipos Rejeição)
Autor     : Rodrigo Mendes Diaz
Data/Hora : 20/10/05 11:00
*/
Function EECREJ100()

Local lRet:=.T., cOldArea:=select()
If !EasyCallMVC("MVC_REJ100EEC",1) // CRF
    Begin Sequence
       AxCadastro("EY1",STR0053)
    End Sequence
EndIf
    dbselectarea(cOldArea)

Return lRet

/*
Funcao    : EECFIXPRE()
Parametros: Nenhum
Objetivos : Permitir manutenção na tabela EY0(Cadastro de Condições de Fixação de Preço)
Autor     : Rodrigo Mendes Diaz
Data/Hora : 03/11/05 11:00
*/
Function EECFIXPRE()

Local lRet:=.T., cOldArea := Select()
If !EasyCallMVC("MVC_FIX100EEC",1)//CRF
   Begin Sequence
      AxCadastro("EY0",STR0054)
   End Sequence
EndIf
DbSelectArea(cOldArea)

Return lRet

/*
Funcao    : AT150Valid()
Parametros: Nenhum
Objetivos : Validação dos Campos do EX7(Cadastro de Cotação de Bolsas)
Autor     : Eduardo C. Romanini
Data/Hora : 03/11/05 13:00
*/
Function AT150VALID(cCampo)

Local lRet := .T., lVld := .T. ,lOk := .T., nInc
Private nTamNY := 0, nTamBM := 0, nTamLO := 0 //LGS-20/09/2013 - Incluido a declaração das variaveis utilizadas para validação.
Begin Sequence

   If Type("nTamNY") <> "N"
      SX3->(AvSeekLast("EX7_NY"))
      nTamNY := Val(Substr(SX3->X3_CAMPO,8,2))
   EndIf

   Do Case

      //Validação dos Campos de Valores (Valor Seatlle, Valor High e Valor Low)
      Case cCampo == "VALORES"

         //Trava para que o Mês seja o primeiro campo preenchido na Inclusão
         For nInc := 1 to nTamNY

            If Empty(M->&("EX7_NYI" + StrZero(nInc,2))) .and. (!Empty(M->&("EX7_NYS" + StrZero(nInc,2))) .or.;
               !Empty(M->&("EX7_NYL" + StrZero(nInc,2))) .or. !Empty(M->&("EX7_NYH" + StrZero(nInc,2))))

               MsgInfo(STR0055,STR0043)//"Favor informar o mês"###"Atenção"
               lRet := .F.
               Break
            EndIf

            //Validação dos Intervalos de Valores
            If !Empty(M->&("EX7_NYL" + StrZero(nInc,2))) .and. !Empty(M->&("EX7_NYH" + StrZero(nInc,2)))
               If M->&("EX7_NYL" + StrZero(nInc,2)) >= M->&("EX7_NYH" + StrZero(nInc,2))

                  MsgInfo(STR0056) //"Os valores devem possuir um intervalo válido."
                  lRet := .F.
                  Break

               EndIf
            EndIf

            If !Empty(M->&("EX7_NYS" + StrZero(nInc,2)))
               If (!Empty(M->&("EX7_NYL" + StrZero(nInc,2))) .And. ;
                  M->&("EX7_NYS" + StrZero(nInc,2)) < M->&("EX7_NYL" + StrZero(nInc,2))) .Or.;
                  (!Empty(M->&("EX7_NYH" + StrZero(nInc,2))) .And. ;
                  M->&("EX7_NYS" + StrZero(nInc,2)) > M->&("EX7_NYH" + StrZero(nInc,2)))

                  MsgInfo(STR0057) //"Valor inválido. O valor Settle deve estar entre o valor Low e o valor High."
                  lRet := .F.
                  Break

               EndIf
            EndIf
         Next

         For nInc := 1 to nTamLO

            If Empty(M->&("EX7_LOI" + StrZero(nInc,2))) .and. (!Empty(M->&("EX7_LOS" + StrZero(nInc,2))) .or.;
               !Empty(M->&("EX7_LOL" + StrZero(nInc,2))) .or. !Empty(M->&("EX7_LOH" + StrZero(nInc,2))))

               MsgInfo(STR0055,STR0043)//"Favor informar o mês"###"Atenção"
               lRet := .F.
               Break
            EndIf

            If !Empty(M->&("EX7_LOL" + StrZero(nInc,2))) .and. !Empty(M->&("EX7_LOH" + StrZero(nInc,2)))
               If M->&("EX7_LOL" + StrZero(nInc,2)) >= M->&("EX7_LOH" + StrZero(nInc,2))

                  MsgInfo(STR0056) //"Os valores devem possuir um intervalo válido."
                  lRet := .F.
                  Break

               EndIf
            EndIf

            If !Empty(M->&("EX7_LOS" + StrZero(nInc,2)))
               If (!Empty(M->&("EX7_LOL" + StrZero(nInc,2))) .And. ;
                  M->&("EX7_LOS" + StrZero(nInc,2)) < M->&("EX7_LOL" + StrZero(nInc,2))) .Or.;
                  (!Empty(M->&("EX7_LOH" + StrZero(nInc,2))) .And. ;
                  M->&("EX7_LOS" + StrZero(nInc,2)) > M->&("EX7_LOH" + StrZero(nInc,2)))

                  MsgInfo(STR0057) //"Valor inválido. O valor Settle deve estar entre o valor Low e o valor High."
                  lRet := .F.
                  Break

               EndIf
            EndIf

         Next

         For nInc := 1 to nTamBM

            If Empty(M->&("EX7_BMI" + StrZero(nInc,2))) .and. (!Empty(M->&("EX7_BMS" + StrZero(nInc,2))) .or.;
               !Empty(M->&("EX7_BML" + StrZero(nInc,2))) .or. !Empty(M->&("EX7_BMH" + StrZero(nInc,2))))

               MsgInfo(STR0055,STR0043)//"Favor informar o mês"###"Atenção"
               lRet := .F.
               Break
            EndIf

            If !Empty(M->&("EX7_BML" + StrZero(nInc,2))) .and. !Empty(M->&("EX7_BMH" + StrZero(nInc,2)))
               If M->&("EX7_BML" + StrZero(nInc,2)) >= M->&("EX7_BMH" + StrZero(nInc,2))

                  MsgInfo(STR0056) //"Os valores devem possuir um intervalo válido."
                  lRet := .F.
                  Break

               EndIf
            EndIf

            If !Empty(M->&("EX7_BMS" + StrZero(nInc,2)))
               If (!Empty(M->&("EX7_BML" + StrZero(nInc,2))) .And. ;
                  M->&("EX7_BMS" + StrZero(nInc,2)) < M->&("EX7_BML" + StrZero(nInc,2))) .Or.;
                  (!Empty(M->&("EX7_BMH" + StrZero(nInc,2))) .And. ;
                  M->&("EX7_BMS" + StrZero(nInc,2)) > M->&("EX7_BMH" + StrZero(nInc,2)))

                  MsgInfo(STR0057) //"Valor inválido. O valor Settle deve estar entre o valor Low e o valor High."
                  lRet := .F.
                  Break

               EndIf
            EndIf
         Next

   	  Case cCampo == "VALORALT"

         //Validação dos Intervalos de Valores
         If !Empty(M->EX7_VLMIN) .and. !Empty(M->EX7_VLMAX)
            If M->EX7_VLMIN >= M->EX7_VLMAX

               MsgInfo(STR0056) //"Os valores devem possuir um intervalo válido."
               lRet := .F.
               Break

            EndIf
          EndIf

          If !Empty(M->EX7_VALCOT)
            If !Empty(M->EX7_VLMIN) .And.  M->EX7_VALCOT < M->EX7_VLMIN .Or.;
               !Empty(M->EX7_VLMAX) .And.  M->EX7_VALCOT > M->EX7_VLMAX

               MsgInfo(STR0057) //"Valor inválido. O valor Settle deve estar entre o valor Low e o valor High."
               lRet := .F.
               Break

            EndIf
         EndIf

      //Validação para o campo Codigo da Bolsa
      Case cCampo == "BOLSA"
         SX5->(DbSetOrder())
         //ASK 15/08/2007 - Alterada no SX5 a tabela ZB para YP
         //If !SX5->(DbSeek(xFilial("SX5")+"ZB"+M->EX7_CODBOL))
         If !SX5->(DbSeek(xFilial("SX5")+"YP"+M->EX7_CODBOL))
            MsgInfo(STR0058) //"Código não cadastrado no sistema"
            lRet := .F.
            Break
         EndIf

      //Validação para os Campos Mês.
      Case cCampo == "MES"

         For nInc := 1 to nTamNY

            If nInc > 1
               //Validação para que os campos de Meses sejam carregados na ordem correta.
               If Empty(M->&("EX7_NYI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_NYI" + StrZero(nInc,2)))
                  lOk := .F.
                  Break
               EndIf

               If !Empty(M->&("EX7_NYI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_NYI" + StrZero(nInc,2))) .and.;
                  !Empty(M->&("EX7_NYA" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_NYA" + StrZero(nInc,2)))

                  If Val(AT150Mes(M->&("EX7_NYI" + StrZero(nInc - 1,2)))) >= Val(AT150Mes(M->&("EX7_NYI" + StrZero(nInc,2)))) .and.;
                     Val(M->&("EX7_NYA" + StrZero(nInc - 1,2))) >= Val(M->&("EX7_NYA" + StrZero(nInc,2)))

                     MsgInfo(STR0061,STR0043)//"O Periodo Atual deve ser maior que o periodo anterior."###"Atenção"
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

            SX5->(DbSetOrder())
            If !Empty(M->&("EX7_NYI" + StrZero(nInc,2)))
               If !SX5->(DbSeek(xFilial("SX5")+"ML" + M->&("EX7_NYI" + StrZero(nInc,2))))
                  MsgInfo(STR0058) //"Código não cadastrado no sistema"
                  lRet := .F.
                  Break
               Else
                  /* RMD -  07/02/06
                  If !(M->&("EX7_NYI" + StrZero(nInc,2)) $ "U/Z/H/K/N") //Meses aceitos para a Bolsa de Nova York
                     lVld := .F.
                     Break
                  EndIf
                  */
               EndIf
            EndIf
         Next

         For nInc := 1 to nTamLO

            If nInc > 1

               If Empty(M->&("EX7_LOI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_LOI" + StrZero(nInc,2)))
                  lOk := .F.
                  Break
               EndIf

               If !Empty(M->&("EX7_LOI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_LOI" + StrZero(nInc,2))) .and.;
                  !Empty(M->&("EX7_LOA" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_LOA" + StrZero(nInc,2)))

                  If Val(AT150Mes(M->&("EX7_LOI" + StrZero(nInc - 1,2)))) >= Val(AT150Mes(M->&("EX7_LOI" + StrZero(nInc,2)))) .and.;
                     Val(M->&("EX7_LOA" + StrZero(nInc - 1,2))) >= Val(M->&("EX7_LOA" + StrZero(nInc,2)))

                     MsgInfo(STR0061,STR0043)//"O Periodo Atual deve ser maior que o periodo anterior."###"Atenção"
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

            SX5->(DbSetOrder())
            If !Empty(M->&("EX7_LOI" + StrZero(nInc,2)))
               If !SX5->(DbSeek(xFilial("SX5")+"ML" + M->&("EX7_LOI" + StrZero(nInc,2))))
                  MsgInfo(STR0058) //"Código não cadastrado no sistema"
                  lRet := .F.
                  Break
               Else
                  /* RMD - 07/02/06
                  If !(M->&("EX7_LOI" + StrZero(nInc,2)) $ "N/U/X/F/H/K") //Meses aceitos para a Bolsa de Londres
                     lVld := .F.
                     Break
                  EndIf
                  */
               EndIf
            EndIf
         Next

         For nInc := 1 to nTamBM

            If nInc > 1

               If Empty(M->&("EX7_BMI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_BMI" + StrZero(nInc,2)))
                  lOk := .F.
                  Break
               EndIf

               If !Empty(M->&("EX7_BMI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_BMI" + StrZero(nInc,2))) .and.;
                  !Empty(M->&("EX7_BMA" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_BMA" + StrZero(nInc,2)))

                  If Val(AT150Mes(M->&("EX7_BMI" + StrZero(nInc - 1,2)))) >= Val(AT150Mes(M->&("EX7_BMI" + StrZero(nInc,2)))) .and.;
                     Val(M->&("EX7_BMA" + StrZero(nInc - 1,2))) >= Val(M->&("EX7_BMA" + StrZero(nInc,2)))

                     MsgInfo(STR0061,STR0043)//"O Periodo Atual deve ser maior que o periodo anterior."###"Atenção"
                     lRet := .F.
                     Break
                  EndIf
               EndIf
            EndIf

            SX5->(DbSetOrder())
            If !Empty(M->&("EX7_BMI" + StrZero(nInc,2)))
               If !SX5->(DbSeek(xFilial("SX5")+"ML" + M->&("EX7_BMI" + StrZero(nInc,2))))
                  MsgInfo(STR0058) //"Código não cadastrado no sistema"
                  lRet := .F.
                  Break
               Else
                  /* RMD - 07/02/06
                  If !(M->&("EX7_BMI" + StrZero(nInc,2)) $ "U/Z/H/K/N") //Meses aceitos para a Bolsa BM&F
                     lVld := .F.
                     Break
                  EndIf
                  */
               EndIf
            EndIf
         Next

      Case cCampo == "MESID"

         //Validação para a seleção de meses por Bolsa.
         //Alguns meses só são aceitos em alguns tipos de Bolsa.

         /*
            Id Mês       Descrição |
          |------------------------|
          | F      |      Janeiro  |
          | H      |       Março   |
          | K      |       Maio    |
          | N      |       Julho   |
          | U      |      Setembro |
          | X      |      Novembro |
          | Z      |      Dezembro |
          --------------------------
         */

         SX5->(DbSetOrder())
         If !SX5->(DbSeek(xFilial("SX5")+"ML"+M->EX7_IDMES))
            MsgInfo(STR0058) //"Código não cadastrado no sistema"
            lRet := .F.
            Break
         Else
            If M->EX7_CODBOL == AvKey("NY","EX7_CODBOL") .or. M->EX7_CODBOL == AvKey("BMF","EX7_CODBOL")
               If !(M->EX7_IDMES $ "U/Z/H/K/N") //Meses aceitos para a Bolsa de Nova York e BM&F
                  lVld := .F.
               EndIf
            ElseIf M->EX7_CODBOL == AvKey("LON","EX7_CODBOL")
               If !(M->EX7_IDMES $ "N/U/X/F/H/K") //Meses aceitos para a Bolsa de Londres
                  lVld := .F.
               EndIf
            EndIF
         EndIf

      Case cCampo == "ANO"

         For nInc := 2 to nTamNY

            If !Empty(M->&("EX7_NYI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_NYI" + StrZero(nInc,2))) .and.;
               !Empty(M->&("EX7_NYA" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_NYA" + StrZero(nInc,2)))

               If Val(AT150Mes(M->&("EX7_NYI" + StrZero(nInc - 1,2)))) >= Val(AT150Mes(M->&("EX7_NYI" + StrZero(nInc,2)))) .and.;
                  Val(M->&("EX7_NYA" + StrZero(nInc - 1,2))) >= Val(M->&("EX7_NYA" + StrZero(nInc,2)))

                  MsgInfo(STR0061,STR0043)//"O Periodo Atual deve ser maior que o periodo anterior."###"Atenção"
                  lRet := .F.
                  Break
               EndIf
            EndIf
         Next

         For nInc := 2 to nTamLO
            If !Empty(M->&("EX7_LOI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_LOI" + StrZero(nInc,2))) .and.;
               !Empty(M->&("EX7_LOA" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_LOA" + StrZero(nInc,2)))

               If Val(AT150Mes(M->&("EX7_LOI" + StrZero(nInc - 1,2)))) >= Val(AT150Mes(M->&("EX7_LOI" + StrZero(nInc,2)))) .and.;
                  Val(M->&("EX7_LOA" + StrZero(nInc - 1,2))) >= Val(M->&("EX7_LOA" + StrZero(nInc,2)))

                  MsgInfo(STR0061,STR0043)//"O Periodo Atual deve ser maior que o periodo anterior."###"Atenção"
                  lRet := .F.
                  Break
               EndIf
            EndIf
         Next

         For nInc := 2 to nTamBM
            If !Empty(M->&("EX7_BMI" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_BMI" + StrZero(nInc,2))) .and.;
               !Empty(M->&("EX7_BMA" + StrZero(nInc - 1,2))) .and. !Empty(M->&("EX7_BMA" + StrZero(nInc,2)))

               If Val(AT150Mes(M->&("EX7_BMI" + StrZero(nInc - 1,2)))) >= Val(AT150Mes(M->&("EX7_BMI" + StrZero(nInc,2)))) .and.;
                  Val(M->&("EX7_BMA" + StrZero(nInc - 1,2))) >= Val(M->&("EX7_BMA" + StrZero(nInc,2)))

                  MsgInfo(STR0061,STR0043)//"O Periodo Atual deve ser maior que o periodo anterior."###"Atenção"
                  lRet := .F.
                  Break
               EndIf
            EndIf

         Next

   EndCase

End Sequence

If !lOk
   MsgInfo(STR0063,STR0043)//"Favor Preencher os Meses na Ordem Correta."###"Atenção"
   lRet := .F.
EndIf

If !lVld
   MsgInfo(STR0062,STR0043)//"O Mês selecionado não é valido para a Bolsa em Uso"###"Atenção"
   lRet := .F.
EndIf

Return lRet

/*
Funcao    : EECBEB100()
Parametros: Nenhum
Objetivos : Permitir manutenção na tabela EY3(Cadastro de Bebidas)
Autor     : Fabio Justo Hildebrand
Data/Hora : 19/12/05 17:00
*/
Function EECBEB100()

Local lRet:=.T.,cOldArea:=select()

    Begin Sequence
       AxCadastro("EY3",STR0059)
    End Sequence
    dbselectarea(cOldArea)

Return lRet


/*
Funcao    : AT150MAN(cAlias,nReg,nOpc)
Parametros: cAlias
            nReg
            nOpc
Objetivos : Permitir manutenção na tabela EX4(Cotação de Bolsas)
Autor     : Eduardo C. Romanini
Data/Hora : 04/01/06 14:45
*/

Function AT150MAN(cAlias,nReg,nOpc)

Local lRet := .T., nOpcA := 0
Local aCampos := {} //Campos apresentados na tela.
Local aPos:= {}

Local aUsado := {}  //OAP - 05/11/2010 - Campos incluidos pelo usuário
Local i := 0

Local bOk     := {|| If(AT150BOk(),nOpcA:=1,),If(nOpcA=1,oDlg:End(),)}
Local bCancel := {|| oDlg:End()}

//Variavel com CodeBlock usado no Botão OK do AxAltera.
Local aParam  := {{|| .T.},{|| .T.},{|| EX7->EX7_MESANO := AT150Mes(M->EX7_IDMES) + M->EX7_ANO},{|| .T.}}
Local nInc

Private aTela[0][0],aGets[0]
Private nTamNY := 0, nTamBM := 0, nTamLO := 0

Private nOpcao := nOpc // variáveis para ponto de entrada.
Private nIdMesOld, nAnoOld

Begin Sequence

   INCLUI := nOpc == INCLUIR
   ALTERA := nOpc == ALTERAR
   EXCLUI := nOpc == EXCLUIR

   //Verifica a quantidade de campos para cada bolsa.
   SX3->(DbSetOrder(2))

   SX3->(AvSeekLast("EX7_NY"))
   nTamNY := Val(Substr(SX3->X3_CAMPO,8,2))

   SX3->(AvSeekLast("EX7_LO"))
   nTamLO := Val(Substr(SX3->X3_CAMPO,8,2))

   SX3->(AvSeekLast("EX7_BM"))
   nTamBM := Val(Substr(SX3->X3_CAMPO,8,2))

   SX3->(DbSetOrder(1))

   SX3->(DbSeek(cAlias))
   If nOpc = INCLUIR
      While SX3->(!EOF()) .and. SX3->X3_ARQUIVO = cAlias

         //Carrega as Variavéis de Memória e o array aCampos para inclusão.
         //OAP -04/11/2010- Inclusão dos campos adicionados pelo uauário:  .or. (Alltrim(SX3->X3_PROPRI) == "U" .AND. X3Uso(SX3->X3_USADO))
         If(Substr(SX3->X3_CAMPO,5,2) $ "NY/LO/BM") .or. SX3->X3_CAMPO = "EX7_DATA" .or. (Alltrim(SX3->X3_PROPRI) == "U" .AND. X3Uso(SX3->X3_USADO))
            M->&((cAlias)->(SX3->X3_CAMPO)) := CRIAVAR(SX3->X3_CAMPO)
            Aadd(aCampos,SX3->X3_CAMPO)
            //OAP -05/11/2010- Array utilizado na gravação dos campos "USADOS"
            If (Alltrim(SX3->X3_PROPRI) == "U" .AND. X3Uso(SX3->X3_USADO))
               Aadd(aUsado,SX3->X3_CAMPO)
            EndIf
         EndIf

         SX3->(DbSkip())
      EndDo

      DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

         aPos := PosDlg(oDlg)

         EnChoice(cAlias,nReg,nOpc,,,,aCampos,aPos)

      ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,bOk,bCancel))

      If nOpcA = 1 //Botão Ok e Validado

         //Para cada mês preenchido na inclusão, é gravado um registro no EX7.
         For nInc := 1 to nTamNY

            If Empty(M->&("EX7_NYI" + StrZero(nInc,2)))
               Exit
            EndIf

            If EX7->(RecLock("EX7",.T.))

               //OAP - 05/11/2010 - Gavação dos campos incluidos pelo usuário
               For i:=1 To Len(aUsado)
                  EX7->&(aUsado[i]) := M->&(aUsado[i])
               Next i

               EX7->EX7_CODBOL := "NY"
               EX7->EX7_DATA   := M->EX7_DATA
               EX7->EX7_VLMIN  := M->&("EX7_NYL" + StrZero(nInc,2))
               EX7->EX7_VALCOT := M->&("EX7_NYS" + StrZero(nInc,2))
               EX7->EX7_VLMAX  := M->&("EX7_NYH" + StrZero(nInc,2))
               EX7->EX7_MESANO := AT150Mes(M->&("EX7_NYI" + StrZero(nInc,2))) + M->&("EX7_NYA" + StrZero(nInc,2))

               EX7->(MsUnlock("EX7"))
            EndIf

         Next

         For nInc := 1 to nTamLO

            If Empty(M->&("EX7_LOI" + StrZero(nInc,2)))
               Exit
            EndIf

            If EX7->(RecLock("EX7",.T.))

               //OAP - 05/11/2010 - Gavação dos campos incluidos pelo usuário
               For i:=1 To Len(aUsado)
                  EX7->&(aUsado[i]) := M->&(aUsado[i])
               Next i

               EX7->EX7_CODBOL := "LON"
               EX7->EX7_DATA   := M->EX7_DATA
               EX7->EX7_VLMIN  := M->&("EX7_LOL" + StrZero(nInc,2))
               EX7->EX7_VALCOT := M->&("EX7_LOS" + StrZero(nInc,2))
               EX7->EX7_VLMAX := M->&("EX7_LOH" + StrZero(nInc,2))
               EX7->EX7_MESANO := AT150Mes(M->&("EX7_LOI" + StrZero(nInc,2))) + M->&("EX7_LOA" + StrZero(nInc,2))

               EX7->(MsUnlock("EX7"))
            EndIf

         Next

         For nInc := 1 to nTamBM

            If Empty(M->&("EX7_BMI" + StrZero(nInc,2)))
               Exit
            EndIf


            If EX7->(RecLock("EX7",.T.))

               //OAP - 05/11/2010 - Gavação dos campos incluidos pelo usuário
               For i:=1 To Len(aUsado)
                  EX7->&(aUsado[i]) := M->&(aUsado[i])
               Next i

               EX7->EX7_CODBOL := "BMF"
               EX7->EX7_DATA   := M->EX7_DATA
               EX7->EX7_VLMIN  := M->&("EX7_BML" + StrZero(nInc,2))
               EX7->EX7_VALCOT := M->&("EX7_BMS" + StrZero(nInc,2))
               EX7->EX7_VLMAX  := M->&("EX7_BMH" + StrZero(nInc,2))
               EX7->EX7_MESANO := AT150Mes(M->&("EX7_BMI" + StrZero(nInc,2))) + M->&("EX7_BMA" + StrZero(nInc,2))

               EX7->(MsUnlock("EX7"))
            EndIf

         Next

      EndIf

   Else

      aCampos := {"EX7_CODBOL","EX7_DSCBOL","EX7_DATA","EX7_VLMIN",;
                  "EX7_VALCOT" ,"EX7_VLMAX" ,"EX7_IDMES" , "EX7_DSCMES",;
                  "EX7_ANO" }

      //OAP - Inclusão de campos asicionados pelo usuária. Assim os campos poderam sofrer alteração.
      aCampos := AddCpoUser(aCampos,"EX7","1")

      For nInc := 1 TO (cAlias)->(FCount())
          M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
      Next nInc

      If nOpc = VISUALIZAR
         nOpcA := AxVisual(cAlias,nReg,nOpc,aCampos)
      ElseIf nOpc = ALTERAR
         nIdMesOld := AT150Mes(Left(EX7->EX7_MESANO,2))
         nAnoOld   := Right(EX7->EX7_MESANO,4)
         nOpcA := AxAltera(cAlias,nReg,nOpc,aCampos,,,,"AT150AOk()",,,,aParam)
      ElseIf nOpc = EXCLUIR
         nOpcA := AxDeleta(cAlias,nReg,nOpc,,aCampos)
      EndIf
   EndIf

   If ValType(nOpcA) <> "N"
      nOpcA := 0
   EndIf

   If nOpcA == 1
      If EasyEntryPoint("EECCAD02")
         ExecBlock("EECCAD02",.F.,.F.,"FIM_GRV_COTACAO")
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao    : AT150BOk()
Parametros: Nenhum
Objetivos : Validação do Botão Ok, no AT150MAN(Manutenção de Cotação de Bolsas)
Autor     : Eduardo C. Romanini
Data/Hora : 06/12/05 17:00
*/
Function AT150BOk

Local lRet := .T., x, nInc

Begin Sequence

   //Valida os campos Obrigatórios
   If !Obrigatorio(aGets,aTela)
      lRet := .F.
      Break
   EndIf

   //Valida se nenhum mês foi preenchido.
   If Empty(M->EX7_NYM01) .and. Empty(M->EX7_LOM01) .and. Empty(M->EX7_BMM01)

      MsgInfo(STR0064,STR0043)//"Nenhuma Cotação foi Preenchida"###"Atenção"
      lRet := .F.
      Break
   EndIf

   For nInc := 1 to nTamNY

      //Verifica se existe algum campo vazio.
      If !Empty(M->&("EX7_NYI" + StrZero(nInc,2)))

         If Empty(M->&("EX7_NYA" + StrZero(nInc,2))) .or. Empty(M->&("EX7_NYL" + StrZero(nInc,2))) .or.;
            Empty(M->&("EX7_NYH" + StrZero(nInc,2))) .or. Empty(M->&("EX7_NYS" + StrZero(nInc,2)))

            MsgInfo(STR0065 + StrZero(nInc,2),STR0043)//"Favor Preencher todos os campos da Sequencia NY : "###"Atenção"
            lRet := .F.
            Break

         EndIf
      EndIf

      //Verifica se existe dados duplicados na Tela
      For x:= 1 to nTamNY

         If x = nInc
            Loop
         EndIf

         If !Empty(M->&("EX7_NYI" + StrZero(nInc,2)))

            If M->&("EX7_NYI" + StrZero(nInc,2)) = M->&("EX7_NYI" + StrZero(x,2)) .and. ;
               M->&("EX7_NYA" + StrZero(nInc,2)) = M->&("EX7_NYA" + StrZero(x,2))

               MsgInfo(STR0066 + StrZero(nInc,2)+ STR0067 + StrZero(x,2) +STR0068, STR0043 )//"Os campos NY :"###" e "###" são iguais"###"Atenção"
               lRet := .F.
               Break

            EndIf
         EndIf
      Next

      //Verifica se não estão sendo gravadas informações já gravadas na base.

      EX7->(DbSetOrder(1))
      If !Empty(M->&("EX7_NYI" + StrZero(nInc,2)))

         If EX7->(DbSeek(xFilial("EX7") + (AT150Mes(M->&("EX7_NYI" + StrZero(nInc,2))) + (M->&("EX7_NYA" + StrZero(nInc,2)))) + Dtos(M->EX7_DATA)+ "NY "))
            MsgInfo( STR0077 + STR0069 + STR0078 +(M->&("EX7_NYI" + StrZero(nInc,2))) + STR0070 + (M->&("EX7_NYA" + StrZero(nInc,2))) , STR0043 )//"Já existe cotação cadastrada para a Bolsa NY, Mês: "###" e Ano: "###"Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf
   Next

   For nInc := 1 to nTamLO

      If !Empty(M->&("EX7_LOI" + StrZero(nInc,2)))
         If Empty(M->&("EX7_LOA" + StrZero(nInc,2))) .or. Empty(M->&("EX7_LOL" + StrZero(nInc,2))) .or.;
            Empty(M->&("EX7_LOH" + StrZero(nInc,2))) .or. Empty(M->&("EX7_LOS" + StrZero(nInc,2)))

            MsgInfo( STR0071 + StrZero(nInc,2),STR0043)//"Favor Preencher todos os campos da Sequencia LO : "###"Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf

      //Verifica se existe dados duplicados na Tela
      For x:= 1 to nTamLO

         If x = nInc
            Loop
         EndIf

         If !Empty(M->&("EX7_LOI" + StrZero(nInc,2)))

            If M->&("EX7_LOI" + StrZero(nInc,2)) = M->&("EX7_LOI" + StrZero(x,2)) .and. ;
               M->&("EX7_LOA" + StrZero(nInc,2)) = M->&("EX7_LOA" + StrZero(x,2))

               MsgInfo(STR0072 + StrZero(nInc,2)+ STR0067 + StrZero(x,2) + STR0068, STR0043 )//"Os campos LO :"###" e "###" são iguais"###"Atenção"
               lRet := .F.
               Break
             EndIf
         EndIf
      Next

      If !Empty(M->&("EX7_LOI" + StrZero(nInc,2)))
         If EX7->(DbSeek(xFilial("EX7") +(AT150Mes(M->&("EX7_LOI" + StrZero(nInc,2))) + (M->&("EX7_LOA" + StrZero(nInc,2)))) + Dtos(M->EX7_DATA)+ "LO "))
            MsgInfo(STR0077 + STR0073 + STR0078 + (M->&("EX7_LOI" + StrZero(nInc,2))) +STR0070 + (M->&("EX7_LOA" + StrZero(nInc,2))) , STR0043 )//"Já existe cotação cadastrada para a Bolsa LO, Mês "###" e Ano: "###"Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf
   Next

   For nInc := 1 to nTamBM
      If !Empty(M->&("EX7_BMI" + StrZero(nInc,2)))
         If Empty(M->&("EX7_BMA" + StrZero(nInc,2))) .or. Empty(M->&("EX7_BML" + StrZero(nInc,2))) .or.;
            Empty(M->&("EX7_BMH" + StrZero(nInc,2))) .or. Empty(M->&("EX7_BMS" + StrZero(nInc,2)))

            MsgInfo(STR0074 + StrZero(nInc,2),STR0043)//"Favor Preencher todos os campos da Sequencia BM : "###"Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf

      //Verifica se existe dados duplicados na Tela
      For x:= 1 to nTamBM

         If x = nInc
            Loop
         EndIf

         If !Empty(M->&("EX7_BMI" + StrZero(nInc,2)))

            If M->&("EX7_BMI" + StrZero(nInc,2)) = M->&("EX7_BMI" + StrZero(x,2)) .and. ;
               M->&("EX7_BMA" + StrZero(nInc,2)) = M->&("EX7_BMA" + StrZero(x,2))

               MsgInfo(STR0075 + StrZero(nInc,2)+ STR0067 + StrZero(x,2) + STR0068, STR0043 )//"Os campos BM :"###" e "###" são iguais"###"Atenção"
               lRet := .F.
               Break
            EndIf
         EndIf
      Next

      If !Empty(M->&("EX7_BMI" + StrZero(nInc,2)))
         If EX7->(DbSeek(xFilial("EX7") + (AT150Mes(M->&("EX7_BMI" + StrZero(nInc,2))) + (M->&("EX7_BMA" + StrZero(nInc,2)))) + Dtos(M->EX7_DATA)+ "BM "))
            MsgInfo(STR0077 + STR0076 + STR0078 +(M->&("EX7_BMI" + StrZero(nInc,2))) + STR0070 + (M->&("EX7_BMA" + StrZero(nInc,2))) , STR0043 )//"Já existe cotação cadastrada para a Bolsa BM, Mês "###"e ano:"###"Atenção"
            lRet := .F.
            Break
         EndIf
      EndIf
   Next

End Sequence
Return lRet


Function AT150AOk

Local lRet := .T.

Begin Sequence

   EX7->(DbSetOrder(1))
   If nIdMesOld <> M->EX7_IDMES .Or. nAnoOld <> M->EX7_ANO
      If EX7->(DbSeek(xFilial("EX7") + (AT150Mes(M->EX7_IDMES) + M->EX7_ANO) + Dtos(M->EX7_DATA) + M->EX7_CODBOL))
         MsgInfo(STR0077 + M->EX7_CODBOL + STR0078 + M->EX7_IDMES + STR0070+ M->EX7_ANO , STR0043 )//"Já existe cotação cadastrada para a Bolsa "###" , Mês "###" e Ano "###"Atenção"
         lRet := .F.
         Break
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao    : EECCADFND()
Parametros: Nenhum
Objetivos : Cadastro de First Notice Day
Autor     : Eduardo C. Romanini
Data/Hora : 09/12/05 10:00
*/

Function EECCADFND

Local lRet:=.T., cOldArea := Select()

If !EasyCallMVC("MVC_CADFNDEEC")//CRF
   Begin Sequence
      AxCadastro("EY4",STR0079)//"Cadastro de First Notice Days"
   End Sequence
EndIf
DbSelectArea(cOldArea)

Return lRet

/*
Funcao    : AT150Mes
Parametros: cValor
Objetivos : Transforma o Mês.
			Caso o mês esteja em formato numerico, é trocado pela sigla correspondente
			ao mês, e vice-versa
Autor     : Eduardo C. Romanini
Data/Hora : 09/12/05 10:00
*/
Function AT150Mes(cValor)

Local aMes   := {"01","03","05","07","09","11","12"}
Local aMesId := {"F" ,"H" ,"K" ,"N" ,"U" ,"X" ,"Z" }
Local cRet   := ""

// ISS - 17/03/10 - Inclusão de tratamentos para o caso do parâmetro cValor for enviado incorretamente.

If ValType(cValor) <> "C"
   cValor := ""
Endif

Begin Sequence

   If Val(cValor) = 0
      nPos := aScan(aMesId,{|X| X == AllTrim(Upper(cValor))})
      If nPos > 0
         cRet := aMes[nPos]
      EndIf
   Else
      nPos := aScan(aMes,{|X| X == AllTrim(cValor)})
      If nPos > 0
         cRet := aMesId[nPos]
      EndIf
   EndIf

End Sequence

Return cRet

/*
Funcao    : EECFNDVAL
Parametros: nenhum
Objetivos : Validação dos campos do EY4
Autor     : Eduardo C. Romanini
Data/Hora : 09/12/05 10:00
*/

Function EECFNDVAL()

Local lRet := .T.

Begin Sequence

   If !Empty(M->EY4_MESANO) .and. !Empty(M->EY4_FND)
      cMesAno := Substr(M->EY4_MESANO,3,4) + Substr(M->EY4_MESANO,1,2)
      cFND    := Substr(DtoS(M->EY4_FND),1,6)

      If Val(cMesAno) < val(cFND)
         lRet := .F.
         MsgInfo(STR0080)//"O valor do campo Mês/Ano deve ser igual ou superior à Data de Cotação"
         Break
      EndIf
   EndIf

   If Empty(M->EY4_MESANO)
      Break
   EndIf

   nMes:= Val(SubStr(M->EY4_MESANO,1,2))

   If Empty(SubStr(M->EY4_MESANO,3,2))
      MsgStop(STR0081,STR0043)//"Informe o ano da cotação da bolsa !"###"Atenção
      lRet:=.f.
      Break
   Else
      nAno:= Val(SubStr(M->EY4_MESANO,3,2))
   EndIf

   If nMes < 1 .Or. nMes > 12
      MsgStop(STR0082,STR0043)//"Mês da cotação da bolsa inválido !"###"Atenção"
      lRet:=.f.
      Break
   EndIf

   If nAno < 0
      MsgStop(STR0082,STR0043)//"Mês da cotação da bolsa inválido !"###"Atenção"
      lRet:=.f.
      Break
   EndIf

End Sequence

Return lRet

/*
Funcao    : EECCopyTo
Parametros: aAlias -> Array com os alias das tabelas que serão copiadas, ex.: {"Alias1","Alias2",...,"AliasN"}
Retorno   : aRet   -> Array com o nome dos arquivos criados e o alias correspondente, ex: {{"Alias, "NomeArquivo"}}
Objetivos : Criar backup de tabelas
Autor     : Rodrigo Mendes Diaz
Data/Hora : 03/02/06
*/

Function EECCopyTo(aAlias)
Local aRet := {}, aOrd, i, cOldArea := Select(), aFilter

Begin Sequence

   If ValType(aAlias) = "C"
      aAlias := {aAlias}
   ElseIf ValType(aAlias) <> "A"
      aAlias := {Alias()}
   EndIf

   aOrd := SaveOrd(aAlias)
   aFilter := EECSaveFilter(aAlias)
   For i := 1 To Len(aAlias)
      (aAlias[i])->(DbClearFilter())
      aAdd(aRet, {CriaTrab(,.F.),aAlias[i]})
      dbSelectArea(aAlias[i])
      //Copy to (aRet[i][1]+GetdbExtension())
      TETempBackup(aRet[i][1]) //THTS - 11/10/2017 - TE-7085 - Temporario no Banco de Dados
   Next
   RestOrd(aOrd, .T.)
   EECRestFilter(aFilter)
   dbSelectArea(cOldArea)

End Sequence

Return aRet

/*
Funcao    : EECRestBack
Parametros: aAlias -> Array com os alias e nomes do arquivos que serão copiados, ex.: {{"Alias1", "NomeArquivo"},...,{"AliasN",,"NomeArquivo"}}
            lNotRest  -> .T. -> Apenas apaga os arquivos do array aAlias;
                         .F. -> Restaura o conteudo dos arquivos para o alias indicado e apaga os arquivos
Objetivos : Restaurar backup de tabelas
Autor     : Rodrigo Mendes Diaz
Data/Hora : 03/02/06
*/

Function EECRestBack(aAlias, lNotRest)
Local cOldArea := Select(), lRet := .T., i

Begin Sequence

   If ValType(aAlias) <> "A"
      lRet := .F.
      Break
   Endif

   For i := 1 To Len(aAlias)
      If !lNotRest
         dbSelectArea(aAlias[i][2])
         AvZap()
         TERestBackup(aAlias[i][1])
         (aAlias[i][2])->(DbGoTop())
      EndIf

      If File(aAlias[i][1]+GetDBExtension())
         FErase(aAlias[i][1]+GetDBExtension())
      EndIf
   Next
   dbSelectArea(cOldArea)

End Sequence

Return lRet

/*
Função      : EECLock()
Objetivos   : Travar um registro de uma tabela e disponibilizar opção de espera para o usuário.
Parâmetros  : cAlias - Alias do arquivo a ser travado.
Retorno     : .T. - Conseguiu travar
              .F. - Não conseguiu travar, e recebeu resposta negativa do usuário.
Autor       : João Pedro Macimiano Trabbold
Data/Hora   : 21/02/06 - 11:00
*/
*----------------------*
Function EECLock(cAlias)
*----------------------*
Local lRet := .T., lLocked := .F.
Local nSec, nWait := 5
Local cCpo := ""

Local cDesc := ""

Default cAlias := Alias()

if FwRetIdiom() == "en"
   cCpo := "X2_NOMEENG"
ELSE
   if FwRetIdiom() == "es"
      cCpo := "X2_NOMESPA"
   ELSE
      cCpo := "X2_NOME"
   ENDIF
ENDIF

cDesc := cAlias+" ("+Capital(AllTrim(Posicione("SX2",1,cAlias,cCpo)))+")"

Begin Sequence

   nSec := Seconds()
   While !(cAlias)->(MsRLock())

      If !lLocked
         lLocked := .T.
      EndIf

      If (Seconds() - nSec) > nWait
         If !MsgYesNo(StrTran(STR0084,"###",cDesc),STR0043)//"O registro da tabela ### está sendo utilizado por outro usuário. Deseja esperar a liberação?"###"Atenção"
            lRet := .F.
            Break
         EndIf
         nSec := Seconds()
      EndIf

      AvDelay(1)
   EndDo

   If lLocked
      If !MsgYesNo(StrTran(STR0083,"###",cDesc),STR0043)//"O registro da tabela ### estava sendo utilizado por outro usuário, e foi liberado agora. Deseja continuar?"###"Atenção"
         (cAlias)->(MsUnlock())
         lRet := .F.
         Break
      EndIf
   EndIf

End Sequence

Return lRet

/*
Função      : EECIniPad()
Objetivos   : Tratar o inicializador padrão dos campos cuja expressão não cabe no dicionário de dados.
Parâmetros  : cCampo - Nome do campo
Retorno     : xRet   - Retorno do inicializador padrão do campo
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 14/10/06 11:00
*/
Function EECIniPad(cCampo)
Local xRet

Begin Sequence

   Do Case
      Case cCampo == "EE8_DSCQUA"
         xRet := EasyMSMM(If(Select("WorkIt") > 0 .And. WorkIt->(FieldPos('EE8_DSCQUA')) > 0, WorkIt->EE8_QUADES, EE8->EE8_QUADES), AvSx3("EE8_DSCQUA", 3),,,,,,If(Select("WorkIt") > 0 .And. WorkIt->(FieldPos('EE8_DSCQUA')) > 0, "WorkIt", "EE8"),"EE8_QUADES")   //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
                                                                                                                                                                                                                                                                     //NCF - 24/09/2013 - Ajuste para integração via Mensagem Única SIGAEEC x LOGIX

      Case cCampo == "EE9_VM_DES"
         If Type("lAbriuExp") == "L" .And. lAbriuExp == .T.
            xRet := MSMM_DR(If(Select("WorkIp") > 0 .And. WorkIp->(FieldPos('EE9_VM_DES')) > 0, WorkIp->EE9_DESC, EE9->EE9_DESC), AvSx3("EE9_VM_DES", 3),,,,,,If(Select("WorkIp") > 0 .And. WorkIp->(FieldPos('EE9_VM_DES')) > 0, "WorkIp", "EE9"),"EE9_DESC")
         Else
            xRet := EasyMSMM(If(Select("WorkIp") > 0 .And. WorkIp->(FieldPos('EE9_VM_DES')) > 0, WorkIp->EE9_DESC, EE9->EE9_DESC), AvSx3("EE9_VM_DES", 3),,,,,,If(Select("WorkIp") > 0 .And. WorkIp->(FieldPos('EE9_VM_DES')) > 0, "WorkIp", "EE9"),"EE9_DESC")
         EndIf

      Case cCampo == "EE9_DSCQUA"
         If Type("lAbriuExp") == "L" .And. lAbriuExp == .T.
            xRet := MSMM_DR(If(Select("WorkIp") > 0 .And. WorkIp->(FieldPos('EE9_DSCQUA')) > 0, WorkIp->EE9_QUADES, EE9->EE9_QUADES), AvSx3("EE9_DSCQUA", 3))
         Else
            xRet := EasyMSMM(If(Select("WorkIp") > 0 .And. WorkIp->(FieldPos('EE9_DSCQUA')) > 0, WorkIp->EE9_QUADES, EE9->EE9_QUADES), AvSx3("EE9_DSCQUA", 3))
         EndIf

      Case cCampo == "EE9_CODNOR"
         If Type("M->EE9_CODNOR") <> "C" .Or. Type("M->EE9_COD_I") <> "C" .Or. Type("M->EE9_PAISET") .Or. Empty(M->EE9_CODNOR)
            xRet := ""
         Else
            xRet := Posicione("EXN",1,xFilial("EXN")+M->EE9_COD_I+M->EEC_PAISET,"EXN_NORMA")
         EndIf

      Case cCampo == "EE9_VM_NOR"
         xRet := MSMM(Posicione("EEI", 1, xFilial("EEI")+If(Select("WorkIp") > 0, WorkIP->EE9_CODNOR, EE9->EE9_CODNOR), "EEI_DESC"), 60)

      Case cCampo == "EE8_VM_DES"
         xRet := EasyMSMM(If(Select("WorkIt") > 0 .And. WorkIt->(FieldPos('EE8_VM_DES')) > 0,WorkIt->EE8_DESC, EE8->EE8_DESC), AVSX3("EE8_VM_DES", 3),,,,,,If(Select("WorkIt") > 0 .And. WorkIt->(FieldPos('EE8_VM_DES')) > 0, "WorkIt", "EE8"),"EE8_DESC")

      Case cCampo == "EE8_VM_NOR"
         xRet := MSMM(Posicione("EEI",1,xFilial("EEI")+If(Select("WorkIt") > 0, WorkIt->EE8_CODNOR, EE8->EE8_CODNOR),"EEI_DESC"),60,1)
      Case cCampo == "EEC_USUDIG"
         If (!Empty(M->EEC_CODUSU))
            PswOrder(1)
            If PswSeek(M->EEC_CODUSU, .T.)
               xRet:= PswRet()[1][4] //EJA - 26/11/2018 //TRP - 01/10/12 - Nome do usuário
            Else
               xRet:= ""
            Endif
         Else
            xRet := ""
         EndIF
      Case cCampo == "EEC_EMAIL"
         If (!Empty(M->EEC_CODUSU))
            PswOrder(1)
            If PswSeek(M->EEC_CODUSU, .T.)
               xRet:= PswRet()[1][14]//TRP - 01/10/12 - E-mail do usuário
            Else
               xRet:= ""
            Endif
         Else
            xRet := ""
         EndIF
      Case cCampo == "EYU_VM_DES"    // By JPP 14/11/2007 - 14:00
         xRet := MSMM(If(Select("WKEYU") > 0,WKEYU->EYU_PR_DES, EYU->EYU_PR_DES), AVSX3("EYU_VM_DES", AV_TAMANHO))
      Case cCampo == "EYY_COD_I"
      	xRet := ""  
      	If Select("WK_NFREM") > 0 	
			xRet := WK_NFREM->EYY_COD_I         	
		Else					
		 	dbSelectArea("EE9")
		 	dbSetOrder(1) //EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN+EE9_PREEMB+EE9_HOUSE
			If EE9->(MsSeek(xfilial("EE9") + EYY->EYY_PEDIDO + EYY->EYY_SEQUEN + EYY->EYY_PREEMB))				
				xRet := EE9->EE9_COD_I				
			EndIf
		 EndIf		               
      Case cCampo == "EYY_VM_DES"  
      	xRet := ""         
         
		If Select("WK_NFREM") > 0 	
			xRet := WK_NFREM->EYY_VM_DES         	
		Else				
		 	dbSelectArea("EE9")
		 	dbSetOrder(1) //EE9_FILIAL+EE9_PEDIDO+EE9_SEQUEN+EE9_PREEMB+EE9_HOUSE
			If EE9->(MsSeek(xfilial("EE9") + EYY->EYY_PEDIDO + EYY->EYY_SEQUEN + EYY->EYY_PREEMB))
				xRet := Posicione("SB1",1,xFilial("SB1") + EE9->EE9_COD_I ,"B1_DESC") //Indice 1 - Filial + Codigo prod					
			EndIf
		 EndIf		
   EndCase

End Sequence

Return xRet

/*
Função      : EECMsg
Objetivos   : Tratar a exibição de mensagens das validações do sistema
Parâmetros  : cMsg  - Mensagem a ser exibida
              cTit  - Titulo da mensagem
              cTipo - Tipo da mensagem (Alert, MsgStop, MsgYesNo, MsgNoYes ou MsgInfo)
Retorno     : lRet
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/11/06 09:00
*/
Function EECMsg(cMsg, cTit, cTipo, lRet, lNotShow)
Local oLogTemp
Default cTit  := STR0043//"Atenção"
Default cTipo := "MSGINFO"
Default lRet := .F.
Default lNotShow := Type("lSched") == "L" .And. lSched

   cTipo := Upper(cTipo)
   If lNotShow
      If Type("oEECLog") == "O"
         oEECLog:AddMsg(cMsg, cTit, cTipo)
         //Força a exibição da mensagem
         If oEECLog:lShowMsg
            EECMsg(cMsg, cTit, cTipo, , .T.)
         EndIf
      Else
         oLogTemp := EECLog():New()
         oLogTemp:AddMsg(cMsg, cTit, cTipo)
         oLogTemp:PrintLog()
      EndIf
   Else
      Do Case
         Case cTipo == "ALERT"
            Alert(cMsg, cTit)
         Case cTipo == "MSGSTOP"
            MsgStop(cMsg, cTit)
         Case cTipo == "MSGYESNO"
            lRet := MsgYesNo(cMsg, cTit)
         Case cTipo == "MSGNOYES"
            lRet := MsgNoYes(cMsg, cTit)
         Otherwise
            MsgInfo(cMsg, cTit)
      End Case
   EndIf

Return lRet

/*
Função      : EECHelp
Objetivos   : Tratar a exibição de mensagens de help das validações do sistema
Parâmetros  : ExpC1 e Lin - Padrão Microsiga
              cCodHelp - Código do help
Retorno     : .T.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/11/06 09:00
*/
Function EECHelp(ExpC1 , Lin, cCodHelp, lNotShow, cNome, cMsg, nLini, nColi)
Local cMsg
Local oLogTemp
Default lNotShow := Type("lSched") == "L" .And. lSched

Begin Sequence

   If lNotShow
      If Len(cMsg := Ap5GetHelp(cCodHelp)) == 0
         Break
      EndIf
      If Type("oEECLog") == "O"
         oEECLog:AddMsg(cMsg,,"Help")
         //Força a exibição do help
         If oEECLog:lShowMsg
            EECHelp(ExpC1 , Lin, cCodHelp, .T.)
         EndIf
      Else
         oLogTemp := EECLog():New()
         oLogTemp:AddMsg(cMsg,,"Help")
         oLogTemp:PrintLog()
      EndIf
   Else
      Help(ExpC1 , Lin, cCodHelp, cNome, cMsg, nLini, nColi)
   EndIf

End Sequence

Return .T.


/*
Clase       : EECLog
Objetivos   : Gera objeto para controle de mensagens apresentadas pelas funções EECMsg e EECHelp quando a rotina for agendada.
              Quando o objeto for declarado em alguma função que possua chamada das funções EECMsg e EECHelp, quando a rotina estiver schedulada,
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 31/10/2006
Revisao     :
Obs.        :
*/
Class EECLog

   Data aProcessos
   //Indica o nome do arquivo de log a ser gerado
   Data cFileLog
   //Indica se as mensagens serão exibidas
   Data lShowMsg
   //Indica se será gerado o arquivo de log.
   Data lLogTxt
   //Indica se o log será exibido via ConOut
   Data lConOut

   Method New() Constructor
   Method AddProc(cDesc)
   Method AddMsg(cMsg, cTit, cTipo)
   Method AddHelp(cHelp)
   Method PrintLog()

End Class

/*
Método      : New
Classe      : EECLog
Objetivos   : Cria novo objeto
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 31/10/2006
Revisao     :
Obs.        :
*/
Method New() Class EECLog
   ::cFileLog := "EECAuto.log"
   ::lShowMsg := .F.
   ::lLogTxt  := .T.
   ::lConOut  := .F.
   ::aProcessos := {}
Return Self

/*
Método      : AddProc
Classe      : EECLog
Objetivos   : Adiciona um processo de controle d
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 31/10/2006
Revisao     :
Obs.        :
*/
Method AddProc(cDesc) Class EECLog
Default cDesc  := STR0085//"Descrição do processo não informada."
   aAdd(::aProcessos, {cDesc, {}})
Return .T.

/*
Método      : AddMsg
Classe      : EECLog
Objetivos   :
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 31/10/2006
*/
Method AddMsg(cMsg, cTit, cTipo) Class EECLog
Default cTit  := STR0043//"Atenção"
Default cTipo := "MSGINFO"

   If Len(::aProcessos) > 0
      aAdd(::aProcessos[Len(::aProcessos)][2], {Time(), cMsg, cTit, cTipo})
   Else
      ::AddProc()
      ::AddMsg(cMsg, cTit, cTipo)
   EndIf

Return .T.

/*
Método      : PrintLog
Classe      : EECLog
Objetivos   : Imprime log das mensagens contidas no objeto EECLog
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 31/10/2006
*/
Method PrintLog() Class EECLog
Local cMsg := "", cFile
Local nInc
Local bPrintMsg := {|m| cMsg += ENTER;
                              + Space(3) + STR0086 + Eval(bSetMsg, m[1]) + ENTER; //"Hora:     "
                              + Space(3) + STR0087 + m[2] + ENTER;                //"Mensagem: "
                              + Space(3) + STR0088 + m[3] + ENTER;                //"Titulo:   "
                              + Space(3) + STR0089 + m[4] + ENTER }               //"Tipo:     "
Local bSetMsg := {|s| StrTran(s, ENTER, Space(3) + ENTER) }

   cMsg += Replicate("-", 80) + ENTER
   cMsg += STR0090 + ENTER//"Log de gravação automática de processos"
   cMsg += STR0091 + " " + DToC(Date()) + " " + AllTrim(STR0086) + " " + Time() + ENTER//"Data de Geração:"###"Hora:"

   For nInc := 1 To Len(::aProcessos)
      cMsg += ENTER
      cMsg += STR0092 + ::aProcessos[nInc][1] + ENTER//"Processo: "
      cMsg += STR0093 + ENTER//"Mensagens apresentadas:"
      aEval(::aProcessos[nInc][2], {|x| Eval(bPrintMsg, x)})
   Next

   If ::lLogTxt
      If !File(::cFileLog)
         //Cria o arquivo
         cFile := EasyCreateFile(::cFileLog)
      Else
         //Utiliza o arquivo já existente
         cFile := EasyOpenFile(::cFileLog, FO_READWRITE)
         cMsg := Replicate(ENTER, 2) + cMsg
      EndIf
      //Posiciona no final do arquivo
      FSeek(cFile, 0, FS_END)
      //Grava o log
      FWrite(cFile, cMsg)
      FClose(cFile)
   EndIf
   If ::lConOut
      ConOut(cMsg)
   EndIf
   ::aProcessos := {}

Return .T.

/*
Função      : CalcPeso
Objetivos   : Calcular o Peso Bruto e Liquido de umm Item do Pedido
Parâmetros  : cPedido   - Pedido
              cFatIt    - Sequencia
              nQuant    - Quantidade
              cPedFat   - Pedido de Venda
Retorno     : aRet [1] - Peso Liquido[
                   [2] - Peso Bruto
Autor       : Eduardo C. Romanini
Data/Hora   : 02/04/2007
*/
*----------------------------------------------*
Function CalcPeso(cPedido,cFatIt,nQuant,cPedFat,nQuantTotal)
*----------------------------------------------*
Local nPesLiq    := 0
Local nPesBru    := 0

Local cSequen    := ""
Local cEmbalagem := ""
Local cLastEmb   := ""

Local cFase      := OC_PE

Local nQtdEmb    := 0
Local nPesEmb    := 0

Local aRet       := {}

//TLM 26/05/2008 - Tratamento para o rateio do peso liquído e bruto com o parâmetro MV_AVG0004 ligado.

Local nQuantAux      := 0
Local nPesLiqAux     := 0

Local nQtdEmbItem   := 0
Local nPesEmbTot    := 0

Local nPesoRatL := 0
Local nPesoRatB := 0

Local nDifLiq := 0
Local nDifBru := 0
Local nEEC0052 := EasyGParam("MV_EEC0052",.F.,1)

Local cEmbalagemItem := ""

Local aOrd := SaveOrd({"EE8","EE5","EEK","EE9","EEC"})

Private lIntEmb := EECFLAGS("INTEMB")

Static cPedidoAux    := ""

Static nPesLiqTot    := 0
Static nPesBruTot    := 0

Default cPedFat := ""

Begin Sequence

   If nQuant == 0
      aRet := {0,0}
      Break
   EndIf

   cPedido := AvKey(cPedido,"EE8_PEDIDO")
   cFatIt  := AvKey(cFatIt,"EE8_FATIT")

   If lIntEmb
      If !Empty(cPedFat)
         cFase := FatFasePV(cPedFat)
      EndIf
   EndIf

   If cFase == OC_PE
      EE8->(DbSetOrder(1))
      If EE8->(DbSeek(xFilial("EE8")+cPedido))
         While EE8->(!EOF()) .and. EE8->(EE8_FILIAL + EE8_PEDIDO) == xFilial("EE8")+cPedido
            If EE8->EE8_FATIT == cFatIt

               cSequen := EE8->EE8_SEQUEN

               //Cálculo do Peso Lìquido
               nPesLiq := nQuant * EE8->EE8_PSLQUN

               //Cálculo do Peso Bruto
               EE5->(DbSetOrder(1))
               If EE5->(DbSeek(xFilial("EE5")+EE8->EE8_EMBAL1))

                  If nQuant <= EE8->EE8_QE
                     nQtdEmb := 1
                  Else
                     IF nEEC0052 == 1
                        If (nQuant % EE8->EE8_QE) > 0
                            nQtdEmb := Int(nQuant / EE8->EE8_QE) + 1
                        Else
                            nQtdEmb := nQuant / EE8->EE8_QE
                        EndIf
                    ElseIF nEEC0052 == 2
                        If (nQuantTotal % EE8->EE8_QE) > 0
                            nQtdEmb := Int(nQuantTotal / EE8->EE8_QE) + 1
                        Else
                            nQtdEmb := nQuantTotal / EE8->EE8_QE
                        EndIf
                    ElseIF nEEC0052 ==3
                        If (EE8->EE8_SLDINI % EE8->EE8_QE) > 0
                            nQtdEmb := Int(EE8->EE8_SLDINI / EE8->EE8_QE) + 1
                        Else
                            nQtdEmb := EE8->EE8_SLDINI / EE8->EE8_QE
                        EndIf
                    EndIF
                  EndIf

                  nPesEmb := nQtdEmb * EE5->EE5_PESO

                  cEmbalagem := EE8->EE8_EMBAL1

                  //Cálculo para Embalagens Múltiplas.
                  EEK->(DbSetOrder(1))
                  If EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagem))
                     Do While EEK->(!Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                                                  EEK->EEK_TIPO   == OC_EMBA .And.;
                                                  EEK->EEK_CODIGO == cEmbalagem

                        If EE5->(DbSeek(xFilial("EE5")+EEK->EEK_EMB))

                           If nQtdEmb <= EEK->EEK_QTDE
                              nQtdEmb := 1
                           Else
                              If (nQtdEmb % EEK->EEK_QTDE) > 0
                                 nQtdEmb := Int(nQtdEmb / EEK->EEK_QTDE) + 1
                              Else
                                 nQtdEmb := nQtdEmb / EEK->EEK_QTDE
                              EndIf
                           EndIf

                           //nPesEmb += (EE5->EE5_PESO*nQtdEmb)
                           nPesEmb += (AvTransUnid(EE8->EE8_UNPES, "KG", EE8->EE8_COD_I, EE5->EE5_PESO, .F.)*nQtdEmb)
                           cLastEmb := EEK->EEK_EMB
                        EndIf

                        EEK->(DbSkip())

                        // quando o código for diferente é que passou pelo último resgistro e caso já tenha passado não passa de novo
                        If !AvFlags("EEC_LOGIX") .And. EEK->EEK_CODIGO <> cEmbalagem
                           If !EEK->(DBSeek(xFilial("EEK") + OC_EMBA + cLastEmb))
                              Exit
                           else
                              cEmbalagem:= cLastEmb // depois de posicionar cEnbalagem recebe o último registro para fazer o loop novamente
                           EndIf
                        EndIf

                     EndDo
                  EndIf

                  //MPG - Acerto do calculo do Peso bruto de acordo com o parametro MV_EEC0052 - 27/12/2017
                  IF nEEC0052 == 1
                      nPesBru := nPesLiq + nPesEmb
                  ElseiF nEEC0052 == 2
                      nPesBru := (nQuant *(nPesEmb/ nQuantTotal)) + nPesLiq
                      //nPesBru := (nPesLiq *(nPesEmb/ nQuantTotal)) + nQuant
                  ElseIF nEEC0052 == 3
                      nPesBru := (nQuant *(nPesEmb / EE8->EE8_SLDINI)) + nPesLiq
                      //nPesBru := (nPesLiq *(nPesEmb / EE8->EE8_SLDINI)) + nQuant
                  EndIF
               EndIf
               Exit
            EndIf
            EE8->(DbSkip())
         EndDo
      EndIf

   Else //Fase de Embarque

      EE9->(DbSetOrder(3))
      If EE9->(DbSeek(xFilial("EE9")+cPedido))
         While EE9->(!EOF()) .and. EE9->(EE9_FILIAL + EE9_PREEMB) == xFilial("EE9")+cPedido
            If EE9->EE9_FATIT == cFatIt

               cSequen := EE9->EE9_SEQEMB

               //Cálculo do Peso Lìquido
               nPesLiq := nQuant * EE9->EE9_PSLQUN

               //Cálculo do Peso Bruto
               EE5->(DbSetOrder(1))
               If EE5->(DbSeek(xFilial("EE5")+EE9->EE9_EMBAL1))

                  If nQuant <= EE9->EE9_QE
                     nQtdEmb := 1
                  Else
                     IF nEEC0052 == 1
                        If (nQuant % EE9->EE9_QE) > 0
                            nQtdEmb := Int(nQuant / EE9->EE9_QE) + 1
                        Else
                            nQtdEmb := nQuant / EE9->EE9_QE
                        EndIf
                    ElseIF nEEC0052 == 2
                        If (nQuantTotal % EE9->EE9_QE) > 0
                            nQtdEmb := Int(nQuantTotal / EE9->EE9_QE) + 1
                        Else
                            nQtdEmb := nQuantTotal / EE9->EE9_QE
                        EndIf
                    ElseIF nEEC0052 ==3
                        If (EE8->EE8_SLDINI % EE9->EE9_QE) > 0
                            nQtdEmb := Int(EE9->EE9_SLDINI / EE9->EE9_QE) + 1
                        Else
                            nQtdEmb := EE9->EE9_SLDINI / EE9->EE9_QE
                        EndIf
                    EndIF
                  EndIf

                  nPesEmb := nQtdEmb * EE5->EE5_PESO

                  cEmbalagem := EE9->EE9_EMBAL1

                  //Cálculo para Embalagens Múltiplas.
                  EEK->(DbSetOrder(1))
                  If EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagem))
                     Do While EEK->(!Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                                                  EEK->EEK_TIPO   == OC_EMBA .And.;
                                                  EEK->EEK_CODIGO == cEmbalagem

                        If EE5->(DbSeek(xFilial("EE5")+EEK->EEK_EMB))

                           If nQtdEmb <= EEK->EEK_QTDE
                              nQtdEmb := 1
                           Else
                              If (nQtdEmb % EEK->EEK_QTDE) > 0
                                 nQtdEmb := Int(nQtdEmb / EEK->EEK_QTDE) + 1
                              Else
                                 nQtdEmb := nQtdEmb / EEK->EEK_QTDE
                              EndIf
                           EndIf

                           //nPesEmb += (EE5->EE5_PESO*nQtdEmb)
                           nPesEmb += (AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE5->EE5_PESO, .F.)*nQtdEmb)
                           cEmbalagem := EEK->EEK_EMB
                        EndIf

                        If !EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagem))
                           Exit
                        EndIf
                        //EEK->(DbSkip())
                     EndDo
                  EndIf

                  //MPG - Acerto do calculo do Peso bruto de acordo com o parametro MV_EEC0052 - 27/12/2017
                  IF nEEC0052 == 1
                      nPesBru := nPesLiq + nPesEmb
                  ElseiF nEEC0052 == 2
                      nPesBru := (nQuant *(nPesEmb/ nQuantTotal)) + nPesLiq
                      //nPesBru := (nPesLiq *(nPesEmb/ nQuantTotal)) + nQuant
                  ElseIF nEEC0052 == 3
                      nPesBru := (nQuant *(nPesEmb / EE8->EE8_SLDINI)) + nPesLiq
                      //nPesBru := (nPesLiq *(nPesEmb / EE8->EE8_SLDINI)) + nQuant
                  EndIF
               EndIf

               Exit
            EndIf
            EE9->(DbSkip())
         EndDo
      EndIf

   EndIf


   aRet := {nPesLiq,nPesBru}


   /* TLM - 26/05/2008
      Tratamento para o rateio do peso liquído e bruto alterado na gravação do pedido de exportação.
      A diferença informada pelo usuário será rateada pela proporção do item sobre o peso total liquído e bruto do pedido.
   */
   If EasyGParam("MV_AVG0004",,.F.)
      If cFase == OC_PE

         If EE8->(DbSeek(xFilial("EE8")+cPedido)) .And.  cPedido <> cPedidoAux    // Necessário totalizar o peso por pedido.
            nPesLiqTot:=nPesBruTot:=0
            While EE8->(!EOF()) .and. EE8->(EE8_FILIAL + EE8_PEDIDO) == xFilial("EE8")+cPedido

               cPedidoAux := cPedido  // Para que não seja totalizado duas vezes o mesmo processo.
               nQuantAux:= EE8->EE8_SLDINI

               nPesLiqAux := nQuantAux * EE8->EE8_PSLQUN
               nPesLiqTot += nPesLiqAux  // Totaliza o peso líquido

               EE5->(DbSetOrder(1))
               If EE5->(DbSeek(xFilial("EE5")+EE8->EE8_EMBAL1))

                  If nQuantAux <= EE8->EE8_QE
                     nQtdEmbItem := 1
                  Else
                     If (nQuantAux % EE8->EE8_QE) > 0
                        nQtdEmbItem := Int(nQuantAux / EE8->EE8_QE) + 1
                     Else
                        nQtdEmbItem := nQuantAux / EE8->EE8_QE
                     EndIf
                  EndIf

                  nPesEmbTot := nQtdEmbItem * EE5->EE5_PESO

                  cEmbalagemItem := EE8->EE8_EMBAL1
               EndIf

               //Cálculo para Embalagens Múltiplas.
               EEK->(DbSetOrder(1))
               If EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagemItem))
                  Do While EEK->(!Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                                               EEK->EEK_TIPO   == OC_EMBA .And.;
                                               EEK->EEK_CODIGO == cEmbalagemItem

                     If EE5->(DbSeek(xFilial("EE5")+EEK->EEK_EMB))

                        If nQtdEmbItem <= EEK->EEK_QTDE
                           nQtdEmbItem := 1
                        Else
                           If (nQtdEmbItem % EEK->EEK_QTDE) > 0
                              nQtdEmbItem := Int(nQtdEmbItem / EEK->EEK_QTDE) + 1
                           Else
                              nQtdEmbItem := nQtdEmbItem / EEK->EEK_QTDE
                           EndIf
                        EndIf
                        nPesEmbTot += (AvTransUnid(EE8->EE8_UNPES, "KG", EE8->EE8_COD_I, EE5->EE5_PESO, .F.)*nQtdEmbItem)
                        cEmbalagemItem := EEK->EEK_EMB
                     EndIf

                     If !EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagemItem))
                        Exit
                     EndIf
                  EndDo
               EndIf

               nPesBruTot += nPesLiqAux + nPesEmbTot  // Totaliza o peso bruto

               EE8->(DbSkip())
            EndDo
         EndIf

         EE7->(DbSetOrder(1))
         If EE7->(Dbseek(xFilial("EE7")+cPedido))

            nDifLiq:= EE7->EE7_PESLIQ - nPesLiqTot   // Diferença entre o peso digitado liquido informado pelo usuário (MV_AVG0004) na capa (EE7) e o total calculado dos itens (EE8).
            nDifBru:= EE7->EE7_PESBRU - nPesBruTot   // Diferença entre o peso digitado bruto informado pelo usuário (MV_AVG0004) na capa (EE7)e o total calculado dos itens (EE8).

            nPesoRatL := (nPesLiq / nPesLiqTot)      // Cálculo do rateio pela divisão do peso líquido do item pelo peso total liquido.
            nPesoRatB := (nPesBru / nPesBruTot)      // Cálculo do rateio pela divisão do peso bruto do item pelo peso total bruto.

            aRet[1] += (nPesoRatL * nDifLiq)         // Cálculo da diferença do peso informada pelo usuário.  Rateio x diferença do peso liquido + peso liquido do item (EE8).
            aRet[2] += (nPesoRatB * nDifBru)         // Cálculo da diferença do peso informada pelo usuário.  Rateio x diferença do peso Bruto + peso bruto do item (EE8).

         EndIf

      Else //Fase de Embarque

         EE9->(DbSetOrder(3))
         If EE9->(DbSeek(xFilial("EE9")+cPedido)) .And.  cPedido <> cPedidoAux    // Necessário totalizar o peso por pedido.
            nPesLiqTot:=nPesBruTot:=0
            While EE9->(!EOF()) .and. EE9->(EE9_FILIAL + EE9_PREEMB) == xFilial("EE9")+cPedido

               cPedidoAux := cPedido  // Para que não seja totalizado duas vezes o mesmo processo.
               nQuantAux:= EE9->EE9_SLDINI

               nPesLiqAux := nQuantAux * EE9->EE9_PSLQUN
               nPesLiqTot += nPesLiqAux  // Totaliza o peso líquido

               EE5->(DbSetOrder(1))
               If EE5->(DbSeek(xFilial("EE5")+EE9->EE9_EMBAL1))

                  If nQuantAux <= EE9->EE9_QE
                     nQtdEmbItem := 1
                  Else
                     If (nQuantAux % EE9->EE9_QE) > 0
                        nQtdEmbItem := Int(nQuantAux / EE9->EE9_QE) + 1
                     Else
                        nQtdEmbItem := nQuantAux / EE9->EE9_QE
                     EndIf
                  EndIf

                  nPesEmbTot := nQtdEmbItem * EE5->EE5_PESO

                  cEmbalagemItem := EE9->EE9_EMBAL1
               EndIf

               //Cálculo para Embalagens Múltiplas.
               EEK->(DbSetOrder(1))
               If EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagemItem))
                  Do While EEK->(!Eof()) .And. EEK->EEK_FILIAL == xFilial("EEK") .And.;
                                               EEK->EEK_TIPO   == OC_EMBA .And.;
                                               EEK->EEK_CODIGO == cEmbalagemItem

                     If EE5->(DbSeek(xFilial("EE5")+EEK->EEK_EMB))

                        If nQtdEmbItem <= EEK->EEK_QTDE
                           nQtdEmbItem := 1
                        Else
                           If (nQtdEmbItem % EEK->EEK_QTDE) > 0
                              nQtdEmbItem := Int(nQtdEmbItem / EEK->EEK_QTDE) + 1
                           Else
                              nQtdEmbItem := nQtdEmbItem / EEK->EEK_QTDE
                           EndIf
                        EndIf
                        nPesEmbTot += (AvTransUnid(EE9->EE9_UNPES, "KG", EE9->EE9_COD_I, EE5->EE5_PESO, .F.)*nQtdEmbItem)
                        cEmbalagemItem := EEK->EEK_EMB
                     EndIf

                     If !EEK->(DbSeek(xFilial("EEK")+OC_EMBA+cEmbalagemItem))
                        Exit
                     EndIf
                  EndDo
               EndIf

               nPesBruTot += nPesLiqAux + nPesEmbTot  // Totaliza o peso bruto

               EE9->(DbSkip())
            EndDo
         EndIf

         EEC->(DbSetOrder(1))
         If EEC->(Dbseek(xFilial("EEC")+cPedido))

            nDifLiq:= EEC->EEC_PESLIQ - nPesLiqTot   // Diferença entre o peso digitado liquido informado pelo usuário (MV_AVG0004) na capa (EE7) e o total calculado dos itens (EE8).
            nDifBru:= EEC->EEC_PESBRU - nPesBruTot   // Diferença entre o peso digitado bruto informado pelo usuário (MV_AVG0004) na capa (EE7)e o total calculado dos itens (EE8).

            nPesoRatL := (nPesLiq / nPesLiqTot)      // Cálculo do rateio pela divisão do peso líquido do item pelo peso total liquido.
            nPesoRatB := (nPesBru / nPesBruTot)      // Cálculo do rateio pela divisão do peso bruto do item pelo peso total bruto.

            aRet[1] += (nPesoRatL * nDifLiq)         // Cálculo da diferença do peso informada pelo usuário.  Rateio x diferença do peso liquido + peso liquido do item (EE8).
            aRet[2] += (nPesoRatB * nDifBru)         // Cálculo da diferença do peso informada pelo usuário.  Rateio x diferença do peso Bruto + peso bruto do item (EE8).

         EndIF

      EndIf
   EndIf

End Sequence

RestOrd(aOrd,.T.)

Return aRet

Static Function MenuDef(cOrigem,lMBrowse)

Local aRotina := {}
Default cOrigem  := AvMnuFnc()
Default lMBrowse := OrigChamada()

 
Do Case
   Case cOrigem == "AVSELECTDO"   
      aAdd(aRotina, { STR0049 , "AxPesqui"                       , 0, 1 } ) //"Pesquisar"
      aAdd(aRotina, { STR0003 , "Processa({|| Mark2AllEEA()  })" , 0, 1 } ) //"Marca/Desmarca"
      aAdd(aRotina, { STR0004 , "Processa({|| Av2DocExport() })" , 0, 1 } ) //"Gerar Arquivos"
	  
   Case cOrigem == "AVDOCIMPOR"      
      aAdd(aRotina , { "", "", 0, 2 })
      
   Case cOrigem == "CANDELEEA"
      aAdd({ "Visualizar", 'AxVisual', 0, 2 })
      	  	
   EndCase
   
   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("EECCAD02MNU")
      aRotAdic := ExecBlock("EECCAD02MNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
	     AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf

Return aRotina

