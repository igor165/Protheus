#Include 'Protheus.ch'
#Include "Average.ch"
#Include "FWMVCDEF.CH"
#Include "APWizard.CH"
#Include "EEC.CH"
#Include "FILEIO.CH" 

/*
Programa   : LogixToProtheus()
Objetivo   : Tela do AvUpdate01.
Retorno    :
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 30/05/2012 - 10:00
Obs.       : Arquivos de +-5mb demora aproximadamente meia hora   	
*/
//User Function LogixToProtheus(o,cDir,lZap)
Function LogixToProtheus(o,cDir,lZap)
Local nIni := 0
Local nFin := 0
Local nTot := 0
Local cRet := ""

   If FindFunction("AVUpdate01")
      oUpd           := AVUpdate01():New()
      oUpd:cTitulo   := "Importação CSV para as tabelas Protheus"
      oUpd:cDescricao:= "Esta rotina tem como objetivo importar os arquivos CSV para Protheus, que contem informações das tabelas Logix."
      oUpd:aChamados := { {EEC,{|o| cRet:= BarraProcesso(o,cDir,lZap)}} }
      niNI := Seconds()
      oUpd:Init(o)
   Else                      
      MsgStop("Esse ambiente não está preparado para executar este update. Favor entrar em contato com o suporte Trade-Easy.")
   EndIf

Return .T.

// ********************************************************************************************************* //

/*
Programa   : BarraProcesso()
Objetivo   : Para abrir e instanciar a barra de progresso antes de realizar update.
Retorno    : String onde aparece no avUpdate
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 04/06/2012 - 10:00
*/
Static Function BarraProcesso(o,cDir,lZap)
Local oProcess
Local cRet := ""
    oProcess := MsNewProcess():New({|lEnd| cRet:= AvLogixImpCSV(o,@oProcess,@lEnd,cDir,lZap)},"Progresso para preparar a importação!","",.T.) 
    oProcess:Activate()
Return cRet
  
// ********************************************************************************************************* //

/*
Programa   : TelaDir()
Objetivo   : Tela onde o usuario ira selecionar o diretorio onde estão os arquivos CSV.
Retorno    : Vetor com o diretorio ex: {c:\comex\ADITAMENTOS_CONTRATO.CSV,n} 
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 04/06/2012 - 10:00
*/
/*
Function TelaDir()
Local cDir    := Space(255)
Local aRet    
Local aFiles  := {}
Local i       := 0
 
   If !Empty(cDir := cGetFile(,"Selecione o diretório CSV", 1, cDir,,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_RETDIRECTORY,,.T.)  )     
      aFiles := Directory(cDir+"*.CSV")   
      aRet := {}
      For i:=1 to Len(aFiles)
         Aadd( aRet,cDir+aFiles[i][1] )//ex: c:\comex\ +ADITAMENTOS_CONTRATO.CSV
      Next
   
   EndIf

Return aClone(aRet)
*/
// ********************************************************************************************************* //
/*
Programa   : TelaOpcoes()
Objetivo   : Tela onde o usuario ira selecionar se deseja apagar a tabela.
Retorno    : Retorno logico verdadeiro para apagar tabela
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 04/06/2012 - 10:00
*/
/*
Static Function TelaOpcoes()
Local nLin    := 15, nCol := 12
Local bOk     := {|| oDlg:End()}
Local oDlg
Local cTitulo := "Selecione a opção desejada"
Local lZap    

   DEFINE MSDIALOG oDlg TITLE cTitulo FROM 320,400 TO 520,710 PIXEL

    @ nLin, 6 To 94, 150 Label "" Of oDlg Pixel
    nLin += 10
    @ nLin,nCol CHECKBOX lZap PROMPT "Deseja limpar dados das tabelas?" OF oDlg SIZE 100,8 PIXEL
    nLin += 15
    @ nLin,nCol SAY "Habilitando essa opção o update ira limpar os dados das importações feitas anteriormente e atualizando com os novos arquivos referentes ao CSV contido no diretório." SIZE 130, 30 OF oDlg PIXEL
    nLin += 40  
	@ nLin,nCol+40 BUTTON "OK" ACTION Eval(bOk) SIZE 50,10 PIXEL OF oDlg
	
   ACTIVATE MSDIALOG oDlg CENTERED 

Return lZap
*/

/*
Programa   : AvLogixImpCSV()
Objetivo   : Função para validar, importar arquivo. 
Retorno    : Retorna string para avUpdate
Autor      : Fabio Satoru Yamamoto/Bruno Akyo
Data/Hora  : 11/05/2012 - 10:00
*/
Static Function AvLogixImpCSV(o,oProcess,lEnd,cDir,lZap)// AvLogixImpCSV(oProcess,lEnd,aArquivos)

Local oAvLogixImpCSV := AvLogixImpCSV():New()
Local i
Local aFiles := {}
Local aDir   := {}
//oAvLogixImpCSV:lZap := TelaOpcoes()

oAvLogixImpCSV:lZap := lZap

aFiles := Directory(cDir+"*.CSV")  
For i:=1 to Len(aFiles)
   Aadd( aDir,cDir+aFiles[i][1] )//ex: c:\comex\ +ADITAMENTOS_CONTRATO.CSV
Next
oAvLogixImpCSV:aArquivos := aDir 

If  Valtype(aDir ) != "U" .And. Len(aDir) != 0
   oProcess:SetRegua1(Len(oAvLogixImpCSV:aArquivos))
   For i:=1 To Len(oAvLogixImpCSV:aArquivos)
      oProcess:IncRegua1 ("Convertendo tabelas CSV. Aguarde: "+AllTrim(Str(i))+" de "+AllTrim(Str(Len(oAvLogixImpCSV:aArquivos))) )   
      oAvLogixImpCSV:cDiretorio := oAvLogixImpCSV:aArquivos[i]
   
      If oAvLogixImpCSV:SelArqCSV(oAvLogixImpCSV:aArquivos[i]) .And. ;
         oAvLogixImpCSV:ValArqCSV(oProcess)
         oAvLogixImpCSV:GravaTable(o)
      EndIf                        

   Next 
 
   oAvLogixImpCSV:cMsg += +ENTER+"Importação finalizada."

Else
   oAvLogixImpCSV:cMsg += +ENTER+"Importação Cancelada."
EndIf 

Return oAvLogixImpCSV:cMsg
  
// ********************************************************************************************************* //
/*
Classe     : AvLogixImpCSV
Objetivo   : Efetuar impotação e validação dos arquivos CSV. 
Autor      : Fabio Satoru Yamamoto/Bruno Akyo
Data/Hora  : 11/05/2012 - 10:00
*/
Class AvLogixImpCSV From AvObject // Classe da importação do dados do arquivo CSV

   // Atributos da Classe
   Data oAvImport
   Data aArquivos
   Data cAlias
   Data nOrder
   Data aEstrutura 
   Data nLinhaCpo
   Data oAvUpdate
   Data aCposProtheus
   Data aCposLogix
   Data aDados
   Data cDiretorio
   Data aTabFeito
   Data lZap
   Data cMsg
   Data nErro

   // Metodos da Classe
   Method New(aArquivos)      //Constructor
   Method SelArqCSV()         // Selecionar arquivo CSV
   Method ValArqCSV(oProcess) // Validar o arquivo CSV
   Method GravaTable(o)       // Grava os dados do arquivo CSV na tabela
   Method SetAlias()          // Seta os atributos cAlias nOrder da Classe
   Method SetCSV(oProcess)    // Seta corretamente as linhas do CSV no Vetor aDados
   Method Reset()             // Limpas e instancia novamente os atributos da classe
   Method aDadosVazio()       // Verifica se o aDados esta vazio. 
   Method MsgErro()           // Seta a mensagem de erro no update
End Class                                                                                                      

// ********************************************************************************************************* //

Method New() Class AvLogixImpCSV

   Self:oAvImport     := AvImport():New() // Objeto com tratamento do arquivo CSV
   Self:cAlias        := "" // Variavel responsavel pela Alias
   Self:nOrder        := 1  // Variavel responsavel pela ordem da Alias
   Self:nLinhaCpo     := 0  // Variavel responsavel para saber em qual linha esta os campos do CSV
   Self:aDados        := {} // Variavel responsavel por todas as informações do CSV         
   Self:cDiretorio    := "" // Variavel que armazena o diretorio do arquivo CSV
   Self:aTabFeito     := {} // Vetor que verifica as tabelas CSV já impotadas, empedindo importação repetidas
   Self:lZap          := .F.// Varial logico que aplica ZAP na tabela
   Self:aEstrutura    := {} // Vetor responsavel pela estrutura da tabela ativa, tais estrutura do Protheus e Logix
   Self:aCposProtheus := {} // Vetor responsavel para armazenar nome dos campos Protheus da tabela ativa
   Self:aCposLogix    := {} // Vetor responsavel para armazenar os nome dos campos Logix
   Self:cMsg          := "" // Variavel responsavel para exibir mensagens no update.
   Self:nErro         := 0  // Variavel responsavel para o tipo de erro. 
   
Return Self 

// ********************************************************************************************************* //
Method Reset() Class AvLogixImpCSV

   Self:oAvImport     := AvImport():New() // Objeto com tratamento do arquivo CSV
   Self:cAlias        := "" // Variavel responsavel pela Alias
   Self:nOrder        := 1  // Variavel responsavel pela ordem da Alias
   Self:nLinhaCpo     := 0  // Variavel responsavel para saber em qual linha esta os campos do CSV
   Self:aDados        := {} // Variavel responsavel por todas as informações do CSV         
   Self:aEstrutura    := {} // Vetor responsavel pela estrutura da tabela ativa, tais estrutura do Protheus e Logix
   Self:aCposProtheus := {} // Vetor responsavel para armazenar nome dos campos Protheus da tabela ativa
   Self:aCposLogix    := {} // Vetor responsavel para armazenar os nome dos campos Logix 

Return Nil 

// ********************************************************************************************************* //
Method SelArqCSV(cArq) Class AvLogixImpCSV
Local lRet := .F.

Self:Reset()

If Valtype(Self:oAvImport) == "O" .And. Valtype(Self:oAvImport:cFile) == "C" .And. Valtype(cArq) == "C"
   // Variavel da classe AvImport, onde selecionamos o arquivo CSV
   Self:oAvImport:cFile := cArq
   lRet := .T.
EndIf

Return lRet

// ********************************************************************************************************* //
Method SetAlias() Class AvLogixImpCSV
Local lRet   := .F.
Local nOrder := 1
Local cAlias := ""

If !Empty ( cAlias := NomeProtheus(Self:oAvImport:aDados[1][1]) )
   If aScan(Self:aTabFeito,cAlias)==0  
      
      If Valtype(nOrder) == "N" .And. Valtype(cAlias) == "C"
         Self:cAlias := cAlias
         Self:nOrder := nOrder
         Self:aEstrutura := StructLogix(Self:cAlias)
         lRet := .T.   
      EndIf
   
      If Self:lZap                               
         
         Begin Sequence
         If Select(cAlias) == 0
            chkfile(cAlias,.T.)
         EndIf
         (cAlias)->(avzap())
         End Sequence
         
      End If
   Else
      Self:nErro := 3
   End If 

Else
   Self:nErro := 1  
    
EndIf

Return lRet

// ********************************************************************************************************* //
Method ValArqCSV(oProcess) Class AvLogixImpCSV
Local lRet := .T.
Local i,j
oProcess:IncRegua2 ("Status : Convertendo 1 de 2.")
oProcess:SetRegua2 (Len(Self:aDados))
Begin Sequence

   If Self:oAvImport:Import() .And. Self:SetAlias() .And. !Empty(Self:aEstrutura) .And. Self:SetCSV(oProcess)
      For i := 1 To Len(Self:aDados)
         aLinha := aClone(Self:aDados[i])
         For j := 1 To Len(aLinha)
            If aScan(Self:aEstrutura,{ |X| AllTrim(Upper(X[1])) == AllTrim(Upper(aLinha[j])) }) > 0
               Self:nLinhaCpo := i
            Else
               Self:nLinhaCpo := 0
            EndIf
         Next
         If Self:nLinhaCpo > 0
            Exit
         EndIf

      Next

      If Self:nLinhaCpo > 0
         Self:aCposLogix := Self:aDados[Self:nLinhaCpo]
      EndIf

      For i := 1 To Len(Self:aCposLogix)
         // Verifica se os campos do CSV estão corretos, conforme a estrutura definida na função StructLogix().
         If aScan(Self:aEstrutura,{ |X| AllTrim(Upper(X[1])) == AllTrim(Upper(Self:aCposLogix[i])) }) == 0
            lRet := .F.
            Self:nErro := 4 
            Self:aCposProtheus := {}
            Break
         Else
            aAdd(Self:aCposProtheus,Self:aEstrutura[i][2])
         EndIf
      Next
   Else
      lRet := .F.
   EndIf

End Sequence

If !lRet
   Self:cMsg += Self:MsgErro()
Else                                                                                    
   Self:cMsg+="Arquivo "+Self:cDiretorio+". Tabela Protheus: "+Self:cAlias+". Processado com sucesso. Linhas: "+AllTrim (Str(Len(Self:aDados)-1)) +ENTER
   Aadd(Self:aTabFeito,Self:cAlias)
EndIf

Return lRet

// *********************************************************************************************************//

Method SetCSV(oProcess) Class AvLogixImpCSV
Local lRet    := .F.
Local i
Local aAux    := {}
Local aAux1   := {}
Local aCampos := {}

oProcess:IncRegua2 ("Status : Convertendo 2 de 2.")
For i := 2 To Len(Self:oAvImport:aDados)

   If Len(Self:oAvImport:aDados[i]) == Len(Self:aEstrutura)
      aAdd(Self:aDados,Self:oAvImport:aDados[i])
      aAux := {}
   Else
      aAdd(aAux,Self:oAvImport:aDados[i])
      If Len(aAux) >= 1
            aCampos := aClone(aAux)
            aAux1   := LineCSVArray(aCampos,Len(Self:aEstrutura))
            If Len(aAux1) == Len(Self:aEstrutura)
               aAdd(Self:aDados,aAux1)
            EndIf
      EndIf
   EndIf

Next

If Len(Self:aDados) > 1 .And. Len(Self:aDados[1]) == Len(Self:aEstrutura)
   lRet := .T.
Else
   Self:nErro := 2
EndIf

Return lRet

// ********************************************************************************************************* //

Method GravaTable(o) Class AvLogixImpCSV
Local i,j


   If Len(Self:aCposProtheus) > 0
      o:TableStruct(Self:cAlias,Self:aCposProtheus,Self:nOrder)
   EndIf

   // Varrendo todas os registros do arquivo CSV
   For i := Self:nLinhaCpo + 1 To Len(Self:aDados)
      For j := 1 To Len(Self:aCposProtheus)
         If AvSX3(Self:aCposProtheus[j],AV_TIPO) == "D"
            Self:aDados[i][j] := CToD(Self:aDados[i][j])
         ElseIf AvSX3(Self:aCposProtheus[j],AV_TIPO) == "N"
            Self:aDados[i][j] := Val(Self:aDados[i][j])
         EndIf
      Next
      o:TableData(Self:cAlias,Self:aDados[i])
   Next 

Return Nil                                          

// ********************************************************************************************************* //

Method aDadosVazio() Class AvLogixImpCSV
Local lRet := .T.
If Len(Self:aDados) == 1
   lRet := .F.
   Self:nErro := 1
EndIf

Return lRet

Method MsgErro() Class AvLogixImpCSV
Local cRet := ""
   Do Case
       
      Case Self:nErro = 1
         cRet := "Arquivo "+Self:cDiretorio+" Nome da tabela invalida no arquivo CSV."
         
      Case Self:nErro = 2
         cRet := "Arquivo "+Self:cDiretorio+" Arquivo vazio ou a formatação da tadela incorreta."
      
      Case Self:nErro = 3
         cRet := "Arquivo "+Self:cDiretorio+" Arquivo com tabela já processada."

      Case Self:nErro = 4
         cRet := "Arquivo "+Self:cDiretorio+" Arquivo com coluna invalida."
         
      OtherWise
         cRet := "Erro no metodo MsgErro MsgErro()."
   End Case
    
Return cRet+= ENTER

// ********************************************************************************************************* //

/*
Programa   : NomeProtheus()
Objetivo   : Relacionar a primeira linha do arquivo CSV para o nome da tabela Protheus. 
Retorno    : Retorna string para avUpdate
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 27/06/2012 - 10:00
Obs.       : cAlias = Nome da tabela em CSV
*/
Static Function NomeProtheus(cAlias)//Nome tecnico em Logix 

Local cRet   := ""
Local nAux   := 0
Local aVetor := {}

aAdd(aVetor,{"ADITAMENTOS_CONTRATO","EJP"})
aAdd(aVetor,{"APLICACAO_CAMBIO","EJU"})
aAdd(aVetor,{"CARTA_CREDITO","EJM"})
aAdd(aVetor,{"COMISSOES","EJK"})
aAdd(aVetor,{"CONTAINERS","EJJ"})
aAdd(aVetor,{"CONTRATO_CAMBIO","EJO"})
aAdd(aVetor,{"DESPESAS_CONTRATO","EJQ"})
aAdd(aVetor,{"EMBARQUE","EJF"})
aAdd(aVetor,{"ITENS_EMBARQUE","EJI"})
aAdd(aVetor,{"ITENS_PROFORMA_COTACAO","EJG"})
aAdd(aVetor,{"ITENS_PROFORMA_PEDIDO","EJH"})
aAdd(aVetor,{"JUROS","EJR"})
aAdd(aVetor,{"PAGAMENTO_CAMBIO","EJV"})
aAdd(aVetor,{"PAGAMENTO_COMISSOES","EJL"})
aAdd(aVetor,{"PAGAMENTO_JUROS","EJS"})
aAdd(aVetor,{"PARCELA_CAMBIO","EJT"})
aAdd(aVetor,{"PROCESSOS_CARTA_CREDITO","EJN"})
aAdd(aVetor,{"PROFORMA","EJE"})

If (nAux := aScan(aVetor,{|x| x[1]== Upper(cAlias) } )) != 0 
   cRet := aVetor[nAux][2]
EndIf 
   
Return cRet

// ********************************************************************************************************* //

/*
Programa   : StructLogix()
Objetivo   : Função responsavel pela estrutura do CSV em relação ao Protheus
Retorno    : Retorna string para avUpdate
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 27/06/2012 - 10:00
Obs.       : cAlias = Nome da tabela no Protheus
*/ 
Static Function StructLogix(cAlias)
Local aRet := {}

cAlias := AllTrim(cAlias)

Do Case

   Case cAlias = "EJE"
      aAdd(aRet,{"cod_empresa","EJE_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJE_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJE_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJE_CODEMB"})
      aAdd(aRet,{"cod_cliente_final","EJE_CODFIN"})
      aAdd(aRet,{"dsc_cliente_final","EJE_DSCFIN"})
      aAdd(aRet,{"cod_cliente_faturar","EJE_CODFAT"})
      aAdd(aRet,{"dsc_cliente_faturar","EJE_DSCFAT"})
      aAdd(aRet,{"cod_consignatario","EJE_CODCON"})
      aAdd(aRet,{"dsc_consignatario","EJE_DSCCON"})
      aAdd(aRet,{"cod_notificador","EJE_CODNO1"})
      aAdd(aRet,{"dsc_notificador","EJE_DSCNO1"})
      aAdd(aRet,{"cod_notificador2","EJE_CODNO2"})
      aAdd(aRet,{"dsc_notificador2","EJE_DSCNO2"})
      aAdd(aRet,{"cod_pais_destino","EJE_CODPAI"})
      aAdd(aRet,{"dsc_pais_destino","EJE_DSCPAI"})
      aAdd(aRet,{"cod_local_destino","EJE_CODDST"})
      aAdd(aRet,{"dsc_local_destino","EJE_DSCDST"})
      aAdd(aRet,{"cod_local_descarga","EJE_CODLDE"})
      aAdd(aRet,{"dsc_local_descarga","EJE_DSCLDE"})
      aAdd(aRet,{"cod_local_embarque","EJE_CODLEM"})
      aAdd(aRet,{"dsc_local_embarque","EJE_DSCLEM"})
      aAdd(aRet,{"cod_incoterm","EJE_CODINC"})
      aAdd(aRet,{"dsc_incoterm","EJE_DSCINC"})
      aAdd(aRet,{"cod_moeda","EJE_CODMOE"})
      aAdd(aRet,{"dsc_moeda","EJE_DSCMOE"})
      aAdd(aRet,{"cod_idioma","EJE_CODIDI"})
      aAdd(aRet,{"dsc_idioma","EJE_DSCIDI"})
      aAdd(aRet,{"cod_tipo_transporte","EJE_CODTIP"})
      aAdd(aRet,{"dsc_tipo_transporte","EJE_DSCTIP"})
      aAdd(aRet,{"cod_modalidade_pagamento","EJE_CODMOD"})
      aAdd(aRet,{"dsc_modalidade_pagamento","EJE_DSCMOD"})
      aAdd(aRet,{"num_pedido_cliente_final","EJE_NPDCLI"})
      aAdd(aRet,{"num_pedido_cliente_fatura","EJE_NPDFAT"})
      aAdd(aRet,{"dat_encerramento","EJE_DATENC"})
      aAdd(aRet,{"vlr_ex_works_cot","EJE_VLEXWC"})
      aAdd(aRet,{"vlr_log_int_cot","EJE_VLLGIC"})
      aAdd(aRet,{"vlr_fob_cot","EJE_VLFOBC"})
      aAdd(aRet,{"vlr_seguro_cot","EJE_VLSEGC"})
      aAdd(aRet,{"vlr_frete_cot","EJE_VLFREC"})
      aAdd(aRet,{"vlr_log_ext_cot","EJE_VLLGEC"})
      aAdd(aRet,{"vlr_juros_cot","EJE_VLJURC"})
      aAdd(aRet,{"vlr_fatura_cot","EJE_VLFATC"})
      aAdd(aRet,{"vlr_desconto_cot","EJE_VLDESC"})
      aAdd(aRet,{"vlr_despesas_cot","EJE_VLDSPC"})
      aAdd(aRet,{"qtd_peso_liq_cot","EJE_PSLIQC"})
      aAdd(aRet,{"qtd_peso_bruto_cot","EJE_PSBRUC"})
      aAdd(aRet,{"vlm_cubagem_cot","EJE_VLCUBC"})
      aAdd(aRet,{"vlr_ex_works_ped","EJE_VLREXW"})
      aAdd(aRet,{"vlr_log_int_ped","EJE_VLLGIF"})
      aAdd(aRet,{"vlr_fob_ped","EJE_VLRFOB"})
      aAdd(aRet,{"vlr_seguro_ped","EJE_VLRSEG"})
      aAdd(aRet,{"vlr_frete_ped","EJE_VLRFRE"})
      aAdd(aRet,{"vlr_log_ext_ped","EJE_VLLGEF"})
      aAdd(aRet,{"vlr_juros_ped","EJE_VLRJUR"})
      aAdd(aRet,{"vlr_fatura_ped","EJE_VLRFAT"})
      aAdd(aRet,{"vlr_desconto_ped","EJE_VLDESF"})
      aAdd(aRet,{"vlr_despesas_ped","EJE_VLDSPF"})
      aAdd(aRet,{"qtd_peso_liq_ped","EJE_PSLIQF"})
      aAdd(aRet,{"qtd_peso_bruto_ped","EJE_PSBRUF"})
      aAdd(aRet,{"vlm_cubagem_ped","EJE_VLMCUB"})

   Case cAlias = "EJF"
      aAdd(aRet,{"cod_empresa","EJF_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJF_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJF_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJF_CODEMB"})
      aAdd(aRet,{"cod_cliente_final","EJF_CODFIN"})
      aAdd(aRet,{"dsc_cliente_final","EJF_DSCFIN"})
      aAdd(aRet,{"cod_cliente_faturar","EJF_CODFAT"})
      aAdd(aRet,{"dsc_cliente_faturar","EJF_DSCFAT"})
      aAdd(aRet,{"cod_consignatario","EJF_CODCON"})
      aAdd(aRet,{"dsc_consignatario","EJF_DSCCON"})
      aAdd(aRet,{"cod_notificador","EJF_CODNO1"})
      aAdd(aRet,{"dsc_notificador","EJF_DSCNO1"})
      aAdd(aRet,{"cod_notificador2","EJF_CODNO2"})
      aAdd(aRet,{"dsc_notificador2","EJF_DSCNO2"})
      aAdd(aRet,{"cod_pais_destino","EJF_CODPAI"})
      aAdd(aRet,{"dsc_pais_destino","EJF_DSCPAI"})
      aAdd(aRet,{"cod_local_destino","EJF_CODDST"})
      aAdd(aRet,{"dsc_local_destino","EJF_DSCDST"})
      aAdd(aRet,{"cod_local_descarga","EJF_CODLDE"})
      aAdd(aRet,{"dsc_local_descarga","EJF_DSCLDE"})
      aAdd(aRet,{"cod_local_embarque","EJF_CODLEM"})
      aAdd(aRet,{"dsc_local_embarque","EJF_DSCLEM"})
      aAdd(aRet,{"cod_incoterm","EJF_CODINC"})
      aAdd(aRet,{"dsc_incoterm","EJF_DSCINC"})
      aAdd(aRet,{"cod_moeda","EJF_CODMOE"})
      aAdd(aRet,{"dsc_moeda","EJF_DSCMOE"})
      aAdd(aRet,{"cod_idioma","EJF_CODIDI"})
      aAdd(aRet,{"dsc_idioma","EJF_DSCIDI"})
      aAdd(aRet,{"cod_tipo_transporte","EJF_CODTIP"})
      aAdd(aRet,{"dsc_tipo_transporte","EJF_DSCTIP"})
      aAdd(aRet,{"cod_modalidade_pagamento","EJF_CODMOD"})
      aAdd(aRet,{"dsc_modalidade_pagamento","EJF_DSCMOD"})
      aAdd(aRet,{"num_pedido_cliente_final","EJF_NPDCLI"})
      aAdd(aRet,{"num_pedido_cliente_fatura","EJF_NPDFAT"})
      aAdd(aRet,{"dat_encerramento","EJF_DATENC"})
      aAdd(aRet,{"cod_banco_pagador","EJF_CDBANP"})
      aAdd(aRet,{"dsc_banco_pagador","EJF_DSBANP"})
      aAdd(aRet,{"cod_banco_negociador","EJF_CDBANN"})
      aAdd(aRet,{"dsc_banco_negociador","EJF_DSBANN"})
      aAdd(aRet,{"cod_seguradora","EJF_CODSEG"})
      aAdd(aRet,{"dsc_seguradora","EJF_DSCSEG"})
      aAdd(aRet,{"dat_venc_carta_credito","EJF_DATVEN"})
      aAdd(aRet,{"dat_fatura","EJF_DATFAT"})
      aAdd(aRet,{"dat_re","EJF_DATRE"})
      aAdd(aRet,{"dat_entrega_banco","EJF_DTENTB"})
      aAdd(aRet,{"dat_entrega_cliente","EJF_DTENTC"})
      aAdd(aRet,{"dat_conhecimento","EJF_DATCON"})
      aAdd(aRet,{"dat_ce","EJF_DATCE"})
      aAdd(aRet,{"num_apolice","EJF_NUMAPO"})
      aAdd(aRet,{"num_conhecimento","EJF_NUMCON"})
      aAdd(aRet,{"num_re","EJF_NUMRE"})
      aAdd(aRet,{"num_ce","EJF_NUMCE"})
      aAdd(aRet,{"num_ref_banco_negociador","EJF_NUMREF"})
      aAdd(aRet,{"num_carta_credito","EJF_NUMCAR"})
      aAdd(aRet,{"obs_marcacao","EJF_OBSMAR"})
      aAdd(aRet,{"flg_sacado","EJF_FLGSAC"})
      aAdd(aRet,{"obs_geral","EJF_OBSGER"})
      aAdd(aRet,{"dat_dde","EJF_DATDDE"})
      aAdd(aRet,{"num_booking","EJF_NUMBOO"})
      aAdd(aRet,{"num_dde","EJF_NUMDDE"})
      aAdd(aRet,{"num_tracking_documentos","EJF_NUMTRA"})
      aAdd(aRet,{"flg_tipo_frete","EJF_FLGTIP"})
      aAdd(aRet,{"cod_transportadora","EJF_CODTRA"})
      aAdd(aRet,{"dsc_cod_transportadora","EJF_DSCCOD"})
      aAdd(aRet,{"cod_despachante","EJF_CODDES"})
      aAdd(aRet,{"dsc_despachante","EJF_DSCDES"})
      aAdd(aRet,{"cod_agente_carga","EJF_CODAGE"})
      aAdd(aRet,{"dsc_agente_carga","EJF_DSCAGE"})
      aAdd(aRet,{"cod_navio","EJF_CODNAV"})
      aAdd(aRet,{"dsc_navio","EJF_DSCNAV"})
      aAdd(aRet,{"vlr_ex_works_fat","EJF_VLREXW"})
      aAdd(aRet,{"vlr_log_interna_fat","EJF_VLLGIF"})
      aAdd(aRet,{"vlr_fob_fat","EJF_VLRFOB"})
      aAdd(aRet,{"vlr_seguro_fat","EJF_VLRSEG"})
      aAdd(aRet,{"vlr_frete_fat","EJF_VLRFRE"})
      aAdd(aRet,{"vlr_log_externa_fat","EJF_VLLGEF"})
      aAdd(aRet,{"vlr_juros_fat","EJF_VLRJUR"})
      aAdd(aRet,{"vlr_fatura_fat","EJF_VLRFAT"})
      aAdd(aRet,{"vlr_desconto_fat","EJF_VLDESF"})
      aAdd(aRet,{"vlr_despesas_fat","EJF_VLDSPF"})
      aAdd(aRet,{"qtd_peso_liq_fat","EJF_PSLIQF"})
      aAdd(aRet,{"qtd_peso_bruto_fat","EJF_PSBRUF"})
      aAdd(aRet,{"vlm_cubagem_fat","EJF_VLMCUB"})
      aAdd(aRet,{"dat_embarque","EJF_DATEMB"})
      aAdd(aRet,{"dat_previsao_emb","EJF_DTPEMB"})
      aAdd(aRet,{"dat_previsao_chegada","EJF_DTPCHG"})
   
   Case cAlias = "EJG"
      aAdd(aRet,{"cod_empresa","EJG_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJG_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJG_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJG_CODEMB"})
      aAdd(aRet,{"num_pedido","EJG_NUMPED"})
      aAdd(aRet,{"num_sequencia","EJG_NSEQPD"})
      aAdd(aRet,{"cod_item","EJG_CODITE"})
      aAdd(aRet,{"dsc_item","EJG_DSCITE"})
      aAdd(aRet,{"qtd_pecas","EJG_QTDPEC"})
      aAdd(aRet,{"qtd_preco_unit","EJG_QTDPRE"})
      aAdd(aRet,{"vlr_total","EJG_VLRTOT"})
      aAdd(aRet,{"vlr_desconto","EJG_VLRDES"})
      aAdd(aRet,{"vlr_frete","EJG_VLRFRE"})
      aAdd(aRet,{"vlr_seguro","EJG_VLRSEG"})
      aAdd(aRet,{"dat_entrega","EJG_DATENT"})   
   
   Case cAlias = "EJH"
      aAdd(aRet,{"cod_empresa","EJH_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJH_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJH_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJH_CODEMB"})
      aAdd(aRet,{"num_pedido","EJH_NUMPED"})
      aAdd(aRet,{"num_sequencia","EJH_NSEQPD"})
      aAdd(aRet,{"cod_item","EJH_CODITE"})
      aAdd(aRet,{"dsc_item","EJH_DSCITE"})
      aAdd(aRet,{"qtd_pecas","EJH_QTDPEC"})
      aAdd(aRet,{"qtd_preco_unit","EJH_QTDPRE"})
      aAdd(aRet,{"vlr_total","EJH_VLRTOT"})
      aAdd(aRet,{"vlr_desconto","EJH_VLRDES"})
      aAdd(aRet,{"vlr_frete","EJH_VLRFRE"})
      aAdd(aRet,{"vlr_seguro","EJH_VLRSEG"})
      aAdd(aRet,{"dat_entrega","EJH_DATENT"})
   
   Case cAlias = "EJI"
      aAdd(aRet,{"cod_empresa","EJI_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJI_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJI_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJI_CODEMB"})
      aAdd(aRet,{"num_pedido","EJI_NUMPED"})
      aAdd(aRet,{"num_sequencia","EJI_NSEQPD"})
      aAdd(aRet,{"num_nota_fiscal","EJI_NUMNOT"})
      aAdd(aRet,{"num_seq_item_nf","EJI_NSEQNF"})
      aAdd(aRet,{"cod_item","EJI_CODITE"})
      aAdd(aRet,{"dsc_item","EJI_DSCITE"})
      aAdd(aRet,{"qtd_peso_liquido","EJI_PSLIQF"})
      aAdd(aRet,{"qtd_peso_bruto","EJI_PSBRUF"})
      aAdd(aRet,{"qtd_pecas","EJI_QTDPEC"})
      aAdd(aRet,{"qtd_embal_01","EJI_QTDEM1"})
      aAdd(aRet,{"qtd_embal_02","EJI_QTDEM2"})
      aAdd(aRet,{"qtd_embal_03","EJI_QTDEM3"})
      aAdd(aRet,{"vlr_preco_unit","EJI_VLRPRE"})
      aAdd(aRet,{"vlr_taxa_moeda","EJI_VLRTAX"})
      aAdd(aRet,{"vlr_total","EJI_VLTOTM"})
      aAdd(aRet,{"vlr_total_reais","EJI_VLTOTR"})
      aAdd(aRet,{"cod_unid_med","EJI_CODUNI"})
      aAdd(aRet,{"dsc_unid_med","EJI_DSCUNI"})
      aAdd(aRet,{"cod_ncm","EJI_CODNCM"})
      aAdd(aRet,{"dsc_ncm","EJI_DSCNCM"})
      aAdd(aRet,{"vlm_cubagem","EJI_VLMCUB"})
      aAdd(aRet,{"dat_emissao","EJI_DATEMI"})
      aAdd(aRet,{"num_re","EJI_NUMRE"})
      aAdd(aRet,{"trans_nota_fiscal","EJI_TRANSN"})
   
   Case cAlias = "EJJ"
      aAdd(aRet,{"cod_empresa","EJJ_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJJ_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJJ_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJJ_CODEMB"})
      aAdd(aRet,{"cod_sequencia","EJJ_CODSEQ"})
      aAdd(aRet,{"cod_container","EJJ_CODCON"})
      aAdd(aRet,{"num_referencia","EJJ_NUMREF"})
      aAdd(aRet,{"num_lacre","EJJ_NUMLAC"})
      aAdd(aRet,{"qtd_tara","EJJ_QTDTAR"})
      aAdd(aRet,{"qtd_peso_liquido","EJJ_PESLIQ"})
      aAdd(aRet,{"qtd_peso_bruto","EJJ_PESBRU"})
      aAdd(aRet,{"vlm_cubagem","EJJ_VLMCUB"})   
   
   Case cAlias = "EJK"
      aAdd(aRet,{"cod_empresa","EJK_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJK_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJK_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJK_CODEMB"})
      aAdd(aRet,{"cod_agente","EJK_CODAGE"})
      aAdd(aRet,{"dsc_agente","EJK_DSCAGE"})
      aAdd(aRet,{"cod_tipo_comissao","EJK_CODTIP"})
      aAdd(aRet,{"dsc_tipo_comissao","EJK_DSCTIP"})
      aAdd(aRet,{"pct_comissao","EJK_PCTCOM"})
      aAdd(aRet,{"vlr_comissao","EJK_VLRCOM"})
      aAdd(aRet,{"flg_liquidada","EJK_FLGLIQ"})
      aAdd(aRet,{"flg_cancelada","EJK_FLGCAN"})
      aAdd(aRet,{"dat_cancelamento","EJK_DATCAN"})
      aAdd(aRet,{"num_remessa","EJK_NUMREM"})
      aAdd(aRet,{"dat_remessa","EJK_DATREM"})

   Case cAlias = "EJL"
      aAdd(aRet,{"cod_empresa","EJL_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJL_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJL_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJL_CODEMB"})
      aAdd(aRet,{"cod_agente","EJL_CODAGE"})
      aAdd(aRet,{"dsc_agente","EJL_DSCAGE"})
      aAdd(aRet,{"cod_contrato","EJL_CODCON"})
      aAdd(aRet,{"cod_banco","EJL_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJL_DSCBAN"})
      aAdd(aRet,{"dat_pagamento","EJL_DATPAG"})
      aAdd(aRet,{"vlr_pago","EJL_VLRPAG"})
      aAdd(aRet,{"vlr_taxa_pagamento","EJL_VLRTAX"})
   
   Case cAlias = "EJM"
      aAdd(aRet,{"num_carta_credito","EJM_NUMCAR"})
      aAdd(aRet,{"cod_cliente","EJM_CODCLI"})
      aAdd(aRet,{"dsc_cliente","EJM_DSCCLI"})
      aAdd(aRet,{"cod_banco","EJM_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJM_DSCBAN"})
      aAdd(aRet,{"cod_banco_docs","EJM_CDBAND"})
      aAdd(aRet,{"dsc_banco_docs","EJM_DSBAND"})
      aAdd(aRet,{"cod_modalidade_pagamento","EJM_CODMOD"})
      aAdd(aRet,{"dsc_modalidade_pagamento","EJM_DSCMOD"})
      aAdd(aRet,{"cod_moeda","EJM_CODMOE"})
      aAdd(aRet,{"dsc_moeda","EJM_DSCMOE"})
      aAdd(aRet,{"cod_tipo_carta_credito","EJM_CODTIP"})
      aAdd(aRet,{"dsc_tipo_carta_credito","EJM_DSCTIP"})
      aAdd(aRet,{"cod_tipo_situacao","EJM_CODSIT"})
      aAdd(aRet,{"dsc_tipo_situacao","EJM_DSCSIT"})
      aAdd(aRet,{"vlr_embarcado","EJM_VLREMB"})
      aAdd(aRet,{"vlr_carta_credito","EJM_VLRCAR"})
      aAdd(aRet,{"flg_transbordo","EJM_FLGTRA"})
      aAdd(aRet,{"flg_embarque_parcial","EJM_FLGEMB"})
      aAdd(aRet,{"pct_tolerancia_acima","EJM_PTOLAC"})
      aAdd(aRet,{"pct_tolerancia_abaixo","EJM_PTOABA"})
      aAdd(aRet,{"dsc_observacao","EJM_DSCOBS"})
      aAdd(aRet,{"dat_emissao","EJM_DATEMI"})
      aAdd(aRet,{"dat_limite_embarque","EJM_DATLIM"})
      aAdd(aRet,{"dat_vencimento","EJM_DATVEN"})

   Case cAlias = "EJN"
      aAdd(aRet,{"num_carta_credito","EJN_NUMCAR"})
      aAdd(aRet,{"cod_empresa","EJN_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJN_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJN_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJN_CODEMB"})
      aAdd(aRet,{"vlr_fatura","EJN_VLRFAT"})
      aAdd(aRet,{"dat_embarque","EJN_DATEMB"})

   Case cAlias = "EJO"
      aAdd(aRet,{"cod_empresa","EJO_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJO_DSCEMP"})
      aAdd(aRet,{"cod_contrato","EJO_CODCON"})
      aAdd(aRet,{"cod_banco","EJO_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJO_DSCBAN"})
      aAdd(aRet,{"cod_tipo_contrato","EJO_CODTIP"})
      aAdd(aRet,{"dsc_tipo_contrato","EJO_DSCTIP"})
      aAdd(aRet,{"cod_moeda","EJO_CODMOE"})
      aAdd(aRet,{"dsc_moeda","EJO_DSCMOE"})
      aAdd(aRet,{"vlr_total_contrato","EJO_VLRTOT"})
      aAdd(aRet,{"vlr_taxa_contrato","EJO_VLRTAX"})
      aAdd(aRet,{"vlr_taxa_juros","EJO_VLTXJR"})
      aAdd(aRet,{"flg_periodo_taxa","EJO_FLGPER"})
      aAdd(aRet,{"dat_vencimento","EJO_DATVEN"})
      aAdd(aRet,{"dat_contrato","EJO_DATCON"})
      aAdd(aRet,{"dat_credito","EJO_DATCRE"})
      aAdd(aRet,{"flg_dias_credito","EJO_FLGDIA"})
      aAdd(aRet,{"dat_fechamento","EJO_DATFEC"})
      aAdd(aRet,{"dsc_observacao","EJO_DSCOBS"})
      aAdd(aRet,{"num_lote_trb","EJO_NUMLOT"})
      aAdd(aRet,{"num_seq_trb","EJO_NUMSEQ"})
      aAdd(aRet,{"cod_banco_credito","EJO_CDBCCR"})
      aAdd(aRet,{"dsc_banco_credito","EJO_DSBCCR"})
      aAdd(aRet,{"vlr_conta_grafica","EJO_VLRCON"})
      aAdd(aRet,{"dat_entrega_doc","EJO_DATENT"})
      aAdd(aRet,{"cod_cliente","EJO_CODCLI"})
      aAdd(aRet,{"dsc_cliente","EJO_DSCCLI"})

   Case cAlias = "EJP"
      aAdd(aRet,{"cod_empresa","EJP_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJP_DSCEMP"})
      aAdd(aRet,{"cod_contrato","EJP_CODCON"})
      aAdd(aRet,{"cod_banco","EJP_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJP_DSCBAN"})
      aAdd(aRet,{"dat_inicio_juros","EJP_DATINI"})
      aAdd(aRet,{"dat_fim_juros","EJP_DATFIM"})
      aAdd(aRet,{"vlr_taxa_juros","EJP_VLRTAX"})
      aAdd(aRet,{"flg_periodo_taxa","EJP_FLGPER"})

   Case cAlias = "EJQ"
      aAdd(aRet,{"cod_empresa","EJQ_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJQ_DSCEMP"})
      aAdd(aRet,{"cod_contrato","EJQ_CODCON"})
      aAdd(aRet,{"cod_banco","EJQ_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJQ_DSCBAN"})
      aAdd(aRet,{"num_despesa","EJQ_NUMDES"})
      aAdd(aRet,{"num_fatura_export","EJQ_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJQ_CODEMB"})
      aAdd(aRet,{"num_parcela","EJQ_NUMPAR"})
      aAdd(aRet,{"cod_despesa","EJQ_CODDES"})
      aAdd(aRet,{"dsc_despesa","EJQ_DSCDES"})
      aAdd(aRet,{"dat_pagamento","EJQ_DATPAG"})
      aAdd(aRet,{"vlr_pago","EJQ_VLPGCO"})
      aAdd(aRet,{"vlr_pago_reais","EJQ_VLRPAG"})
      aAdd(aRet,{"vlr_taxa_pagamento","EJQ_VLRTAX"})
      aAdd(aRet,{"cod_tipo_calculo","EJQ_CODTIP"})
      aAdd(aRet,{"dsc_tipo_calculo","EJQ_DSCTIP"})
      aAdd(aRet,{"vlr_percentual","EJQ_VLRPER"})
      aAdd(aRet,{"num_lote_trb","EJQ_NUMLOT"})
      aAdd(aRet,{"num_seq_trb","EJQ_NUMSEQ"})
      aAdd(aRet,{"cod_banco_despesa","EJQ_CDBAND"})
      aAdd(aRet,{"dsc_banco_despesa","EJQ_DSBAND"})
      aAdd(aRet,{"num_conta_cont","EJQ_NUMCON"})

   Case cAlias = "EJR"
      aAdd(aRet,{"cod_empresa","EJR_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJR_DSCEMP"})
      aAdd(aRet,{"cod_contrato","EJR_CODCON"})
      aAdd(aRet,{"cod_banco","EJR_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJR_DSCBAN"})
      aAdd(aRet,{"num_fatura_export","EJR_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJR_CODEMB"})
      aAdd(aRet,{"num_parcela","EJR_NUMPAR"})
      aAdd(aRet,{"dat_pagamento","EJR_DATPAG"})
      aAdd(aRet,{"vlr_pagamento","EJR_VLRPAG"})
      aAdd(aRet,{"dat_aplicacao","EJR_DATAPL"})
      aAdd(aRet,{"vlr_aplicado","EJR_VLRAPL"})
      aAdd(aRet,{"cod_moeda","EJR_CODMOE"})
      aAdd(aRet,{"dsc_moeda","EJR_DSCMOE"})
      aAdd(aRet,{"vlr_juros","EJR_VLJURM"})
      aAdd(aRet,{"num_dias_juros","EJR_NUMDIA"})
      aAdd(aRet,{"vlr_juros_reais","EJR_VLJURR"})
      aAdd(aRet,{"dat_juros","EJR_DATJUR"})
      aAdd(aRet,{"vlr_taxa_juros","EJR_VLRTAX"})
      aAdd(aRet,{"flg_paga","EJR_FLGPAG"})
   
   Case cAlias = "EJS"
      aAdd(aRet,{"cod_empresa","EJS_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJS_DSCEMP"})
      aAdd(aRet,{"cod_contrato","EJS_CODCON"})
      aAdd(aRet,{"cod_banco","EJS_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJS_DSCBAN"})
      aAdd(aRet,{"num_fatura_export","EJS_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJS_CODEMB"})
      aAdd(aRet,{"num_parcela","EJS_NUMPAR"})
      aAdd(aRet,{"dat_pagamento","EJS_DATPAG"})
      aAdd(aRet,{"vlr_pago","EJS_VLPAGM"})
      aAdd(aRet,{"vlr_pago_reais","EJS_VLPAGR"})
      aAdd(aRet,{"vlr_taxa_pagamento","EJS_VLRTAX"})
   
   Case cAlias = "EJT"
      aAdd(aRet,{"cod_empresa","EJT_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJT_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJT_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJT_CODEMB"})
      aAdd(aRet,{"num_parcela","EJT_NUMPAR"})
      aAdd(aRet,{"cod_momento","EJT_CODMOM"})
      aAdd(aRet,{"dsc_momento","EJT_DSCMOM"})
      aAdd(aRet,{"dsc_observacao","EJT_DSCOBS"})
      aAdd(aRet,{"vlr_cambial","EJT_VLRCAM"})
      aAdd(aRet,{"vlr_quitado","EJT_VLRQUI"})
      aAdd(aRet,{"vlr_total_aplicado","EJT_VLVINC"})
      aAdd(aRet,{"vlr_total_pago","EJT_VLPAGO"})
      aAdd(aRet,{"vlr_total_liqui","EJT_VLLIQ"})
      aAdd(aRet,{"flg_paga","EJT_FLGPAG"})
      aAdd(aRet,{"flg_liquidada","EJT_FLGLIQ"})
      aAdd(aRet,{"flg_vinculada","EJT_FLGVIN"})
      aAdd(aRet,{"flg_vencida","EJT_FLGVEN"})
      aAdd(aRet,{"flg_cancelada","EJT_FLGCAN"})
      aAdd(aRet,{"dat_vencimento","EJT_DATVEN"})

   Case cAlias = "EJU"
      aAdd(aRet,{"cod_empresa","EJU_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJU_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJU_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJU_CODEMB"})
      aAdd(aRet,{"num_parcela","EJU_NUMPAR"})
      aAdd(aRet,{"dat_aplicacao","EJU_DATAPL"})
      aAdd(aRet,{"cod_contrato","EJU_CODCON"})
      aAdd(aRet,{"cod_banco","EJU_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJU_DSCBAN"})
      aAdd(aRet,{"flg_aplicacao","EJU_FLGAPL"})
      aAdd(aRet,{"vlr_aplicado","EJU_VLAPLM"})
      aAdd(aRet,{"vlr_aplicado_reais","EJU_VLAPLR"})
      aAdd(aRet,{"dsc_observacao","EJU_DSCOBS"})
      aAdd(aRet,{"vlr_taxa_aplicacao","EJU_VLRTAX"})
      aAdd(aRet,{"dat_comissao","EJU_DATCOM"})
      aAdd(aRet,{"vlr_comissao","EJU_VLRCOM"})
      aAdd(aRet,{"vlr_paridade","EJU_VLRPAR"})
      aAdd(aRet,{"num_referencia","EJU_NUMREF"})

   Case cAlias = "EJV"
      aAdd(aRet,{"cod_empresa","EJV_CODEMP"})
      aAdd(aRet,{"dsc_empresa","EJV_DSCEMP"})
      aAdd(aRet,{"num_fatura_export","EJV_NUMFAT"})
      aAdd(aRet,{"cod_embarque","EJV_CODEMB"})
      aAdd(aRet,{"num_parcela","EJV_NUMPAR"})
      aAdd(aRet,{"cod_pagamento","EJV_CODPAG"})
      aAdd(aRet,{"dat_pagamento","EJV_DATPAG"})
      aAdd(aRet,{"vlr_pagamento","EJV_VLRPAG"})
      aAdd(aRet,{"vlr_quitado","EJV_VLRQUI"})
      aAdd(aRet,{"cod_motivo_abatimento","EJV_CODMOT"})
      aAdd(aRet,{"dsc_motivo_abatimento","EJV_DSCMOT"})
      aAdd(aRet,{"dsc_observacao","EJV_DSCOBS"})
      aAdd(aRet,{"cod_contrato","EJV_CODCON"})
      aAdd(aRet,{"cod_banco","EJV_CODBAN"})
      aAdd(aRet,{"dsc_banco","EJV_DSCBAN"})
      aAdd(aRet,{"flg_abate_contrato","EJV_FLGABA"})

   OtherWise
      aRet := {}
      MsgInfo("Tabela " + cAlias + "não definida.","Atenção")
End Case

Return aClone(aRet)

/*
Programa   : LineCSVArray
Objetivo   : Função responsavel para corrigir o tamanho do vetor e identar caso avImporte corte o arquivo CSV no vetor.
Retorno    : Vetor com a estrutura corretos
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 11/05/2012
*/
Static Function LineCSVArray(aCampos,nTamanho)
Local aAux := {}
Local aTam := {}
Local i,j
Local nTam := 0

For i := 1 To Len(aCampos)
   aAdd(aTam,Len(aCampos[i]))
   For j := 1 To Len(aCampos[i])
      aAdd(aAux,aCampos[i][j])
   Next
Next

If Len(aAux) > nTamanho
   For i := 1 To Len(aTam)
      nTam += aTam[i]
      If Len(aAux) > nTam
         aAux[aTam[i]] := aAux[aTam[i]]+aAux[aTam[i]+1]
         aDel(aAux,aTam[i]+1)
         aSize(aAux,Len(aAux)-1)
      EndIf
   Next
EndIf

Return aClone(aAux)

/*
Programa   : TESX2Name
Objetivo   : Pegar o nome do alias pelo X2
Retorno    : Nome da tabela
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 03/02/2012 - 14:39
*/
Function TESX2Name(cNome)
   Local cTabela := ""
   dbSelectArea("SX2")
   cTabela := Posicione("SX2",1,cNome,"X2_NOME")
Return AllTrim(cTabela)