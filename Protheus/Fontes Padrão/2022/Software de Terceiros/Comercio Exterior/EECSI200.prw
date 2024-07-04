#INCLUDE "EECSI200.ch"
#include "EEC.cH" 

/*
Funcao....: EECSI200
Objetivo..: 1. Gerar o Arquivo p/ Siscomex
            2. Ler a Data de Averbação e o Nr. da S.D. do arquivo de retorno.
Autor.....: Osman Medeiros Jr. 
Data/Hora.: 12/06/01 09:34
Revisão...: -LUCIANO CS - 16/04/2003 - SE FOR FILIAL DO EXTERIOR NAO PERMITIR
             GERAR DADOS PARA O SISCOMEX
            -Jeferson Barros Jr. 
            -LUCIANO CAMPOS DE SANTANA 27/08/2001
Data/Hora.: 16/08/01 10:36
Obs.......: 
*/
                                                                                       
*--------------------------------------*
Function EECSI200()
*--------------------------------------*
Local oDlg
Local lRet := .f.
Local cCadastro := STR0001 //"Geração de Dados para o Siscomex"
Local nOpcao := 1, nOpcA := 0
Local nAliasOld := Select()
LOCAL cFILEXT
Private cPathOr := AllTrim(EasyGParam("MV_AVG0002"))  
Private aCampos := Array(EE9->(fcount()))
Private aHeader :={}
Private cForn := CriaVar("EE9_FORN")

Begin Sequence
   cFILEXT := ALLTRIM(EasyGParam("MV_AVG0024",,""))   
   cFILEXT := IF(cFILEXT=".","",cFILEXT)
   If !Empty(EasyGParam("MV_AVG0023",,"")) .And. !Empty(cFILEXT) .And.;
      (EE7->(FieldPos("EE7_INTERM")) # 0) .And. (EE7->(FieldPos("EE7_COND2")) # 0) .And.;
      (EE7->(FieldPos("EE7_DIAS2")) # 0) .And. (EE7->(FieldPos("EE7_INCO2")) # 0) .And.;
      (EE7->(FieldPos("EE7_PERC")) # 0) .And. (EE8->(FieldPos("EE8_PRENEG")) # 0) .AND.;
      cFILEXT = XFILIAL("EEC")
      *
      MSGINFO(STR0022,STR0023) //"Filial do Exterior não pode gerar dados para o SISCOMEX !"###"Atenção"
      BREAK
   ENDIF
   
   While .t.

      // Verifica a existencia do diretorio
      If(Right(cPathOr,1) != "\", cPathOr += "\",)
   
      If !lIsDir(Left(cPathOr,Len(cPathOr)-1))
         MSGINFO(STR0002 + cPathOr +")",STR0003) //"Diretorio para gravacao e leitura do txt não existe ("###"Aviso"
         break
      EndIf

      nOpcA := 0

      Define MSDialog oDlg Title cCadastro From 9,0 To 18,40 Of oMainWnd
      
        @ 10,5 To 45,150 LABEL STR0004 Of oDlg Pixel //"Eventos:"
      
        @ 23,13 Radio oRad Var nOpcao Size 100,09 Items STR0005,STR0006 Of oDlg Pixel //"01 - Envio"###"02 - Retorno"
     
        Define SButton From 50,180-90 Type 1 Of oDlg Action (nOpcA:=1,oDlg:End()) Enable
        Define SButton From 50,180-57 Type 2 Of oDlg Action (oDlg:End()) Enable
     
      Activate MSDialog oDlg Centered
     
      If nOpcA == 0 
         Exit
      Endif
     
      Do Case 
         Case nOpcao == 1
            // ** By JBJ - 11/03/04 - Tela de Parâmetros para filtro.
            If !SI200Filtros()
               Break
            EndIf
            
            Processa({|| lRet := GeraArqSis() },STR0007) //"Gerando Arquivo..."
            If !lRet
               MsgInfo(STR0008,STR0009) //"Não existem dados para a geração."###"Informação!"
            Endif
        Case nOpcao == 2
            Processa({|| LerRetSis() },STR0010) //"Lendo Arquivos..." 
      End Case
     
   EndDo
  
   Select(nAliasOld)

End Sequence

Return Nil 

/*
Funcao          : GeraArqSis
Objetivo        : Le os dados do EE9 e gera o arquivo texto.
Autor           : Osman Medeiros Jr. 
Data/Hora       : 12/06/01 10:55
Revisão         : Jeferson Barros Jr.
Data/HOra       : 16/08/01 10:38
Obs.            : 
*/
*-------------------------------------*
Static Function GeraArqSis()
*-------------------------------------*
Local nTamLin, cLin, cCpo
Local lRet := .f.
Local nHdl, nCritRe:=0
Local cArqTxt 
Local cREAnt  := ""                                                               
Local cWork
Local aOrd:=SaveOrd({"EE9"})
Local nCount:=0
Local cMemo := ""
Local cAux  := ""
#IFDEF TOP
   Local cCmd
#ENDIF

ProcRegua(200)

Begin Sequence

   IncProc(STR0011) //"Lendo Arquivo..."
   #IFDEF TOP
      IF TCSRVTYPE() <> "AS/400"
         cCmd   := "SELECT COUNT(*) AS NCOUNT" +;
                   " FROM " + RetSqlName("EE9") + " EE9" +;
                   " WHERE D_E_L_E_T_ <> '*' AND" +;
                   " EE9_FILIAL = '" + xFilial("EE9")  + "' AND" +;
                   " EE9_RE <> '" + Space(AvSx3("EE9_RE",AV_TAMANHO)) + "' AND" +;
                   " EE9_DTAVRB = '        '"
         // ** Filtros
         If !Empty(cForn)
            cCmd += " And EE9_FORN = '"+AllTrim(cForn)+"' "
         EndIf

         cCmd := ChangeQuery(cCmd) 
         dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRYTEMP", .F., .T.) 
         If QRYTEMP->NCOUNT > 0 
            cArqTxt := cPathOr + "EE" + SeqArq() + ".ave"
            nHdl := EasyCreateFile(cArqTxt)
            If nHdl == -1
               MsgAlert(STR0012+cArqTxt+STR0013,STR0014) //"O arquivo de nome "###" nao pode ser criado! Verifique os parametros."###"Atencao!"
               QRYTEMP->(dbCloseArea())
               Return lRet
            EndIf
         EndIf

         ProcRegua(QRYTEMP->NCOUNT)
         QRYTEMP->(dbCloseArea())
         cCmd   := "SELECT EE9_RE, EE9_PREEMB" +;
                   " FROM " + RetSqlName("EE9") + " EE9" +;
                   " WHERE D_E_L_E_T_ <> '*' AND" +;
                   " EE9_FILIAL = '" + xFilial("EE9")  + "' AND" +;
                   " EE9_RE <> '" + Space(AvSx3("EE9_RE",AV_TAMANHO)) + "' AND" +;
                   " EE9_DTAVRB = '        '"

         // ** Filtros
         If !Empty(cForn)
            cCmd += " And EE9_FORN = '"+AllTrim(cForn)+"' "
         EndIf

         cCmd += " ORDER BY EE9_RE"
         cCmd := ChangeQuery(cCmd)
         dbUseArea(.T., "TOPCONN", TCGENQRY(,,cCmd), "QRY", .F., .T.) 
      ELSE
   #ENDIF
         EE9->(DbSetOrder(1))
         EE9->(DbSeek(xFilial()))
         Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9")         
            If !Empty(EE9->EE9_RE) .And. Empty(EE9->EE9_DTAVRB)
               If !Empty(cForn)
                  If AllTrim(Upper(EE9->EE9_FORN)) == AllTrim(Upper(cForn))
                     nCount ++
                  EndIf
               Else
                  nCount:= nCount + 1
               EndIf
            EndIf
            EE9->(DbSkip())
         EndDo
         If nCount > 0 
            cArqTxt := cPathOr + "EE" + SeqArq() + ".ave"
            nHdl := EasyCreateFile(cArqTxt)
            If nHdl == -1
               MsgAlert(STR0012+cArqTxt+STR0013,STR0014) //"O arquivo de nome "###" nao pode ser criado! Verifique os parametros."###"Atencao!"
               Return lRet
            EndIf
         EndIf
         ProcRegua(nCount)
         RestOrd(aOrd)
         cWork  := E_CRIATRAB("EE9",,"QRY") 
         IndRegua("QRY",cWork+TEOrdBagExt(),"EE9_RE" ,"AllwayTrue()","AllwaysTrue()",STR0021) //"Processando Arquivo Temporario"
         Set Index to (cWork+TEOrdBagExt())
         EE9->(DbSetOrder(1))
         EE9->(DbSeek(xFilial()))
         Do While EE9->(!Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9")         
            If !Empty(EE9->EE9_RE) .And. Empty(EE9->EE9_DTAVRB)
               If !Empty(cForn)
                  If AllTrim(Upper(EE9->EE9_FORN)) == AllTrim(Upper(cForn))
                     QRY->(DbAppend())
                     QRY->EE9_RE     := EE9->EE9_RE
                     QRY->EE9_PREEMB := EE9->EE9_PREEMB
                  EndIf
               Else
                  QRY->(DbAppend())
                  QRY->EE9_RE     := EE9->EE9_RE
                  QRY->EE9_PREEMB := EE9->EE9_PREEMB
               EndIf
            EndIf
            EE9->(DbSkip())
         Enddo
         QRY->(DbGoTop())
         RestOrd(aOrd)
   #IFDEF TOP
      ENDIF
   #ENDIF
  
   While QRY->(!Eof())

      IncProc(STR0011) //"Lendo Arquivo..."

      If SubStr(QRY->EE9_RE,1,9) <> SubStr(cREAnt,1,9)

         // ** By JBJ - 08/03/04 - Critica para os nros de RE.
         If Len(AllTrim(QRY->EE9_RE)) < 12 .or. Val(Right(AllTrim(QRY->EE9_RE), 3)) = 0
            cMemo += IncSpace(AllTrim(Transf(QRY->EE9_PREEMB,AVSX3("EE9_PREEMB",AV_PICTURE))),22,.f.)+Space(1)+;
                     IncSpace(AllTrim(Transf(QRY->EE9_RE,AVSX3("EE9_RE",AV_PICTURE))),12,.f.)+ENTER

            nCritRe ++ // Totaliza os processos criticados.
            QRY->(dbSkip())
            Loop
         EndIf

         nTamLin := 32
         cLin    := Space(nTamLin)+ENTER 
         cCpo    := Padr(QRY->EE9_PREEMB,20)
         cLin    := Stuff(cLin,01,20,cCpo)
         cCpo    := Padr(QRY->EE9_RE,12)
         cLin    := Stuff(cLin,21,12,cCpo)

         fWrite(nHdl,cLin,Len(cLin))

         cREAnt := QRY->EE9_RE
      EndIf

      QRY->(dbSkip())

      lRet := .t.           
   EndDo   

   QRY->(dbCloseArea())   

   IF Select("Work_Men") > 0
      Work_Men->(E_EraseArq(cWork))
   Endif                    

   If lRET
      cLin := "####eof#####"+ENTER
      fWrite(nHdl,cLin,Len(cLin))
      fClose(nHdl)
      nHdl    := EasyCreateFile(cPathOr + "EECTOT.ave",0) // cria arquivo com o nome do arquivo com os RE's
      nTamLin := 12
      cLin    := Space(nTamLin)+ENTER 
      cCpo    := Padr(Right(AllTrim(cArqTxt),12),12)
      cLin    := Stuff(cLin,01,12,cCpo)
      fWrite(nHdl,cLin,Len(cLin)) 
      cLin    := "####eof#####"+ENTER
      fWrite(nHdl,cLin,Len(cLin)) 
      fClose(nHdl)       
      MsgInfo(STR0015 + cArqTxt  + STR0016  ,STR0009)   //"Arquivos gerado: "###" e EECTOT.ave"###"Informação!"
   EndIf

   // ** By JBJ - 08/03/04 - Exibe Processo(s) e nro(s) de Re criticados.
   If !Empty(cMemo)
      cAux := STR0024+ENTER+; //"O(s) número(s) de RE abaixo esta(ão) inválido(s) e não podera(ão) "
              STR0025+Replic(ENTER,2) //"ser enviado(s) ao Siscomex."

      cAux += STR0026+AllTrim(Transf(nCritRe,"@E 99,999") +Replic(ENTER,2)) //"Número(s) de RE inválido(s): "
      cAux += IncSpace(STR0027,22,.f.)+Space(1)+IncSpace("R.E.",12,.f.)+Replic(ENTER,2) //"Processo"

      cMemo := cAux+cMemo

      //SI200LogView(cMemo)
      EECView(cMemo)
   EndIf

End Sequence

Return(lRET)

/*
Funcao          : LerRetSis
Objetivo        : Verifica se existe arquivos com a extensão .avr 
				  e atualiaza os dados do EE9 com a Dt de Averbação e o Nr. do S.D.
Autor           : Osman Medeiros Jr. 
Data/Hora       : 12/06/01 13:46
Obs.            : 
*/
*-------------------------------------*
Static Function LerRetSis()
*-------------------------------------*
Local nTamFile, nTamLin, cBuffer, nBtLidos
Local lRet := .f.                      
Local nHdl, i:=0
Local aFiles := {} 
Local cSituac := "", lExist_SITRE := (EE9->(FieldPos("EE9_SITRE")) <> 0)
Local dDtEmba := AvCtod("")
Local aOrd:=SaveOrd("EEC")
Local bLastHandler

aFiles := Directory(cPathOr+"EE??????.avr")
If Len(aFiles) > 0 

   For i:=1 to Len(aFiles)		

      cArqTxt := cPathOr+aFiles[i,1]
      nHdl    := EasyOpenFile(cArqTxt,68)
      nTamFile := fSeek(nHdl,0,2)
      fSeek(nHdl,0,0)
      nTamLin  := 95 +Len(ENTER)   // 75, 64 
      cBuffer  := Space(nTamLin)  // Variavel para criacao da linha do registro para leitura
      nBtLidos := 0
		
      ProcRegua(nTamFile)
		
      While nBtLidos < nTamFile
         
         nBtLidos += SI100ReadLn(nHdl,@cBuffer,nTamFile)         
         
         IncProc(STR0017 + AllTrim(Str(i)) + STR0018 + AllTrim(Str(Len(aFiles)))) //"Lendo Arquivo.: "###" de "
            
         If Substr(cBuffer,01,12) <> "####eof#####"
            cPREEMB := Substr(cBuffer,01,20) // 01-20
            cRE     := Substr(cBuffer,21,12) // 21-32
            cSD     := Substr(cBuffer,33,20) // 33-52
            dDTAVB  := AvCtoD(Substr(cBuffer,53,2) + "/" + Substr(cBuffer,55,2) + "/" + Substr(cBuffer,57,4))// 53-60
            // Data 99/99/9999  // 61-70
            // Hora 99:99       // 71-75
            cSituac := Substr(cBuffer,76,20) // 76-95
            dDtEmba := AvCtoD(Substr(cBuffer,96,2) + "/" + Substr(cBuffer,98,2) + "/" + Substr(cBuffer,100,4)) //96-103

            EEC->(DbSetOrder(1))
            If EEC->(DbSeek(xFilial("EEC")+AVKEY(cPREEMB,"EEC_PREEMB")))
               If (EEC->(FieldPos("EEC_DTEMRE")) <> 0) .And. !Empty(dDtEmba)    
                  
                  EEC->(RecLock("EEC",.F.))
                  EEC->EEC_DTEMRE := dDtEmba
                  
                  //AMS - 10/12/2003 às 10:46. Gravação da data de embarque.
                  If EasyGParam("MV_AVG0058",, .F.) .and. Empty(EEC->EEC_DTEMBA)
                     
                     EEC->EEC_DTEMBA := dDtEmba

                     //Geração de parcela de cambio.
                     bLastHandler := ErrorBlock({||.t.})
                     Begin Sequence
                        AF200GPARC()
                     End Sequence
                     ErrorBlock(bLastHandler)
                     
                     //Gravação do status de embarcado.
                     EEC->EEC_STATUS  := "6"      //Embarcado.
                     EEC->EEC_FIM_PE  := dDtEmba  //Data de termino.
                     DSCSITEE7(.T., OC_EM)        //Atualiza descrição do status.
                     
                  EndIf                  
                  
                  EEC->(MSUnLock())
               EndIf
            EndIf

            dbSelectArea("EE9")
            EE9->(dbSetOrder(3))
            EE9->(dbSeek(xFilial("EE9")+AVKEY(cPREEMB,"EE9_PREEMB")))

            While !EE9->(Eof()) .And. EE9->EE9_FILIAL == xFilial("EE9") .And. EE9->EE9_PREEMB == AVKEY(cPREEMB,"EE9_PREEMB")
 	           If SubStr(EE9->EE9_RE,1,9) == SubStr(cRE,1,9)
   	              EE9->(RecLock("EE9",.F.))                   
   	              IF lExist_SITRE
 	                 EE9->EE9_SITRE := cSituac
  	              Endif
   	              IF !Empty(dDTAVB) .Or. !Empty(cSD) 
                     EE9->EE9_DTAVRB := dDTAVB  
                     If ! Empty(cSD)            // By JPP - 04/05/2005 14:00 - So atribuir dados ao campo EE9_NRSD se a variavel cSD estiver preenchida.
  		                EE9->EE9_NRSD   := AvKey(cSD,"EE9_NRSD")
  		             EndIf   
  		          Else 
  		             // EE9->EE9_RE     := Space(Len(EE9->EE9_RE))
  		             // EE9->EE9_DTRE   := AvCtod("")
                     EE9->EE9_DTAVRB := AvCtod("")
                     If EasyGParam("MV_AVG0089",,.t.) // By JPP - 04/05/2005 14:00 - Só inicializar o campo EE9_NRSD se o parametro MV_AVG0089 retornar .t.
  		                EE9->EE9_NRSD   := Space(Len(EE9->EE9_NRSD))
  		             EndIf   
  		          Endif
  		          
  		          //DFS - 21/03/13 - Ponto de entrada para manipulação dos campos referente à averbação
  		          IF EasyEntryPoint("EECSI200")
   		             ExecBlock("EECSI200",.F.,.F.,{"SI200_DTAVRB"})
   		          Endif 
   		             
         	      EE9->(MSUnLock())
	           EndIf    
               EE9->(dbSkip())
	        EndDo	
   		 EndIf
   		    		 
   		 // by CAF 24/07/2003 ...
   		 IF EasyEntryPoint("EECSI200")
   		    ExecBlock("EECSI200",.F.,.F.,{"PE_RET",EEC->EEC_PREEMB})
   		 Endif    		 
      EndDo

      fClose(nHdl)
      fErase(cArqTxt)
      cArqTxt := SubStr(AllTrim(cArqTxt),1,Len(AllTrim(cArqTxt))-4)
      cArqTxt := cArqTxt + ".ave"
  
      If File(cArqTxt)
         fErase(cArqTxt)
      EndIf   
                
   Next

EndIf

MsgInfo(STR0019+ AllTrim(If(Len(aFiles)>0,Str(Len(aFiles)),"0")) +STR0020,STR0009) //"Foram processados "###" Arquivos."###"Informação!"

RestOrd(aOrd)

Return lRet

/*
Funcao          : SeqArq
Objetivo        : Defini o Nr. de sequencia do arquivo a ser criado 
Autor           : Osman Medeiros Jr. 
Data/Hora       : 12/06/01 10:55
Obs.            : 
*/
*-------------------------------------*
Static Function SeqArq()  
*-------------------------------------*
Local nSeq:=0        

If EasyGParam("MV_SEQAVB",,0) == 999999
   SetMv("MV_SEQAVB",0)
EndIf         

SetMv("MV_SEQAVB",EasyGParam("MV_SEQAVB")+1)
nSeq:= EasyGParam("MV_SEQAVB")
MsUnlock()                                      

Return Padl(nSeq,6,'0')

/*
Funcao      : SI200LogView.
Parametros  : cMemo => Texto a ser exibido no memo.
Retorno     : .t.
Objetivos   : Apresenta tela com todos os detalhes da validação/migração da planilha de dados.
              Alem de informativo, disponibiliza a opção de edição das informações pelo NotePad.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/04/03 - 15:33.
Revisao     : 27/02/2004 às 10:35. Alexsander Martins dos Santos.
Obs.        :
*/
*---------------------------------*
Static Function SI200LogView(cMemo)
*---------------------------------*
Local lRet    := .t.
Local cTitulo := STR0028 //"Log - Rotina de Envio Data de Averbação"
Local cLabel  := STR0029 //"Detalhes"
Local oDlg,oMemo, oFont := TFont():New("Courier New",09,15)

Local bOk      := {|| oDlg:End(),SI200LogNotePad(.t.,cMemo)},;
      bCancel  := {|| oDlg:End(),SI200LogNotePad(.t.,cMemo)},;
      aButtons := {{"NOTE" ,{||  SI200LogNotePad(.f.,cMemo,"SI200LOG.TXT")},"NotePad"}}

Begin Sequence

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 9,0 TO 35,85 of oDlg

      @ 15,05 To 190,330 Label cLabel PIXEL OF oDlg
      @ 25,10 GET oMemo VAR cMemo MEMO HSCROLL FONT oFont SIZE 315,160 READONLY OF oDlg  PIXEL

      oMemo:lWordWrap := .F.      
      oMemo:EnableVScroll(.t.)
      oMemo:EnableHScroll(.t.)

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bOk,bCancel,,aButtons) CENTERED

End Sequence

Return lRet

/*
Funcao      : SI200LogNotePad()
Parametros  : lApaga -> .t. - apaga arquivo temporário.
              cMemo  -> Texto a ser exibido no NotePad.
              cFile  -> Nome do arquivo a ser aberto no NotePad.
Retorno     : .T.
Objetivos   : Auxiliar a função ViewDet. Abre o NotePad com todos os detalhes da seleção
              efetuada, a fim de proporcionar ao usuário imprimir ou salvar em arquivo para 
              futura conferência.
Autor       : Jeferson Barros Jr.
Data/Hora   : 14/04/2003 15:49
Revisao     : 27/02/2004 às 10:35. Alexsander Martins dos Santos.
Obs.        :
*/
*----------------------------------------------*
Static Function SI200LogNotePad(lApaga,cMemo,cFile)
*----------------------------------------------*
Local lRet:=.t., cDir:=GetTempPath(),hFile

Default lApaga := .f. // Se .t. apaga arquivo temporário.
Default cFile  := "SI200LOG.txt"

Begin Sequence

   If !lApaga
      hFile := EasyCreateFile(cDir+cFile)

      fWrite(hFile,cMemo,Len(cMemo))

      fClose(hFile)

      //1WinExec("NotePad "+cDir+cFile)
      ShellExecute("open",cDir + cFile,"","", 1)
   Else
      If File(cDir+cFile)
         fErase(cDir+cFile)
      EndIf
   EndIf

End Sequence

Return lRet

/*
Funcao      : SI200Filtros().
Parametro   : Nenhum.
Retorno     : .t.
Objetivos   : Tela de filtros.
Autor       : Jeferson Barros Jr.
Data/Hora   : 13/03/2004 17:48.
Revisao     :
Obs.        :
*/
*----------------------------*
Static Function SI200Filtros()
*----------------------------*
Local bOk:={|| lRet:=.t., oDlg:End()},;
      bCancel:={|| oDlg:End()},;
      bVal:={|| If(ExistCpo("SA2",cForn),Eval(bDesc),nil)},;
      bDesc := {|| cDesc := Posicione("SA2",1,xFilial("SA2")+AvKey(cForn,"A2_COD"),"A2_NOME")}

Local lRet:=.f., cDesc:="", xx:="", nOldArea := Select()

Begin Sequence

   DbSelectArea("SA2")

   Define MsDialog oDlg Title STR0030 From 10,12 To 26.5,57 Of oMainWnd //"Parâmetros Iniciais"
      
      oPanel:= TPanel():New(0, 0, "", oDLG,, .F., .F.,,, 90, 165) //MCF - 11/09/2015
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT
      
      @ 1.1, 0.5 TO 5.5,22 LABEL STR0031 OF oPanel //"Filtros"

      @ 1.8, 1.0 Say AllTrim(AvSx3("EE9_FORN",AV_TITULO)) Of oPanel SIZE 35,9
      @ 2.4, 1.0 MsGet cForn  Size 45,07  F3 "FOR" Picture AVSX3("EE9_FORN",AV_PICTURE) Of oPanel Valid (Vazio() .Or. Eval(bVal))
  
      @ 3.4, 1.0 Say STR0032 Of oPanel Size 35,9 //"Descrição"
      @ 4.0, 1.0 MsGet cDesc SIZE 120,07 OF oPanel When .f.

      @ 10.0, 1.0 MsGet xx OF oPanel
 
   Activate MsDialog oDlg On Init EnchoiceBar(oDlg,bOk,bCancel) Centered

End Sequence

DbSelectArea(nOldArea)

Return lRet
*-----------------------------------------------------------------------------------------------------------------*
* FIM DO PROGRAMA EECSI200                                                                                        *
*-----------------------------------------------------------------------------------------------------------------*
