#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "EasyDM400.CH"

/*
Funcao      : EasyDM400
Parametros  : 
Retorno     : 
Objetivos   : Efetuar a rotina de controle de demurrage
Autor       : Felipe Sales Martinez
Data/Hora   : 25/03/11
Revisao     : 
Obs.        : 
*/

Function EasyDM400()
Local oBrowse
Private cWork := "",; //nome da work
        aGetDados := {},; // array com informações da GetDados
        cError := ""

//CRIAÇÃO DA MBROWSE
oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EJ5") //Informando o Alias 
oBrowse:SetMenuDef("EasyDM400") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001) //Descrição a ser apresentada no Browse //##"Controle de Demurrage / Detention"
oBrowse:SetFilterDefault("EJ5->EJ5_MODULO == cModulo")
oBrowse:Activate()

Return Nil

*------------------------*
Static Function MenuDef()
*------------------------*
Private aRotina := {}

//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE  STR0030 ACTION "AxPesqui"        OPERATION 1 ACCESS 0    //"Pesquisar"
ADD OPTION aRotina TITLE  STR0031 ACTION "VIEWDEF.EasyDM400" OPERATION 2 ACCESS 0  //"Visualizar"
ADD OPTION aRotina TITLE  STR0032 ACTION "VIEWDEF.EasyDM400" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE  STR0033 ACTION "VIEWDEF.EasyDM400" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE  STR0034 ACTION "VIEWDEF.EasyDM400" OPERATION 5 ACCESS 0

//RMD - 25/09/14 - Criado relatório para relacionar os containers
ADD OPTION aRotina TITLE  STR0035 ACTION "DM400REL" OPERATION 2 ACCESS 0  //"Relatório"
If ExistBlock("EASYDM400")
   ExecBlock("EASYDM400",.F.,.F.,"DM400_MENUDEF")
Endif
Return aRotina


*-------------------------*
Static Function ModelDef()
*-------------------------*
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruEJ5 := FWFormStruct( 1, "EJ5", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruEJ6 := FWFormStruct( 1, "EJ6", /*bAvalCampo*/, /*lViewUsado*/ )
Local oModel
Local bCommit  := {|oMdl| DEMUCOMMIT(oMdl)},;
      bCancel  := {||     FECHAWORK()},;
      bLinePre := {|A,B,C,D| RecalculaValores(A,B,C,D)}
Local aCposCalc   := {{"EJ6_DTDEVO", "EJ6_VLFINA"}},;
      aCposRecalc := {{"EJ5_TABPRE", "EJ5_VTOTAL"}}

/* Criação do Modelo com o cID = "EasyDem", este nome deve conter como as tres letras inicial de acordo com o
   módulo. Exemplo: SIGAEEC (EXP), SIGAEIC (IMP) */
oModel := MPFormModel():New( "EasyDem", /*bPreValidacao*/, /*bPosValidacao*/, bCommit, bCancel )


oStruEJ5 := AddGatilhos(oStruEJ5,aCposRecalc,"DM400AltValores")

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'EJ5MASTER', /*cOwner*/, oStruEJ5 )

oStruEJ6 := AddGatilhos(oStruEJ6,aCposCalc,"DM400CalcVFinal")
// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'EJ6DETAIL', 'EJ5MASTER', oStruEJ6, bLinePre, /*bLinePost*/, /*bPreVal*/ , /*bPosVal*/, /*BLoad*/ )


//Modelo de relação entre Capa(EJ5) e detalhe(EJ6)
oModel:SetRelation('EJ6DETAIL',{{"EJ6_FILIAL",'xFilial("EJ6")'},{"EJ6_CODDEM","EJ5_CODDEM"}}, EJ6->(IndexKey()) )


// Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0001) //##"Controle de Demurrage/Detention"


// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'EJ5MASTER' ):SetDescription( STR0002 ) //##'Dados da Capa'
oModel:GetModel( 'EJ6DETAIL' ):SetDescription( STR0003 ) //##"Dados da Detalhes"

Return oModel


*------------------------*
Static Function ViewDef()
*------------------------*
// Cria a estrutura a ser usada na View
Local oStruEJ5 := FWFormStruct( 2, "EJ5", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruEJ6 := FWFormStruct( 2, "EJ6", /*bAvalCampo*/, /*lViewUsado*/ )

// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oView
Local oModel   := FWLoadModel( "EasyDM400" )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados a ser utilizado
oView:SetModel( oModel )


//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_EJ5', oStruEJ5, 'EJ5MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_EJ6', oStruEJ6, 'EJ6DETAIL' )


// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'ACIMA'  , 50 /*,,,"IDFOLDER","IDSHEET01"*/)
oView:CreateHorizontalBox( 'ABAIXO' , 50 /*,,,"IDFOLDER","IDSHEET01"*/)


// Relaciona o ID da View com o "box" para exibição
oView:SetOwnerView( 'VIEW_EJ5', 'ACIMA'  )
oView:SetOwnerView( 'VIEW_EJ6', 'ABAIXO' )


// Liga a identificação do componente
oView:EnableTitleView( 'VIEW_EJ5', STR0001 , /*Color - */RGB(240, 248, 255 )) //##"Controle de Demurrage / Detention"
oView:EnableTitleView( 'VIEW_EJ6', STR0004 , /*Color - */RGB(240, 248, 255 ) )//##"Valores das Tarifas do Containeres"

//Acrescenta um novo botão à "Ações Relacionadas"
oView:addUserButton( STR0005 ,"",{ |X| IIf(DM400ValDado(X,"OBRIGAT"),IncCont(X),Nil) },"") //##"Incluir Container"

//Habilita ButtonsBar
oView:EnableControlBar(.T.)

Return oView

*-------------------------------*
Static Function DEMUCOMMIT(oMdl) 
*-------------------------------*
Local nOperation := oMdl:GetOperation()

FWModelActive(oMdl)
FWFormCommit(oMdl)

If nOperation <> 5 .And. nOperation <> 2 //Excluir ## Visualizar

   cEJ5CodTab := oMdl:GetModel():GetValue( 'EJ5MASTER','EJ5_CODDEM' )

   If RecLock("EJ5", !EJ5->( DBSeek( xFilial("EJ5") + cEJ5CodTab ) ) )
      EJ5->EJ5_MODULO := cModulo
   EndIf
   
   
   EJ6->( DBSetOrder(1) )//"EJ6_FILIAL+EJ6_CODDEM+EJ6_CODPRO+EJ6_CODCON+EJ6_NCONTA"
   If EJ6->( DBSeek( xFilial("EJ6") + cEJ5CodTab ) )   

      Do While EJ6->( !EOF() ) .And. xFilial("EJ6") == EJ6->EJ6_FILIAL .And. AllTrim(cEJ5CodTab) == AllTrim(EJ6->EJ6_CODDEM)

         If EJ6->( RecLock("EJ6",.F.) )         
            EJ6->EJ6_CODDEM := cEJ5CodTab
            EJ6->EJ6_CHAVE  := cModulo + AVKey(EJ5->EJ5_CODARM,"EJ5_CODARM") + AVKey(EJ6->EJ6_CODPRO,"EJ6_CODPRO") + AVKey(EJ6->EJ6_NCONTA,"EJ6_NCONTA")
            EJ6->EJ6_MODULO := cModulo
            EJ6->( MSUnlock() )
         EndIf   
         EJ6->( DBSkip() )
      EndDo

   EndIf

EndIf

FechaWork()

Return .T.

*--------------------------*
Static Function FECHAWORK() 
*--------------------------*

//Fechando alias ativa.
If Select("Work") > 0
   Work->( DbCloseArea() )
   FErase(cWork + getDbExtension())
   //MFR 18/12/2018 OSSME-1974
   FErase(cWork + TeOrdBagExt())
EndIf

Return .T.


*-------------------------------------------*
Function AddGatilhos(oStruct,aCampos,cFuncao)
*-------------------------------------------*
Local nI := 1

For nI := 1 To Len(aCampos)
    cCodBlock := "{ |X| " + cFuncao + "(X,'"+aCampos[nI][1]+"','"+aCampos[nI][2]+"') }"
    oStruct:AddTrigger( aCampos[nI][1] ,; // [01] Id do campo de origem
                        aCampos[nI][2] ,; // [02] Id do campo de destino
                       { || .T. } ,; 	  // [03] Bloco de codigo de validação da execução do gatilho
                       &(cCodBlock) )     // [04] Bloco de codigo de execução do gatilho
Next

Return oStruct


*--------------------------------------------*
Function DM400ValDado(oModel,cCampo,xValor,D)
*--------------------------------------------*
Local lRet := .T.
Local cMsg := ""

Begin Sequence

   Do Case
      
      Case cCampo == "EJ5_TABPRE"
           If !Empty(M->EJ5_TABPRE)

              DBSelectArea( "EWU" )
              EWU->( DBSetOrder(1) ) //"EWU_FILIAL+EWU_ARMADO+EWU_CODTAB"
              
              If EWU->( DBSeek( xFilial("EWU") + AvKey(M->EJ5_CODARM,"EWU_ARMADO") + AvKey(M->EJ5_TABPRE,"EWU_CODTAB") ) )
                 If !(AllTrim(M->EJ5_CODPOR) == AllTrim(EWU->EWU_Y9COD)) .And. !Empty( AllTrim(EWU->EWU_Y9COD) )
                    cMsg += STR0006 + Replic(ENTER,2) +; //##"A tabela informada não possui cadastro na 'Tabela de Tarifas do Armador' com o mesmo porto informado anteriormente."
                            STR0007 + STR0008 //#"Solução:" ##" Informar outra tabela equivalente ao porto informado ou cadastrar o porto informado na tabela de tarifas do armador."

                 ElseIf !Empty(EWU->EWU_DTFINV) .And. dDataBase > EWU->EWU_DTFINV
                     lRet := MsgYesNo(STR0009 +ENTER +; //##"A tabela informada está com a data de validade encerrada."
                              STR0010 ,STR0011) //##"Deseja continuar?" ##"Atenção"
                    
                 EndIf
              Else
                 cMsg += STR0012 //##"Tabela de preço informada não esta cadastrada na 'Tabela de tarifas' deste aramdor."
              EndIf
           
           Else
             cMsg += STR0013 //##"O campo não pode estar vazio."
           EndIf
           
           If( !Empty(cMsg) ,(lRet := .F., MsgInfo(cMsg,STR0011) ), Nil) //##"Atenção"
           
           If lRet .And. ValType("M->EJ5_COBRAN" ) <> "U" .And. ValType("M->EJ5_CONDIA" ) <> "U"
              M->EJ5_COBRAN := Posicione("EWU",1,xFilial("EWU")+M->EJ5_CODARM+M->EJ5_TABPRE,"EWU_COBRAN")
              M->EJ5_CONDIA := Posicione("EWU",1,xFilial("EWU")+M->EJ5_CODARM+M->EJ5_TABPRE,"EWU_CONDIA")
           EndIf


      Case cCampo == "EJ6_DTDEVO" //Data de devolução

           If !Empty( xValor )
              If xValor < oModel:GetModel():GetValue("EJ6DETAIL","EJ6_DTRETI")
                 lRet := .F.
              EndIf
           EndIf


      Case cCampo == "OBRIGAT" //Valida campos obrigatorios
           
           If oModel:GetOperation() <> 1 .And. oModel:GetOperation() <> 5 //Visualizar ## Excluir
      
              DBSelectArea("SX3")
              SX3->( DBSetOrder(1) )
              SX3->( DBSeek("EJ5") )
              Do While SX3->( !EOF() ) .And. SX3->X3_ARQUIVO == "EJ5"

                 If X3Obrigat(SX3->X3_CAMPO)
                    If Empty(oModel:GetModel():GetValue('EJ5MASTER',SX3->X3_CAMPO) )
                       lRet := .F.
                       MsgInfo(STR0014,STR0011) //#"Para incluir os containeres é preciso antes informar todos os campos obrigatorios." ##"Atenção"
                       Break
                    EndIf
                 EndIf
                 SX3->( DBSkip() )
              EndDo
           
           Else
              lRet := .F.
              MsgInfo(STR0015,STR0011) //#"Impossível incluir containeres em modo 'Visualização' ou 'Exclusão'." ##"Atenção"
           EndIf

      Case cCampo == "EJ5_CODARM" .Or. cCampo == "EJ5_CODPOR"
     
           If !Empty( oModel:GetModel():GetValue("EJ6DETAIL","EJ6_NCONTA") ) .And. oModel:GetModel():GetModel('EJ6DETAIL'):GetQtdLine() >= 1 
              lRet := .F.
           EndIf
      
      Case cCampo == "EJ5_VENCIM"
           
           If Empty( oModel:GetModel():GetValue("EJ5MASTER","EJ5_FATURA") )
              If !Empty(xValor)
                 lRet := .F.
              EndIf
              MsgInfo(STR0016,STR0011) //#"Campo Nº da Fatura esta em branco." ##"Atenção"
           EndIf
     

   EndCase

End Sequence

Return lRet
                 
*-------------------------*
Static Function IncCont(X)
*-------------------------*
Local oMdlGrid  := X:GetModel('EJ6DETAIL') //pega o modelo do Grid
Local oModel    := X:GetModel()
Local oDlgSel, oMsSelect

Local cPergunte := cModulo + "DEM",; //  EICDEM (Importação) ## EECDEM (Exportação)
      cMarca    := GetMark(),;
      cProcesso := "",; //Codigo do processo
      cPorto    := "",; //Sigla do porto
      cCodPorto := "",; //Codigo do porto
      cArmador  := "",; //codigo do armador
      cTabPreco := "",;   //codigo da tabela de tarifas do armador
      cMsg := ""

Local i := 0, nPerIni   := 0, nPerFin   := 0, nBotao := 0, nDias := 0

Local bOk      := {|| nBotao := 1, oDlgSel:End() },;
      bCancel  := {|| nBotao := 0, oDlgSel:End() }

Local lInverte := .F.,;
      lSeek    := .F.

Local aCampos  := {},;
      aSemSX3  := {},;
      aButtons := {},;
      aAux     := {},;
      aTarifas := {},;
      aValores := {}


cCodPorto := oModel:GetValue("EJ5MASTER","EJ5_CODPOR") //codigo do porto
cArmador  := oModel:GetValue("EJ5MASTER","EJ5_CODARM") //codigo do armador
cTabPreco := oModel:GetValue("EJ5MASTER","EJ5_TABPRE") //codigo da tabela de tarifas de containeres
cTabela   := oModel:GetValue("EJ5MASTER","EJ5_CODDEM")
cPorto    := Posicione('SY9',1,xFilial('SY9') + cCodPorto ,'Y9_SIGLA')//recuperando a sigla do porto atraves do seu codigo, para comparação da query


aAdd(aCampos,{"WK_MARCA"    ,,"  "})
aAdd(aCampos,{"PROCESSO"    ,,STR0017})//##"Processo"
aAdd(aCampos,{"NCONTAI"     ,,STR0018})//##"Nr Container"
aAdd(aCampos,{"TIPO"        ,,STR0019})//##"Tipo Container"
aAdd(aCampos,{"DTRETIRADA"  ,,STR0020})//##"Dt. Retirada"
aAdd(aCampos,{"DTPREVISAO"  ,,STR0021})//##"Dt Previsão"
aAdd(aCampos,{"DTDEVOLUCA"  ,,STR0022})//##"Dt Devolução"

If Select("Work") == 0

   aAdd(aSemSX3, {"WK_MARCA"    , "C"                        ,2                              , 0})
   aAdd(aSemSX3, {"PROCESSO"    , AvSx3("JD_HAWB", AV_TIPO)  , AvSx3("JD_HAWB", AV_TAMANHO)  , AvSx3("JD_HAWB",AV_DECIMAL)   })
   aAdd(aSemSX3, {"NCONTAI"     , AvSx3("JD_CONTAIN",AV_TIPO), AvSx3("JD_CONTAIN",AV_TAMANHO), AvSx3("JD_CONTAIN",AV_DECIMAL)})
   aAdd(aSemSX3, {"TIPO"        , AvSx3("JD_TIPO_CT",AV_TIPO), AvSx3("JD_TIPO_CT",AV_TAMANHO), AvSx3("JD_TIPO_CT",AV_DECIMAL)})
   aAdd(aSemSX3, {"DTRETIRADA"  , AvSx3("JD_DT_ENT",AV_TIPO) , AvSx3("JD_DT_ENT",AV_TAMANHO) , AvSx3("JD_DT_ENT",AV_DECIMAL) })
   aAdd(aSemSX3, {"DTPREVISAO"  , AvSx3("JD_DTPREVI",AV_TIPO), AvSx3("JD_DTPREVI",AV_TAMANHO), AvSx3("JD_DTPREVI",AV_DECIMAL)})
   aAdd(aSemSX3, {"DTDEVOLUCA"  , AvSx3("JD_DEVOLUC",AV_TIPO), AvSx3("JD_DEVOLUC",AV_TAMANHO), AvSx3("JD_DEVOLUC",AV_DECIMAL)})

   cWork := E_CriaTrab(,aSemSx3, "Work")
   //MFR 18/12/2018 OSSME-1974
   IndRegua("Work", cWork+TeOrdBagExt() ,"PROCESSO+NCONTAI",,, STR0023 )//##"Processando arquivo temporário..."

Else
   Work->( avzap() )
EndIf

Begin Sequence

   While Pergunte(cPergunte,.T.,STR0024)//##"Selecao de Processo"

      cProcesso := mv_par01 //numero do processo informado

      If Select("QUERY") > 0
         QUERY->(DbCloseArea())
      EndIf

      Do Case

         Case nModulo == 17 //Importação

              BeginSql Alias "QUERY"

                 SELECT SJD.JD_HAWB AS PROCESSO, SJD.JD_CONTAIN AS NCONTAI, SJD.JD_DT_ENT AS DTRETIRADA, SJD.JD_TIPO_CT AS TIPO, SJD.JD_DTPREVI AS DTPREVISAO, SJD.JD_DEVOLUC AS DTDEVOLUCA
                 FROM %table:SJD% SJD INNER JOIN %table:SW6% SW6 ON SJD.JD_HAWB = SW6.W6_HAWB
                 LEFT OUTER JOIN %table:EJ6% EJ6 ON SJD.JD_CONTAIN = EJ6.EJ6_NCONTA AND EJ6.%NotDel%
                 WHERE SJD.%NotDel% AND SJD.JD_FILIAL = %xFilial:SJD% AND SW6.%NotDel%
                       AND SW6.W6_DEST = %Exp:cPorto%    AND SJD.JD_ARMADOR = %Exp:cArmador% 
                       AND SW6.W6_HAWB = %Exp:cProcesso% AND EJ6.EJ6_NCONTA IS NULL 

              EndSql
              
         Case nModulo == 29 //Exportação

              BeginSql Alias "QUERY"

                 SELECT  EX9.EX9_PREEMB AS PROCESSO, EX9.EX9_CONTNR AS NCONTAI, EX9.EX9_DTRETI AS DTRETIRADA, EX9.EX9_TIPCON AS TIPO, EX9.EX9_DTPREV AS DTPREVISAO, EX9.EX9_DTDEVO AS DTDEVOLUCA
                 FROM %table:EXL% EXL LEFT JOIN  %table:EX9% EX9 ON EXL.EXL_PREEMB = EX9.EX9_PREEMB
		              INNER JOIN %table:EEC% EEC ON EX9.EX9_PREEMB = EEC.EEC_PREEMB
                      LEFT JOIN %table:EJ6% EJ6 ON EX9.EX9_CONTNR = EJ6.EJ6_NCONTA AND EJ6.%NotDel%
                 WHERE EX9.%NotDel%     AND EX9.EX9_FILIAL = %xFilial:EX9%
                       AND EXL.%NotDel% AND EXL.EXL_FILIAL = %xFilial:EXL%
                       AND EXL.EXL_ARMADO = %Exp:cArmador%   AND EEC.EEC_DEST = %Exp:cPorto% 
                       AND EEC.EEC_PREEMB = %Exp:cProcesso%  AND EJ6.EJ6_NCONTA IS NULL
              EndSql

      End Case
      
      //Alterando os campos que veem como Caracteres para Datas
      TcSetField("QUERY","DTRETIRADA","D")
      TcSetField("QUERY","DTPREVISAO","D")
      TcSetField("QUERY","DTDEVOLUCA","D")
              
      If !CarregaWork(X) //carrega a work a ser exibida na tela de filtro com os processos e containeres
         MsgInfo(STR0025 ,STR0011) //#"Nenhum registro encontrado com este número de processo." ##"Atenção"
         Loop
      EndIf

      Work->( DBGoTop() )              
      DEFINE MSDIALOG oDlgSel TITLE  STR0026 + AllTrim(cProcesso) FROM 0,0 TO DLG_LIN_FIM , DLG_COL_FIM * 0.7 OF oMainWnd PIXEL //##"Containeres do Processo: "

           oMsSelect := MsSelect():New("Work","WK_MARCA",,aCampos,@lInverte,@cMarca,PosDLG(oDlgSel))
           oMsSelect:bAval := {|| MarcaWork(cMarca, .F.), oMsSelect:oBrowse:Refresh() }
                 
      ACTIVATE MSDIALOG oDlgSel ON INIT EnchoiceBar(oDlgSel, bOk, bCancel,, aButtons) CENTERED
                 
      If nBotao == 1

         Work->( DBGoTop() )
         Do While Work->( !EOF() )

            lSeek := .F.
            aPeriodos:= {}
            aTarifas := {}
            aValores := {}

            If !Empty(Work->WK_MARCA)
               
               Private aGetDados := {}
          
               EWU->( DBSetOrder(1) ) //"EWU_FILIAL+EWU_ARMADO+EWU_CODTAB"                       
               If EWU->( DBSeek( xFilial("EWU") + AvKey(cArmador,"EWU_ARMADO") + AvKey(cTabPreco,"EWU_CODTAB") ) )
 
                  EWV->( DBSetOrder(1) )//"EWV_FILIAL+EWV_ARMADO+EWV_CODTAB+EWV_CODCON+EWV_PERINI"
                  If  EWV->( DBSeek( xFilial("EWV") + AvKey(cArmador,"EWU_ARMADO") + AvKey(cTabPreco,"EWV_CODTAB") + AvKey(Work->TIPO,"EWV_CODCON") ) )

                      nDias    := CalcDias( Work->DTRETIRADA, dDataBase, EWU->EWU_CONDIA )//quantidade de dias atuais
                      aTarifas := BuscaTarifa(cArmador,Work->TIPO,cTabPreco,nDias,.T.)//busca valores das tarifas atual,prevista e final
                      aValores := CalcTarifa( nDias, aTarifas,  AllTrim(EWU->EWU_COBRAN)  )
                          
                      //Atuais
                      SetaGetDados("EJ6_QTDATU", aValores[1,1]) //Qtd Dias atual da tarifa
                      SetaGetDados("EJ6_VTARAT", aValores[1,2]) //Valor da tarifa atual
                      SetaGetDados("EJ6_VLATUA", aValores[1,3]) //Valor atual da tarifa

                      //Previstos
                      nDias    := CalcDias( Work->DTRETIRADA, Work->DTPREVISAO, EWU->EWU_CONDIA )//quantidade de dias previstos
                      aTarifas := BuscaTarifa(cArmador,Work->TIPO,cTabPreco,nDias,.T.)//busca valores das tarifas atual,prevista e final
                      aValores := CalcTarifa( nDias, aTarifas,  AllTrim(EWU->EWU_COBRAN)  )
                              
                      SetaGetDados("EJ6_QTDPRE", aValores[1,1]) //Qtd Dias previsto da tarifa
                      SetaGetDados("EJ6_VTARPR", aValores[1,2]) //Valor da tarifa previsto               
                      SetaGetDados("EJ6_VLPREV", aValores[1,3]) //Valor previsto da tarifa
               
                      //Finais
                      nDias    := CalcDias( Work->DTRETIRADA, Work->DTDEVOLUCA, EWU->EWU_CONDIA  )//quantidade de dias finais
                      aTarifas := BuscaTarifa(cArmador,Work->TIPO,cTabPreco,nDias,.T.)//busca valores das tarifas atual,prevista e final
                      aValores := CalcTarifa( nDias, aTarifas,  AllTrim(EWU->EWU_COBRAN)  )
               
                      SetaGetDados("EJ6_QTDFIN", aValores[1,1]) //Qtd Dias final da tarifa
                      SetaGetDados("EJ6_VTARFI", aValores[1,2]) //Valor da tarifa final
                      SetaGetDados("EJ6_VLFINA", aValores[1,3]) //Valor final da tarifa

                      SetaGetDados("EJ6_CODPRO" , cProcesso)
                      SetaGetDados("EJ6_NCONTA" , Work->NCONTAI)
                      SetaGetDados("EJ6_CODCON" , Work->TIPO)
                      SetaGetDados("EJ6_DTRETI" , Work->DTRETIRADA)
                      SetaGetDados("EJ6_DTPREV" , Work->DTPREVISAO)
                      SetaGetDados("EJ6_DTDEVO" , Work->DTDEVOLUCA)

                      AddRegistro(oModel)//Adiciona linha no gride 
                   
                   Else
                     cMsg := STR0027 + AllTrim(cArmador) + STR0028 + AllTrim(Work->TIPO) +; //#"O armador " ##" não possue o container do tipo '"
                               " - " +  AllTrim(Posicione("SX5",1,xFilial("SX5")+"C3"+AvKey(Work->TIPO,"EWV_CODCON"),"X5_DESCRI") ) +;
                               STR0029//##"' cadastrado na 'Tabela de Tarifas do Armador'."
                         
                   EndIf
                EndIf

            EndIf

            Work->( DBSkip() )
         EndDo

         Break //finaliza o loop quando adicionada ao menos uma linha
       
      Else //nBotao == 0 ## Operação cancelada
         Work->( avzap() )
      EndIf

   EndDo
   
End Sequence

ShowError(cMsg)

GeraTotais(X)
oMdlGrid:GoLine( 1 )

Return oModel

*---------------------------------*
Static Function CarregaWork(oModel)
*---------------------------------*
Local lExiste := .F.,;
      lRet    := .F.  // .T. se a work foi carregada
Local i := 0

Begin Sequence

   QUERY->( DBGoTop()) 
   //Carregando Work com os valores do select da Query
   Do While QUERY->( !EOF() )
      
      lExiste := .F.

      For i := 1 To oModel:GetModel('EJ6DETAIL'):GetQtdLine()
          oModel:GetModel('EJ6DETAIL'):GoLine( i )
          If AllTrim(QUERY->PROCESSO) == AllTrim(oModel:GetModel():GetValue('EJ6DETAIL',"EJ6_CODPRO")) .And.; //Processo
             AllTrim(QUERY->NCONTAI) ==  AllTrim(oModel:GetModel():GetValue('EJ6DETAIL',"EJ6_NCONTA")) //Nr COntainer
             lExiste := .T.
             Exit
          EndIf
      Next

      If !lExiste
         Work->( DBAppend() )
         Work->PROCESSO     := QUERY->PROCESSO
         Work->NCONTAI      := QUERY->NCONTAI
         Work->TIPO         := QUERY->TIPO
         Work->DTRETIRADA   := QUERY->DTRETIRADA
         Work->DTPREVISAO   := QUERY->DTPREVISAO
         Work->DTDEVOLUCA   := QUERY->DTDEVOLUCA
         lRet := .T.
      EndIf
      
      QUERY->( DBSkip() )
      
   EndDo

End Sequence

Return lRet


/**************************************************************
*                                                             *
* Funcao    : MarcaWork()                                     *
* Parametro : cMarca  - Marcação                              *
*             lTodos - Para habilitar marcação de todos       *
* Autor     : Felipe S. Martinez                              *
* Data      : 28/03/11                                        *
*                                                             *
***************************************************************/
*----------------------------------------*
Static Function MarcaWork(cMarca, lTodos)
*----------------------------------------*   

  If lTodos
    
     Work->( DBGoTop() )
     Do While Work->( !EOF() )
        Work->WK_MARCA := If(Work->WK_MARCA == cMarca, "" ,cMarca)
        Work->( DBSkip() )
     EndDo
     
  Else
     Work->WK_MARCA := If(Work->WK_MARCA == cMarca, "" ,cMarca)
  EndIf
   
Return Nil   



/*************************************************************
*                                                            *
* Funcao    : AddRegistro()                                  *
* Parametro : oModel - Modelo (gride) a ser adicionado os    *
*             registros                                      *
* Autor     : Felipe S. Martinez                             *
* Data      : 28/03/11                                       *
*                                                            *
**************************************************************/
*----------------------------------*
Static Function AddRegistro(oModel)
*----------------------------------*
Local lRet := .T.
Local oMdlGride := oModel:GetModel('EJ6DETAIL')
Local i := 0

Begin Sequence

    If !Empty(oModel:GetModel():GetValue('EJ6DETAIL',"EJ6_NCONTA"))
       oMdlGride:GoLine( oMdlGride:GetQtdLine() )
       oMdlGride:AddLine()//adiciona linha no grid
    EndIf
    
    For i := 1 To Len(aGetDados)
        oModel:SetValue('EJ6DETAIL', aGetDados[i][1], GetaGetDados(aGetDados[i][1]) )
    Next
    
End Sequence

Return lRet



/*************************************************************
*                                                            *
* Funcao    : BuscaTarifa()                                  *
* Parametro : cArmador - cod. Armador                        *
*             cTipoCon - Tipo do container                   *
*             cTabela  - Cod. tabela de Tarifas do Armador   *
*             aDias    - Quantidade de dias em demurrage     *
* Autor     : Felipe S. Martinez                             *
* Data      : 01/03/11                                       *
*                                                            *
**************************************************************/
*----------------------------------------------------------------*
Static Function BuscaTarifa(cArmador,cTipoCon,cTabela,nDias,lErro)
*----------------------------------------------------------------*
Local nPerIni := 0,;
      nPerFin := 0

Local lSeek  := .F.
Local cMsg   := "",;
      cTexto := ""
Local nTarifa := 0  
Local aPeriodos := {}

Default lErro := .F.

Begin Sequence
      
      EWU->( DBSetOrder(1) ) //"EWU_FILIAL+EWU_ARMADO+EWU_CODTAB"                       
      If EWU->( DBSeek( xFilial("EWU") + AvKey(cArmador,"EWU_ARMADO") + AvKey(cTabela,"EWU_CODTAB") ) )
         lSeek := .T.
      Else

         EWU->( DBSetOrder(2) )//"EWU_FILIAL+EWU_ARMADO+EWU_Y9COD"

         //porto em branco como padrao para todos os portos não cadastrados
         If EWU->( DBSeek( xFilial("EWU") + AvKey(cArmador,"EWU_ARMADO")  + Space(AvSx3("EWU_Y9COD",3)) ) )
            lSeek := .T.
         EndIf
      
      EndIf
      
         EWV->( DBSetOrder(1) )//"EWV_FILIAL+EWV_ARMADO+EWV_CODTAB+EWV_CODCON+EWV_PERINI"
         //Posicionando tabela de detalhes das tarifas para efetuar os calculos
         If lSeek .And. EWV->( DBSeek( xFilial("EWV") + AvKey(cArmador,"EWU_ARMADO") + AvKey(EWU->EWU_CODTAB,"EWV_CODTAB") + AvKey(cTipoCon,"EWV_CODCON") ) )
                             
            //Adicionar o primeiro periodo do 1 ao periodo inicial do armador
            If Val( AllTrim(EWV->EWV_PERINI) ) > 1
               aAdd( aPeriodos, {1, Val( AllTrim(EWV->EWV_PERINI) )-1, 0, .F.} )
            EndIf

            Do While EWV->( !EOf() ) .And. xFilial("EWV") == EWV->EWV_FILIAL .And.;
                     AllTrim(cArmador) == AllTrim(EWV->EWV_ARMADO) .And. AllTrim(EWV->EWV_CODTAB) == AllTrim(EWU->EWU_CODTAB) .And.;
                     AllTrim(cTipoCon) == AllTrim(EWV->EWV_CODCON) .And. Val( AllTrim(EWV->EWV_PERINI) ) <= nDias
                     
                     nPerIni := Val( AllTrim(EWV->EWV_PERINI) )
                     nPerFin := If( !Empty(AllTrim(EWV->EWV_PERFIN)), Val( AllTrim(EWV->EWV_PERFIN) ), 9999)
                     nTarifa := EWV->EWV_TARIFA

                     aAdd( aPeriodos, {nPerIni, Min(nPerFin, nDias), nTarifa, .T. } )
                     
                     EWV->( DBSkip() )
            EndDo

         ElseIf lErro
         
            cTexto := STR0027 + AllTrim(cArmador) + STR0028 + AllTrim(cTipoCon) +; //#"O armador " ##" não possue o container do tipo '"
                      " - " +  AllTrim(Posicione("SX5",1,xFilial("SX5")+"C3"+AvKey(cTipoCon,"EWV_CODCON"),"X5_DESCRI") ) +;
                      STR0029//##"' cadastrado na 'Tabela de Tarifas do Armador'."

            If !( cTexto $ cError )
               cMsg += cTexto + ENTER
            EndIf
             cError := cMsg
         EndIf
         
End Sequence

ShowError(cMsg)

Return aPeriodos



/*************************************************************
*                                                            *
* Funcao    : SetaGetDados()                                 *
* Parametro : cCampo   - Campo a ser incluso no array        *
*             xDadi    - Informação a ser inclusa no campo   *
                         informado                           *
* Autor     : Felipe S. Martinez                             *
* Data      : 01/03/11                                       *
*                                                            *
**************************************************************/
*------------------------------------------*
Static Function SetaGetDados(cCampo, xDado)
*------------------------------------------*
Local nPos := 0

//Verifica se o campo existe, se sim adiciona informação nele, se nao adiciona o campo no Array juntamente com a informação.
If (nPos := aScan(aGetDados,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0
   aGetDados[nPos][2] := xDado
Else
   aAdd(aGetDados,{cCampo,xDado})
EndIf

Return .T.


/*************************************************************
*                                                            *
* Funcao    : GetaGetDados()                                 *
* Parametro : cCampo   - Campo a ser resgatado a informação  *
* Autor     : Felipe S. Martinez                             *
* Data      : 01/03/11                                       *
*                                                            *
**************************************************************/
*-----------------------------------*
Static Function GetaGetDados(cCampo)
*-----------------------------------*
Local nPos
Local xRet

//Verifica se o Campo exite no array, se sim pega o dado dele, se não adiciona informação em Branco
if (nPos := aScan(aGetDados,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0
   xRet := aGetDados[nPos][2]
Else
   xRet := CriaVar(cCampo)
EndIf

Return xRet


/***************************************************************
*                                                              *
* Funcao    : CalcTarifa()                                     *
* Parametro : nValor - Valor base do calculo final             *
*             nDias  - Quantidade de dias para o calculo final *
* Autor     : Felipe S. Martinez                               *
* Data      : 29/03/11                                         *
*                                                              *
****************************************************************/
*-------------------------------------------*
Static Function CalcTarifa(nPeriodos, aTarifas, cTipoCalc)
*-------------------------------------------*
Local aValores := {}
Local i := 0, j := 0
Local nValor := 0
Local nDias := nPeriodos 
Local nTarifa := 0

Default cTipoCalc := 1

Begin Sequence
   
      
      If cTipoCalc == "1" //Normal

         For j := 1 To Len(aTarifas)
             If nPeriodos >= aTarifas[j,1]
                 If !aTarifas[j,4]
                    nDias -= (aTarifas[j,2] - aTarifas[j,1]) + 1
                 EndIf
                 nValor  += ( ( (aTarifas[j,2] - aTarifas[j,1]) + 1) * aTarifas[j,3] )
                 nTarifa += aTarifas[j,3]        
             EndIf
         Next

         nTarifa := nValor/nDias

      Else //Retroativa
      
         For i := 1 To Len(aTarifas)
             If aTarifas[i][2] == nPeriodos
                nTarifa := aTarifas[i][3]
             EndIf
         Next 

         nDias   := nPeriodos
         nValor  := nDias * nTarifa

      EndIf
      
      nDias := If(nDias>=0,nDias,0)
     
      aAdd( aValores, { nDias, nTarifa ,nValor } )
   
End Sequence

Return aValores     





/**************************************************************
*                                                             *
* Funcao    : CalcDias()                                      *
* Parametro : dRetirada  - Data de retirado do container      *
*             dDevolucao - Data de devolucao do container     *
* Autor     : Felipe S. Martinez                              *
* Data      : 29/03/11                                        *
*                                                             *
***************************************************************/
*---------------------------------------------*
Static Function CalcDias(dRetirada,dDevolucao, nTipoCalc)
*---------------------------------------------*
Local nDias := 0
Default nTipoCalc := "1"

Begin Sequence
   
   If dDevolucao == cToD("  /  /  ")
      nDias := 0
   Else
      If AllTrim(nTipoCalc) == "2"  //2 = De Segunda à Sexta
         nDias := Dias_Uteis(dRetirada,dDevolucao) + 1
      Else //1 = Dias corridos
         nDias := (dDevolucao - dRetirada ) + 1
      EndIf
   EndIf
   
End Sequence

Return nDias


/******************************************************
**   Funções de calculos:
*******************************************************/

/**************************************************************
*                                                             *
* Funcao    : RecalculaValores()                              *
* Parametro :                                                 *
* Objetivo  : Recalcular os valores totais da capa quando     *
              DELETADA uma linha de detalhe.                  *
* Autor     : Felipe S. Martinez                              *
* Data      : 15/04/11                                        *
*                                                             *
***************************************************************/
*------------------------------------------------------*
Static Function RecalculaValores(oModel,nLinha,cAcao,D)
*------------------------------------------------------*
Local lRet := .F.
Local nOperation := oModel:GetOperation()
Local nOperador := 1,;
      nVlAtual  := 0,;
      nVlPrev   := 0,;
      nVlFinal  := 0
Local oView := FWViewActive()//carrega view ativa

Begin Sequence

   If !(cAcao == "DELETE") .And. !(cAcao == "UNDELETE")
      lRet := .T.
      Break
   EndIf

   If nOperation <> 5 .And. nOperation <> 2 //Excluir ## Visualizar
      oModel := oModel:GetModel()

      nOperador := IIf( cAcao == "DELETE" , -1 , 1 ) //atribuindo operação para o calculo

      oModel:GetModel('EJ6DETAIL'):GoLine( nLinha )//posiciona na linha deletada

      If !Empty( oModel:GetValue("EJ6DETAIL", "EJ6_NCONTA" ) ) //tratamento para deleção de linha em branco

         nVlAtual := oModel:GetValue("EJ6DETAIL", "EJ6_VLATUA" )
         nVlPrev  := oModel:GetValue("EJ6DETAIL", "EJ6_VLPREV" )
         nVlFinal := oModel:GetValue("EJ6DETAIL", "EJ6_VLFINA" )

         //valor total atual
         oModel:SetValue("EJ5MASTER",  "EJ5_VATUAL" , ( oModel:GetValue("EJ5MASTER",  "EJ5_VATUAL") + (nOperador * nVlAtual) ) )

         //valor total previsto
         oModel:SetValue("EJ5MASTER",  "EJ5_VPREVI" , ( oModel:GetValue("EJ5MASTER",  "EJ5_VPREVI") + (nOperador * nVlPrev ) ) )

         //valor total final
         oModel:SetValue("EJ5MASTER",  "EJ5_VTOTAL" , ( oModel:GetValue("EJ5MASTER",  "EJ5_VTOTAL") + (nOperador * nVlFinal) )  )

         oView:Refresh()

      EndIf

      lRet := .T.

   EndIf

End Sequence

Return lRet


/*************************************************************
*                                                            *
* Funcao    : DM400AtuTarifa()                               *
* Parametro :                                                *
* Objetivos : Atualiza campos virtuais da capa e do detalhe  *
*             ao ENTRAR na rotina, atraves de gatilhos.      *
* Autor     : Felipe S. Martinez                             *
* Data      : 04/03/11                                       *
*                                                            *
**************************************************************/
*------------------------*
Function DM400AtuTarifa()
*------------------------*
Local cArmador := EJ5->EJ5_CODARM,;
      cTipoCon := EJ6->EJ6_CODCON,;
      cTabela  := EJ5->EJ5_TABPRE
Local nRetorno := 0,;
      nDias    := 0,;
      nOperation := 0
Local aDias := {} //vetor com informações dos dias (aDias[N][1]) e valor da tarifa dos dias (aDias[N][2])
Local oModel := FWModelActive()
Local xCampo := ReadVar()
Local xValor := &xCampo
Local aTarifas := {}
Local aValores := {}

Begin Sequence
   
   If !( ValType( xValor ) == "U" ) .Or. Empty(cArmador).And.Empty(cTipoCon).And.Empty(cTabela)
      Break //Não efetuar calculos
   EndIf

   nOperation := oModel:GetOperation()   
   oModel := oModel:GetModel("EJ6DETAIL")

   EWU->( DBSetOrder(1) ) //"EWU_FILIAL+EWU_ARMADO+EWU_CODTAB"                       
   EWU->( DBSeek( xFilial("EWU") + AvKey(cArmador,"EWU_ARMADO") + AvKey(cTabela,"EWU_CODTAB") ) )
   
   nDias := CalcDias( EJ6->EJ6_DTRETI, dDataBase, EWU->EWU_CONDIA )   //calcula a quantidade de dias em demurrage
   aTarifas := BuscaTarifa(cArmador,cTipoCon,cTabela,nDias)//busca valor da tarifa de acordo com o tipo do container e os dias em demuurage
   aValores := CalcTarifa( nDias, aTarifas,  AllTrim(EWU->EWU_COBRAN) )
   
   If xCampo == "M->EJ6_QTDATU"
      nRetorno := aValores[1,1] //Quantidade de dias em demurrage
      Break
   EndIf

   If xCampo == "M->EJ6_VTARAT"
      nRetorno := aValores[1,2] //Valor da tarifa no periodo de demurrage
      Break
   EndIf
   
   If xCampo == "M->EJ6_VLATUA"
      nRetorno := aValores[1,3] //Valor total do demurrage

      //calculando total atual da capa
      If nOperation <> 1 .And. nOperation <> 5 //Visualizar ## Excluir //FSM - 14/03/2012
         oModel:GetModel():SetValue( "EJ5MASTER","EJ5_VATUAL",  (oModel:GetModel():GetValue( "EJ5MASTER","EJ5_VATUAL") + nRetorno ) )
      EndIf      
      
      Break
      
   EndIf

End Sequence

oModel := FWModelActive() //Tratamento para correta atualização do MVC.
oModel:lModify := .F.

Return nRetorno



/*************************************************************
*                                                            *
* Funcao    : DM400AltValores()                                *
* Parametro :                                                *
* Objetivos : Altera os valores do detalhe quando selecionado* 
              outra tabela de tarifas de base dos calculos   *
* Autor     : Felipe S. Martinez                             *
* Data      : 04/03/11                                       *
*                                                            *
**************************************************************/
*-----------------------------------------------------*
Function DM400AltValores(oMdl,cCampoOrigem,cCampoDest)
*-----------------------------------------------------*
Local nOperation

Local dDevolucao := cToD("  /  /  "),;
      dRetirada  := cToD("  /  /  "),;
      dPrevisto  := cToD("  /  /  ")

Local nQntDias     := 0 ,; //Quantida de dias em Demurrage
      nValorTotal  := 0 ,;   //Valor total do demurrage
      nTotalProcesso := 0,;
      i := 0, j:= 0

Local cArmador := "",;
      cTipoCon := "",;
      cTabela := ""

Local aTarifas := {},;
      aValores := {},;
      aArray := {}

nOperation := oMdl:GetOperation() //Operação a ser realizada INCLUSAO/ALTERACAO/EXCLUSAO....
oModel     := oMdl:GetModel() // Modelo

Begin Sequence

   If nOperation <> 5 .And. nOperation <> 2 //Excluir ## Visualizar
      
      cArmador := oModel:GetValue('EJ5MASTER',"EJ5_CODARM") //Código do armador
      cTabela  := &cCampoOrigem //Código da tabela de precos

      aArray := {{"EJ6_DTRETI",""/*Date()*/,"EJ6_QTDATU","EJ6_VTARAT","EJ6_VLATUA"},; //valores atuais
                 {"EJ6_DTRETI","EJ6_DTPREV","EJ6_QTDPRE","EJ6_VTARPR","EJ6_VLPREV"},; //valores previstos
                 {"EJ6_DTRETI","EJ6_DTDEVO","EJ6_QTDFIN","EJ6_VTARFI","EJ6_VLFINA"}}  //valores finais
      
      For j := 1 To oModel:GetModel('EJ6DETAIL'):GetQtdLine()
 
          oModel:GetModel('EJ6DETAIL'):GoLine( j )
          cTipoCon := oModel:GetValue('EJ6DETAIL',"EJ6_CODCON") //Tipo do container
          
          For i:=1 To Len(aArray)
              
              aDias := {}
              aTarifas := {}
              aValores := {}
         
              dRetirada  := oModel:GetValue('EJ6DETAIL',aArray[i][1]) //Data de retirada
              dDevolucao := IIf(!Empty(aArray[i][2]), oModel:GetValue('EJ6DETAIL',aArray[i][2]), dDataBase) //Data de devolucao
          
              EWU->( DBSetOrder(1) ) //"EWU_FILIAL+EWU_ARMADO+EWU_CODTAB"                       
              EWU->( DBSeek( xFilial("EWU") + AvKey(cArmador,"EWU_ARMADO") + AvKey(cTabela,"EWU_CODTAB") ) )
   
              nQntDias := CalcDias( dRetirada, dDevolucao, EWU->EWU_CONDIA )  //add a quantidade de dias em demurrage

              aTarifas := BuscaTarifa(cArmador,cTipoCon,cTabela,nQntDias)//busca valor da tarifa de acordo com o tipo do container e os dias em demuurage
               
              aValores := CalcTarifa( nQntDias, aTarifas,  AllTrim(EWU->EWU_COBRAN) )
          
              //Atribuições as celulas do gride
              oModel:SetValue('EJ6DETAIL', aArray[i][3], aValores[1,1] ) //Qntd de Dias
              oModel:SetValue('EJ6DETAIL', aArray[i][4], aValores[1,2] ) //Valor da tarifa
              oModel:SetValue('EJ6DETAIL', aArray[i][5], aValores[1,3] ) //Valor total do demurrage
          
          Next      
      Next
      
   EndIf 
   
   
End Sequence

//Recalcula os totais
GeraTotais(oMdl)

nTotalProcesso := oModel:GetValue('EJ5MASTER',"EJ5_VTOTAL")


Return nTotalProcesso



/*************************************************************
*                                                            *
* Funcao    : DM400CalcVFinal()                                *
* Parametro :                                                *
* Objetivos : Atraves de gatilho do campo, altera os valores *
*             finais tanto da capa quanto do detalhe         *
* Autor     : Felipe S. Martinez                             *
* Data      : 04/03/11                                       *
*                                                            *
*************************************************************/
*-------------------------------------------------------*
Function DM400CalcVFinal(oModel,cCampoOrigem,cCampoDest)
*-------------------------------------------------------*
Local nOperation

Local dDevolucao := cToD("  /  /  "),;
      dRetirada  := cToD("  /  /  "),;
      dPrevisto  := cToD("  /  /  ")

Local nValorTotal  := 0 ,;   //Valor total do demurrage
      nSaldoAnterior := 0,;
      nVTotal := 0

Local cArmador := "",;
      cTipoCon := "",;
      cTabela := ""


Local aTarifas := {},;
      aValores := {}

nOperation := oModel:GetOperation() //Operação a ser realizada INCLUSAO/ALTERACAO/EXCLUSAO....

Begin Sequence

   If nOperation <> 5 .And. nOperation <> 2 //Excluir ## Visualizar
   
      oModel     := oModel:GetModel() // Modelo
   
      cArmador := oModel:GetValue('EJ5MASTER',"EJ5_CODARM") //Código do armador
      cTabela  := oModel:GetValue('EJ5MASTER',"EJ5_TABPRE") //Código da tabela de precos

      dRetirada  := oModel:GetValue('EJ6DETAIL',"EJ6_DTRETI") //Data de retirada
      dPrevisto  := oModel:GetValue('EJ6DETAIL',"EJ6_DTPREV") //Data prevista
      dDevolucao := oModel:GetValue('EJ6DETAIL',"EJ6_DTDEVO") //Data de devolucao
      cTipoCon   := oModel:GetValue('EJ6DETAIL',"EJ6_CODCON") //Tipo do container
      
      Do Case 
              //Calculando o valor do Demurrage (Final)
         Case UPPER(cCampoDest) == "EJ6_VLFINA"
         
              EWU->( DBSetOrder(1) ) //"EWU_FILIAL+EWU_ARMADO+EWU_CODTAB"                       
              EWU->( DBSeek( xFilial("EWU") + AvKey(cArmador,"EWU_ARMADO") + AvKey(cTabela,"EWU_CODTAB") ) )
        
              nDias :=  CalcDias( dRetirada, dDevolucao, EWU->EWU_CONDIA )   //add a quantidade de dias em demurrage

              aTarifas := BuscaTarifa(cArmador,cTipoCon,cTabela,nDias)//busca valor da tarifa de acordo com o tipo do container e os dias em demuurage
               
              aValores := CalcTarifa( nDias, aTarifas,  AllTrim(EWU->EWU_COBRAN) )

              //Atribuições as celulas do gride
              oModel:SetValue("EJ6DETAIL", "EJ6_QTDFIN", aValores[1,1] )//Dias 'final'
  
              oModel:SetValue("EJ6DETAIL", "EJ6_VTARFI", aValores[1,2] )//Valor tarifa 'final'
              
              nValorTotal := aValores[1,3] //Valor 'Final' do calculo
              
              //calculando total final da capa
              nSaldoAnterior := oModel:GetValue("EJ6DETAIL","EJ6_VLFINA")
              
              nVTotal := oModel:GetValue("EJ5MASTER","EJ5_VTOTAL")

              If nValorTotal > 0
                 oModel:SetValue("EJ5MASTER", "EJ5_VTOTAL", nVTotal + (nValorTotal-nSaldoAnterior) )
              Else
                 oModel:SetValue("EJ5MASTER", "EJ5_VTOTAL",  nVTotal - nSaldoAnterior )
              EndIf

      EndCase
      
   EndIf
      
End Sequence

Return nValorTotal

*-------------------------*
Static Function GeraTotais(oModel)
*-------------------------*
Local nFinal    := 0,;
      nPrevisto := 0,;
      nAtual    := 0,;
      nOperation := 2,;
      i := 0

nOperation := oModel:GetOperation() //Operação a ser realizada INCLUSAO/ALTERACAO/EXCLUSAO....
oModel     := oModel:GetModel() // Modelo

Begin Sequence

  If nOperation <> 5 .And. nOperation <> 2 //Excluir ## Visualizar
  
     For i := 1 To oModel:GetModel('EJ6DETAIL'):GetQtdLine()

         oModel:GetModel('EJ6DETAIL'):GoLine( i )
         If !oModel:GetModel('EJ6DETAIL'):IsDeleted(i)
            nAtual    += oModel:GetValue("EJ6DETAIL","EJ6_VLATUA")
            nPrevisto += oModel:GetValue("EJ6DETAIL","EJ6_VLPREV")
            nFinal    += oModel:GetValue("EJ6DETAIL","EJ6_VLFINA")
         EndIf
         
     Next

  EndIf

  oModel:SetValue("EJ5MASTER","EJ5_VATUAL",nAtual)
  oModel:SetValue("EJ5MASTER","EJ5_VPREVI",nPrevisto)
  oModel:SetValue("EJ5MASTER","EJ5_VTOTAL",nFinal)
    
End Sequence

Return .T.

Static Function ShowError(cTexto)

If !Empty( cTexto )
   EECView(cTexto)
EndIf

Return .T.

//RMD - 25/09/14 - Imprime o relatório de Demurrage, a partir do programa EASYDMREL.APH
Function DM400Rel()
Local cDir := "\Comex\"
Local cFile:= "EASYDMREL.xrp"  
Local oDm400Rel, oReport 

Begin Sequence

   If !lIsDir(cDir) .And. !(MakeDir(cDir) == 0)
      MsgInfo(StrTran("Erro ao criar o diretório temporário '###'. Não será possível executar o relatório.", "###", cDir),"Atenção")
      lRet := .F.
      Break
   EndIf
   
   If File(cDir+cFile)
      FErase(cDir+cFile)
   EndIf
                                                  
   If !MemoWrite(cDir+cFile, EasyExecAHU("EASYDMREL"))
      MsgInfo("Erro de Abertura do arquivo.","Atenção")
      Break
   EndIf  
     
   /*LoadReport(cDir+cFile)
   FErase(cDir+cFile)*/

   oDm400Rel:= EasyTReport():New("EASYDMREL", .T.)
   If !oDm400Rel:lError
      oReport := oDm400Rel:RetOReport()
      oReport:SetLandscape()
      oReport:DisableOrientation()
      oDm400Rel:PrintReport()
   EndIf

End Sequence

Return .T.