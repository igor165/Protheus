#Include 'Protheus.ch'
#Include "Average.ch"

/*
Funcao      : ESSIN100().
Objetivos   : 
Sintaxe     : 
Parametros  : 
Retorno     : 
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 05/02/2013 - 10:00.
Revisão     : Guilherme Fernandes Pilan - GFP
Data/Hora   : 17/02/2014
Comentários : Implementação de integração CSV para cadastros
*/
Function ESSIN100(cDirAuto,lSaveLog, lRenameFile)
Local cDir    := Space(255)
Local oSiscoserv :=  ImportSiscoserv():new() 
Local aFiles
Local nFile
Local cHeader
Local cFileLog
Private lEssAuto := IsBlind()
Private oProgress := EasyProgress():New()
Private aCadastros := {}, aDadosCad := {}, aCposChvCad := {}
Private cMsgResumo := ""
Private aCpoChave
Default lRenameFile:= .T.
   
   //RMD - 09/03/16 - Possibilita a execução automática
   /*
   //If !Empty(cDir := cGetFile("Arquivo separado por ; | *.csv","Selecione o arquivo CSV para integração no Easy Siscoserv", 2, cDir,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD,.F.,.T.)  )     
   If !Empty(cDir := oSiscoserv:oAvImport:ChooseFile("Selecione o arquivo CSV para integração no Easy Siscoserv","Arquivo separado por ; | *.csv",cDir,,{|X| INT104ValTipo(X,".CSV")}))
   */
   
   SIX->(DbSetOrder(1)) //MCF - 09/08/2016
   If EasyGParam("MV_ESS0027",,9) >= 10 .And. SIX->(DBSeek("ELM1")) .AND. Alltrim(SIX->CHAVE) == 'ELM_FILIAL+ELM_COD+ELM_CODCLI+ELM_LOJCLI+ELM_CODFOR+ELM_LOJFOR'
      EasyHelp("É necessário realizar uma alteração de indices para prosseguir com a utilização do Easy Siscoserv. Entre em contato com o administrador e peça para que o mesmo siga as "+;
            "orientações do documento http://tdn.totvs.com/display/PROT/ " + ENTER + "TUPFFU_DT_Implementacao_Easy_Siscoserv","Aviso")
      Return
   EndIf
   
   If !lEssAuto
      //Exibe tela para seleção do arquivo.
      cDir := oSiscoserv:oAvImport:ChooseFile("Selecione o arquivo CSV para integração no Easy Siscoserv","Arquivo separado por ; | *.csv",cDir,,{|X| INT104ValTipo(X,".CSV")})
      aFiles := {{cDir, 0}}
      Default lSaveLog := .F.
   Else
      //Busca todos os arquivos .csv do diretório informado.
      aFiles := GetFileList(cDirAuto)
      If Len(aFiles) > 0
         //Define o primeiro arquivo a ser importado (compatibilidade com a forma de execução via tela).
         cDir := oSiscoserv:oAvImport:SetFile(cDirAuto + aFiles[1][1])
      EndIf
      Default lSaveLog := .T.
   EndIf
   
   //Executa a integração uma vez para cada arquivo.
   For nFile := 1 To Len(aFiles)

      //RMD - 09/03/16 - Reinicia as variáveis private para possibilitar a leitura de mais de um arquivo por execução.
      aCadastros := {}
      aDadosCad := {}
      aCposChvCad := {}
      cMsgResumo := ""
   
      If !Empty(aFiles[nFile][1])
         If nFile > 1
         	  //Reinicia o objeto
             oSiscoserv :=  ImportSiscoserv():new()
         	  //Define o arquivo a ser importado.
            cDir := oSiscoserv:oAvImport:SetFile(cDirAuto + aFiles[nFile][1])
         EndIf
         If oSiscoserv:SelArquivo(cDir) .And. oSiscoserv:oAvImport:Import(!lEssAuto) .And. oSiscoserv:SetTipo()
            //Private aCpoChave //RMD - 09/03/16 - Movido para o cabeçalho
            aCpoChave := Nil
         
            oSiscoserv:aStructCapa := StructCapa(oSiscoserv:cIntegracao,oSiscoserv:cTipo,oSiscoserv:aCabecalho, oSiscoserv/*RMD - 09/03/16*/)
            oSiscoserv:aStructDeta := StructDeta(oSiscoserv:cIntegracao,oSiscoserv:cTipo,oSiscoserv:aCabecalho, oSiscoserv/*RMD - 09/03/16*/)
         
            /* RMD - 09/03/16 - Incluído tratamento para execução via Job
            oProgress:SetProcess({|| oSiscoserv:ConfigExecESS(oSiscoserv:oAvImport:aDados,aCpoChave) },"Integrando dados...")
            oProgress:Init()
            */
            bProc := {|| oSiscoserv:ConfigExecESS(oSiscoserv:oAvImport:aDados,aCpoChave) }
            
            //LRS - 20/05/2016 - Caso o arquivo for do Processo Aquisição Reg e em modo de alteração, trocar para o modo de inclusão pois o tratamento esta correto para inclusão
            IF oSiscoserv:oAvImport:aDados[1][1] == "PROCESSO_AQUISICAO_REG" .AND. oSiscoserv:oAvImport:aDados[3][1] == "4"
               oSiscoserv:oAvImport:aDados[3][1] := "3"
            EndIF

            If IsBlind()
               Eval(bProc)
            Else
               oProgress:SetProcess(bProc, "Integrando dados...")
               oProgress:Init()
            EndIf
         EndIf
      
         If !IsBlind()//RMD - 09/03/16
            oSiscoserv:cMsgErro:ShowErrors(.T.)
         Else
            If !lRenameFile
               //Implementado para possibilitar a automação de testes
               If oSiscoserv:cMsgErro:HasErrors()
                  lMsErroAuto:= .T.
                  EasyHelp(oSiscoserv:cMsgErro:GetStrErrors())
               EndIf
            EndIf
         EndIf
         
         //RMD - 09/03/16 - Renomeia o arquivo importado adicionando ".ok" no final do nome
         If lEssAuto .And. lRenameFile //definir regra de renomeação de arquivo - wfs
         	If FRename(cDirAuto + aFiles[nFile][1], cDirAuto + aFiles[nFile][1] + ".ok") == -1
         		oSiscoserv:cMsgErro:Error("Erro ao renomear o arquivo. Erro: " + Str(FError(),4))
         	EndIf
         EndIf
      
         //RMD - 09/03/16 - Grava log com resultado da execução.
         If lSaveLog
         	
         	cFileLog := StrTran(Upper(cDirAuto + aFiles[nFile][1]), ".CSV", ".LOG")
         	
         	cHeader := "Easy SISCOSERV - Importação de Arquivo" + ENTER
         	cHeader += ENTER
         	cHeader += "Arquivo: " + cDirAuto + aFiles[nFile][1] + ENTER
         	cHeader += "Usuário: " + If(IsBlind() .And. Empty(cUserName), "(Execução Automática)", cUsuario) + ENTER
         	cHeader += "Data: " + DToC(dDataBase) + ENTER
         	cHeader += "Hora: " + Time() + ENTER
         	cHeader += ENTER
         	cHeader += "Resultado: " + ENTER
         	cHeader += ENTER
         	If Len(cMsgResumo) > 0
         	   cHeader += cMsgResumo
         	   cHeader += ENTER
         	EndIf
         	//Grava o log incluindo as mensagens de erro do objeto AvObject
            oSiscoserv:cMsgErro:SaveLog(.T., .T., cFileLog, cHeader)
         EndIf
      
      Else
         Return
      EndIf
   
   Next

Return

/**************************************************************************************/
/*
Classe      : StructSiscoserv().
Objetivos   : 
Sintaxe     : 
Parametros  : 
Retorno     : 
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 05/02/2013 - 10:00.
*/

Class ImportSiscoserv From AvObject  

   Data oAvImport   
   Data aItem
   Data cPrograma
   Data cTipo
   Data aCabecalho
   Data aStructCapa
   Data aStructDeta
   Data lErro
   Data aAutoCapa
   Data aAutoDeta
   Data aAutoDoca
   Data cMsgErro
   Data cPosicao
   Data cIntegracao
      
   Method New()           //Metodo para instanciar
   Method SetTipo()       //Metodo para atribuir o tipo da importação Aquisição/Venda.
   Method SelArquivo()    //Metodo para atribuir o diretorio e o arquivo a ser importado.
   Method CapaItem()      //Metodo para separar capa e item.
   Method ScanCapa()      //Metodo para procurar o campo Protheus do campo da capa.
   Method ScanDeta()      //Metodo para procurar o campo Protheus do campo do detalhe.
   Method ConfigExecESS() //Metodo para o tratamento dos vetores Capa, Detalhe e aDados   
   Method VetorAutoExec() //Metodo para contruir aCapa e aItem para ser usado na classe MsExecAuto.
   Method ExecAutoESS()   //Metodo para a chamada da classe MsExecAuto.
   Method AtuStatus()     //Metodo para atualizar o status conforme o valor do campo data registro //MFR 21/02/2020
      
End Class

/**************************************************************************************/

Method New() Class ImportSiscoserv
   Self:oAvImport   := AvImport():New()
   Self:aItem       := {}
   Self:lErro       := .F.
   Self:aStructCapa := {}
   Self:aStructDeta := {}
   Self:aAutoCapa   := {}
   Self:aAutoDeta   := {}
   Self:aAutoDoca   := {}   
   Self:cMsgErro    := AvObject():New()
   Self:cPosicao    := "0"
   Self:cIntegracao := ""
Return

/**************************************************************************************/
Method SetTipo() Class ImportSiscoserv
Local lRet := .T.

If Len(Self:oAvImport:aDados) > 2
   
   //Self:oAvImport:aDados[1][1] := StrTran(Self:oAvImport:aDados[1][1],Self:oAvImport:cSeparador,"") //Retirar eventuais ; da primeira linha 
   Self:cIntegracao := Self:oAvImport:aDados[1][1]
   Self:aCabecalho  := Self:oAvImport:aDados[2]

   Do Case
      
      Case Self:oAvImport:aDados[1][1] == "PROCESSO_AQUISICAO_SERVICO"
         Self:cPrograma := "EICPS400"
         Self:cTipo     := "A"
      Case Self:oAvImport:aDados[1][1] == "PROCESSO_AQUISICAO_DIS"
         Self:cPrograma := "EICPS400"
         Self:cTipo     := "A"
      Case Self:oAvImport:aDados[1][1] == "PROCESSO_VENDA_SERVICO"
         Self:cPrograma := "EECPS400"
         Self:cTipo     := "V"
      Case Self:oAvImport:aDados[1][1] == "PROCESSO_VENDA_RES"
         Self:cPrograma := "EECPS400"
         Self:cTipo     := "V"
      Case Self:oAvImport:aDados[1][1] == "INVOICE_AQUISICAO_SERVICO"
         Self:cPrograma := "ESSIS400"
         Self:cTipo     := "A"
      Case Self:oAvImport:aDados[1][1] == "INVOICE_VENDA_SERVICO"
         Self:cPrograma := "ESSIS400"
         Self:cTipo     := "V"
   	  Case Self:oAvImport:aDados[1][1] == "CAMBIO_AQUISICAO_SERVICO"
      	 Self:cPrograma := "EECAF500"
      	 Self:cTipo     := "A"
   	  Case Self:oAvImport:aDados[1][1] == "CAMBIO_VENDA_SERVICO"
         Self:cPrograma := "EECAF500"
         Self:cTipo     := "V"
      Case Self:oAvImport:aDados[1][1] == "PROCESSO_VENDA_REG"
         Self:cPrograma := "ESSRV400"
         Self:cTipo     := "V"
      Case Self:oAvImport:aDados[1][1] == "PROCESSO_AQUISICAO_REG"
         Self:cPrograma := "ESSRA400"
         Self:cTipo     := "A"
      Case Self:oAvImport:aDados[1][1] == "INVOICE_VENDA_REG"
         Self:cPrograma := "ESSPS402"
         Self:cTipo     := "V"
      Case Self:oAvImport:aDados[1][1] == "CAMBIO_AQUISICAO_REG"
         Self:cPrograma := "ESSPS402"
         Self:cTipo     := "A"
      OtherWise
         Self:cMsgErro:Error("Tipo da importação indefinido. Verifique o cabeçalho do arquivo CSV.")
         lRet := .F.
   End Do
Else
   lRet := .F.
EndIf

Return lRet

/**************************************************************************************/

Method SelArquivo(cArq) Class ImportSiscoserv

If Valtype(Self:oAvImport) == "O" .And. Valtype(Self:oAvImport:cFile) == "C" .And. Valtype(cArq) == "C"
   Self:oAvImport:cFile := cArq//Variavel da classe AvImport, onde selecionamos o arquivo CSV
   Return .T.
EndIf

Return .F.

*-------------------------*
Method ConfigExecESS(aDados,aCpoChave)Class ImportSiscoserv
*-------------------------*
Local i
Local aItens := {}
Local nPosFilial
Local nPosProcesso
Local nPosOperacao
Local cOperacao
Local cFil
Local nQtdOk      := 0
Local nQtdFail    := 0
Local nOpc        := 3
Local cChave      := ""
Local cChaveLinha := ""
Local nPosCpo, j
Local nPerc   := 0
Local lOk
Local cEmprSM0:= SM0->M0_CODIGO
Local nOldM0 := SM0->(RecNo())
Local lAchoFil
Private aStrCadastros := aClone(aCadastros)

SM0->(dbSetOrder(1))

Begin Sequence

   //Self:cMsgErro += "Integraçao via arquivo CSV para o Easy Siscoserv:" + ENTER + ENTER + "Descrições:" + ENTER
   aDadosCad := aDados
   nPosOperacao :=  aScan(aDados[2],{|X| AllTrim(Upper(X)) == "OPERACAO"})
   nPosFilial := aScan(aDados[2],{ |X|  "_FILIAL" $ AllTrim(Upper(X))})
   
   For j := 1 To Len(aCpoChave)
      If (nPosCpo := aScan(aDados[2],{|X| AllTrim(Upper(X)) == aCpoChave[j] })) == 0
         EXIT
      EndIf
   Next j
   
   If Len(aDados) < 2 .OR. nPosCpo == 0 .OR. nPosOperacao == 0//.and. Len(alltrim(aDados[i][nPosFilial])) == 2
      Self:cMsgErro:Error("Campos obrigatorios não foram informado no cabeçalho ou formatação invalida no arquivo CSV: OPERACAO, FILIAL e PROCESSO.")
      nQtdFail := Len(aDados)
      Return
   End If
      
   //ProcRegua(Min(Len(aDados)-2,100))
   If !IsBlind()
      oProgress:SetRegua(Len(aDados)-2) //RMD - 09/03/16
   EndIf
   
   For i := 3 To Len(aDados)//Pega quantidade de linhas

      If Len(aDados[i]) < Len(aDados[2])
         Self:cMsgErro:Error("Registro inválido. Há menos campos que os definidos no cabeçalho. Registro: "+Str(i))
         nQtdFail++
         Loop
      EndIf
      
      If nPosFilial > 0 .AND. !Empty(aDados[i][nPosFilial])
         lAchoFil := SM0->(dbSeek(cEmprSM0+Replicate("0",FWSizeFilial()-Len(aDados[i][nPosFilial]))+aDados[i][nPosFilial]))
         SM0->(dbGoTo(nOldM0))
         If !lAchoFil
            Self:cMsgErro:Error("Filial "+aDados[i][nPosFilial]+" não cadastrada no Protheus."+ENTER+;
                                "Verifique a necessidade de integrar processos para essa filial ou "+ENTER+;
                                "deixe em branco para integrar na filial em uso no sistema.")
            nQtdFail++
            Loop
         EndIf
      End If
      
      nOpc     := Val(aDados[i][nPosOperacao])
      
      cChaveLinha := ""
      For j := 1 To Len(aCpoChave)
         nPosCpo := aScan(aDados[2],{|X| AllTrim(Upper(X)) == aCpoChave[j] })
         cChaveLinha += aDados[i][nPosCpo]
      Next j

      If cChave <> cChaveLinha
         If Empty(cChave)
            cChave := cChaveLinha
         Else            
            Self:VetorAutoExec(aItens)
            lOk = Self:ExecAutoESS(nOpc)
                        
            If lOk
               nQtdOk   += 1
            Else
               nQtdFail += 1
            EndIf   
         EndIf

         aItens := {}
         Self:aAutoCapa := {}
         Self:aAutoDeta := {}
         Self:aAutoDoca := {}
         cChave := cChaveLinha
         Self:cPosicao := AllTrim(Str(i))
      EndIf
      
      aAdd(aItens,aDados[i])
      
      If !IsBlind() .And. !oProgress:IncRegua() //RMD - 09/03/16
         BREAK
      EndIf
      /*If INT(100*(i-2)/(Len(aDados)-2)) > nPerc
   	     nPerc := INT(100*(i-2)/(Len(aDados)-2))
	     IncProc("Progresso:  " +STR(nPerc)+ " %")
   	     SysRefresh()
	  EndIf*/
      
   Next i

   If !Empty(cChave)
      
      Self:VetorAutoExec(aItens)
      lOk := Self:ExecAutoESS(nOpc)   

      If lOk
         nQtdOk   += 1
      Else
         nQtdFail += 1
      EndIf

   End If

End Sequence

cMsgResumo := "Quantidade de processo não integrado: "         + alltrim(Str(nQtdFail)) + ENTER
cMsgResumo += "Quantidade de processo integrado com sucesso: " + alltrim(Str(nQtdOk))   + ENTER

If !IsBlind()//RMD - 09/03/16
   MsgInfo(cMsgResumo,"Integração finalizada!")
EndIf
   
Return .T.

/**************************************************************************************/

Method ExecAutoESS(nOpc) Class ImportSiscoserv 
Local bExecAuto
Local nPosPgt          := 0
Local cCpoLiq          := ""
Local dPagto           := CTOD("  \  \  ") 
Local nPosFilial
Local aOrd             := SaveOrd({"EJW","ELA","EEQ"}) //RRC - 18/11/2013
Local i := 0, k := 0
Local lErroCad         := .F.
Local cCond            := "" //LRS - 13/01/2016 - declaração variavel local
Local cCodEmp          := ""
Local cLojEmp          := ""
Local nCodEmp          := 0
Local nLojEmp          := 0
Local nTamFil          := FWSizeFilial()
Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.
Private nRecNoFilial   := SM0->(RecNo())
   bExecAuto  := &("{|a,b,c,d,e,f,g| "+Self:cPrograma+"(a,b,c,d,e,f,g)}")
   nPosFilial := aScan(Self:aAutoCapa,{ |x|  "_FILIAL" $ AllTrim(Upper(x[1]))})
   //RRC - 18/11/2013 - Ajusta a filial no array caso a mesma possua um caractere
   Self:aAutoCapa[nPosFilial][2] := PADL(Self:aAutoCapa[nPosFilial][2],nTamFil,"0")
      
   /*Do Case
      Case Self:cTipo == "A"
         MSExecAuto({|a,b,c,d| EICPS400(a,b,c,d)},Self:aAutoCapa,Self:aAutoDeta,Self:aAutoDoca,nOpc)
      Case Self:cTipo == "V"
         MSExecAuto({|a,b,c,d| EECPS400(a,b,c,d)},Self:aAutoCapa,Self:aAutoDeta,Self:aAutoDoca,nOpc)
   End case*/
   
   If Len(aCadastros) # 0
      For i := 1 To Len(aCadastros)
         //aRetnOpc := SetnOPC(aCadastros[i],nOpc)
		  //Tratamentos para o vínculo entre empresas
         If aCadastros[i][1] == "ELM" //MCF - 12/08/2016
            If (nPos := aScan(aCadastros[i][3], {|x| AllTrim(x[1]) == "ELM_TIPVIN" })) > 0
                  //Atualiza os campos do vínculo com o código da empresa correta, caso não tenha sido enviado no csv.
                  If Self:cTipo == "V"
                     If (nCodEmp := aScan(aCadastros[i][3], {|x| x[1] == "ELM_CODFOR" })) > 0 .And. (nLojEmp := aScan(aCadastros[i][3], {|x| x[1] == "ELM_LOJFOR" })) > 0
                        If (Empty(aCadastros[i][3][nCodEmp][2]) .And. Empty(aCadastros[i][3][nLojEmp][2]) .Or. aCadastros[i][3][nCodEmp][2] == "X" .And. aCadastros[i][3][nLojEmp][2] == "X") .Or. !EasyGParam("MV_ESS0021",,.F.)
                           SA2->(DbSetOrder(3))
                           If SA2->(DbSeek(xFilial()+SM0->M0_CGC))
                              aCadastros[i][3][nCodEmp][2] := SA2->A2_COD
                              aCadastros[i][3][nLojEmp][2] := SA2->A2_LOJA
                           EndIf
                        
                        If (Empty(SM0->M0_CGC) .Or. !SA2->(DbSeek(xFilial()+SM0->M0_CGC))) .And. aCadastros[i][3][nPos][2] != ""
                              Self:cMsgErro:Error("Não foi localizado fornecedor com o CNPJ definido para esta filial do sistema.")
                              lErroCad := .T.
                              lMSErroAuto := .T.
                              EXIT
                           EndIf
                        EndIf
                     
                     //Caso o campo exista na estrutura, mas esteja em branco, ignora.
                     If (nImport := aScan(Self:aAutoCapa,{ |x| AllTrim(Upper(x[1])) == "EJW_IMPORT" })) > 0 .And. (nLojImp := aScan(Self:aAutoCapa,{ |x| AllTrim(Upper(x[1])) == "EJW_LOJIMP" })) > 0
                        ELM->(DbSetOrder(1))
                        If aCadastros[i][3][nPos][2] == "" .And. !ELM->(dBSeek(xFilial("ELM")+AvKey(Self:aAutoCapa[nImport][2],"ELM_CODCLI")+AvKey(Self:aAutoCapa[nLojImp][2],"ELM_LOJCLI")+AvKey(aCadastros[i][3][nCodEmp][2],"ELM_CODFOR")+AvKey(aCadastros[i][3][nLojEmp][2],"ELM_LOJFOR")))
                           Loop
                        EndIf
                     EndIf
                        
                     EndIf
                  Else
                     If (nCodEmp := aScan(aCadastros[i][3], {|x| x[1] == "ELM_CODCLI" })) > 0 .And. (nLojEmp := aScan(aCadastros[i][3], {|x| x[1] == "ELM_LOJCLI" })) > 0
                        If (Empty(aCadastros[i][3][nCodEmp][2]) .And. Empty(aCadastros[i][3][nLojEmp][2]) .Or. aCadastros[i][3][nCodEmp][2] == "X" .And. aCadastros[i][3][nLojEmp][2] == "X") .Or. !EasyGParam("MV_ESS0021",,.F.)
                           SA1->(DbSetOrder(3))
                           If SA1->(DbSeek(xFilial()+SM0->M0_CGC))
                              aCadastros[i][3][nCodEmp][2] := SA1->A1_COD
                              aCadastros[i][3][nLojEmp][2] := SA1->A1_LOJA
                           EndIf
                        
                        If (Empty(SM0->M0_CGC) .Or. !SA1->(DbSeek(xFilial()+SM0->M0_CGC))) .And. aCadastros[i][3][nPos][2] != ""
                              Self:cMsgErro:Error("Não foi localizado cliente com o CNPJ definido para esta filial do sistema.")
                              lErroCad := .T.
                              lMSErroAuto := .T.
                              EXIT
                           EndIf
                        EndIf
                     
                     //Caso o campo exista na estrutura, mas esteja em branco, ignora.
                     If (nExport := aScan(Self:aAutoCapa,{ |x| AllTrim(Upper(x[1])) == "EJW_EXPORT" })) > 0 .And. (nLojExp := aScan(Self:aAutoCapa,{ |x| AllTrim(Upper(x[1])) == "EJW_LOJEXP" })) > 0
                        ELM->(DbSetOrder(1))
                        If aCadastros[i][3][nPos][2] == "" .And. !ELM->(dBSeek(xFilial("ELM")+AvKey(aCadastros[i][3][nCodEmp][2],"ELM_CODCLI")+AvKey(aCadastros[i][3][nLojEmp][2],"ELM_LOJCLI")+AvKey(Self:aAutoCapa[nExport][2],"ELM_CODFOR")+AvKey(Self:aAutoCapa[nLojExp][2],"ELM_LOJFOR")))
                           Loop
                        EndIf
                     EndIf
                  
                  EndIf
               EndIf                 
            EndIf
         EndIf
            
         If aCadastros[i][1] == "SA6"
         	aEval(aCadastros[i][3], {|x| If(x[1] == "A6_NOME2", x[1] := "A6_NOME", Nil) })
         EndIf
         MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2])
		 
		 If xFilial(aCadastros[i][1]) <> ""
	         //aEval(aCadastros[i][3], {|x| If("_FILIAL" $ x[1], x[2] := Self:aAutoCapa[nPosFilial][2],) })
			 aEval(aCadastros[i][3], {|x| If("_FILIAL" $ x[1], x[2] := xFilial(aCadastros[i][1]),) })
	     EndIf
		 
         aRetnOpc := SetnOPC(aCadastros[i],Self:cTipo)  // AAF - 10/11/2014
         If aRetnOpc[1]
            If !EasyIsInMVC(aCadastros[i][2])
               MSExecAuto(&("{|a,b,c,d,e,f,g| "+aCadastros[i][2]+"(a,b,c,d,e,f,g)}"),aCadastros[i][3],aCadastros[i][4],aRetnOpc[2])
            Else
               //cRotina := aCadastros[i][2]+"_MVC(aRetnOpc[2],aCadastros[i][3],aCadastros[i][4])"
               lMSErroAuto := !EasyMVCAuto(aCadastros[i][2],aRetnOpc[2],{aCadastros[i][1]+"MASTER",aCadastros[i][3]})
            EndIf
         EndIf
         MudaFilial(.T.)
		 If lMSErroAuto
		    lErroCad := .T.
			EXIT
		 EndIf
      Next i
   EndIf
            
   If "PROCESSO" $ Self:oAvImport:aDados[1][1]
      //Self:aAutoCapa[nPosFilial][2] := xFilial("EJW") //RMD - 08/06/15 - Removido por estar incorreto.
      If !lErroCad
         AjustaCampos(Self:oAvImport:aDados[1][1],@Self:aAutoCapa,@Self:aAutoDeta) //MCF - 30/11/2016
	     If "_DIS" $ Self:oAvImport:aDados[1][1] .OR. "_RES" $ Self:oAvImport:aDados[1][1]
            //If !EasyGParam("MV_ESS0027",,9) >= 10
               EJW->(dbSetOrder(1))
               If EJW->(dbSeek(If(Empty(xFilial("EJW")),xFilial("EJW"),Self:aAutoCapa[nPosFilial][2])+Self:cTipo+AvKey(GetField(Self:aAutoCapa,"EJW_PROCES"),"EJW_PROCES")))
                  If nOpc == 5  // Caso deleção de documentos
                     For k := 1 To Len(Self:aAutoDeta)
                        aadd(Self:aAutoDeta[k],{"AUTDELETA","S",NIL})
                     Next k
                  EndIf
                  MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
                  MSExecAuto(bExecAuto,Self:aAutoCapa,{},Self:aAutoDeta,4)
                  MudaFilial(.T.)
			   Else
                  lMsErroAuto := .T.
                  Self:cMsgErro:Error("Erro processo não está cadastrado. Processo: "+  GetField(Self:aAutoCapa,"EJW_PROCES") +" linha: "+ self:cPosicao)
	           EndIf
			//Else
			//   EJY->(dbSetOrder(1))
            //   If EJY->(dbSeek(If(Empty(xFilial("EJY")),xFilial("EJY"),Self:aAutoCapa[nPosFilial][2])+Self:cTipo+AvKey(GetField(Self:aAutoCapa,"EJY_REGIST"),"EJY_REGIST")))
            //      MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
            //      MSExecAuto(bExecAuto,Self:aAutoCapa,Self:aAutoDeta,nOpc)
            //      MudaFilial(.T.)
			//   Else
            //      lMsErroAuto := .T.
            //      Self:cMsgErro:Error("Erro processo não está cadastrado. Processo: "+  GetField(Self:aAutoCapa,"EJY_REGIST") +" linha: "+ self:cPosicao)
	        //   EndIf
			//EndIf
         Else
            MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
            MSExecAuto(bExecAuto,Self:aAutoCapa,Self:aAutoDeta,Self:aAutoDoca,nOpc)
            MudaFilial(.T.)
         EndIf
      EndIf
	  
      If lMsErroAuto
         Self:cMsgErro:Error("Erro: "+If(lErroCad,"Ao efetuar cadastro para ","No")+" processo: "+  GetField(Self:aAutoCapa,"EJW_PROCES") +" linha: "+ Self:cPosicao)
      EndIf
      
   ElseIf "INVOICE" $ Self:oAvImport:aDados[1][1]
      If !("_REG" $ Self:oAvImport:aDados[1][1])
         AjustaCampos(Self:oAvImport:aDados[1][1],@Self:aAutoCapa,@Self:aAutoDeta)
         EJW->(dbSetOrder(1))
         //RRC - 18/11/2013 - Antes de buscar pela filial informada no arquivo csv, verifica se o compartilhamento das tabelas é o mesmo
         If EJW->(dbSeek(If(Empty(xFilial("EJW")),xFilial("EJW"),Self:aAutoCapa[nPosFilial][2])+Self:cTipo+AvKey(GetField(Self:aAutoCapa,"ELA_PROCES"),"ELA_PROCES")))
            If !lErroCad
			   MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
               MSExecAuto(bExecAuto,"EJW", EJW->(RecNo()), , Self:cTipo, Self:aAutoCapa,Self:aAutoDeta,nOpc)
               MudaFilial(.T.)
			EndIf
			
            If lMsErroAuto
               Self:cMsgErro:Error("Erro: "+If(lErroCad,"Ao efetuar cadastro para ","No")+" processo: "+  GetField(Self:aAutoCapa,"ELA_PROCES") +" Invoice: "+  GetField(Self:aAutoCapa,"ELA_NRINVO") +" linha: "+ self:cPosicao)
            EndIf
         Else
            lMsErroAuto := .T.
            Self:cMsgErro:Error("Erro processo não está cadastrado. Processo: "+  GetField(Self:aAutoCapa,"ELA_PROCES") +" linha: "+ self:cPosicao)
         EndIf
      Else
         If Select("EL9") == 0
            ChkFile("EL9",.F.)
         EndIf
         //Self:aAutoCapa[nPosFilial][2] := xFilial("EL9") //RMD - 08/06/15 - Removido por estar incorreto.
         EL9->(DbSetOrder(1))
         If EL9->(DbSeek(If(Empty(xFilial("EL9")),xFilial("EL9"),Self:aAutoCapa[nPosFilial][2])+Self:cTipo+AvKey(GetField(Self:aAutoCapa,"EL9_REGIST"),"EL9_REGIST")))
            If !lErroCad
               MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
               MSExecAuto(bExecAuto,Self:aAutoCapa,Self:aAutoDeta,nOpc,Self:cTipo)
               MudaFilial(.T.)
			EndIf
            
			If lMsErroAuto
               Self:cMsgErro:Error("Erro: "+If(lErroCad,"Ao efetuar cadastro para ","No")+" processo: "+  GetField(Self:aAutoCapa,"EL9_PROCES") +" Invoice: "+  GetField(Self:aAutoCapa,"EL9_NRINVO") +" linha: "+ self:cPosicao)
            EndIf
         EndIf
      EndIf
   ElseIf "CAMBIO" $ Self:oAvImport:aDados[1][1]
      If !("_REG" $ Self:oAvImport:aDados[1][1])
         //Self:aAutoCapa[nPosFilial][2] := xFilial("EEQ") //RMD - 08/06/15 - Removido por estar incorreto.
         //EJW->(dbSetOrder(1))
         //If EJW->(dbSeek(xFilial("EJW")+Self:cTipo+AvKey(GetField(Self:aAutoCapa,"EEQ_PROCES"),"EEQ_PROCES")))
         /*
         If Self:cTipo == "A"
            nOrd    := 3
            cForCli := "EEQ_FORN"
            cLoja   := "EEQ_FOLOJA"
         Else
            nOrd    := 2          
            cForCli := "EEQ_IMPORT"
            cLoja   := "EEQ_IMLOJA"
         EndIf
         */
         If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015         
            EEQ->(DbSetOrder(4)) //EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC
         Else
            EEQ->(DbSetOrder(15)) //EEQ_FILIAL+EEQ_TPPROC+EEQ_PROC+EEQ_NRINVO+EEQ_PARC  // GFP - 26/05/2015
         EndIf
         //ELA->(dbSetOrder(nOrd))
         ELA->(dbSetOrder(4))
         //RRC - 18/11/2013 - Antes de buscar pela filial informada no arquivo csv, verifica se o compartilhamento das tabelas é o mesmo
         //If ELA->(dbSeek(If(Empty(xFilial("ELA")),xFilial("ELA"),Self:aAutoCapa[nPosFilial][2])+Self:cTipo+AvKey(GetField(Self:aAutoCapa,cForCli),cForCli)+AvKey(GetField(Self:aAutoCapa,cLoja),cLoja)+AvKey(GetField(Self:aAutoCapa,"EEQ_NRINVO"),"ELA_NRINVO")+AvKey(GetField(Self:aAutoCapa,"EEQ_PROCES"),"ELA_PROCES")))
         If ELA->(dbSeek(If(Empty(xFilial("ELA")),xFilial("ELA"),Self:aAutoCapa[nPosFilial][2])+Self:cTipo+AvKey(GetField(Self:aAutoCapa,"EEQ_PROCES"),"ELA_PROCES")+AvKey(GetField(Self:aAutoCapa,"EEQ_NRINVO"),"ELA_NRINVO")))
            //RRC - 15/07/2013 - Tratamento para estorno da baixa na exclusão da parcela de câmbio, apaga o conteúdo do campo de liquidação
            If nOpc == EXCLUIR
               If (nPosPgt := aScan(Self:aAutoCapa,{ |x| AllTrim(Upper(x[1])) == "EEQ_MODAL" })) > 0 .And. ValType(Self:aAutoCapa[nPosPgt][2]) == "C" .And. Self:aAutoCapa[nPosPgt][2] == "2"
                  nPosPgt  := aScan(Self:aAutoCapa,{|x| AllTrim(Upper(x[1])) == "EEQ_DTCE"})
                  cCpoLiq  := "EEQ_DTCE"           
               Else
                  nPosPgt  := aScan(Self:aAutoCapa,{|x| AllTrim(Upper(x[1])) == "EEQ_PGT"})
                  cCpoLiq  := "EEQ_PGT"  
               EndIf
               //Alteração sem o campo de pagamento é considerada estorno da baixa            
               If nPosPgt > 0 .And. !Empty(GetField(Self:aAutoCapa,cCpoLiq))
                  Self:aAutoCapa[nPosPgt][2] := CToD("  /  /  ")        
                  nOpc := ALTERAR
                  If !lErroCad
				     MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
                     MSExecAuto(bExecAuto,"EEQ",,,Self:aAutoCapa,nOpc,Self:cTipo)
                     MudaFilial(.T.)
				  EndIf
               EndIf
               //Após o estorno da baixa, fará a exclusão normalmente
               If lMsErroAuto
                  Self:cMsgErro:Error("Erro: "+If(lErroCad,"Ao efetuar cadastro para ","No")+" processo: "+  GetField(Self:aAutoCapa,"EEQ_PROCES") +" Invoice: "+  GetField(Self:aAutoCapa,"EEQ_NRINVO") +" linha: "+ self:cPosicao)
               Else
                  nOpc := EXCLUIR
               EndIf
            
               //RRC - 18/07/2013 - Tratamento para baixa na inclusão, além disso, se for informado tipo de operação 4 e não existir a parcela, fará a inclusão seguida da baixa         
               /*If !SIX->(dbSeek("EEQF"))    // GFP - 26/05/2015 - Nopado por MCF - 18/11/2015 
                  cCond := '!EEQ->(DbSeek(Self:aAutoCapa[nPosFilial][2]+AvKey(GetField(Self:aAutoCapa,"EEQ_NRINVO"),"EEQ_NRINVO")+AvKey(Self:cTipo+GetField(Self:aAutoCapa,"EEQ_PROCES"),"EEQ_PREEMB")+AvKey(GetField(Self:aAutoCapa,"EEQ_PARC"),"EEQ_PARC")))'
               Else
                  cCond := '!EEQ->(DbSeek(Self:aAutoCapa[nPosFilial][2]+AvKey(Self:cTipo,"EEQ_TPPROC")+AvKey(GetField(Self:aAutoCapa,"EEQ_PROC"),"EEQ_PROC")+AvKey(GetField(Self:aAutoCapa,"EEQ_NRINVO"),"EEQ_NRINVO")+AvKey(GetField(Self:aAutoCapa,"EEQ_PARC"),"EEQ_PARC")))'
               EndIf*/
            ElseIf nOpc == INCLUIR .Or. If(!SIX->(dbSeek("EEQF")),!EEQ->(DbSeek(Self:aAutoCapa[nPosFilial][2]+AvKey(GetField(Self:aAutoCapa,"EEQ_NRINVO"),"EEQ_NRINVO")+AvKey(Self:cTipo+GetField(Self:aAutoCapa,"EEQ_PROCES"),"EEQ_PREEMB")+AvKey(GetField(Self:aAutoCapa,"EEQ_PARC"),"EEQ_PARC"))),; //MCF - 18/11/2015
                                                                  !EEQ->(DbSeek(Self:aAutoCapa[nPosFilial][2]+AvKey(Self:cTipo,"EEQ_TPPROC")+AvKey(GetField(Self:aAutoCapa,"EEQ_PROC"),"EEQ_PROC")+AvKey(GetField(Self:aAutoCapa,"EEQ_NRINVO"),"EEQ_NRINVO")+AvKey(GetField(Self:aAutoCapa,"EEQ_PARC"),"EEQ_PARC"))))
               If (nPosPgt := aScan(Self:aAutoCapa,{ |x| AllTrim(Upper(x[1])) == "EEQ_MODAL" })) > 0 .And. ValType(Self:aAutoCapa[nPosPgt][2]) == "D" .And. Self:aAutoCapa[nPosPgt][2] == "2"
                  nPosPgt  := aScan(Self:aAutoCapa,{|x| AllTrim(Upper(x[1])) == "EEQ_DTCE"})
                  cCpoLiq  := "EEQ_DTCE"           
               Else
                  nPosPgt  := aScan(Self:aAutoCapa,{|x| AllTrim(Upper(x[1])) == "EEQ_PGT"})
                  cCpoLiq  := "EEQ_PGT"  
               EndIf
               //Fará a inclusão sem o campo de pagamento, para depois realizar a alteração preenchendo este campo, para ser considerada considerada liquidação            
               If nPosPgt > 0 .And. !Empty(GetField(Self:aAutoCapa,cCpoLiq))
                  dPagto :=  GetField(Self:aAutoCapa,cCpoLiq)
                  Self:aAutoCapa[nPosPgt][2] := CToD("  /  /  ")        
                  //RRC - 18/11/2013 - Adicionada chamada da função MudaFilial() para esta chamada de MsExecAuto()
                  IF !lErroCad
				     MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
                     MSExecAuto(bExecAuto,"EEQ",,,Self:aAutoCapa,nOpc,Self:cTipo)
                     MudaFilial(.T.)
				  EndIf
                  If lMsErroAuto
                     Self:cMsgErro:Error("Erro: "+If(lErroCad,"Ao efetuar cadastro para ","No")+" processo: "+  GetField(Self:aAutoCapa,"EEQ_PROCES") +" Invoice: "+  GetField(Self:aAutoCapa,"EEQ_NRINVO") +" linha: "+ self:cPosicao)
                  Else
                     Self:aAutoCapa[nPosPgt][2] := dPagto       
                     nOpc := ALTERAR
                  EndIf
               EndIf
            EndIf
            If !lMsErroAuto
               MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
               MSExecAuto(bExecAuto,"EEQ",,,Self:aAutoCapa,nOpc,Self:cTipo)
               MudaFilial(.T.)
               If lMsErroAuto
                  Self:cMsgErro:Error("Erro: "+If(lErroCad,"Ao efetuar cadastro para ","No")+" processo: "+  GetField(Self:aAutoCapa,"EEQ_PROCES") +" Invoice: "+  GetField(Self:aAutoCapa,"EEQ_NRINVO") +" linha: "+ self:cPosicao)
               EndIf
            EndIf
         Else
         	lMsErroAuto := .T.
         	Self:cMsgErro:Error("Erro processo não está cadastrado. No processo: "+  GetField(Self:aAutoCapa,"EEQ_PROCES") +" Invoice: "+  GetField(Self:aAutoCapa,"EEQ_NRINVO") +" linha: "+ self:cPosicao)
         EndIf
      Else
         If Select("EL9") == 0
            ChkFile("EL9",.F.)
         EndIf
         //Self:aAutoCapa[nPosFilial][2] := xFilial("EL9") //RMD - 08/06/15 - Removido por estar incorreto.
         EL9->(DbSetOrder(1))
         If EL9->(DbSeek(If(Empty(xFilial("EL9")),xFilial("EL9"),Self:aAutoCapa[nPosFilial][2])+Self:cTipo+AvKey(GetField(Self:aAutoCapa,"EL9_REGIST"),"EL9_REGIST")))
            If !lMsErroAuto
               MudaFilial(.F.,Self:aAutoCapa[nPosFilial][2]) 
               MSExecAuto(bExecAuto,Self:aAutoCapa,Self:aAutoDeta,nOpc,Self:cTipo)
               MudaFilial(.T.)
               If lMsErroAuto
                  Self:cMsgErro:Error("Erro: "+If(lErroCad,"Ao efetuar cadastro para ","No")+" processo: "+  GetField(Self:aAutoCapa,"EL9_REGIST") +" Invoice: "+  GetField(Self:aAutoCapa,"EL9_NRINVO") +" linha: "+ self:cPosicao)
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf
   
   If lMsErroAuto
      Self:cMsgErro:Error(GetAutoGRLog(),,.F.)
   EndIf
RestOrd(aOrd,.T.)

Return !lMsErroAuto

/**************************************************************************************/

Method VetorAutoExec(aItens) Class ImportSiscoserv
Local cCampo, cCpo
Local i,j,n
Local aReg, nPos
Local aCadastro

aCadastros := {}

For n := 1 To Len(aItens)
	aCadastro := aClone(aStrCadastros)
	
	If Len(aCadastro) # 0
	   For i := 1 To Len(aCadastro)
	       For j := 1 To Len(aCadastro[i][3])
	          If (nPos := aScan(aDadosCad[2], {|x| x == aCadastro[i][3][j][1]})) # 0 .Or. (aCadastro[i][3][j][1] == "A6_NOME" .And. (nPos := aScan(aDadosCad[2], {|x| x == "A6_NOME2"})) # 0)
	             cCpo := If(aCadastro[i][3][j][1] == "A6_NOME2","A6_NOME",aCadastro[i][3][j][1])
	             //aCadastro[i][3][j][1] := cCpo
	             aCadastro[i][3][j][2] := AvConvert( ,AvSx3(cCpo,2),,aItens[n][nPos])
	          Else
	             nPosCad := aScan(aCposChvCad,{|X| X[1] == aCadastro[i][1]})
                 DeParaCadastros(@aCadastro[i][3][j],aDadosCad[2],aItens[n],aCposChvCad[nPosCad][2])
	          Endif
	       Next j
	       If aCadastro[i][1] == "SB1" .AND. (nPos := aScan(aCadastro[i][3], {|x| x[1] == "B5_NBS"})) # 0  // GFP - 09/04/2014
	          IN100IncSB5(aCadastro[i])
	       EndIf	   
	   Next i
	EndIf
	
	For i := 1 To Len(aCadastro)
		aAdd(aCadastros, aClone(aCadastro[i]))
	Next
	
Next

For i := 1 To Len(Self:aStructCapa)
   If Len(Self:aStructCapa[i]) >= 4 .And. !Empty(Self:aStructCapa[i][4])
      aAdd(Self:aAutoCapa,{Self:aStructCapa[i][1], AvConvert ( ,Self:aStructCapa[i][3], /*AVSX3(cCampo,3)*/, Self:aStructCapa[i][4]) , Nil })
   Else
      aAdd(Self:aAutoCapa,{Self:aStructCapa[i][1], AvConvert ( ,Self:aStructCapa[i][3], /*AVSX3(cCampo,3)*/, aItens[1][Self:aStructCapa[i][2]]) , Nil })
   EndIf
Next i

For i:= 1 to Len(aItens)
   aReg := {}
   For j:= 1 to Len(Self:aStructDeta)
      //If (nPos := aScan(Self:aCabecalho, {|X| Upper(AllTrim(X)) == Self:aStructDeta[j][1]})) > 0
      If Len(Self:aStructDeta[j]) >= 4 /*.And. !Empty(Self:aStructDeta[j][4])*/ //Não impedir conteudo vazio.
         aAdd(aReg,{Self:aStructDeta[j][1], AvConvert ( ,Self:aStructDeta[j][3],/*AVSX3(cCampo,3)*/ , Self:aStructDeta[j][4]) , Nil })
      Else   
         aAdd(aReg,{Self:aStructDeta[j][1], AvConvert ( ,Self:aStructDeta[j][3],/*AVSX3(cCampo,3)*/ , aItens[i][Self:aStructDeta[j][2]]) , Nil })
      EndIf
   Next j
   If Len(aReg) # 0  // GFP - 07/03/2014
      aAdd(Self:aAutoDeta,aClone(aReg))
   EndIf
Next i
//Trata todos os campos da capa e detalhe com o AvKey
If !Empty(Self:aAutoCapa)
   AvKeyAuto(Self:aAutoCapa)
EndIf
If !Empty(Self:aAutoDeta)
   Self:AtuStatus(Self)
   AvKeyAuto(Self:aAutoDeta)
EndIf

Return .T.

/* 
Funcao      : StructCapa().
Objetivos   : Definir a estrutura usada para a capa no protheus
Parametros  : cTipo - Tipo do processo "A" = aquisição/"V" = venda
Retorno     : 
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 05/02/2013 - 10:00.
*/
Static Function StructCapa(cIntegracao,cTipo,aCabecalho, oObjIntegracao)
Local aDePara := {}
Local aRet    := {}
Local aRetCad := {}
Local nPos, i, j
Local lSA6 := .F.

If "PROCESSO" $ cIntegracao
   aCpoChave := {"EJW_FILIAL","EJW_PROCES"}

   Do Case
      Case cTipo == "A"
         
         If "_DIS" $ cIntegracao
            //If !EasyGParam("MV_ESS0027",,9) >= 10
               aAdd(aDePara,{"EJW_FILIAL","EJW_FILIAL"})
               aAdd(aDePara,{"EJW_PROCES","EJW_PROCES"})
               aAdd(aDePara,{"EJW_ORIGEM","EJW_ORIGEM"})
               aAdd(aDePara,{cTipo,"EJW_TPPROC",.T.})
            //Else
            //   aCpoChave := {"EJY_FILIAL","EJY_REGIST"}
            //   aAdd(aDePara,{"EJY_FILIAL","EJY_FILIAL"})
            //   aAdd(aDePara,{"EJY_PROCES","EJY_PROCES"})
            //   aAdd(aDePara,{"EJY_REGIST","EJY_REGIST"})
            //   aAdd(aDePara,{cTipo,"EJY_TPPROC",.T.})
               //aAdd(aDePara,{"EJY_ORIGEM","EJY_ORIGEM"})
            //EndIf
         ElseIf "_REG" $ cIntegracao
            aCpoChave := {"EJY_FILIAL","EJY_REGIST"}
            aAdd(aDePara,{"EJY_FILIAL","EJY_FILIAL"})
            aAdd(aDePara,{"EJY_REGIST","EJY_REGIST"})
            aAdd(aDePara,{"EJY_PROCES","EJY_PROCES"})
            aAdd(aDePara,{"EJY_NIF"   ,"EJY_NIF"})
            //aAdd(aDePara,{"A1_CGC","EJY_IMPORT"})
            //aAdd(aDePara,{"A1_CGC","EJY_LOJIMP"})
            aAdd(aDePara,{"EJY_IMPORT","EJY_IMPORT"})
            aAdd(aDePara,{"EJY_LOJIMP","EJY_LOJIMP"})
            aAdd(aDePara,{"3","EJY_STTSIS",.T.})
            aAdd(aDePara,{"EJY_DTREG" ,"EJY_DTREG"})
            aAdd(aDePara,{"EJY_NROREG","EJY_NROREG"})
            aAdd(aDePara,{"EJY_DTRET" ,"EJY_DTRET"})

         Else
            aAdd(aDePara,{"EJW_FILIAL","EJW_FILIAL"})
            aAdd(aDePara,{"EJW_PROCES","EJW_PROCES"})
            aAdd(aDePara,{"EJW_ORIGEM","EJW_ORIGEM"})
            aAdd(aDePara,{"EJW_EXPORT","EJW_EXPORT"})
            aAdd(aDePara,{"EJW_LOJEXP","EJW_LOJEXP"})
            aAdd(aDePara,{"EJW_MOEDA" ,"EJW_MOEDA" })
            aAdd(aDePara,{"EJW_COMPL" ,"EJW_COMPL" })
            aAdd(aDePara,{"EJW_DTPROC","EJW_DTPROC"})
            AAdd(aDePara,{"A2_NOME", "A2_NREDUZ"})
            aAdd(aDePara,{"EJW_CONDPG","EJW_CONDPG"})  // GFP - 24/07/2014
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo
            If EasyGParam("MV_ESS0021",,.F.) .And. EJW->(FieldPos("EJW_CODEMP")) > 0 .And. EJW->(FieldPos("EJW_LOJEMP")) > 0 .And.EJW->(FieldPos("EJW_CGC")) > 0
               aAdd(aDePara,{"EJW_CODEMP","EJW_CODEMP"})
               aAdd(aDePara,{"EJW_LOJEMP","EJW_LOJEMP"})
               aAdd(aDePara,{"EJW_CGC"   ,"EJW_CGC"   })
            EndIf
         EndIf
               
      Case cTipo == "V"

         If "_RES" $ cIntegracao
            //If !EasyGParam("MV_ESS0027",,9) >= 10
               aAdd(aDePara,{"EJW_FILIAL","EJW_FILIAL"})
               aAdd(aDePara,{"EJW_PROCES","EJW_PROCES"})
               aAdd(aDePara,{"EJW_ORIGEM","EJW_ORIGEM"})
            //Else
            //   aCpoChave := {"EJY_FILIAL","EJY_REGIST"}
            //   aAdd(aDePara,{"EJY_FILIAL","EJY_FILIAL"})
            //   aAdd(aDePara,{"EJY_PROCES","EJY_PROCES"})
            //   aAdd(aDePara,{"EJY_REGIST","EJY_REGIST"})
            //   aAdd(aDePara,{cTipo,"EJY_TPPROC",.T.})
               //aAdd(aDePara,{"EJY_ORIGEM","EJY_ORIGEM"})
            //EndIf

         ElseIf "_REG" $ cIntegracao
            aCpoChave := {"EJY_FILIAL","EJY_REGIST"}
            aAdd(aDePara,{"EJY_FILIAL","EJY_FILIAL"})
            aAdd(aDePara,{"EJY_REGIST","EJY_REGIST"})
            aAdd(aDePara,{"EJY_PROCES","EJY_PROCES"})
            aAdd(aDePara,{"EJY_NIF"   ,"EJY_NIF"})
            //aAdd(aDePara,{"A2_CGC"    ,"EJY_EXPORT"})
            //aAdd(aDePara,{"A2_CGC"    ,"EJY_LOJEXP"})
            aAdd(aDePara,{"EJY_EXPORT","EJY_EXPORT"})
            aAdd(aDePara,{"EJY_LOJEXP","EJY_LOJEXP"})
            aAdd(aDePara,{"3","EJY_STTSIS",.T.})
            aAdd(aDePara,{"EJY_DTREG" ,"EJY_DTREG"})
            aAdd(aDePara,{"EJY_NROREG","EJY_NROREG"})
            aAdd(aDePara,{"EJY_DTRET" ,"EJY_DTRET"})

         Else
            aAdd(aDePara,{"EJW_FILIAL","EJW_FILIAL"})
            aAdd(aDePara,{"EJW_PROCES","EJW_PROCES"})
            aAdd(aDePara,{"EJW_ORIGEM","EJW_ORIGEM"})
            aAdd(aDePara,{"EJW_IMPORT","EJW_IMPORT"})
            aAdd(aDePara,{"EJW_LOJIMP","EJW_LOJIMP"})
            aAdd(aDePara,{"EJW_MOEDA" ,"EJW_MOEDA" })
            aAdd(aDePara,{"EJW_COMPL" ,"EJW_COMPL" })
            aAdd(aDePara,{"EJW_DTPROC","EJW_DTPROC"})
            AAdd(aDePara,{"A1_NOME", "A1_NREDUZ"})
            aAdd(aDePara,{"EJW_CONDPG","EJW_CONDPG"})  // GFP - 24/07/2014
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo
            If EasyGParam("MV_ESS0021",,.F.) .And. EJW->(FieldPos("EJW_CODEMP")) > 0 .And.  EJW->(FieldPos("EJW_LOJEMP")) > 0 .And. EJW->(FieldPos("EJW_CGC")) > 0
               aAdd(aDePara,{"EJW_CODEMP","EJW_CODEMP"})
               aAdd(aDePara,{"EJW_LOJEMP","EJW_LOJEMP"})
               aAdd(aDePara,{"EJW_CGC"   ,"EJW_CGC"   })
            EndIf
            If EasyGParam("MV_ESS0027",,9) >= 10
               aAdd(aDePara,{"EXJ_MOTNIF","EXJ_MOTNIF"})
               aAdd(aDePara,{"ELM_TIPVIN","ELM_TIPVIN"})
            EndIf
         EndIf
         
      OtherWise
         //RMD - 09/03/16 - Utilização do controle de erros da classe.
         //MsgInfo("Arquivo de integração inválido.")
         oObjIntegracao:cMsgErro:Error("Arquivo de integração inválido.")
         aDePara := {}
   End Case
ElseIf "INVOICE" $ cIntegracao
   aCpoChave := {"ELA_FILIAL","ELA_PROCES","ELA_NRINVO"}
   
   Do Case
      Case cTipo == "A"
         aAdd(aDePara,{"ELA_FILIAL","ELA_FILIAL"})
         aAdd(aDePara,{cTipo,"ELA_TPPROC",.T.})
         aAdd(aDePara,{"ELA_EXPORT","ELA_EXPORT"})
         aAdd(aDePara,{"ELA_LOJEXP","ELA_LOJEXP"})
         aAdd(aDePara,{"ELA_ORIGEM","ELA_ORIGEM"})
         aAdd(aDePara,{"ELA_PROCES","ELA_PROCES"})
         aAdd(aDePara,{"ELA_NRINVO","ELA_NRINVO"})
         aAdd(aDePara,{"ELA_DTEMIS","ELA_DTEMIS"})
         aAdd(aDePara,{"ELA_CONDPG","ELA_CONDPG"})
         aAdd(aDePara,{"ELA_MOEDA" ,"ELA_MOEDA" })
         aAdd(aDePara,{"ELA_TX_MOE","ELA_TX_MOE"})
         aAdd(aDePara,{"ELA_COMPL" ,"ELA_COMPL" })

         aAdd(aDePara,{"ELA_EXPINV","ELA_EXPINV"})
         aAdd(aDePara,{"ELA_ELJINV","ELA_ELJINV"})
         
                           
      Case cTipo == "V"
         If "_REG" $ cIntegracao
            aCpoChave := {"EL9_FILIAL","EL9_REGIST","EL9_NRINVO","EL9_SEQPAG"}
            aAdd(aDePara,{"EL9_FILIAL","EL9_FILIAL"})
            aAdd(aDePara,{"EL9_REGIST","EL9_REGIST"})
            aAdd(aDePara,{"EL9_NRINVO","EL9_NRINVO"})
            aAdd(aDePara,{"EL9_SEQPAG","EL9_SEQPAG"})
            aAdd(aDePara,{"EL9_PARC"  ,"EL9_PARC"})
            If EEQ->(FieldPos("EL9_ORIGEM")) > 0
               aAdd(aDePara,{"EL9_ORIGEM","EL9_ORIGEM"})
            EndIf
            aAdd(aDePara,{"EL9_DTREG" ,"EL9_DTREG"})
            aAdd(aDePara,{"EL9_NROREG","EL9_NROREG"})
         Else
            aAdd(aDePara,{"ELA_FILIAL","ELA_FILIAL"})
            aAdd(aDePara,{cTipo,"ELA_TPPROC",.T.})
            aAdd(aDePara,{"ELA_IMPORT","ELA_IMPORT"})
            aAdd(aDePara,{"ELA_LOJIMP","ELA_LOJIMP"})
            aAdd(aDePara,{"ELA_ORIGEM","ELA_ORIGEM"})
            aAdd(aDePara,{"ELA_PROCES","ELA_PROCES"})
            aAdd(aDePara,{"ELA_NRINVO","ELA_NRINVO"})
            aAdd(aDePara,{"ELA_DTEMIS","ELA_DTEMIS"})
            aAdd(aDePara,{"ELA_CONDPG","ELA_CONDPG"})
            aAdd(aDePara,{"ELA_MOEDA" ,"ELA_MOEDA" })
            aAdd(aDePara,{"ELA_TX_MOE","ELA_TX_MOE"})
            aAdd(aDePara,{"ELA_COMPL" ,"ELA_COMPL" })

            aAdd(aDePara,{"ELA_IMPINV","ELA_IMPINV"})
            aAdd(aDePara,{"ELA_ILJINV","ELA_ILJINV"})
         EndIf
         
      OtherWise
         //RMD - 09/03/16 - Utilização do controle de erros da classe.
         //MsgInfo("Arquivo de integração inválido.")
         oObjIntegracao:cMsgErro:Error("Arquivo de integração inválido.")
         aDePara := {}
   End Case

ElseIf "CAMBIO" $ cIntegracao
   aCpoChave := {"EEQ_FILIAL","EEQ_PROCES","EEQ_PARC", "EEQ_NRINVO"}  // GFP - 07/03/2014
   Do Case
      Case cTipo == "A"
         If "_REG" $ cIntegracao
            aCpoChave := {"EL9_FILIAL","EL9_REGIST","EL9_NRINVO","EL9_SEQPAG"}
            aAdd(aDePara,{"EL9_FILIAL","EL9_FILIAL"})
            aAdd(aDePara,{"EL9_REGIST","EL9_REGIST"})
            aAdd(aDePara,{"EL9_NRINVO","EL9_NRINVO"})
            aAdd(aDePara,{"EL9_SEQPAG","EL9_SEQPAG"})
            aAdd(aDePara,{"EL9_PARC"  ,"EL9_PARC"})
            If EEQ->(FieldPos("EL9_ORIGEM")) > 0
               aAdd(aDePara,{"EL9_ORIGEM","EL9_ORIGEM"})
            EndIf
            aAdd(aDePara,{"EL9_DTREG" ,"EL9_DTREG"})
            aAdd(aDePara,{"EL9_NROREG","EL9_NROREG"})
         Else
            aAdd(aDePara,{"EEQ_FILIAL","EEQ_FILIAL"})
            aAdd(aDePara,{"EEQ_FORN"  ,"EEQ_FORN"  })
            aAdd(aDePara,{"EEQ_FOLOJA","EEQ_FOLOJA"})
            aAdd(aDePara,{"EEQ_NRINVO","EEQ_NRINVO"})
            aAdd(aDePara,{"EEQ_TPPROC","EEQ_TPPROC"})
            aAdd(aDePara,{"EEQ_PROCES","EEQ_PROCES"})
            aAdd(aDePara,{"EEQ_SEQPRC","EEQ_SEQPRC"})
            aAdd(aDePara,{"EEQ_PARC"  ,"EEQ_PARC"  })
            aAdd(aDePara,{"EEQ_SOURCE","EEQ_SOURCE"})
            aAdd(aDePara,{"EEQ_MOEDA" ,"EEQ_MOEDA" })
            aAdd(aDePara,{"EEQ_VL"    ,"EEQ_VL"    })
            //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
            If EEQ->(FieldPos("EEQ_VLSISC")) > 0
               aAdd(aDePara,{"EEQ_VLSISC","EEQ_VLSISC"})
            EndIf
            aAdd(aDePara,{"EEQ_EVENT" ,"EEQ_EVENT" })
            aAdd(aDePara,{"EEQ_MODAL" ,"EEQ_MODAL" })
            aAdd(aDePara,{"EEQ_DTCE"  ,"EEQ_DTCE"  })
            aAdd(aDePara,{"EEQ_BCOEXT","EEQ_BCOEXT"})
            aAdd(aDePara,{"EEQ_AGCEXT","EEQ_AGCEXT"})
            aAdd(aDePara,{"EEQ_CNTEXT","EEQ_CNTEXT"})
            aAdd(aDePara,{"EEQ_BANC"  ,"EEQ_BANC"  })
            aAdd(aDePara,{"EEQ_AGEN"  ,"EEQ_AGEN"  })
            aAdd(aDePara,{"EEQ_NCON"  ,"EEQ_NCON"  })
            aAdd(aDePara,{"EEQ_SOL"   ,"EEQ_SOL"   })
            aAdd(aDePara,{"EEQ_NROP"  ,"EEQ_NROP"  })
            aAdd(aDePara,{"EEQ_PGT"   ,"EEQ_PGT"   })
            aAdd(aDePara,{"EEQ_TX"    ,"EEQ_TX"    })
            aAdd(aDePara,{"EEQ_EQVL"  ,"EEQ_EQVL"  })
            aAdd(aDePara,{"EEQ_EMISSA","EEQ_EMISSA"})
            aAdd(aDePara,{"EEQ_VCT"   ,"EEQ_VCT"   })
         EndIf
         
      Case cTipo == "V"
         aAdd(aDePara,{"EEQ_FILIAL","EEQ_FILIAL"})
         aAdd(aDePara,{"EEQ_IMPORT","EEQ_IMPORT"})
         aAdd(aDePara,{"EEQ_IMLOJA","EEQ_IMLOJA"})
         aAdd(aDePara,{"EEQ_NRINVO","EEQ_NRINVO"})
         aAdd(aDePara,{"EEQ_TPPROC","EEQ_TPPROC"})
         aAdd(aDePara,{"EEQ_PROCES","EEQ_PROCES"})
         aAdd(aDePara,{"EEQ_SEQPRC","EEQ_SEQPRC"})
         aAdd(aDePara,{"EEQ_PARC"  ,"EEQ_PARC"  })
         aAdd(aDePara,{"EEQ_SOURCE","EEQ_SOURCE"})
         aAdd(aDePara,{"EEQ_MOEDA" ,"EEQ_MOEDA" })
         aAdd(aDePara,{"EEQ_VL"    ,"EEQ_VL"    })
         //RRC - 04/11/2013 - Atualização para verificar a existência do campo EEQ_VLSISC
         If EEQ->(FieldPos("EEQ_VLSISC")) > 0
            aAdd(aDePara,{"EEQ_VLSISC","EEQ_VLSISC"})
         EndIf
         aAdd(aDePara,{"EEQ_EVENT" ,"EEQ_EVENT" })
         aAdd(aDePara,{"EEQ_MODAL" ,"EEQ_MODAL" })
         aAdd(aDePara,{"EEQ_DTCE"  ,"EEQ_DTCE"  })
         aAdd(aDePara,{"EEQ_BCOEXT","EEQ_BCOEXT"})
         aAdd(aDePara,{"EEQ_AGCEXT","EEQ_AGCEXT"})
         aAdd(aDePara,{"EEQ_CNTEXT","EEQ_CNTEXT"})
         aAdd(aDePara,{"EEQ_BANC"  ,"EEQ_BANC"  })
         aAdd(aDePara,{"EEQ_AGEN"  ,"EEQ_AGEN"  })
         aAdd(aDePara,{"EEQ_NCON"  ,"EEQ_NCON"  })
         aAdd(aDePara,{"EEQ_SOL"   ,"EEQ_SOL"   })
         aAdd(aDePara,{"EEQ_NROP"  ,"EEQ_NROP"  })
         aAdd(aDePara,{"EEQ_PGT"   ,"EEQ_PGT"   })
         aAdd(aDePara,{"EEQ_TX"    ,"EEQ_TX"    })
         aAdd(aDePara,{"EEQ_EQVL"  ,"EEQ_EQVL"  })
         aAdd(aDePara,{"EEQ_EMISSA","EEQ_EMISSA"})
         aAdd(aDePara,{"EEQ_VCT"   ,"EEQ_VCT"   })
   End Case


Else
   //RMD - 09/03/16 - Utilização do controle de erros da classe.
   //MsgInfo("Arquivo de integração inválido.")
   oObjIntegracao:cMsgErro:Error("Arquivo de integração inválido.")
   aDePara := {}
EndIf

	//RMD - 02/06/15 - Adiciona os campos de usuário que tenham sido informados no cabeçalho
	cAliUsr := ""
	aScan(aDePara, {|x| If("_FILIAL" $ x[1], cAliUsr := Left(x[1], 3),) })
	If Len(aDePara) > 0 .And. !Empty(cAliUsr)
		If(Right(cAliUsr, 1) == "_", cAliUsr := "S"+Left(cAliUsr, 2),)	
		aEval(AddCpoUser(,cAliUsr,"1"), {|x| If(aScan(aCabecalho, AllTrim(x))>0, aAdd(aDePara, {AllTrim(x),AllTrim(x)}), ) })
	EndIf

nPos := aScan(aCabecalho, {|x|  "_FILIAL" $ x})
If nPos # 0
   cTable := If(At("_",aCabecalho[nPos]) == 4,SubStr(aCabecalho[nPos],1,3),SubStr(aCabecalho[nPos],1,2))
   For i := 1 To Len(aCabecalho)
      If aCabecalho[i] <> "OPERACAO" .AND. !(cTable $ aCabecalho[i])
         cTabela := If(At("_",aCabecalho[i]) == 4,SubStr(aCabecalho[i],1,3),SubStr("S"+aCabecalho[i],1,3))
         If aScan(aCadastros, {|x| x[1] == cTabela}) == 0
            Do While .T.

               lSA6 := If(cTabela == "SA6" .AND. aScan(aCabecalho, {|x| x == "A6_NOME2"}) # 0,.T.,.F.) .AND.;
                        If((nPos := aScan(aCadastros, {|x| x[1] == cTabela })) == 0,.T., If(aScan(aCadastros[nPos][3], {|x| x[1] == "A6_NOME2"}) # 0,.F.,.T.))

               aRetCad := VldExecAuto(cTabela,aCabecalho,lSA6,cTipo)

               If aRetCad[1]
                  aAdd(aCadastros, {cTabela, SetProg(cTabela), aRetCad[2],{}})
               EndIf

               If !lSA6
                  Exit
               EndIf
            EndDo 
         EndIf
      EndIf
   Next i  
EndIf

For i := 1 To Len(aDePara)
   If (nPos := aScan(aCabecalho, {|X| Upper(AllTrim(X)) == aDePara[i][1]})) > 0
      aAdd(aRet,{aDePara[i][2],nPos,AvSX3(aDePara[i][2],2)})
   //RRC - 18/04/2013
   ElseIf Len(aDePara[i]) >= 3 .And. aDePara[i][3]
      aAdd(aRet,{aDePara[i][2],nPos,AvSX3(aDePara[i][2],2),aDePara[i][1]})
   EndIf
Next i
Return aClone(aRet)

Static Function StructDeta(cIntegracao,cTipo,aCabecalho, oObjIntegracao)
Local aDePara := {}
Local aRet    := {}
Local nPos, i

If "PROCESSO" $ cIntegracao
   
   If "_DIS" $ cIntegracao .OR. "_RES" $ cIntegracao
      //If !EasyGParam("MV_ESS0027",,9) >= 10
         aAdd(aDePara,{"EJW_FILIAL","EL2_FILIAL"})
         aAdd(aDePara,{"EJW_PROCES","EL2_PROCES"})
      //Else
      //   aAdd(aDePara,{"EJY_FILIAL","EL2_FILIAL"})
      //   aAdd(aDePara,{"EJY_REGIST","EL2_REGIST"})
      //   aAdd(aDePara,{"EJY_PROCES","EL2_PROCES"})
      //EndIf
      aAdd(aDePara,{cTipo,"EL2_TPPROC",.T.})
      //aAdd(aDePara,{AvKey("","EL2_REGIST"),"EL2_REGIST",.T.})
      aAdd(aDePara,{AvKey("","EL2_SEQPAG"),"EL2_SEQPAG",.T.})
      aAdd(aDePara,{"EL2_SEQDOC","EL2_SEQDOC",.T.})
      
      If !EasyGParam("MV_ESS0027",,9) >= 10
         If "_RES" $ cIntegracao
            aAdd(aDePara,{"EL2_RE"  ,"EL2_RE"  })
         Else
            aAdd(aDePara,{"EL2_DI"  ,"EL2_DI"  })
         EndIf
      Else
         aAdd(aDePara,{"EL2_RE"  ,"EL2_RE"  })
         aAdd(aDePara,{"EL2_DI"  ,"EL2_DI"  })
         aAdd(aDePara,{"EL2_SEQPRC" ,"EL2_SEQPRC" })
         //aAdd(aDePara,{"3","EL2_STTSIS",.T.})
      EndIf
   
   ElseIf "_REG" $ cIntegracao
      aAdd(aDePara,{"EJZ_REGIST","EJZ_REGIST"})
      aAdd(aDePara,{"EJZ_SEQREG","EJZ_SEQREG"})
      aAdd(aDePara,{"EJZ_SEQAD" ,"EJZ_SEQAD"})
      aAdd(aDePara,{"EJZ_NROREG","EJZ_NROREG"})
      aAdd(aDePara,{"","EJZ_STTSIS",.T.}) //LRS - 20/05/2016
      aAdd(aDePara,{"EJZ_DTREG" ,"EJZ_DTREG"})
      aAdd(aDePara,{"EJZ_DTRET" ,"EJZ_DTRET"})
   Else
      aAdd(aDePara,{"EJW_FILIAL","EJX_FILIAL"})
      aAdd(aDePara,{"EJW_PROCES","EJX_PROCES"})
      aAdd(aDePara,{cTipo,"EJX_TPPROC",.T.})
      aAdd(aDePara,{"EJX_SEQPRC","EJX_SEQPRC"})
      aAdd(aDePara,{"EJX_ITEM"  ,"EJX_ITEM"  })
      aAdd(aDePara,{"EJX_NBS"   ,"EJX_NBS"   })
      aAdd(aDePara,{"EJX_PAIS"  ,"EJX_PAIS"  })
      If cTipo == "A"
         aAdd(aDePara,{"EJX_MODO"  ,"EJX_MODAQU"  })
      ElseIf cTipo == "V"
         aAdd(aDePara,{"EJX_MODO"  ,"EJX_MODVEN"  })
      EndIf
      aAdd(aDePara,{"EJX_DTPRIN","EJX_DTPRIN"})
      aAdd(aDePara,{"EJX_DTPRFI","EJX_DTPRFI"})
      aAdd(aDePara,{"EJX_DTINI" ,"EJX_DTINI" })
      aAdd(aDePara,{"EJX_DTFIM" ,"EJX_DTFIM" })

      If EJX->(FieldPos("EJX_UM")) > 0
         aAdd(aDePara,{"EJX_UM"  ,"EJX_UM"  })
      EndIf
      
      aAdd(aDePara,{"EJX_QTDE"  ,"EJX_QTDE"  })
      aAdd(aDePara,{"EJX_PRCUN" ,"EJX_PRCUN" })
      aAdd(aDePara,{"EJX_TX_MOE","EJX_TX_MOE"})
      aAdd(aDePara,{"EJX_COMPL" ,"EJX_COMPL" })
	  //LRS - 9/11/2015
	  aAdd(aDePara,{"EJX_ENQ01" ,"EJX_ENQ01" })
	  aAdd(aDePara,{"EJX_ENQ02" ,"EJX_ENQ02" })
	  aAdd(aDePara,{"EJX_ENQ03" ,"EJX_ENQ03" })
	  
   EndIf
   
ElseIf "INVOICE" $ cIntegracao
   aAdd(aDePara,{"ELB_SEQPRC","ELB_SEQPRC"})
   aAdd(aDePara,{"ELB_VLCAMB","ELB_VLCAMB"})
   aAdd(aDePara,{"ELB_VLEXT" ,"ELB_VLEXT" })
ElseIf "CAMBIO" $ cIntegracao
Else
   //RMD - 09/03/16 - Utilização do controle de erros da classe.
   //MsgInfo("Arquivo de integração inválido.")
   oObjIntegracao:cMsgErro:Error("Arquivo de integração inválido.")
   aDePara := {}
EndIf

For i := 1 To Len(aDePara)
   If (nPos := aScan(aCabecalho, {|X| Upper(AllTrim(X)) == aDePara[i][1]})) > 0
      aAdd(aRet,{aDePara[i][2],nPos,AvSX3(aDePara[i][2],2)})
   //RRC - 18/04/2013
   ElseIf Len(aDePara[i]) >= 3 .And. aDePara[i][3]
      aAdd(aRet,{aDePara[i][2],nPos,AvSX3(aDePara[i][2],2),aDePara[i][1]})
   EndIf
Next i
Return aClone(aRet)

Static Function GetField(aArray,cCampo)
Local nPos
Local cRet := ""

If (nPos := aScan(aArray,{|X| ValType(X) == "A" .AND. Len(X) >= 2 .AND. ValType(X[1]) == "C" .AND. AllTrim(Upper(X[1])) == AllTrim(Upper(cCampo))})) > 0
   cRet := aArray[nPos][2]
EndIf

Return cRet

/* 
Funcao      : MudaFilial().
Objetivos   : Função responsavel para alterar a filial do sistemas atraves do parametro
Parametros  : lRestRecNo - Logico para restaurar a posição da SM0 pelo private nRecNoFilial ; CodFilial - codigo da filial desejado.
Retorno     : 
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 08/11/2013 - 10:00.
*/
Static Function MudaFilial(lRestRecNo,cCodFilial)
Local cCodigo    := SM0->M0_CODIGO
Local cAuxFilial := PADL(cCodFilial,2,"0")//ajuste caso o CSV conte filial com um caractere

If lRestRecNo
   SM0->(DbGoTo(nRecNoFilial))
ElseIf !Empty(cCodFilial) .AND. !cCodFilial == Replicate("0",Len(cCodFilial))
   SM0->(DbSetOrder(1))//M0_CODIGO+M0_CODFIL
   Posicione("SM0",1,cCodigo+cAuxFilial,"")
EndIf

cFilAnt := SM0->M0_CODFIL
Return

/*
Funcao     : VldExecAuto()
Parametros : cTable
Retorno    : cPrograma
Objetivos  : Informar programa necessário para execução do ExecAuto
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/02/2014 :: 14:46
*/
Static Function VldExecAuto(cTabela,aCabecalho,lSA6,cTipo)
Local lRet := .T.
Local i := 0, j := 0
Local lCposObrigat := .T.
Local aCampos := {}
Local aExecAuto := {}
Local aCposChave := {}
Local aCposExec := {}
Default lSA6 := .F.

Do Case
   Case cTabela == "SA1"
      aCampos := {"A1_NOME", "A1_END", "A1_EST", "A1_PAIS"}
      If EasyGParam("MV_ESS0027",,9) >= 10
         aadd(aCampos,"EXJ_NIF")
         aadd(aCampos,"EXJ_MOTNIF")
      Else
         aadd(aCampos,"A1_NIF")
      EndIf
      aCposChave:= {{"A1_COD" ,"EJW_IMPORT"},;
      	            {"A1_LOJA","EJW_LOJIMP"},;
					{"A1_NREDUZ" ,"A1_NOME"},;
					{"EXJ_MOTNIF","EXJ_MOTNIF"}}
	  
	  aAdd(aCposExec,{"A1_MUN"    ,".",NIL})
	  aAdd(aCposExec,{"A1_TIPO"   ,"X",NIL})					  
   Case cTabela == "SA2"
      aCampos := {"A2_NOME", "A2_END", "A2_EST", "A2_PAIS", "A2_NIFEX"}
      If EasyGParam("MV_ESS0027",,9) >= 10
         aadd(aCampos,"A2_MOTNIF")
      EndIf
      aCposChave:= {{"A2_COD" ,"EJW_EXPORT"},;
                    {"A2_LOJA","EJW_LOJEXP"},;
					{"A2_NREDUZ" ,"A2_NOME"}}
	  
	  aAdd(aCposExec,{"A2_MUN"    ,".",NIL})
	  aAdd(aCposExec,{"A2_TIPO"   ,"J",NIL})
   Case cTabela == "SB1"
      aCampos := {"B1_DESC"}
      aCposChave:= {{"B1_COD" ,"EJX_ITEM"},;
                    {"B5_NBS" ,"EJX_NBS"}}
	  
	  aAdd(aCposExec,{"B1_TIPO"  ,"MO",NIL})
	  aAdd(aCposExec,{"B1_UM"    ,"HR",NIL})
	  aAdd(aCposExec,{"B1_LOCPAD",AvKey(".","B1_LOCPAD") ,NIL})
	  
   Case cTabela == "SA6"
      aCampos := {If(lSA6,"A6_NOME2","A6_NOME")}
      aCposChave:= {{"A6_COD"      ,If(lSA6,"EEQ_BANC","EEQ_BCOEXT")},;
                      {"A6_AGENCIA" ,If(lSA6,"EEQ_AGEN","EEQ_AGCEXT")},;
                      {"A6_NUMCON"  ,If(lSA6,"EEQ_NCON","EEQ_CNTEXT")}}

   Case cTabela == "ELM"
      aCampos := {"ELM_TIPVIN"}
      If cTipo == "V"
         aCposChave:= {{"ELM_CODCLI" ,"EJW_IMPORT"},;
      	               {"ELM_LOJCLI","EJW_LOJIMP"},;
      	               {"ELM_CODFOR","EJW_CODEMP"},;
      	               {"ELM_LOJFOR","EJW_LOJEMP"}}
      	  
      	  //aAdd(aCposExec,{"ELM_CODFOR" ,".",.T.})
      	  //aAdd(aCposExec,{"ELM_LOJFOR" ,".",.T.})
      Else
         aCposChave:= {{"ELM_CODFOR" ,"EJW_EXPORT"},;
      	               {"ELM_LOJFOR","EJW_LOJEXP"},;
      	               {"ELM_CODCLI","EJW_CODEMP"},;
      	               {"ELM_LOJCLI","EJW_LOJEMP"}}
      	  
      	  //aAdd(aCposExec,{"ELM_CODCLI" ,".",.T.})
      	  //aAdd(aCposExec,{"ELM_LOJCLI" ,".",.T.})
      EndIf
End Case

If Len(aCposChave) # 0 .AND. aScan(aCposChvCad,{|X| X[1] == cTabela}) == 0
   aAdd(aCposChvCad, {cTabela,aCposChave})
EndIf 

If Len(aCampos) # 0
   For i := 1 To Len(aCampos)
      If aScan(aCabecalho, {|x| x == aCampos[i]}) == 0
         lRet := .F.
         Exit
      Else
         If aScan(aExecAuto, {|x| "_FILIAL" $ x[1]}) == 0
            aAdd(aExecAuto,{If(Left(cTabela,1) == "S",Right(cTabela,2),Right(cTabela,3))+"_FILIAL",xFilial(cTabela),NIL})
         EndIf
         If Len(aCposChave) # 0
            For j := 1 To Len(aCposChave)
               aAdd(aExecAuto,{aCposChave[j][1],NIL,NIL})
            Next j
            aCposChave := {}
         EndIf
         aAdd(aExecAuto,{aCampos[i],NIL,NIL})
      EndIf
   Next i
   
   For i := 1 To Len(aCposExec)
      aAdd(aExecAuto,aClone(aCposExec[i]))
   Next i
Else
   lRet := .F.
EndIf

/*If lRet .AND. lCposObrigat
   BuscaCpsObrigat(cTabela,@aExecAuto,aCampos)
   lCposObrigat := .F.
EndIf*/

Return {lRet,aExecAuto}

/*
Funcao     : SetProg()
Parametros : cTable
Retorno    : cPrograma
Objetivos  : Informar programa necessário para execução do ExecAuto
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 18/02/2014 :: 14:22
*/
Static Function SetProg(cTabela)
Local cPrograma := ""

Do Case
   Case cTabela == "SA1" .OR. cTabela == "EXJ"
      cPrograma := "EECAC100"
   Case cTabela == "SA6"
      cPrograma := "EECAC110"
   Case cTabela == "SA2"
      cPrograma := "EECAC115"      
   Case cTabela == "SB1"
      cPrograma := "EECAC120"
   Case cTabela == "ELM"
      cPrograma := "ESSAM400"
End Case

Return cPrograma

/*
Funcao     : DeParaCadastros()
Parametros : aCadastros, aDados
Retorno    : NIL
Objetivos  : Efetuar o De/Para dos campos chaves para o ExecAuto
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 19/02/2014 :: 10:13
*/
Static Function DeParaCadastros(aCadastros, aCabecalho, aDados, aCposChvCad)
Local i := 0
Local nPos := 0

If Len(aCposChvCad) # 0
//   For i := 1 To Len(aCposChvCad)
      If (nPos := aScan(aCposChvCad/*[i]*/, {|x| x[1] == aCadastros[1]})) # 0
         cCampo := aCposChvCad/*[i]*/[nPos][2]
         If (nPos := aScan(aCabecalho, cCampo)) # 0 
            aCadastros[2] := AvConvert( ,AvSx3(aCadastros[1],2),,aDados[nPos])
			If AvSx3(aCadastros[1],2) == "C"  // AAF - 10/11/2014
			   aCadastros[2] := AvKey(aCadastros[2],aCadastros[1])
			EndIf
		 Else
            Do Case
               Case AllTrim(aCadastros[1]) == "A1_TIPO"
                  aCadastros[2] := AvConvert( ,AvSx3(aCadastros[1],2),,"J")
               Case AllTrim(aCadastros[1]) == "A2_TIPO"
                  aCadastros[2] := AvConvert( ,AvSx3(aCadastros[1],2),,"J")
               Case AllTrim(aCadastros[1]) == "A1_MUN"
                  aCadastros[2] := AvConvert( ,AvSx3(aCadastros[1],2),,"EX")
               Case AllTrim(aCadastros[1]) == "A2_MUN"
                  aCadastros[2] := AvConvert( ,AvSx3(aCadastros[1],2),,"EX")
               OtherWise
                  If !("_FILIAL" $ AllTrim(aCadastros[1])) 
                     aCadastros[2] := AvConvert( ,AvSx3(aCadastros[1],2),,"X")
                  EndIf
            End Case
         EndIf
      EndIf
//   Next i
EndIf

Return NIL

/*
Funcao     : MontaSX3()
Parametros : lAtu, cTabela, aExecAuto, aCampos
Retorno    : NIL
Objetivos  : Inclusão de campos obrigatórios das tabelas para ExecAuto
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 19/02/2014 :: 14:39
*/
Static Function BuscaCpsObrigat(cTabela,aExecAuto,aCampos)
Local aOrd := SaveOrd("SX3")
Local bConteudo := {|Tipo| If(Tipo == "C",;
	                          If(!Empty(SX3->X3_CBOX),AvKey(Left(SX3->X3_CBOX,1),SX3->X3_CAMPO),AvKey("1",SX3->X3_CAMPO)),;
	                          If(Tipo == "N", 1,;
	                          If(Tipo == "D", CtoD(""),)))}
Begin Sequence

   SX3->(DbSetOrder(1))
   If SX3->(DbSeek(cTabela+"01"))
      Do While SX3->(!Eof()) .AND. SX3->X3_ARQUIVO == cTabela
         If X3Uso(SX3->X3_USADO,nModulo) .AND. X3Obrigat(SX3->X3_CAMPO)
            If aScan(aExecAuto, {|x| x[1] $ SX3->X3_CAMPO}) == 0 .And. (cTabela <> "SA6" .Or. SX3->X3_CAMPO == "A6_NOME" .AND. aScan(aExecAuto, {|x| x[1] $ "A6_NOME2"}) == 0)
               aAdd(aExecAuto, {SX3->X3_CAMPO,Eval(bConteudo,SX3->X3_TIPO),NIL})
            EndIf
         EndIf
         SX3->(DbSkip())
      EndDo
   EndIf

End Sequence

RestOrd(aOrd,.T.)
Return NIL

/*
Funcao     : SetnOPC()
Parametros : aCadastros, nOpc
Retorno    : nOpc
Objetivos  : Verifica operação para os ExecAutos de Cadastros
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 21/02/2014 :: 17:44
Revisão    : Alessandro Alves Ferreira - AAF
Data/Hora  : 10/11/2014 :: 15:21
*/
Static Function SetnOPC(aCadastros,cTipo)
Local cTabela := aCadastros[1]
Local cIndice := ""
Local aCampos := {}
Local lRet := .T.
Local i := 0, nPos := 0
Local nOpc := 0

Begin Sequence

   If Select(cTabela) == 0//Select(cTabela) # 0 - RMD - 18/08/15 - Ajustado, teste incorreto
      ChkFile(cTabela,.F.)
   EndIf

   If cTabela == "ELM" //MCF - 03/08/2016
      (cTabela)->(DbSetOrder(1))
      /*If cTipo == "V"
         (cTabela)->(DbSetOrder(2))
      Else
         (cTabela)->(DbSetOrder(3))
      EndIf*/
   EndIf
   
   cIndice := "'" + &(cTabela)->(IndexKey()) + "'"
   cIndice := StrTran(cIndice,"+","','")
   aCampos := &("{"+cIndice+"}")

   cIndice := ""
   For i := 1 To Len(aCampos)
      If (nPos := aScan(aCadastros[3], {|x| aCampos[i] == x[1]})) # 0
         If "_FILIAL" $ aCampos[i]  // GFP - 20/05/2014
            cIndice += If(IN100Modo(cTabela),xFilial(cTabela),AvKey(aCadastros[3][nPos][2],aCampos[i]))
         Else
            cIndice += AvKey(aCadastros[3][nPos][2],aCampos[i])
         EndIf
      Else
         nOpc := 0
         lRet := .F.
         Break
      EndIf
   Next i
   If !Empty(cIndice)
      //If cTabela == "ELM" .AND. SubStr(cIndice,Len(xFilial("ELM"))+1,1) == "."
         //nOpc := 3  //Inclusão
      If &(cTabela)->(DbSeek(cIndice))
         nOpc := 4  //Alteração
         //lRet := .F.
      Else
         nOpc := 3  //Inclusão
         //lRet := .T.
      EndIf
   EndIf
   
End Sequence

Return {lRet, nOpc}

/*
Funcao     : IN100IncSB5()
Parametros : aCadastro
Retorno    : NIL
Objetivos  : Efetua a inclusão das informações de complemento de produto
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 09/04/2014 :: 11:16
*/
Static Function IN100IncSB5(aCadastro)
Local aCampos := {"B5_FILIAL","B5_COD"}
Local i

For i := 1 To Len(aCampos)
   nPos := aScan(aCadastro[3],{|x| x[1] == "B1"+SubStr(aCadastro[3][i][1],At("_",aCadastro[3][i][1]),Len(aCadastro[3][i][1]))})
   aAdd(aCadastro[4],{aCampos[i],aCadastro[3][nPos][2],NIL})
Next i

nPos := aScan(aCadastro[3],{|x| x[1] == "B5_NBS"})
aAdd(aCadastro[4],{aCadastro[3][nPos][1],aCadastro[3][nPos][2],NIL})
ADel(aCadastro[3], nPos)
ASize(aCadastro[3], Len(aCadastro[3])-1)

Return NIL

/*
Programa   : IN100Modo
Parâmetros : cAlias - Tabela
Objetivo   : Verificar se tabela é compartilhada ou não
Retorno    : lRet : .T. - Compartilhado / .F. - Exclusivo
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 20/05/2014 :: 14:12
*/
*----------------------------* 
Static Function IN100Modo(cAlias)    
*----------------------------*
Local lRet := .F.

SX2->(DbSetOrder(1))  // X2_CHAVE
If SX2->(DbSeek(cAlias))
   lRet := FWModeAccess(cAlias) == "C"
EndIf

Return lRet

/*
Programa   : AjustaCampos
Parâmetros : Capa / Detalhe
Objetivo   : Ajusta conteudo de campos conforme necessidade de integração com o Protheus, permanecendo referência entre os itens 
Retorno    : NIL
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 11/02/2016 :: 16:52
*/
*---------------------------------------------------------*
Static Function AjustaCampos(cIntegracao,aCapa,aDetalhes)
*---------------------------------------------------------*
Local i

Do Case
   Case "INVOICE" $ cIntegracao
      For i := 1 To Len(aDetalhes)
         If (nPos := aScan(aDetalhes[i],{|x| x[1] == "ELB_SEQPRC"})) # 0
            If Val(aDetalhes[i][nPos][2]) # 0
               cSeqPrc := StrZero(Val(aDetalhes[i][nPos][2]),AvSx3("ELB_SEQPRC",3),0)
               aDetalhes[i][nPos][2] := cSeqPrc
            Else
               aDetalhes[i][nPos][2] := StrZero(1,AvSx3("ELB_SEQPRC",3),0)
            EndIf
         EndIf
      Next i
   Case "PROCESSO" $ cIntegracao
      For i := 1 To Len(aDetalhes)
         If (nPos := aScan(aDetalhes[i],{|x| x[1] == "EJX_SEQPRC"})) # 0
            If Val(aDetalhes[i][nPos][2]) # 0
               cSeqPrc := StrZero(Val(aDetalhes[i][nPos][2]),AvSx3("EJX_SEQPRC",3),0)
               aDetalhes[i][nPos][2] := cSeqPrc
            Else
               aDetalhes[i][nPos][2] := StrZero(1,AvSx3("EJX_SEQPRC",3),0)
            EndIf
         EndIf
      Next i
End Case

Return NIL

/*
Função    : GetFileList
Parâmetros: cDirAuto - Diretório contendo os arquivos para importação
Autor     : Rodrigo Mendes Diaz
Objetivo  : Retornar os arquivos .csv do diretório definido, ordenados de acordo com as dependências do processo (Processo, Invoice e Câmbio).
*/
Static Function GetFileList(cDirAuto)
Local cLine, nInc
Local lUTF8 := .F.
Local aDirectory, aFileList := {}
Local aOrdem := {"PROCESSO_AQUISICAO_SERVICO",;
                 "PROCESSO_AQUISICAO_DIS",;
                 "PROCESSO_VENDA_SERVICO",;
                 "PROCESSO_VENDA_RES",;
                 "INVOICE_AQUISICAO_SERVICO",;
                 "INVOICE_VENDA_SERVICO",;
                 "CAMBIO_AQUISICAO_SERVICO",;
                 "CAMBIO_VENDA_SERVICO",;
                 "PROCESSO_VENDA_REG",;
                 "PROCESSO_AQUISICAO_REG",;
                 "INVOICE_VENDA_REG",;
                 "CAMBIO_AQUISICAO_REG"}

	aDirectory := Directory(cDirAuto + "*.csv")
       
	For nInc := 1 To Len(aDirectory)

		FT_FUSE(cDirAuto + aDirectory[nInc][1])
		FT_FGOTOP()
	
		If Left(FT_FReadLn(),3) ==  "ï»¿" //Le e Pula o BOM (Byte Order Mark) UTF-8
			lUTF8 := .T.
			FT_FGOTO(4)
		EndIf
		   
		If Empty(cLine := If(lUTF8,DecodeUTF8(FT_FReadLn()),StrTran(FT_FReadLn(),CHR(9),""))) .Or. (nOrdem := aScan(aOrdem, {|x| x $ cLine })) == 0
			nOrdem := 99                                	
		EndIf

		aAdd(aFileList, {aDirectory[nInc][1], StrZero(nOrdem, 2)})

		FT_FUSE()

	Next

	aSort(aFileList,,, {|x, y| x[2]+x[1] < y[2]+y[1]  })

Return aFileList

Function ESSIN100Sch(aParams)
Local cDir := ""

   RpcSetType(3)
   RpcSetEnv(aParams[1],aParams[2])
   
   If IsBlind()
      If !Empty(EasyGParam("MV_ESS0026",,""))
         cDir := Alltrim(EasyGParam("MV_ESS0026"))
      Else
         ConOut("Diretório de Importação Arquivos não definido")
      EndIf
   EndIf

Return ESSIN100(cDir)

Method AtuStatus(Self) Class ImportSiscoserv
Local i,nPosDt,nPosSt
 nPosDt := aScan(Self:aAutoDeta[1],{|x| x[1] == "EJZ_DTREG"  })
 nPosSt := aScan(Self:aAutoDeta[1],{|x| x[1] == "EJZ_STTSIS" })
 if nPosDt != 0 .And. nPosSt != 0
    for i:=1 to len(Self:aAutoDeta)
        if Self:aAutoDeta[i][nPosDt][1] == "EJZ_DTREG"
           if Empty(Self:aAutoDeta[i][nPosDt][2])
                 Self:aAutoDeta[i][nPosSt][2]:="1"
               Else
                 Self:aAutoDeta[i][nPosSt][2]:="3"          
           EndIf    
        EndIf   
    Next i                
 EndIf  
 
return 


