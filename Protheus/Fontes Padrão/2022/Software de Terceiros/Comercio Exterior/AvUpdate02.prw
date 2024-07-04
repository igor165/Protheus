#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*
Funcao      : EasyUpd12
Objetivos   : Validação para Update para 12
Autor       : Lucas Raminelli - LRS
Data/Hora   : 03/03/2015
*/
Function EasyUpd12(cRelease,cModulo)
   Local cVersao := "P" + Alltrim(SubSTR(cRelease,1,2))
   Local cLastRe := SubSTR(cRelease,Rat(".",cRelease)+1)
   Local aRelease :={"023","025","027", "033"}

   If aScan(aRelease,cLastRe) > 0
      &('RUP_'+cModulo+'("'+cVersao+'","0","'+cValToChar(aRelease[1])+'","'+cLastRe+'","BRA")')
   EndIF

   /*  THTS - 11/07/2017 - TE-5662 / MTRADE-1083 / WCC-524454 -  Implementar as funções TOTVS para alteração dos dicionários no Banco de Dados
    Alterada a forma de execucao das funcoes RUP de todos os modulos para que sejam executados os Releases ativos no mesmo objeto, desta
    forma, dentro das funcoes RUP teremos um unico oUpd := AVUpdate01():New() e um unico oUpd:Init(,.T.). Esta alteracao foi necessaria
    para as chamadas das novas funcoes de dicionarios no banco de dados.
   */

Return

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_[XXX]
Função de compatibilização do release incremental.
Serão chamadas todas as funções compiladas referentes aos módulos cadastrados do Protheus
Será sempre considerado prefixo "RUP_" acrescido do nome padrão do módulo sem o prefixo SIGA.
Ex: para o módulo SIGAEIC criar a função RUP_EIC

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa) - 0=Chamada do AvGeral, para correções de manutenção
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Framework
@since 28/01/2015
@version P12

Revisão:
1. removidas as chamadas de funções que não existem no programa
2. condicionada a atualização de dicionário para quando o cmode for igual a 1 (chamada via upddistr) ou 0 (chamado via avgeral) e atualização de carga de dados quando for 2 (chamada por filial)

/* Módulo SIGAEIC */
Function RUP_EIC(cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1" )  .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "003"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EIC,{|o|UPDEIC003(o)}} }//MMM=(EIC,EEC,EDC,EFF,ECO)/M=Modulo(I=EIC,E=EEC,D=EDC,F=EFF,C=ECO)
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC003(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "004"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC004(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC004(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "005"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC005(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC005(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "006"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC006(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC006(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "007"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC007(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "014"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC014(o)}} }
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC014(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC016(o)}} }
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "017"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EIC,{|o|UPDEIC017(o)}} }
                  aAdd(oUpd:aChamados, {EIC,{|o|UPDEIC017(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEIC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               EndIF
            Next nRelease
         EndIf

         If cMode == "0" //.Or. cMode == "2" //atualização de carga de dados, chamado do avgeral (ajustes de manutenção) ou do RUP
            //MCF - 25/05/2016
            If GetRemoteType() == 5
               //oUpd := AVUpdate01():New()
               //oUpd:aChamados := {{EIC,{|o| AjustaSmartHtml(o)}}}
               aAdd(oUpd:aChamados, {EIC,{|o| AjustaSmartHtml(o)}} )
               //oUpd:Init(,.T.)
            EndIf

            if avflags("FORM_LPCO")
               aAdd(oUpd:aChamados,  {nModulo,{|o| cargaSJJ(o)}} )
               oUpd:cTitulo := "Update para o modulo carga padrão da tabela SJJ."
            EndIf

         EndIf

         If cRelFinish <= "2210" //Chamada via Upddistr
            //Efetuada verificacao do relacionamento no SX9 para os campos de Codigo e Loja da tabela SWB. Caso ja exista o relacionamento correto com codigo e loja, deve ser removido o antigo sem a loja
            aAdd(oUpd:aChamados, {EIC,{|o| AjusSX9SW6(o)}})
            aAdd(oUpd:aChamados, {EIC,{|o| AjusSX9Moe(o)}})
         EndIf

         If cMode == '1' .And. cRelFinish >= "023" .And. EKB->(fieldPos("EKB_PAIS")) # 0 //Chamada via Upddistr
            aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033(o) },.F.})
         EndIf

         If cMode == '1' .And. cRelFinish >= "027" //Chamada via Upddistr
            aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033V(o)},.F.}) // Ajuste de registros existentes na SX5 (tabela Y3)
            If SW6->(FieldPos("W6_TIPOREG")) > 0
               aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033W(o)},.F.}) // Ajustes pontuais para DUIMP
            EndIf
         EndIf

         If cMode == '2' /* trocar o zero pelo '2' */ .And. cRelFinish >= "023"
            aAdd(oUpd:aChamados, {EIC,{|o| UPDEIC033Fil(o)},.F.})
         EndIf

         If cMode == '0'
            aAdd(oUpd:aChamados, {EIC,{|o| UPDEICSYO(o)},.F.})
         EndIf

         oUpd:Init(,lBlind)


      EndIf

   #ENDIF

Return

/* Módulo SIGAEEC */
Function RUP_EEC( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)

   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP 

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         //atualização de carga de dados, chamado do avgeral (ajustes de manutenção) ou do RUP
         If cMode == "0" //.Or. cMode == "2"

            aAdd(oUpd:aChamados,  {nModulo, {|o| cargaELO(o)}} )
            aAdd(oUpd:aChamados,  {nModulo, {|o| cargaEVN(o)}} )

            //MCF - 01/04/2016 - Atualização da carga padrão independente da versão
            //oUpd := AVUpdate01():New()
            //oUpd:aChamados := {{nModulo,{|o| EDadosEEA(o)}}}
            aAdd(oUpd:aChamados,  {nModulo,{|o| EDadosEEA(o)}} )
            oUpd:cTitulo := "Update para o modulo carga padrão da tabela EEA."
            //oUpd:Init(,.T.)

            //Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil
            //oUpd := AVUpdate01():New()
            //oUpd:aChamados := {{nModulo, {|o| ELinkDados(o)}}}
            aAdd(oUpd:aChamados,  {nModulo, {|o| ELinkDados(o)}} )
            oUpd:cTitulo := "Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil."
            //oUpd:Init(,.T.)

            aAdd(oUpd:aChamados,  {nModulo, {|o| cargaEC6(o)}} )
            oUpd:cTitulo := "Verifica a carga inicial da tabela EC6 quando a mesma estiver exclusiva no sistema"

            If ChkFile("EJ0") .And. ChkFile("EJ1") .And. ChkFile("EJ2")
               aAdd(oUpd:aChamados,  {nModulo, {|o| EEDadosEJ0(o)}} )
            EndIf

            aAdd(oUpd:aChamados,  {nModulo, {|o| CargEC6Adt(o)}} )   //NCF - 03/07/2019

         EndIf

         If cMode == "1" .And. cRelFinish >= "033"
            aAdd(oUpd:aChamados,{EEC,{|o|UPDEEC033(o)},.F.} )
         EndIf

         oUpd:Init(,lBlind) //não rodar o init depois do AtuDoc, se não a carga de dados vai matar as alteraçõs do AtduDoc
         //cMode 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa) - 0=Chamada do AvGeral
         // só maior que 027
         If cMode == "0" .And. EEA->(FieldPos("EEA_TIPMOD")) # 0 .And. cRelFinish > "027"
            //MFR 14/01/2021 OSSME-5547 -Desativa os documentos não utilizados a mais de 6 meses respeitando a lista
            //MFR 18/05/2021 OSSME-5554 DTRADE-6381 -Desativa os documentos tipo Fax quando houver um outro correspodente com o mesmo código do tipo Carta
            //Atualiza os campo tipo modelo padrao e modelo customizado conforme critérios no jira
            AtuDoc()
            // atualiza os documentos da versão a partir da 27 para utlizarem o modelo de impressão html
            // e apaga o campo arquivo e preenche o campo modelo com o novo aph a ser impresso
            AtuModeloAPH()
         EndIf
      EndIf
   #ENDIF

Return
/*
Função     : AtuModeloAPH()
Objetivo   : Atualizar os itens do array para uso do relatório em formato html
Autor      : MPG - Miguel Prado GOntijo
Data       : 04/06/2021
*/
Static Function AtuModeloAPH()
   Local aDocs := {}
   Local nx, nw

   aadd(aDocs,{{"chaveEEA", avkey("37","EEA_COD")+avkey("2-Documento","EEA_TIPDOC") },{"EEA_MODELO","FATING"},{"EEA_TIPMOD","1"},{"EEA_ARQUIV",""}})

   for nx := 1 to len(aDocs)
      IF EEA->(DBSEEK(xfilial("EEA") + aDocs[nx][1][2] ))
         for nw := 2 to len(aDocs[nx])
            EEA->(RecLock("EEA", .F.))
            EEA->&(aDocs[nx][nw][1]) := aDocs[nx][nw][2]
            EEA->(MsUnlock())
         next
      EndIf
   next

return
/*
Função     : AtuDoc()
Parâmetro  : Array com a lista dos documentos a serem considerados para desativação
Objetivo   : Atualizar para EEA_ATIVO=2 os documentos crystal sem utilização a mais de 6 meses conforme lista
Retorno    :
Autor      : MFR - Maurício Frison
Data       : 13/01/2021
*/
Static Function AtuDoc()
   Local cQryUpd
   Local cFilSYA := xFilial("SY0")
   Local cFilEEA := xFilial("EEA")
   Local dDataLimite := MonthSub(dDataBase,6)
   Local cTableEEA := RetSqlName("EEA")
   Local cTableSY0 := RetSqlName("SY0")
   Local cListArq := "(", cListNotIn := "("
   Local i:=0
   Local aListArq := {}
   Local cQryEEA


   aadd(aListArq,'34')
   aadd(aListArq,'10')
   aadd(aListArq,'17')
   aadd(aListArq,'7')
   aadd(aListArq,'19')
   aadd(aListArq,'22')
   aadd(aListArq,'21')
   aadd(aListArq,'55')
   aadd(aListArq,'18')
   aadd(aListArq,'15')
   aadd(aListArq,'6')
   aadd(aListArq,'27')
   aadd(aListArq,'11')
   aadd(aListArq,'9')
   aadd(aListArq,'8')
   aadd(aListArq,'4')
   aadd(aListArq,'33')
   aadd(aListArq,'30')
   aadd(aListArq,'29')
   aadd(aListArq,'93')
   aadd(aListArq,'F-001')
   aadd(aListArq,'12')
   aadd(aListArq,'31')
   aadd(aListArq,'32')
   aadd(aListArq,'68')
   aadd(aListArq,'97')
   aadd(aListArq,'A-119')
   aadd(aListArq,'23')
   aadd(aListArq,'67')
   aadd(aListArq,'69')
   aadd(aListArq,'74')
   aadd(aListArq,'99')
   aadd(aListArq,'A-115')
   aadd(aListArq,'25')
   aadd(aListArq,'A-116')
   aadd(aListArq,'A-130')
   aadd(aListArq,'A-118')
   aadd(aListArq,'A-117')
   aadd(aListArq,'73')
   aadd(aListArq,'75')
   aadd(aListArq,'A-131')
   aadd(aListArq,'A-132')
   aadd(aListArq,'A-108')
   aadd(aListArq,'A-109')
   aadd(aListArq,'A-136')
   aadd(aListArq,'A-135')
   aadd(aListArq,'80')
   aadd(aListArq,'A-101')
   aadd(aListArq,'A-104')
   aadd(aListArq,'40')
   aadd(aListArq,'A-110')
   aadd(aListArq,'A-102')
   aadd(aListArq,'A-106')
   aadd(aListArq,'79')
   aadd(aListArq,'81')
   aadd(aListArq,'77')
   aadd(aListArq,'A-100')
   aadd(aListArq,'A-105')
   aadd(aListArq,'39')
   aadd(aListArq,'A-111')
   aadd(aListArq,'A-103')
   aadd(aListArq,'A-107')
   aadd(aListArq,'76')
   aadd(aListArq,'78')
   aadd(aListArq,'96')
   aadd(aListArq,'71')
   aadd(aListArq,'98')
   aadd(aListArq,'A-113')
   aadd(aListArq,'16')
   aadd(aListArq,'A-112')
   aadd(aListArq,'A-133')
   aadd(aListArq,'A-114')
   aadd(aListArq,'70')
   aadd(aListArq,'72')
   aadd(aListArq,'A-134')
   aadd(aListArq,'24')
   aadd(aListArq,'5')

   //******************************************************************************************************
   //*
   //*                       Atenção não inverter a ordem da execução dessas operações
   //*  1o. Desativa os registros tipo Fax desde que tenha outro com mesmo código do tipo Carta
   //*  2O. Desativa os documentos não utilizados a mais de 6 meses respeitando a lista
   //*  3O. Atualiza os campos modelo padrao, modelo customizado e tipo modelo padrão conforme critérios no jira
   //******************************************************************************************************


   //1o. Desativa os registros tipo Fax desde que tenha outro com mesmo código do tipo Carta
   // script validado nos três bancos pelo query analyzer da Totvs
   cQryEEA := "SELECT EEA1.EEA_COD,EEA1.EEA_TIPDOC,EEA1.R_E_C_N_O_ FROM " + cTableEEA + " EEA1 WHERE EEA1.EEA_TIPDOC = '1-Fax' "
   cQryEEA += " AND EEA1.EEA_COD  = (SELECT EEA2.EEA_COD FROM " + cTableEEA + " EEA2 WHERE EEA2.EEA_COD=EEA1.EEA_COD AND EEA2.EEA_TIPDOC = '1-Carta' and D_E_L_E_T_ = ' ' and EEA1.EEA_FILIAL = EEA2.EEA_FILIAL) "
   cQryEEA += " AND EEA1.EEA_ATIVO <>'2' AND EEA1.D_E_L_E_T_ = ' ' "
   TcQuery cQryEEA Alias "TMPEEA" New

   TMPEEA->(DBGoTop())
   EEA->(DbSetOrder(1))
   While TMPEEA->(!Eof())
      IF EEA->(DBSEEK(cFilEEA + TMPEEA->EEA_COD + TMPEEA->EEA_TIPDOC))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_ATIVO := '2'
         EEA->(MsUnlock())
      EndIf
      TMPEEA->(DBSkip())
   Enddo

   TMPEEA->(DBCloseArea())

   //2o. Desativa os documentos não utilizados a mais de 6 meses respeitando a lista
   for i:=1 to len(aListArq)
      cListArq += "'" + aListArq[i] + "',"
   next

   cListArq := substr(cListArq,1,len(cListArq)-1)
   cListArq += ")"

   cQryEEA:= "SELECT Y0_CODRPT FROM " + cTableSY0
   cQryEEA += " WHERE D_E_L_E_T_ = ' ' AND Y0_FILIAL = '" + cFilSYA + "' AND Y0_DATA <= '" + dtos(dDataLimite) + "'"
   cQryEEA += " AND Y0_CODRPT IN" + cListArq
   cQryEEA:= ChangeQuery(cQryEEA)
   TcQuery cQryEEA Alias "TMPSY0" New
   TMPSY0->(DBGoTop())

   While TMPSY0->(!Eof())
      IF EEA->(DBSEEK(cFilSYA+TMPSY0->Y0_CODRPT))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_ATIVO := '2'
         EEA->(MsUnlock())
      EndIf
      TMPSY0->(DBSkip())
   EndDO
   TMPSY0->(DBCloseArea())

   cQryEEA := "SELECT DISTINCT Y0_CODRPT FROM " + cTableSY0 + " WHERE D_E_L_E_T_ = ' ' AND Y0_FILIAL = '" + cFilSYA + "'"
   cQryEEA:= ChangeQuery(cQryEEA)
   TcQuery cQryEEA Alias "TMPNOTIN" New
   TMPNOTIN->(DBGoTop())
   While TMPNOTIN->(!Eof())
      cListNotIn += "'" + RTRIM(TMPNOTIN->Y0_CODRPT) + "',"
      TMPNOTIN->(DBSkip())
   EndDo
   TMPNOTIN->(DBCloseArea())
   cListNotIn := substr(cListNotIn,1,len(cListNotIn)-1)
   cListNotIn += ")"

   if len(cListNotIn) > 1
      cQryUpd := "UPDATE " + cTableEEA + " SET EEA_ATIVO = '2' WHERE EEA_COD IN " + cListArq + " AND EEA_COD NOT IN " + cListNotIn
      if TCSQLEXEC(cQryUpd) < 0
         MsgInfo(TCSqlError(),"Erro na atualização do update na tabela EEA")
      EndIf
   EndIf

   // 3o. Atualiza os campos modelo padrao, modelo customizado e tipo modelo padrão conforme critérios no jira
   // script validado nos três bancos pelo query analyzer da Totvs
   // EEA_MODELO = Modelo padrão
   // EEA_ARQUIV = Modelo customizado
   cQryEEA := "SELECT EEA.EEA_COD, EEA.EEA_TIPDOC FROM " + cTableEEA + " EEA WHERE EEA.EEA_MODELO=' ' AND EEA.EEA_ARQUIV='AVGLTT.RPT' AND EEA.D_E_L_E_T_ = ' ' "

   TcQuery cQryEEA Alias "TMPEEAUPD" New

   TMPEEAUPD->(DBGoTop())

   While TMPEEAUPD->(!Eof())
      IF EEA->(DBSEEK(cFilEEA + TMPEEAUPD->EEA_COD + TMPEEAUPD->EEA_TIPDOC))
         EEA->(RecLock("EEA", .F.))
         EEA->EEA_MODELO := 'AVGLTT'
         EEA->EEA_ARQUIV = ''
         EEA->EEA_TIPMOD = '1'
         EEA->EEA_EDICAO = '1'
         EEA->(MsUnlock())
      EndIf
      TMPEEAUPD->(DBSkip())
   Enddo
   TMPEEAUPD->(DBCloseArea())

Return

Static Function cargaSJJ(o)
   Local aAuxSJJ := {}
   Local i

   aadd( aAuxSJJ , {'ANATEL'     ,'ANATEL - AGÊNCIA NACIONAL DE TELECOMUNICAÇÕES'                                      , "2" } )
   aadd( aAuxSJJ , {'ANCINE'     ,'ANCINE - AGENCIA NACIONAL DO CINEMA'                                                , "2" } )
   aadd( aAuxSJJ , {'ANEEL'      ,'ANEEL - AGENCIA NACIONAL DE ENERGIA ELETRICA'                                       , "2" } )
   aadd( aAuxSJJ , {'ANP'        ,'ANP - AGENCIA NACIONAL DO PETROLEO'                                                 , "2" } )
   aadd( aAuxSJJ , {'ANVISA'     ,'ANVISA - AGENCIA NACIONAL DE VIGILANCIA SANITARIA'                                  , "2" } )
   aadd( aAuxSJJ , {'BB'         ,'BB - BANCO DO BRASIL'                                                               , "2" } )
   aadd( aAuxSJJ , {'BEFIEX'     ,'PROGRAMAS BEFIEX'                                                                   , "2" } )
   aadd( aAuxSJJ , {'BNDES'      ,'BNDES - BANCO NACIONAL DE DESENVOLVIMENTO ECONÔMICO E SOCIAL'                       , "2" } )
   aadd( aAuxSJJ , {'CNEN'       ,'CNEN - COMISSAO NACIONAL DE ENERGIA NUCLEAR'                                        , "2" } )
   aadd( aAuxSJJ , {'CNPQ'       ,'CNPQ - CONSELHO NACIONAL DE DESENVOLVIMENTO CIENTIFICO E TECNOLOGICO'               , "2" } )
   aadd( aAuxSJJ , {'CONFAZ'     ,'CONFAZ - CONSELHO NACIONAL DE POLITICA FAZENDARIA/SECRETARIAS DE FAZENDA ESTADUAIS' , "2" } )
   aadd( aAuxSJJ , {'COTAC'      ,'MIN.AERON. - COMISSAO COORDENADORA DO TRANSPORTE AEREO CIVIL'                       , "2" } )
   aadd( aAuxSJJ , {'DEAEX'      ,'DEAEX - DEPARTAMENTO DE ESTATISTICA E APOIO A EXPORTACAO'                           , "2" } )
   aadd( aAuxSJJ , {'DECEX'      ,'DECEX - DEPARTAMENTO DE OPERACOES DE COMERCIO EXTERIOR'                             , "2" } )
   aadd( aAuxSJJ , {'DEPLA'      ,'DEPARTAMENTO DE PLANEJAMENTO E DESENVOLVIMENTO DO COMERCIO EXTERIOR'                , "2" } )
   aadd( aAuxSJJ , {'DFPC'       ,'DFPC - DIRETORIA DE FISCALIZACAO DE PRODUTOS CONTROLADOS-COMANDO DO EXERCITO'       , "2" } )
   aadd( aAuxSJJ , {'DNPM'       ,'DNPM - DEPARTAMENTO NACIONAL DE PRODUCAO MINERAL'                                   , "2" } )
   aadd( aAuxSJJ , {'DPF'        ,'DPF - DEPARTAMENTO DE POLICIA FEDERAL'                                              , "2" } )
   aadd( aAuxSJJ , {'ECT'        ,'ECT - EMPRESA BRASILEIRA DE CORREIOS E TELEGRAFOS'                                  , "2" } )
   aadd( aAuxSJJ , {'GESTOR'     ,'MICT/DECEX/GESTOR'                                                                  , "2" } )
   aadd( aAuxSJJ , {'IBAMA'      ,'IBAMA - INSTITUTO BRASILEIRO DO MEIO AMBIENTE E DOS RECURSOS NATURAIS RENOVAVEIS'   , "2" } )
   aadd( aAuxSJJ , {'INMETRO'    ,'INMETRO - INSTITUTO NACIONAL DE METROLOGIA'                                         , "2" } )
   aadd( aAuxSJJ , {'IPHAN'      ,'IPHAN - INSTITUTO DO PATRIMÔNIO HISTÓRICO E ARTÍSTICO NACIONAL'                     , "2" } )
   aadd( aAuxSJJ , {'MAPA'       ,'MAPA - MINISTERIO DA AGRICULTURA,PECUARIA E ABASTECIMENTO'                          , "2" } )
   aadd( aAuxSJJ , {'MCT'        ,'MCTI - MINISTERIO DA CIENCIA, TECNOLOGIA E INOVACAO'                                , "2" } )
   aadd( aAuxSJJ , {'MIN.DEFESA' ,'MD - MINISTERIO DA DEFESA'                                                          , "2" } )
   aadd( aAuxSJJ , {'MRE'        ,'MRE - MINISTÉRIO DAS RELAÇÕES EXTERIORES'                                           , "2" } )
   aadd( aAuxSJJ , {'RECEITA'    ,'RFB - RECEITA FEDERAL DO BRASIL'                                                    , "2" } )
   aadd( aAuxSJJ , {'SDAVO'      ,'AUDIOVISUAL'                                                                        , "2" } )
   aadd( aAuxSJJ , {'SECEX'      ,'SECEX - SECRETARIA DE COMERCIO EXTERIOR'                                            , "2" } )
   aadd( aAuxSJJ , {'SEPIN'      ,'MIN.DA CIENCIA E TECNOLOGIA-SEC.DE POLIT. INFORM.E AUTOMACAO'                       , "2" } )
   aadd( aAuxSJJ , {'SPC-MA'     ,'MA - SECRETARIA DE PRODUCAO E COMERCIALIZACAO'                                      , "2" } )
   aadd( aAuxSJJ , {'SUFRAMA'    ,'SUFRAMA - SUPERINTENDENCIA DA ZONA FRANCA DE MANAUS'                                , "2" } )

   SJJ->(dbgotop())
   while SJJ->(!EOF())
      if ascan( aAuxSJJ, {|x| alltrim(upper(x[1])) == alltrim(SJJ->JJ_CODIGO) } ) == 0
         o:TableStruct("SJJ",{"JJ_CODIGO" , "JJ_MSBLQL" },1)
         o:TableData( 'SJJ',{ SJJ->JJ_CODIGO,'1'})
      endif
      SJJ->(dbskip())
   enddo

   for i := 1 to len(aAuxSJJ)
      o:TableStruct("SJJ",{"JJ_CODIGO" ,"JJ_DESC" , "JJ_MSBLQL" },1)
      o:TableData( 'SJJ',{ aAuxSJJ[i][1], aAuxSJJ[i][2], aAuxSJJ[i][3] })
   next

Return

Static Function cargaELO(o)

   //NCF - 30/05/2017 - Declaração Única de Exportação (anexar outras atualizações para este release acima no fonte)
   If AvFlags("DU-E") .And. !ELO->(DBSeek(xFilial() + "AD"))

      o:TableStruct("ELO",{"ELO_COD" ,"ELO_DESC"  },1)
      o:TableData( 'ELO',{ 'AD','ANDORRA'})
      o:TableData( 'ELO',{ 'AE','UNITED ARAB EMIRATES'})
      o:TableData( 'ELO',{ 'AF','AFGHANISTAN'})
      o:TableData( 'ELO',{ 'AG','ANTIGA AND BARBUDA'})
      o:TableData( 'ELO',{ 'AI','ANGUILLA'})
      o:TableData( 'ELO',{ 'AL','ALBANIA'})
      o:TableData( 'ELO',{ 'AM','ARMENIA'})
      o:TableData( 'ELO',{ 'AN','NETHERLANDS ANTILLES'})
      o:TableData( 'ELO',{ 'AO','ANGOLA'})
      o:TableData( 'ELO',{ 'AQ','ANTARCTICA'})
      o:TableData( 'ELO',{ 'AR','ARGENTINA'})
      o:TableData( 'ELO',{ 'AS','AMERICAN SAMOA'})
      o:TableData( 'ELO',{ 'AT','AUSTRIA'})
      o:TableData( 'ELO',{ 'AU','AUSTRALIA'})
      o:TableData( 'ELO',{ 'AW','ARUBA'})
      o:TableData( 'ELO',{ 'AX','ÅLAND ISLANDS'})
      o:TableData( 'ELO',{ 'AZ','AZERBAIJAN'})
      o:TableData( 'ELO',{ 'BA','BOSNIA AND HERZEGOVINA'})
      o:TableData( 'ELO',{ 'BB','BARBADOS'})
      o:TableData( 'ELO',{ 'BD','BANGLADESH'})
      o:TableData( 'ELO',{ 'BE','BELGIUM'})
      o:TableData( 'ELO',{ 'BF','BURKINA FASO'})
      o:TableData( 'ELO',{ 'BG','BULGARIA'})
      o:TableData( 'ELO',{ 'BH','BAHRAIN'})
      o:TableData( 'ELO',{ 'BI','BURUNDI'})
      o:TableData( 'ELO',{ 'BJ','BENIN'})
      o:TableData( 'ELO',{ 'BL','SAINT BARTH'})
      o:TableData( 'ELO',{ 'BM','BERMUDA'})
      o:TableData( 'ELO',{ 'BN','BRUNEI DARUSSALAM'})
      o:TableData( 'ELO',{ 'BO','BOLIVIA'})
      o:TableData( 'ELO',{ 'BQ','BONAIRE, SINT EUSTATIUS AND SABA'})
      o:TableData( 'ELO',{ 'BR','BRAZIL'})
      o:TableData( 'ELO',{ 'BS','BAHAMAS'})
      o:TableData( 'ELO',{ 'BT','BHUTAN'})
      o:TableData( 'ELO',{ 'BV','BOUVET ISLAND'})
      o:TableData( 'ELO',{ 'BW','BOTSWANA'})
      o:TableData( 'ELO',{ 'BY','BELARUS'})
      o:TableData( 'ELO',{ 'BZ','BELIZE'})
      o:TableData( 'ELO',{ 'CA','CANADA'})
      o:TableData( 'ELO',{ 'CC','COCOS {KEELING) ISLANDS'})
      o:TableData( 'ELO',{ 'CD','CONGO, THE DEMOCRATIC REPUBLIC OF THE'})
      o:TableData( 'ELO',{ 'CF','CENTRAL AFRICAN REPUBLIC'})
      o:TableData( 'ELO',{ 'CG','CONGO'})
      o:TableData( 'ELO',{ 'CH','SWITZERLAND'})
      o:TableData( 'ELO',{ 'CI',"CÈTE D'IVOIRE"})
      o:TableData( 'ELO',{ 'CK','COOK ISLANDS'})
      o:TableData( 'ELO',{ 'CL','CHILE'})
      o:TableData( 'ELO',{ 'CM','CAMEROON'})
      o:TableData( 'ELO',{ 'CN','CHINA'})
      o:TableData( 'ELO',{ 'CO','COLOMBIA'})
      o:TableData( 'ELO',{ 'CR','COSTA RICA'})
      o:TableData( 'ELO',{ 'CS','SERBIA AND MONTENEGRO'})
      o:TableData( 'ELO',{ 'CU','CUBA'})
      o:TableData( 'ELO',{ 'CV','CAPE VERDE'})
      o:TableData( 'ELO',{ 'CX','CHRISTMAS ISLAND'})
      o:TableData( 'ELO',{ 'CW','CURAÇAO'})
      o:TableData( 'ELO',{ 'CY','CYPRUS'})
      o:TableData( 'ELO',{ 'CZ','CZECH REPUBLIC'})
      o:TableData( 'ELO',{ 'DE','GERMANY'})
      o:TableData( 'ELO',{ 'DJ','DJIBOUTI'})
      o:TableData( 'ELO',{ 'DK','DENMARK'})
      o:TableData( 'ELO',{ 'DM','DOMINICA'})
      o:TableData( 'ELO',{ 'DO','DOMINICAN REPUBLIC'})
      o:TableData( 'ELO',{ 'DZ','ALGERIA'})
      o:TableData( 'ELO',{ 'EC','ECUADOR'})
      o:TableData( 'ELO',{ 'EE','ESTONIA'})
      o:TableData( 'ELO',{ 'EG','EGYPT'})
      o:TableData( 'ELO',{ 'EH','WESTERN SAHARA'})
      o:TableData( 'ELO',{ 'ER','ERITREA'})
      o:TableData( 'ELO',{ 'ES','SPAIN'})
      o:TableData( 'ELO',{ 'ET','ETHIOPIA'})
      o:TableData( 'ELO',{ 'FI','FINLAND'})
      o:TableData( 'ELO',{ 'FJ','FIJI'})
      o:TableData( 'ELO',{ 'FK','FALKLAND ISLANDS {MALVINAS)'})
      o:TableData( 'ELO',{ 'FM','MICRONESIA, FEDERATED STATES OF'})
      o:TableData( 'ELO',{ 'FO','FAROE ISLANDS'})
      o:TableData( 'ELO',{ 'FR','FRANCE'})
      o:TableData( 'ELO',{ 'GA','GABON'})
      o:TableData( 'ELO',{ 'GB','UNITED KINGDOM'})
      o:TableData( 'ELO',{ 'GD','GRENADA'})
      o:TableData( 'ELO',{ 'GE','GEORGIA'})
      o:TableData( 'ELO',{ 'GF','FRENCH GUIANA'})
      o:TableData( 'ELO',{ 'GG','GUERNSEY'})
      o:TableData( 'ELO',{ 'GH','GHANA'})
      o:TableData( 'ELO',{ 'GI','GIBRALTAR'})
      o:TableData( 'ELO',{ 'GL','GREENLAND'})
      o:TableData( 'ELO',{ 'GM','GAMBIA'})
      o:TableData( 'ELO',{ 'GN','GUINEA'})
      o:TableData( 'ELO',{ 'GP','GUADELOUPE'})
      o:TableData( 'ELO',{ 'GQ','EQUATORIAL GUINEA'})
      o:TableData( 'ELO',{ 'GR','GREECE'})
      o:TableData( 'ELO',{ 'GS','SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS'})
      o:TableData( 'ELO',{ 'GT','GUATEMALA'})
      o:TableData( 'ELO',{ 'GU','GUAM'})
      o:TableData( 'ELO',{ 'GW','GUINEA-BISSAU'})
      o:TableData( 'ELO',{ 'GY','GUYANA'})
      o:TableData( 'ELO',{ 'HK','HONG KONG'})
      o:TableData( 'ELO',{ 'HM','HEARD ISLAND AND MCDONALD ISLANDS'})
      o:TableData( 'ELO',{ 'HN','HONDURAS'})
      o:TableData( 'ELO',{ 'HR','CROATIA'})
      o:TableData( 'ELO',{ 'HT','HAITI'})
      o:TableData( 'ELO',{ 'HU','HUNGARY'})
      o:TableData( 'ELO',{ 'ID','INDONESIA'})
      o:TableData( 'ELO',{ 'IE','IRELAND'})
      o:TableData( 'ELO',{ 'IL','ISRAEL'})
      o:TableData( 'ELO',{ 'IM','ISLE OF MAN'})
      o:TableData( 'ELO',{ 'IN','INDIA'})
      o:TableData( 'ELO',{ 'IO','BRITISH INDIAN OCEAN TERRITORY'})
      o:TableData( 'ELO',{ 'IQ','IRAQ'})
      o:TableData( 'ELO',{ 'IR','IRAN, ISLAMIC REPUBLIC OF'})
      o:TableData( 'ELO',{ 'IS','ICELAND'})
      o:TableData( 'ELO',{ 'IT','ITALY'})
      o:TableData( 'ELO',{ 'JE','JERSEY'})
      o:TableData( 'ELO',{ 'JM','JAMAICA'})
      o:TableData( 'ELO',{ 'JO','JORDAN'})
      o:TableData( 'ELO',{ 'JP','JAPAN'})
      o:TableData( 'ELO',{ 'KE','KENYA'})
      o:TableData( 'ELO',{ 'KG','KYRGYZSTAN'})
      o:TableData( 'ELO',{ 'KH','CAMBODIA'})
      o:TableData( 'ELO',{ 'KI','KIRIBATI'})
      o:TableData( 'ELO',{ 'KM','COMOROS'})
      o:TableData( 'ELO',{ 'KN','SAINT KITTS AND NEVIS'})
      o:TableData( 'ELO',{ 'KP',"KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF"})
      o:TableData( 'ELO',{ 'KR','KOREA, REPUBLIC OF'})
      o:TableData( 'ELO',{ 'KW','KUWAIT'})
      o:TableData( 'ELO',{ 'KY','CAYMAN ISLANDS'})
      o:TableData( 'ELO',{ 'KZ','KAZAKHSTAN'})
      o:TableData( 'ELO',{ 'LA',"LAO PEOPLE'S DEMOCRATIC REPUBLIC"})
      o:TableData( 'ELO',{ 'LB','LEBANON'})
      o:TableData( 'ELO',{ 'LC','SAINT LUCIA'})
      o:TableData( 'ELO',{ 'LI','LIECHTENSTEIN'})
      o:TableData( 'ELO',{ 'LK','SRI LANKA'})
      o:TableData( 'ELO',{ 'LR','LIBERIA'})
      o:TableData( 'ELO',{ 'LS','LESOTHO'})
      o:TableData( 'ELO',{ 'LT','LITHUANIA'})
      o:TableData( 'ELO',{ 'LU','LUXEMBOURG'})
      o:TableData( 'ELO',{ 'LV','LATVIA'})
      o:TableData( 'ELO',{ 'LY','LIBYAN ARAB JAMAHIRIYA'})
      o:TableData( 'ELO',{ 'MA','MOROCCO'})
      o:TableData( 'ELO',{ 'MC','MONACO'})
      o:TableData( 'ELO',{ 'MD','MOLDOVA, REPUBLIC OF'})
      o:TableData( 'ELO',{ 'ME','MONTENEGRO'})
      o:TableData( 'ELO',{ 'MF','SAINT MARTIN'})
      o:TableData( 'ELO',{ 'MG','MADAGASCAR'})
      o:TableData( 'ELO',{ 'MH','MARSHALL ISLANDS'})
      o:TableData( 'ELO',{ 'MK','MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF'})
      o:TableData( 'ELO',{ 'ML','MALI'})
      o:TableData( 'ELO',{ 'MM','MYANMAR'})
      o:TableData( 'ELO',{ 'MN','MONGOLIA'})
      o:TableData( 'ELO',{ 'MO','MACAO'})
      o:TableData( 'ELO',{ 'MP','NORTHERN MARIANA ISLANDS'})
      o:TableData( 'ELO',{ 'MQ','MARTINIQUE'})
      o:TableData( 'ELO',{ 'MR','MAURITANIA'})
      o:TableData( 'ELO',{ 'MS','MONTSERRAT'})
      o:TableData( 'ELO',{ 'MT','MALTA'})
      o:TableData( 'ELO',{ 'MU','MAURITIUS'})
      o:TableData( 'ELO',{ 'MV','MALDIVES'})
      o:TableData( 'ELO',{ 'MW','MALAWI'})
      o:TableData( 'ELO',{ 'MX','MEXICO'})
      o:TableData( 'ELO',{ 'MY','MALAYSIA'})
      o:TableData( 'ELO',{ 'MZ','MOZAMBIQUE'})
      o:TableData( 'ELO',{ 'NA','NAMIBIA'})
      o:TableData( 'ELO',{ 'NC','NEW CALEDONIA'})
      o:TableData( 'ELO',{ 'NE','NIGER'})
      o:TableData( 'ELO',{ 'NF','NORFOLK ISLAND'})
      o:TableData( 'ELO',{ 'NG','NIGERIA'})
      o:TableData( 'ELO',{ 'NI','NICARAGUA'})
      o:TableData( 'ELO',{ 'NL','NETHERLANDS'})
      o:TableData( 'ELO',{ 'NO','NORWAY'})
      o:TableData( 'ELO',{ 'NP','NEPAL'})
      o:TableData( 'ELO',{ 'NR','NAURU'})
      o:TableData( 'ELO',{ 'NU','NIUE'})
      o:TableData( 'ELO',{ 'NZ','NEW ZEALAND'})
      o:TableData( 'ELO',{ 'OM','OMAN'})
      o:TableData( 'ELO',{ 'PA','PANAMA'})
      o:TableData( 'ELO',{ 'PE','PERU'})
      o:TableData( 'ELO',{ 'PF','FRENCH POLYNESIA'})
      o:TableData( 'ELO',{ 'PG','PAPUA NEW GUINEA'})
      o:TableData( 'ELO',{ 'PH','PHILIPPINES'})
      o:TableData( 'ELO',{ 'PK','PAKISTAN'})
      o:TableData( 'ELO',{ 'PL','POLAND'})
      o:TableData( 'ELO',{ 'PM','SAINT PIERRE AND MIQUELON'})
      o:TableData( 'ELO',{ 'PN','PITCAIRN'})
      o:TableData( 'ELO',{ 'PR','PUERTO RICO'})
      o:TableData( 'ELO',{ 'PS','PALESTINE'})
      o:TableData( 'ELO',{ 'PT','PORTUGAL'})
      o:TableData( 'ELO',{ 'PW','PALAU'})
      o:TableData( 'ELO',{ 'PY','PARAGUAY'})
      o:TableData( 'ELO',{ 'QA','QATAR'})
      o:TableData( 'ELO',{ 'RE','R UNION'})
      o:TableData( 'ELO',{ 'RO','ROMANIA'})
      o:TableData( 'ELO',{ 'RS','SERBIA'})
      o:TableData( 'ELO',{ 'RU','RUSSIAN FEDERATION'})
      o:TableData( 'ELO',{ 'RW','RWANDA'})
      o:TableData( 'ELO',{ 'SA','SAUDI ARABIA'})
      o:TableData( 'ELO',{ 'SB','SOLOMON ISLANDS'})
      o:TableData( 'ELO',{ 'SC','SEYCHELLES'})
      o:TableData( 'ELO',{ 'SD','SUDAN'})
      o:TableData( 'ELO',{ 'SE','SWEDEN'})
      o:TableData( 'ELO',{ 'SG','SINGAPORE'})
      o:TableData( 'ELO',{ 'SH','SAINT HELENA'})
      o:TableData( 'ELO',{ 'SI','SLOVENIA'})
      o:TableData( 'ELO',{ 'SJ','SVALBARD AND JAN MAYEN'})
      o:TableData( 'ELO',{ 'SK','SLOVAKIA'})
      o:TableData( 'ELO',{ 'SL','SIERRA LEONE'})
      o:TableData( 'ELO',{ 'SM','SAN MARINO'})
      o:TableData( 'ELO',{ 'SN','SENEGAL'})
      o:TableData( 'ELO',{ 'SO','SOMALIA'})
      o:TableData( 'ELO',{ 'SR','SURINAME'})
      o:TableData( 'ELO',{ 'SS','SOUTH SUDAN'})
      o:TableData( 'ELO',{ 'ST','SAO TOME AND PRINCIPE'})
      o:TableData( 'ELO',{ 'SV','EL SALVADOR'})
      o:TableData( 'ELO',{ 'SX','SINT MAARTEN'})
      o:TableData( 'ELO',{ 'SY','SYRIAN ARAB REPUBLIC'})
      o:TableData( 'ELO',{ 'SZ','SWAZILAND'})
      o:TableData( 'ELO',{ 'TC','TURKS AND CAICOS ISLANDS'})
      o:TableData( 'ELO',{ 'TD','CHAD'})
      o:TableData( 'ELO',{ 'TG','TOGO'})
      o:TableData( 'ELO',{ 'TH','THAILAND'})
      o:TableData( 'ELO',{ 'TJ','TAJIKISTAN'})
      o:TableData( 'ELO',{ 'TK','TOKELAU'})
      o:TableData( 'ELO',{ 'TL','TIMOR-LESTE'})
      o:TableData( 'ELO',{ 'TM','TURKMENISTAN'})
      o:TableData( 'ELO',{ 'TN','TUNISIA'})
      o:TableData( 'ELO',{ 'TO','TONGA'})
      o:TableData( 'ELO',{ 'TR','TURKEY'})
      o:TableData( 'ELO',{ 'TT','TRINIDAD AND TOBAGO'})
      o:TableData( 'ELO',{ 'TV','TUVALU'})
      o:TableData( 'ELO',{ 'TW','TAIWAN, PROVINCE OF CHINA'})
      o:TableData( 'ELO',{ 'TZ','TANZANIA, UNITED REPUBLIC OF'})
      o:TableData( 'ELO',{ 'UA','UKRAINE'})
      o:TableData( 'ELO',{ 'UG','UGANDA'})
      o:TableData( 'ELO',{ 'UM','UNITED STATES MINOR OUTLYING ISLANDS'})
      o:TableData( 'ELO',{ 'US','UNITED STATES'})
      o:TableData( 'ELO',{ 'UY','URUGUAY'})
      o:TableData( 'ELO',{ 'UZ','UZBEKISTAN'})
      o:TableData( 'ELO',{ 'VA','HOLY SEE {VATICAN CITY STATE)'})
      o:TableData( 'ELO',{ 'VC','SAINT VINCENT AND THE GRENADINES'})
      o:TableData( 'ELO',{ 'VE','VENEZUELA'})
      o:TableData( 'ELO',{ 'VG','VIRGIN ISLANDS, BRITISH'})
      o:TableData( 'ELO',{ 'VI','VIRGIN ISLANDS, US'})
      o:TableData( 'ELO',{ 'VN','VIET NAM'})
      o:TableData( 'ELO',{ 'VU','VANUATU'})
      o:TableData( 'ELO',{ 'WF','WALLIS AND FUTUNA'})
      o:TableData( 'ELO',{ 'WS','SAMOA'})
      o:TableData( 'ELO',{ 'XZ','INSTALLATIONS IN INTERNATIONAL WATERS'})
      o:TableData( 'ELO',{ 'YE','YEMEN'})
      o:TableData( 'ELO',{ 'YT','MAYOTTE'})
      o:TableData( 'ELO',{ 'ZA','SOUTH AFRICA'})
      o:TableData( 'ELO',{ 'ZM','ZAMBIA'})
      o:TableData( 'ELO',{ 'ZW','ZIMBABWE'})
      o:TableData( 'ELO',{ 'TF','FRENCH SOUTHERN TERRITORIES'})

   EndIf

Return

Static Function cargaEVN(o)

   /*WHRS TE-6464 542022 - MTRADE-1806 - Ajustes nos dados do XML da DUE*/
   If AvFlags("DU-E2") .And. !EVN->(DBSeek(xFilial() + "1001" +"CUS"))

      o:TableStruct("EVN",{"EVN_CODIGO","EVN_GRUPO","EVN_DESCRI"},1)
      o:TableData( 'EVN',{ '1001'      ,'CUS'      ,'Por conta própria'})
      o:TableData( 'EVN',{ '1002'      ,'CUS'      ,'Por conta e ordem de terceiros'})
      o:TableData( 'EVN',{ '1003'      ,'CUS'      ,'Por operador de remessa postal ou expressa'})
      o:TableData( 'EVN',{ '2001'      ,'AHZ'      ,'DU-E a posteriori'})
      o:TableData( 'EVN',{ '2002'      ,'AHZ'      ,'Embarque antecipado'})
      o:TableData( 'EVN',{ '2003'      ,'AHZ'      ,'Exportação sem saída da mercadoria do país'})
      o:TableData( 'EVN',{ '4001'      ,'TRA'      ,'Meios próprios ou por reboque'})
      o:TableData( 'EVN',{ '4002'      ,'TRA'      ,'Dutos'})
      o:TableData( 'EVN',{ '4003'      ,'TRA'      ,'Linhas de transmissão'})
      o:TableData( 'EVN',{ '4004'      ,'TRA'      ,'Em mãos'})
      o:TableData( 'EVN',{ '3001'      ,'ACG'      ,'Bagagem desacompanhada'})
      o:TableData( 'EVN',{ '3002'      ,'ACG'      ,'Bens de viajante não incluídos no conceito de bagagem'})
      o:TableData( 'EVN',{ '3003'      ,'ACG'      ,'Retorno de mercadoria ao exterior antes do registro da DI'})
      o:TableData( 'EVN',{ '3004'      ,'ACG'      ,'Embarque antecipado'})
      o:TableData( 'EVN',{ '5001'      ,'PRI'      ,'Carga viva'})
      o:TableData( 'EVN',{ '5002'      ,'PRI'      ,'Carga perecível'})
      o:TableData( 'EVN',{ '5003'      ,'PRI'      ,'Carga perigosa'})
      o:TableData( 'EVN',{ '5006'      ,'PRI'      ,'Partes/peças de aeronave'})

   EndIf

Return

Static Function cargaEC6(o)
   /* RMD - 08/12/17 - Melhoria de performance (mover para o RUP)
   */
   //RMD - Verifica a carga inicial da tabela EC6 quando a mesma estiver exclusiva no sistema

   Local nInc

   cAlias := "EC6"
   ChkFile(cAlias)
   If Select(cAlias) > 0
      (cAlias)->(DbSetOrder(1))
      If !(cAlias)->(DbSeek(xFilial()))
         If xFilial(cAlias) <> Space(FWSizeFilial()) .And. (cAlias)->(DbSeek(Space(FWSizeFilial())))
            While (cAlias)->EC6_FILIAL == Space(FWSizeFilial())
               nPos := (cAlias)->(Recno())
               For nInc := 1 TO (cAlias)->(FCount())
                  M->&((cAlias)->(FIELDNAME(nInc))) := (cAlias)->(FieldGet(nInc))
               Next nInc
               M->EC6_FILIAL := xFilial(cAlias)
               (cAlias)->(RecLock(cAlias, .T.))
               AvReplace("M", cAlias)
               (cAlias)->(MsUnlock())
               (cAlias)->(DbGoTo(nPos))
               (cAlias)->(DbSkip())
            EndDo
         EndIf
      EndIf
   EndIf

Return

Static Function EEDadosEJ0(o)

   Begin Sequence

      o:TableStruct('EJ0',{'EJ0_FILIAL','EJ0_COD','EJ0_DESC'                            ,'EJ0_ENTR','EJ0_CHITEM','EJ0_TIPO','EJ0_CONSLD','EJ0_CHUSLD','EJ0_RE','EJ0_ADICAO','EJ0_CRITER','EJ0_MNTOBX'                                         ,'EJ0_CONDBX'          ,'EJ0_VALID'},1)
      o:TableData("EJ0",{"  ","01","Admissão Temporária de Embalagem","SW3",""          ,"E"       ,"2"         ,""          ,"1"     ,"1"         ,""          ,"BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT","                    ","                    "},,.F.) //STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{"  ","01","Admissão Temporária de Embalagem","SW5","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.)//STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{"  ","01","Admissão Temporária de Embalagem","SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","E","1","EJ3_DI+EJ3_ADICAO+ EJ3_COD_I                                                                                                                                                                            ","1","1","                    ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)//STR0199 "Admissão Temporária de Embalagem   "
      o:TableData("EJ0",{"  ","02","Reexportação de embalagem admitida temporariamente","EE8","xFilial('EE8')+#EE8#->EE8_PEDIDO+#EE8#->EE8_SEQUEN+#EE8#->EE8_COD_I                                                                                                                                     ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.)//STR0200 "Reexportação de embalagem admitida temporariamente"
      o:TableData("EJ0",{"  ","02","Reexportação de embalagem admitida temporariamente","EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)//STR0200 "Reexportação de embalagem admitida temporariamente"
      o:TableData("EJ0",{"  ","03",If( cPaisLoc $ "ANG|PTG", "Exportação temporária de embalagem", "Exportação Temporária de Embalagem" ),"EE8","                                                                                                                                                                                                        ","E","2","                                                                                                                                                                                                        ","1","1","                    ","BTN_IT_EE8|BTN_EXC_PED                                                                              ","                    ","                    "},,.F.)//STR0201 "Exportação Temporária de Embalagem"
      o:TableData("EJ0",{"  ","03",If( cPaisLoc $ "ANG|PTG", "Exportação temporária de embalagem", "Exportação Temporária de Embalagem" ),"EE9","xFilial('EE9')+#EEC#->EEC_PREEMB+#EE9#->EE9_SEQEMB                                                                                                                                                      ","E","1","EJ3_PREEMB+EJ3_COD_I                                                                                                                                                                                        ","1","1","                    ","EXC_EMB|DESMARC_IT|MARC_ITS_EMB                                                                     ","                    ","VldGrvCtrlEmb       "},,.F.)//STR0201 "Exportação Temporária de Embalagem"
      o:TableData("EJ0",{"  ","04","Reimportação de embalagem admitida temporariamente","SW3","xFilial('SW3')+#SW3#->W3_PO_NUM+#SW3#->W3_POSICAO                                                                                                                                                       ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_TDS_ITS_PO|DESMARCA_IT_PO|MK_IT_PO|BTN_MK_IT                                                 ","                    ","                    "},,.F.) //STR0202 "Reimportação de embalagem admitida temporariamente          "
      o:TableData("EJ0",{"  ","04","Reimportação de embalagem admitida temporariamente","SW5","                                                                                                                                                                                                        ","S","2","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","BTN_MK_IT_PLI|DESMARCA_IT_PLI|MARCATODOS_ITS_PLI|MARCA_ITS_PLI                                      ","                    ","                    "},,.F.) //STR0202 "Reimportação de embalagem admitida temporariamente          "
      o:TableData("EJ0",{"  ","04","Reimportação de embalagem admitida temporariamente","SW8","xFilial('SW8')+#SW6#->W6_HAWB+#SW9#->W9_INVOICE+#SW8#->W8_PO_NUM+#SW8#->W8_POSICAO+#SW8#->W8_PGI_NUM                                                                                                    ","S","1","                                                                                                                                                                                                        ","1","1","EASYFIFO            ","MARC_TDS_EST|BTN_PRINC_EMB|MARC_IT_EST|MARC_EST_IV                                                  ","CondGrvCtrlEmb      ","VldGrvCtrlEmb       "},,.F.)//STR0202 "Reimportação de embalagem admitida temporariamente          "

      o:TableStruct('EJ1',{'EJ1_FILIAL','EJ1_CODE','EJ1_ENTR','EJ1_CODS','EJ1_SAIDA'},1)
      o:TableData('EJ1',{xFilial("EJ1"),'01','SW8','02','EE8'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'01','SW8','02','EE9'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'03','EE9','04','SW3'},,.F.)
      o:TableData('EJ1',{xFilial("EJ1"),'03','EE9','04','SW8'},,.F.)

      o:TableStruct('EJ2',{'EJ2_FILIAL','EJ2_CODE','EJ2_ENTR','EJ2_DE'          ,'EJ2_PARA'},1)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_DI_NUM","EJ3_DI"  },,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_DTREG_D","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8",'BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja("#SW8#", "W8_FABLOJ"), EICRetLoja("#SW8#", "W8_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"01","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_PSLQUN * #EE8#->EE8_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","#EE8#->EE8_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE8","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","IIf( EEC->(FieldPos('EEC_NRODUE')) == 0 .Or. !Empty(#EE9#->EE9_RE), #EE9#->EE9_RE , #EEC#->EEC_NRODUE )                                                                                                  ","EJ3_RE                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","IIf( EEC->(FieldPos('EEC_DTDUE')) > 0 .And. !Empty(#EEC#->EEC_DTDUE), #EEC#->EEC_DTDUE, IIF(Empty(#EE9#->EE9_DTRE),IIF(Empty(#EEC#->EEC_DTEMBA),#EEC#->EEC_DTPROC,#EEC#->EEC_DTEMBA),#EE9#->EE9_DTRE))  ","EJ3_DATA                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"02","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_UNIDAD                                                                                                                                                                                       ","EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SLDINI                                                                                                                                                                                       ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_COD_I                                                                                                                                                                                        ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","IIf( EEC->(FieldPos('EEC_NRODUE')) == 0 .Or. !Empty(#EE9#->EE9_RE), #EE9#->EE9_RE , #EEC#->EEC_NRODUE )                                                                                                  ","EJ3_RE                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","IIf( EEC->(FieldPos('EEC_DTDUE')) > 0 .And. !Empty(#EEC#->EEC_DTDUE), #EEC#->EEC_DTDUE, IIF(Empty(#EE9#->EE9_DTRE),IIF(Empty(#EEC#->EEC_DTEMBA),#EEC#->EEC_DTPROC,#EEC#->EEC_DTEMBA),#EE9#->EE9_DTRE))          ","EJ3_DATA                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EEC#->EEC_PREEMB                                                                                                                                                                                       ","EJ3_PREEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SEQEMB                                                                                                                                                                                       ","EJ3_SEQEMB                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_PEDIDO                                                                                                                                                                                       ","EJ3_PEDIDO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_SEQUEN                                                                                                                                                                                       ","EJ3_SEQUEN                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"03","EE9","#EE9#->EE9_PSLQUN * #EE9#->EE9_SLDINI                                                                                                                                                                   ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3",'BUSCA_UM(#SW3#->W3_COD_I+#SW3#->W3_FABR +#SW3#->W3_FORN,#SW3#->W3_CC+#SW3#->W3_SI_NUM,EICRetLoja("#SW3#", "W3_FABLOJ"), EICRetLoja("#SW3#", "W3_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","#SW3#->W3_PESOL * #SW3#->W3_QTDE                                                                                                                                                                        ","EJ3_PESO                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW3","dDataBase                                                                                                                                                                                               ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_DTREG_D                                                                                                                                                                                       ","EJ3_DATA                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_DI_NUM                                                                                                                                                                                        ","EJ3_DI                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_ADICAO                                                                                                                                                                                        ","EJ3_ADICAO                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8",'BUSCA_UM(#SW8#->W8_COD_I+#SW8#->W8_FABR+#SW8#->W8_FORN,#SW8#->W8_CC+#SW8#->W8_SI_NUM, EICRetLoja("#SW8#", "W8_FABLOJ"), EICRetLoja("#SW8#", "W8_FORLOJ"))                                               ',"EJ3_UM                                                                                                                                                                                                  "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_QTDE                                                                                                                                                                                          ","EJ3_QTD                                                                                                                                                                                                 "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_COD_I                                                                                                                                                                                         ","EJ3_COD_I                                                                                                                                                                                               "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_PO_NUM                                                                                                                                                                                        ","EJ3_PO_NUM                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_POSICAO                                                                                                                                                                                       ","EJ3_POSICA                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW6#->W6_HAWB                                                                                                                                                                                          ","EJ3_HAWB                                                                                                                                                                                                "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_PGI_NUM                                                                                                                                                                                       ","EJ3_PGI_NU                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW8#->W8_INVOICE                                                                                                                                                                                       ","EJ3_INVOIC                                                                                                                                                                                              "},,.F.)
      o:TableData("EJ2",{xFilial("EJ2"),"04","SW8","#SW7#->W7_PESO * #SW8#->W8_QTDE                                                                                                                                                                         ","EJ3_PESO                                                                                                                                                                                                "},,.F.)

   End Sequence

Return Nil

//NCF - 03/07/2019 - Carga na tab. EC6 para atualização dos típos de título dos eventos de adiantamentos integrados.
Static Function CargEC6Adt(o)

   Begin Sequence
      If !AvFlags("EEC_LOGIX")
         o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_TPTIT"}, 1)
         o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"605"          ,""          ,"1"	         , "RA"      },,.T.)

         o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_DESC"            , "EC6_TPTIT"}, 1)
         o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"606"          ,""          ,"1"	         ,"NOTA CRED. - CLIENTE", "NCC"      },,.F.)

         o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_IDENTC","EC6_RECDES" ,"EC6_DESC"            , "EC6_TPTIT"}, 1)
         o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"603"          ,""          ,"1"	         ,"ADIANT. PÓS EMBARQUE", ""      },,.F.)
      EndIf
   End Sequence

Return Nil

/* Módulo SIGAEFF */
Function RUP_EFF( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1")  .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "005"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF005(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF005(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "006"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF006(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF006(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "007"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF007(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "014"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EFF,{|o|UPDEFF014(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF014(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados  := { {EEC,{|o|UPDEFF016(o)}} }
                  aAdd(oUpd:aChamados, {EEC,{|o|UPDEFF016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIF cRelLoop == "017"
                  aAdd(oUpd:aChamados, {EFF,{|o|UPDEFF017(o)}} )
                  oUpd:cTitulo := "Update para o modulo sIGAEFF, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
               EndIf
            Next nRelease
         EndIf

         //atualização de carga de dados, chamado do avgeral (ajustes de manutenção) ou do RUP
         If cMode == "0" //.Or. cMode == "2"
            //Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil
            //oUpd := AVUpdate01():New()
            //oUpd:aChamados := {{nModulo, {|o| ELinkDados(o)}}}
            aAdd(oUpd:aChamados,  {nModulo, {|o| ELinkDados(o)}} )
            oUpd:cTitulo := "Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil."
            //oUpd:Init(,.T.)
         EndIf

         oUpd:Init(,lBlind)

      EndIf

   #ENDIF

Return

/* Módulo SIGAEDC */
Function RUP_EDC( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1") .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "003"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC003(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  //aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC003(o)}} )
                  //oUpd:cTitulo := "Update para o modulo sIGAEDC, Release " + cRelLoop + "."
                  //oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "004"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC004(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  //aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC004(o)}} )
                  //oUpd:cTitulo := "Update para o modulo sIGAEDC, Release " + cRelLoop + "."
                  //oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "005"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC005(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  //aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC005(o)}} )
                  //oUpd:cTitulo := "Titulo do boletim técnico do Update".
                  //oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "007"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC007(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEDC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEDC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "017"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {EDC,{|o|UPDEDC007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {EDC,{|o|UPDEDC017(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAEDC, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               EndIf
            Next nRelease
         EndIf

         oUpd:Init(,lBlind)

      EndIf

   #ENDIF

Return

/* Módulo SIGAESS */
Function RUP_ESS( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
   Local cRelLoop
   Local nRelease:= 0
   Local lSimula:= .F.
   Local lBlind:= .T.

   #IFDEF TOP

      If FindFunction("AVUpdate01")

         oUpd := AVUpdate01():New()
         oUpd:lSimula:= lSimula

         If (cMode == "0" .Or. cMode == "1") .And. cRelFinish < "023" //atualização de dicionário, chamado do avgeral (ajustes de manutenção) ou do RUP
            /* Execução para os releases de partida ao de chegada, inclusive */
            For nRelease := Val( cRelStart ) to Val( cRelFinish )
               cRelLoop := StrZero( nRelease, 3 )
               If cRelLoop == "003"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS003(o)}} } //MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS003(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "006"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS006(o)}} } //MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS006(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "007"  // GFP - 19/10/2015
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS007(o)}} }//MMM = (EIC,EEC,EDC,EFF,ECO) / XXX = RELEASE
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS007(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "014"  // LRS- 26/10/2016
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS014(o)}} }
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS014(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
                  //oUpd:Init(,.T.)
               ElseIf cRelLoop == "016"
                  //oUpd := AVUpdate01():New()
                  //oUpd:aChamados := { {ESS,{|o|UPDESS016(o)}} }
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS016(o)}} )
                  aAdd(oUpd:aChamados, {EIC,{|o|UTTESWHG(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
               ElseIf cRelLoop == "017"
                  aAdd(oUpd:aChamados, {ESS,{|o|UPDESS017(o)}} )
                  oUpd:cTitulo := "Update para o modulo SIGAESS, Release " + cRelLoop + "."
                  oUpd:cDescricao := "Atualizações de dicionário sem impacto em modelo de dados, release " + cRelLoop + "."
               EndIf
            Next nRelease
         EndIf

         If cMode == "0" //.Or. cMode == "2" //atualização de carga de dados, chamado do avgeral (ajustes de manutenção) ou do RUP
            //Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil
            //oUpd := AVUpdate01():New()
            //oUpd:aChamados := {{nModulo, {|o| ELinkDados(o)}}}
            aAdd(oUpd:aChamados,  {nModulo, {|o| ELinkDados(o)}} )
            oUpd:cTitulo := "Carga inicial das tabelas utilizadas na integração com os módulos financeiro e contábil."
            //oUpd:Init(,.T.)
         EndIf

         oUpd:Init(,lBlind)

      EndIf

   #ENDIF

Return

/*********************
*******************************************************/
Static Function EDadosEEA(o) //MCF - 01/04/2016
   Local lAlteraEEA := .F.
   Local aIdioma := FWGetSX5 ( "ID" )
   Local ne := 0
   Local ns := 0
   Local aTableStruct := {}
   Local aTableData   := {}
   Local nPosCod
   Local nPosArq
   If EEA->(DbSeek(xFilial("EEA")+AvKey("66","EEA_COD"))) //MCF - 01/04/2015 - Correção na carga padrão no relatório 66
      If Alltrim(EEA->EEA_TITULO) == "INTERNATIONAL RECYABLE ACCOUNT STATEMENT"
         lAlteraEEA := .T.
      EndIf
   EndIf

   Begin Sequence
      //MFR 14/01/2021 nopar abaixo a carga dos documentos que serão desativados (aguardando lista)
      aadd(aTableStruct,{"EEA" ,{"EEA_FILIAL"   , "EEA_COD" , "EEA_FASE" , "EEA_TIPDOC" , "EEA_TITULO"                                                      , "EEA_CLADOC"             , "EEA_IDIOMA"       ,                                 "EEA_ARQUIV"    , "EEA_FILTRO" , "EEA_RDMAKE"                                        ,"EEA_CNTLIM" , "EEA_CODMEM" , "EEA_ATIVO"  , "EEA_DOCAUT" , "EEA_DOCBAS" , "EEA_PE"  , "EEA_TABCAP" , "EEA_TABDET" , "EEA_INDICE" , "EEA_CHAVE"  , "EEA_IMPINV" , "EEA_MARCA"     },1})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "01"      , "2"        , "1-Carta"    , "ORDER ACKNOWLEDGMENT"                                            , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGLTT.RPT"    , ""           , "EXECBLOCK('EECPPE01',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "02"      , "2"        , "1-Carta"    , "ORDER CONFIRMATION"                                              , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEDRECi.RPT"   , ""           , "EXECBLOCK('EECPPE02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "03"      , "2"        , "1-Carta"    , "COMMERCIAL PROFORM"                                              , "1-Proforma"             , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PROFING.RPT"   , ""           , "EXECBLOCK('EECPPE05',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "04"      , "3"        , "2-Documento", "SAQUE / CAMBIAL"                                                 , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "SAC00001.RPT"  , ""           , "EXECBLOCK('EECPEM01',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "13"      , "3"        , "2-Documento", "PACKING LIST"                                                    , "3-Packing List"         , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PAC00002.RPT"  , ""           , "EXECBLOCK('EECPEM10',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "14"      , "3"        , "2-Documento", "PACKING LIST"                                                    , "3-Packing List"         , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PAC00003.RPT"  , ""           , "EXECBLOCK('EECPEM10',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "16"      , "3"        , "2-Documento", "C.O. ALADI (FIESP)"                                              , "4-Certificado de Origem", /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "20"      , "3"        , "1-Carta"    , "RESERVA DE PRAÇA"                                                , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGLTT.RPT"    , ""           , "EXECBLOCK('EECPEM17',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "23"      , "3"        , "2-Documento", "C.O. NORMAL (FIESP)"                                             , "4-Certificado de Origem", /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "25"      , "3"        , "2-Documento", "C.O. MERCOSUL (FIESP)"                                           , "4-Certificado de Origem", /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "26"      , "3"        , "2-Documento", "MEMORANDO DE EXPORTAÇÃO"                                         , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "MEMEXP.RPT"    , ""           , "EXECBLOCK('EECPEM26',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "28"      , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM28',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "33"      , "3"        , "2-Documento", "SOLICITACAO PARA EMISSAO DE NOTA FISCAL PARA EXPORTACAO"         , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "EMNFEXP.RPT"   , ""           , "EXECBLOCK('EECPEM32',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "35"      , "2"        , "1-Carta"    , "PEDIDO CLIENTE"                                                  , "6-Outros"               , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PEDREC.RPT"    , ""           , "EXECBLOCK('EECPPE02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "36"      , "2"        , "1-Carta"    , "FACTURA PROFORMA"                                                , "1-Proforma"             , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PROFESP.RPT"   , ""           , "EXECBLOCK('EECPPE05',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "37"      , "3"        , "2-Documento", "COMMERCIAL INVOICE"                                              , "2-Fatura"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "FATING.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "38"      , "3"        , "2-Documento", "FACTURA COMERCIAL"                                               , "2-Fatura"               , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "FATESP.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "39"      , "3"        , "2-Documento", "C.O. BOLIVIA (FIESP)"                                            , "4-Certificado de Origem", /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "40"      , "3"        , "2-Documento", "C.O. CHILE (FIESP)"                                              , "4-Certificado de Origem", /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "41"      , "3"        , "2-Documento", "AMOSTRA - INGLES"                                                , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "FATAMI.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "42"      , "3"        , "2-Documento", "AMOSTRA - ESPANHOL"                                              , "6-Outros"               , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "FATAME.RPT"    , ""           , "EXECBLOCK('EECPEM11',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "50"      , "3"        , "3-Relatorio", "MEMORANDO DE EXPORTAÇÃO"                                         , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "MEMEXP.RPT"    , ""           , "EXECBLOCK('EECPEM26',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "51"      , "3"        , "3-Relatorio", "STATUS DO PROCESSO"                                              , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL01.RPT"     , ""           , "EXECBLOCK('EECPRL01',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "52"      , "2"        , "3-Relatorio", "OPEN ORDERS"                                                     , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "REL02.RPT"     , ""           , "EXECBLOCK('EECPRL02',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "53"      , "3"        , "3-Relatorio", "PROGRAMAÇÃO DE EMBARQUES"                                        , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL03.RPT"     , ""           , "EXECBLOCK('EECPRL03',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "54"      , "3"        , "3-Relatorio", "PROCESSOS POR VIA DE TRANSPORTE"                                 , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL04.RPT"     , ""           , "EXECBLOCK('EECPRL04',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "56"      , "3"        , "3-Relatorio", "PROCESSOS POR DATA DE ATRACAÇÃO"                                  , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL06.RPT"     , ""           , "EXECBLOCK('EECPRL06',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "57"      , "3"        , "3-Relatorio", "COMISSÕES PENDENTES"                                             , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL07.RPT"     , ""           , "EXECBLOCK('EECPRL07',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "58"      , "3"        , "3-Relatorio", "SHIPPED ORDERS"                                                  , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "REL08.RPT"     , ""           , "EXECBLOCK('EECPRL08',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "59"      , "3"        , "3-Relatorio", "EXPORT REPORT"                                                   , "6-Outros"               , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "REL09.RPT"     , ""           , "EXECBLOCK('EECPRL09',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "60"      , "3"        , "2-Documento", "CONTROLE DE EMBARQUE"                                            , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL11.RPT"     , ""           , "EXECBLOCK('EECPRL10',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "61"      , "3"        , "3-Relatorio", "DEMONSTRATIVOS DE MERCADORIAS FATURADAS POREM NÃO EMBARCADAS"    , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL12.RPT"     , ""           , "EXECBLOCK('EECPRL12',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "62"      , "2"        , "3-Relatorio", "CARTEIRA DE PEDIDOS"                                             , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL13.RPT"     , ""           , "EXECBLOCK('EECPRL13',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "63"      , "3"        , "3-Relatorio", "RELATÓRIO DE EMBARQUES"                                          , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL14.RPT"     , ""           , "EXECBLOCK('EECPRL14',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "65"      , "3"        , "3-Relatorio", "VARIAÇÃO CAMBIAL"                                                , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL16.RPT"     , ""           , "EXECBLOCK('EECPRL16',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "66"      , "3"        , "3-Relatorio", "INTERNATIONAL RECEIVABLE ACCOUNT STATEMENT"                      , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL17.RPT"     , ""           , "EXECBLOCK('EECPRL17',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "67"      , "3"        , "2-Documento", "C.O. NORMAL (CEARA)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "68"      , "3"        , "2-Documento", "C.O. NORMAL (RIO GRANDE DO SUL)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "69"      , "3"        , "2-Documento", "C.O. NORMAL (ASSOCIACAO COMERCIAL DE SANTOS)"                    , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "70"      , "3"        , "2-Documento", "C.O. ALADI (CEARA)"                                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "71"      , "3"        , "2-Documento", "C.O. ALADI (RIO GRANDE DO SUL)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "72"      , "3"        , "2-Documento", "C.O. ALADI (ASSOCIACAO COMERCIAL DE SANTOS)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "73"      , "3"        , "2-Documento", "C.O. MERCOSUL (CEARA)"                                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "74"      , "3"        , "2-Documento", "C.O. MERCOSUL (RIO GRANDE DO SUL)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "75"      , "3"        , "2-Documento", "C.O. MERCOSUL (ASSOCIACAO COMERCIAL DE SANTOS)"                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.)"                     , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "76"      , "3"        , "2-Documento", "C.O. BOLIVIA (CEARA)"                                            , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "77"      , "3"        , "2-Documento", "C.O. BOLIVIA (RIO GRANDE DO SUL)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "78"      , "3"        , "2-Documento", "C.O. BOLIVIA (ASSOCIACAO COMERCIAL DE SANTOS)"                   , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'B')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "79"      , "3"        , "2-Documento", "C.O. CHILE (CEARA)"                                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "80"      , "3"        , "2-Documento", "C.O. CHILE (RIO GRANDE DO SUL)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "81"      , "3"        , "2-Documento", "C.O. CHILE (ASSOCIACAO COMERCIAL DE SANTOS)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'C')"                 , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "82"      , "3"        , "3-Relatorio", "CUSTO REALIZADO"                                                 , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL18.RPT"     , ""           , "EXECBLOCK('EECAF155',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "83"      , "3"        , "1-Carta"    , "CARTA REMESSA DE DOCUMENTOS"                                     , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "PEM56.RPT"     , ""           , "EXECBLOCK('EECPEM56',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "84"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 4)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM52I.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "85"      , "3"        , "2-Documento", "FACTURA COMERCIAL (MODELO 4)"                                    , "2-Fatura"                , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PEM52E.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "86"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 4)"                                   , "2-Fatura"                , /*"FRANCE-FRANCES"  */ retIdioma(aIdioma,"FRANCE") , "PEM52F.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "87"      , "3"        , "2-Documento", "PACKING LIST (MODELO 3)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM55I.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "88"      , "3"        , "2-Documento", "LISTA DE EMPAQUE (MODELO 4)"                                     , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PEM55E.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "89"      , "3"        , "2-Documento", "PACKING LIST (MODELO 3)"                                         , "3-Packing List"          , /*"FRANCE-FRANCES"  */ retIdioma(aIdioma,"FRANCE") , "PEM55F.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "90"      , "3"        , "2-Documento", "SAQUE (MODELO 2)"                                                , "6-Outros"                , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM57.RPT"     , ""           , "EXECBLOCK('EECPEM57',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "91"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 3)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM51.RPT"     , ""           , "EXECBLOCK('EECPEM51',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "92"      , "3"        , "2-Documento", "PACKING LIST (MODELO 2)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM54.RPT"     , ""           , "EXECBLOCK('EECPEM54',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "93"      , "3"        , "2-Documento", "CERTIFICADO ORIGEM OIC"                                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM58',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "94"      , "3"        , "2-Documento", "COMMERCIAL INVOICE (MODELO 2)"                                   , "2-Fatura"                , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM50.RPT"     , ""           , "EXECBLOCK('EECPEM50',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "95"      , "2"        , "2-Documento", "PROFORMA INVOICE (MODELO 2)"                                     , "1-Proforma"              , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM49.RPT"     , ""           , "EXECBLOCK('EECPEM49',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "96"      , "3"        , "2-Documento", "C.O. ARABIA"                                                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "COARABIA.RPT"  , ""           , "EXECBLOCK('EECPEM45',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "97"      , "3"        , "2-Documento", "C.O. NORMAL (FIRJAN)"                                            , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM20',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "98"      , "3"        , "2-Documento", "C.O. ALADI (FIRJAN)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM13',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "99"      , "3"        , "2-Documento", "C.O. MERCOSUL (FIRJAN)"                                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM24',.F.,.F.,'RJ')"                , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "100"     , "1"        , "3-Relatorio", "RELATÓRIO DE ADIANTAMENTO"                                       , "6-Outros"                , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "REL23.RPT"     , ""           , "EXECBLOCK('EECPRL23',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-100"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIRJAN)"                                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'RJ-B')"              , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-101"   , "3"        , "2-Documento", "C.O. CHILE (FIRJAN)"                                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,'RJ-C')"              , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-102"   , "3"        , "2-Documento", "C.O. CHILE (FIEB) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIEB'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-103"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIEB) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIEB'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-104"   , "3"        , "2-Documento", "C.O. CHILE (FIESP) (COM LAYOUT)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIESP'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-105"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIESP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIESP'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-106"   , "3"        , "2-Documento", "C.O. CHILE (FEDERASUL) (COM LAYOUT)"                             , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FEDERASUL'})"   , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-107"   , "3"        , "2-Documento", "C.O. BOLIVIA (FEDERASUL) (COM LAYOUT)"                           , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM61.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FEDERASUL'})"   , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-108"   , "3"        , "2-Documento", "C.O. MERCOSUL - APENDICE I AO ANEXO IV (FIESP)"                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM61',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-109"   , "3"        , "2-Documento", "C.O. MERCOSUL - APENDICE I AO ANEXO IV (ASSOC. COM. DE SANTOS)"  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGFORM.RPT"   , ""           , "EXECBLOCK('EECPEM61',.F.,.F.,{'SANTOS'})"          , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-110"   , "3"        , "2-Documento", "C.O. CHILE (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'C','FIEP'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-111"   , "3"        , "2-Documento", "C.O. BOLIVIA (FIEP) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM33.RPT"     , ""           , "EXECBLOCK('EECPEM33',.F.,.F.,{'B','FIEP'})"        , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-112"   , "3"        , "2-Documento", "C.O. ALADI (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIEP'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-113"   , "3"        , "2-Documento", "C.O. ALADI (FIESP) (COM LAYOUT)"                                 , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-114"   , "3"        , "2-Documento", "C.O. ALADI (FIEB) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM59.RPT"     , ""           , "EXECBLOCK('EECPEM59',.F.,.F.,{'FIEB'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-115"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIESP) (COM LAYOUT)"                              , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIESP'})"           , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-116"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIEP'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-117"   , "3"        , "2-Documento", "C.O. MERCOSUL (FEDERASUL) (COM LAYOUT)"                          , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FEDERASUL'})"       , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-118"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEB) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM60.RPT"     , ""           , "EXECBLOCK('EECPEM60',.F.,.F.,{'FIEB'})"            , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-119"   , "3"        , "2-Documento", "C.O. NORMAL (FIESP) (COM LAYOUT)"                                , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM20.RPT"     , ""           , "EXECBLOCK('EECPEM35',.F.,.F.,{'LAYOUT'})"          , ""           , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-120"   , "3"        , "3-Relatorio", "CONTROLE DE CAMBIAIS"                                            , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL20.RPT"     , ""           , "EXECBLOCK('EECPRL20',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-121"   , "1"        , "3-Relatorio", "CONTRATOS DE CÂMBIO NO PERÍODO"                                  , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL21.RPT"     , ""           , "EXECBLOCK('EECPRL21',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-130"   , "3"        , "2-Documento", "C.O. MERCOSUL (FIEP) (COM LAYOUT)"                               , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM70.RPT"     , ""           , "EXECBLOCK('EECPEM70',.F.,.F.,{'FIEP'})"            , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-131"   , "3"        , "2-Documento", "C.O. MERCOSUL - CHILE (FIEP) (COM LAYOUT)"                       , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM71.RPT"     , ""           , "EXECBLOCK('EECPEM71',.F.,.F.,{'C','FIEP'})"        , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-132"   , "3"        , "2-Documento", "C.O. MERCOSUL - BOLIVIA (FIEP) (COM LAYOUT)"                     , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM71.RPT"     , ""           , "EXECBLOCK('EECPEM71',.F.,.F.,{'B','FIEP'})"        , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-133"   , "3"        , "2-Documento", "C.O. ALADI (FIEP) (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM72.RPT"     , ""           , "EXECBLOCK('EECPEM72',.F.,.F.,{'FIEP'})"            , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-134"   , "3"        , "2-Documento", "C.O. ACORDO MERCOSUL- COLOMBIA, EQUADOR E VENEZUELA (COM LAYOUT)", "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM73.RPT"     , ""           , "EXECBLOCK('EECPEM73',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-135"   , "3"        , "2-Documento", "C.O. COMUM - FIEP (COM LAYOUT)"                                  , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM74.RPT"     , ""           , "EXECBLOCK('EECPEM74',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-136"   , "3"        , "2-Documento", "C.O. GSTP (FIEP) (COM LAYOUT)"                                   , "4-Certificado de Origem" , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM75.RPT"     , ""           , "EXECBLOCK('EECPEM75',.F.,.F.)"                     , "2"          , ""           , "2"           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-137"   , "3"        , "3-Relatorio", "RELATÓRIO DE PRÉ-CALCULO"                                        , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL22.RPT"     , ""           , "U_EECPRL22()"                                      , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-139"   , "1"        , "3-Relatorio", "RELAÇÃO DE DESPESAS NACIONAIS"                                   , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL25.RPT"     , ""           , "EXECBLOCK('EECPRL25',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-140"   , "3"        , "2-Documento", "PACKING LIST (MODELO 4)"                                         , "3-Packing List"          , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "PEM76.RPT"     , ""           , "EXECBLOCK('EECPEM76',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-138"   , "2"        , "2-Documento", "PRÉ CUSTO"                                                       , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "PC150.RPT"     , ""           , "EECPC150()"                                        , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "R-001"   , "1"        , "3-Relatorio", "EMBALAGENS ESPECIAIS"                                            , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , ""              , ""           , "EXECBLOCK('EASYADM100',.F.,.F.)"                   , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-146"   , "3"        , "2-Documento", "LISTA DE EMPAQUE (MODELO 2)"                                     , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PEM55E.RPT"    , ""           , "EXECBLOCK('EECPEM55',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , "0"          , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-147"   , "3"        , "2-Documento", "FACTURA COMERCIAL (MODELO 2)"                                    , "2-Fatura"                , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PEM52E.RPT"    , ""           , "EXECBLOCK('EECPEM52',.F.,.F.)"                     , "2"          , ""           , ""           , ""           , ""           , ""        , ""           , "0"          , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-141"   , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM83',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-142"   , "3"        , "2-Documento", "INSTRUÇÃO DE EMBARQUE"                                           , "6-Outros"                , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "INS00002.RPT"  , ""           , "EXECBLOCK('EECPEM84',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "A-143"   , "3"        , "2-Documento", "PACKING LIST (MODELO 4)"                                         , "3-Packing List"          , /*"ESP.  -ESPANHOL" */ retIdioma(aIdioma,"ESP.  ") , "PEM85.RPT"     , ""           , "EXECBLOCK('EECPEM85',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "3-RELATORIO" , "1"    , "3-Relatorio", "TABELA DE PREÇOS"                                                , "6-Outros"                , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL24.RPT"     , ""           , "EXECBLOCK('EECPRL24',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.})
      aadd(aTableData,{ 'EEA'  ,{xFilial('EEA') , "F-001"   , "3"        , "2-Documento", "CERTIFICADO DE ORIGEM - FIERGS"                                  , "4-Certificado de origem" , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , ""              , ""           , "AE108FIERGS()"                                     , ""           , ""           , "2"          , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})

      If lAlteraEEA //MCF - 01/04/2016
         aadd(aTableData,{ 'EEA', {xFilial('EEA') , "66", "3"        , "3-Relatorio", "INTERNATIONAL RECEIVABLE ACCOUNT STATEMENT"                      , "6-Outros"               , /*"PORT. -PORTUGUES"*/ retIdioma(aIdioma,"PORT. ") , "REL17.RPT"     , ""           , "EXECBLOCK('EECPRL17',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.F.})
      EndIf

      // o:TableStruct("EEA",{"EEA_FILIAL"   , "EEA_COD" , "EEA_FASE" , "EEA_TIPDOC" , "EEA_TITULO"          , "EEA_CLADOC", "EEA_IDIOMA"       ,                                 "EEA_ARQUIV"    , "EEA_FILTRO" , "EEA_RDMAKE"                                        ,"EEA_CNTLIM" , "EEA_CODMEM" , "EEA_ATIVO"  , "EEA_DOCAUT" , "EEA_DOCBAS" , "EEA_PE"  , "EEA_TABCAP" , "EEA_TABDET" , "EEA_INDICE" , "EEA_CHAVE"  , "EEA_IMPINV" , "EEA_MARCA"     },1)
      for ns:=1 to len(aTableStruct)
         if aTableStruct[ns][1] == "EEA" .and. EEA->(FieldPos("EEA_TIPMOD")) > 0
            aadd(aTableStruct[ns][2],"EEA_TIPMOD")
         endif
         //                tabelas        -     campos        -      indice
         o:TableStruct(aTableStruct[ns][1],aTableStruct[ns][2],aTableStruct[ns][3])
      next

      // o:TableData('EEA'  ,{xFilial('EEA') , "01"      , "2"        , "1-Carta"    , "ORDER ACKNOWLEDGMENT", "6-Outros"  , /*"INGLES-INGLES"   */ retIdioma(aIdioma,"INGLES") , "AVGLTT.RPT"    , ""           , "EXECBLOCK('EECPPE01',.F.,.F.)"                     , ""           , ""           , ""           , ""           , ""           , ""        , ""           , ""           , ""           , ""           , ""           , ""              },,.T.)
      If ValType(aTableStruct[1][2]) == "A" //EEA_COD###EEA_ARQUIV
         nPosCod := aScan(aTableStruct[1][2],{ |x| x == "EEA_COD" })
         nPosArq := aScan(aTableStruct[1][2],{ |x| x == "EEA_ARQUIV" })
      EndIf

      for ne := 1 to len(aTableData)
         if aTableData[ne][1] == "EEA" .and. EEA->(FieldPos("EEA_TIPMOD")) > 0 .And. (aTableData[ne][2][nPosCod] == "37" .Or. "AVGLTT" $ aTableData[ne][2][nPosArq])
            aadd(aTableData[ne][2],"1")
         Else
            aadd(aTableData[ne][2],"2")
         endif
         //             tabela        ,   dados         ,   nil           ,   atualiza ?
         o:TableData(aTableData[ne][1],aTableData[ne][2],aTableData[ne][3],aTableData[ne][4])
      next

      o:TableStruct("EEA",{"EEA_FILIAL"   , "EEA_COD" , "EEA_TIPDOC" , "EEA_IDIOMA" },1)
      o:DelTableData('EEA'  ,{xFilial('EEA') , "14"    , "2-Documento" , "ESP."   })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "60"    , "2-Documento" , "PORT."  })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-130" , "2-Documento" , "INGLES" })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-131" , "2-Documento" , "INGLES" })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-132" , "2-Documento" , "INGLES" })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-133" , "2-Documento" , "INGLES" })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-134" , "2-Documento" , "INGLES" })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-135" , "2-Documento" , "INGLES" })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-136" , "2-Documento" , "INGLES" })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-137" , "3-Relatorio" , "PORT."  })
      o:DelTableData('EEA'  ,{xFilial('EEA') , "100"   , "3" , "INGLES"})
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-138" , "2" , "PORT."})
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-139" , "3" , "PORT."})
      o:DelTableData('EEA'  ,{xFilial('EEA') , "A-140" , "2" , "INGLES"})

   End Sequence

Return Nil

static function retIdioma(aIdioma,cChave)
   Local cRet := ""
   Local nPos := 0

   if ( nPos :=  ascan( aIdioma, {|x| x[3] == AVKEY( cChave, "X5_CHAVE" ) }) ) > 0
      cRet := aIdioma[nPos][3] + "-" + aIdioma[nPos][4]
   endif

return cRet

Static Function AjustaSmartHtml(o)

   o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TITULO"   ,"X3_TITSPA"   ,"X3_TITENG"   ,"X3_DESCRIC"          ,"X3_DESCSPA"          ,"X3_DESCENG"       },2)
   o:TableData  ("SX3",{"W2_FRETEIN" ,"Intl Freigh" ,"Intl Freigh" ,"Intl Freigh" ,"Intl Freigh"         ,"Intl Freigh"         ,"Intl Freigh"      })
   o:TableData  ("SX3",{"W2_CONTA20" ,"Contain. 20" ,"Contain. 20" ,"Contain. 20" ,"Containers de 20"    ,"Containers de 20"    ,"Containers of 20" })
   o:TableData  ("SX3",{"W2_CONTA40" ,"Contain. 40" ,"Contain. 40" ,"Contain. 40" ,"Containers de 40"    ,"Containers de 40"    ,"Containers of 40" })
   o:TableData  ("SX3",{"W2_CON40HC" ,"Cont. 40 hc" ,"Cont. 40 hc" ,"40 hc Cont." ,"Containers de 40 hc" ,"Containers de 40 hc" ,"40 hc Containers" })

Return Nil


/*
Funcao                     : AjustaEYYSXB
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização da consulta padrão EYY
Autor       			      : wfs
Data/Hora   			      :
Revisao                    :
Obs.                       : Migrado do UPDEEC, para possibilitar a excução intependente do release, até que o pacote
                             oficial com a melhoria seja publicado
*/
Static Function AjustaEYYSXB(o)
   //MCF - Correção para versão 12.1.14 - Deletando digitação nota fiscal de remessa - Projeto Durli
   If !NFRemNewStruct() //NCF - 17/03/2017 - Deve verificar se a utilização da nova rotina está ativada antes de atualizar a consulta(solução temporária até a homologação da nova consulta)
      //Limpa nova consulta
      o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"           ,"XB_DESCSPA"          ,"XB_DESCENG"          ,"XB_CONTEM"                 })
      o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"DB"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"02"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"03"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"04"       ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                    ,""                    ,""                    ,""                          })
      o:DelTableData("SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                    ,""                    ,""                    ,""                          })
      //Restaura a antiga consulta
      o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"              ,"XB_DESCSPA"            ,"XB_DESCENG"            ,"XB_CONTEM"                })
      o:TableData("SXB"   ,{"EYY"     ,"1"      ,"01"    ,"DB"       ,"N.F.s de Entrada"       ,"Fact. de Entrada"      ,"Receipt Invoices"      ,"SF1"                      })
      o:TableData("SXB"   ,{"EYY"     ,"2"      ,"01"    ,"01"       ,"Numero + Serie + For"   ,"Numero + Serie + Pro"  ,"Number+Series+Sup."    ,""                         })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"01"       ,"Número"                 ,"Numero"                ,"Number"                ,"F1_DOC"                   })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"02"       ,"Serie"                  ,"Serie"                 ,"Series"                ,"F1_SERIE"                 })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"03"       ,"Fornecedor"             ,"Proveedor"             ,"Supplier"              ,"F1_FORNECE"               })
      o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"04"       ,"Loja"                   ,"Tienda"                ,"Unit"                  ,"F1_LOJA"                  })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"01"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_DOC"              })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"02"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_SERIE"            })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"03"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_FORNECE"          })
      o:TableData("SXB"   ,{"EYY"     ,"5"      ,"04"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_LOJA"             })

   Else
      //Limpa a antiga consulta
      o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA"}, 1)
      o:DelTableData("SXB" ,{"EYY"     ,"1"      ,"01"    ,"DB"       })
      o:DelTableData("SXB" ,{"EYY"     ,"2"      ,"01"    ,"01"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"01"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"02"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"03"       })
      o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"04"       })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"01"    ,""         })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"02"    ,""         })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"03"    ,""         })
      o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"04"    ,""         })
      //Implementa a nova consulta
      o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA"    ,"XB_DESCENG" ,"XB_CONTEM"              ,"XB_WCONTEM"})
      o:TableData(  "SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,"N.F.s de Entrada","Fact de entrada" ,"Inbound Invoices","SD1"            ,            })
      o:TableData(  "SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                ,""                ,""                ,"AE110SD1F3()"   ,            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                ,""                ,""                ,"SD1->D1_DOC"    ,            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                ,""                ,""                ,"SD1->D1_SERIE"  ,            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                ,""                ,""                ,"SD1->D1_FORNECE",            })
      o:TableData(  "SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                ,""                ,""                ,"SD1->D1_LOJA"   ,            })

      o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"    },2)
      o:TableData  ("SX3",{"EYY_SEQEMB" ,TODOS_MODULOS })
      o:TableData  ("SX3",{"EYY_D1ITEM" ,TODOS_MODULOS })
      o:TableData  ("SX3",{"EYY_D1PROD" ,TODOS_MODULOS })
      o:TableData  ("SX3",{"EYY_QUANT"  ,TODOS_MODULOS })
   EndIf

Return

Static Function ELinkDados(o)

   Local aTabelas := {"EYA","EYB","EYC","EYD","EYE"}

   Local nInc, nInc2, nInc3, i // GFP - 24/08/2012
   Local lParcTit := EYC->(FieldPos("EYC_CONDIC")) > 0 .And. EYE->(FieldPos("EYE_FUNCT")) > 0 //FSM - 27/08/2012

   Private aIndEYA := {"EYA_FILIAL", "EYA_CODINT", "EYA_NOMINT", "EYA_COND"}
   Private aIndEYB := {"EYB_FILIAL", "EYB_CODAC", "EYB_DESAC"}
   Private aIndEYC := {"EYC_FILIAL", "EYC_CODEVE", "EYC_CODINT", "EYC_CODAC", "EYC_CODSRV"} //,"EYC_CONDIC"} - FSM - 27/08/2012
   Private aIndEYD := {"EYD_FILIAL", "EYD_NAME", "EYD_TYPE", "EYD_SIZE", "EYD_DECIM", "EYD_PICT", "EYD_AS"}
   Private aIndEYE := {"EYE_FILIAL", "EYE_CODINT", "EYE_CODSRV", "EYE_DESSRV", "EYE_ARQXML", "EYE_FUNCT"}
   Private aRecEYA := {}, aRecEYB := {}, aRecEYC := {}, aRecEYD := {}, aRecEYE := {}, aDelEYC := {}, aDelEYCEAI := {}

   If EYC->(FieldPos("EYC_CONDIC")) > 0  //FSM - 27/08/2012
      aAdd(aIndEYC,"EYC_CONDIC")
   EndIf

   Begin Sequence
      //FSM - 28/08/2012  - RRC - 08/02/2013 - Inclusão das integrações "003", "004" e "100"
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "001", "SIGAEEC X SIGAFIN e SIGACTB", "EasyGParam('MV_AVG0131',,.F.)"   })
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "002", "Integração Inttra"                 , "EECFlags('INTTRA')"  })
      //aAdd(aRecEYA, {EYA->(xFilial("EYA")), "003", "Estufagem de mercadorias","EECFLAGS('ESTUFAGEM')"})
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "004", "Integração SIGAESS x SIGAFIN", "Int101GetCond()"})
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "010", "Integração SIGAEEC/SIGAEFF x LOGIX", "AVFLAGS('EEC_LOGIX')"})
      aAdd(aRecEYA, {EYA->(xFilial("EYA")), "100", "SigaEEC x NovoEx", "EECFLAGS('NOVOEX')"})
      //aAdd(aRecEYA, {EYA->(xFilial("EYA")), "200", "Importacao por conta e Ordem", "EasyGParam('MV_EIC_PCO',,.F.)"})

      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "001", "Inclusao de adiantamento                 "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "002", "Exclusao de adiantamento                 "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "003", "Alteracao de adiantamento                "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "004", "Baixa de Titulo                          "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "005", "Inclusao de parcela de cambio a receber  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "006", "Alteracao de parcela de cambio a receber "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "007", "Exclusao de parcela de cambio a receber  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "008", "Baixa de Titulo a receber                "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "009", "Estorno de baixa de titulo a receber     "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "010", "Inclusao de parcela de cambio a pagar    "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "011", "Alteracao de parcela de cambio a pagar   "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "012", "Exclusao de parcela de cambio a pagar    "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "013", "Baixa de titulo a pagar                  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "014", "Estorno de baixa de titulo a pagar       "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "015", "Inclusao de desp. nacional               "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "016", "Estorno de desp. nacional                "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "017", "Inclusao de cambio de desp. internacional"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "018", "Estorno de cambio de desp. internacional "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "019", "Alteracao de desp. nacional              "})  // GFP - 13/03/2012
      //aAdd(aRecEYB, {EYB->(xFilial("EYB")), "022", "Inclusão de container e estufagem" }) //RRC - 08/02/2013 - Foi descontinuado o uso do EasyLink para estufagem
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "020", "Inclusao de titulo a receber de serviço" })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "021", "Alteracao de titulo a receber de serviço"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "022", "Exclusao de titulo a receber de serviço" })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "023", "Baixa de titulo a receber de serviço"    })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "024", "Estorno de titulo a receber de serviço"  })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "025", "Inclusao de titulo a pagar de serviço"   })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "026", "Alteracao de titulo a pagar de serviço"  })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "027", "Exclusao de titulo a pagar de serviço"   })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "028", "Baixa de titulo a pagar de serviço"      })
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "029", "Estorno de titulo a pagar de serviço"    })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '050', 'Inclusão de Contrato de Financiamento    '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '051', 'Inclusão de Encargo em Contrato de Financiamento   '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '052', 'Inclusão de Invoice em Financiamento               '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '053', 'Inclusão de Liquidação de Invoice em Financiamento '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '054', 'Inclusão de Parcela do Principal em Financiamento  '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '055', 'Inclusão de Parcela de Juros em Financiamento      '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '056', 'Alteração de Contrato de Financiamento'})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '057', 'Alteração de Encargo em Contrato de Financiamento  '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '058', 'Alteração de Invoice em Financiamento              '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '059', 'Alteração de Liquidação de Invoice em Financiamento'})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '060', 'Alteração de Parcela do Principal em Financiamento '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '061', 'Alteração de Parcela de Juros em Financiamento     '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '062', 'Estorno de Contrato de Financiamento               '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '063', 'Estorno de Encargo em Contrato de Financiamento    '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '064', 'Estorno de Invoice em Financiamento                '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '065', 'Estorno de Liquidação de Invoice em Financiamento  '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '066', 'Estorno de Parcela do Principal em Financiamento   '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '067', 'Estorno de Parcela de Juros em Financiamento       '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '068', 'Liquidação de Parcela do Principal em Financiamento'})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '069', 'Liquidação de Parcela de Juros em Financiamento    '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '070', 'Estorno de Liquidação de Parcela de Principal      '})
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), '071', 'Estorno de Liquidação de Parcela de Juros          '})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "072", "Data de Embarque p/ Exportação                     "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "073", "Alteração da Data de Embarque p/ Exportação        "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "074", "Cancelamento da Data de Embarque                   "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "075", "Contabilização dos Contratos de Financiamento Ativos"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "076", "Liquidação de Encargo em Contrato de Financiamento  "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "077", "Estorno da Liquidacao dos Contratos de Financiamento"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "078", "Compensação do Adiantamento                         "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "079", "Estorno da Compensação do Adiantamento              "})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "080", "Contabilização dos Contratos de Financiamento Excluidos"}) // GFP - 26/01/2012
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "090", "Estorno da Contabilização dos Contratos de Financiamento"})

      //THTS - 21/03/2017 - Tratamento para inclusao e exclusao de adiantamento a fornecedores com integracao Logix
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "091", "Inclusão de Adiantamento a Fornecedor"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "092", "Exclusão de Adiantamento a Fornecedor"})
      //THTS - 18/04/2017 - Tratamento para compensacao e estorno de adiantamento a fonrnecedor com integracao Logix
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "093", "Compensação de Adiantamento a Fornecedor"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "094", "Estorno Compensação de Adiantamento a Fornecedor"})

      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "100", "Envio RE NovoEx"})

      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "082", "Alteração/Aprov. de Proforma do Pedido de Exportação"})    // NCF - 02/08/2013
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "083", "Alteração/Cancelamento do Pedido de Exportação"})          // NCF - 02/08/2013

      //AAF - 10/10/2013 - Tratamento de baixa de comissão em título a receber
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "085", "Baixa de Comissão em Título a Receber"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "086", "Estorno de Baixa de Comissão em Título a Receber"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "087", "Inclusao Título receber para Comissão"})
      aAdd(aRecEYB, {EYB->(xFilial("EYB")), "088", "Estorno de Título a receber para Comissão"})

      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "300" ,"Geracao de Solicitacao de Booking"     })                         //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "301" ,"Recebimento de Informacoes de Booking" })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "302" ,"Envio de Informacoes de SI"            })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "303" ,"Recebimento de Informacoes de SI"      })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "304" ,"Recebimento de Track and Trace"        })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "305" ,"Recebimento de BL"                     })
      aAdd(aRecEYB, {EYB->(xFilial('EYB')), "306" ,"Atualizacao de arquivos Inttra"        })
      //                                      EVENT  INTEG  ACAO   SERV
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "001", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "002", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "003", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "003", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "004", "005", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "005", "003", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "006", "004", "!EECFLAGS('ALT_EASYLINK')"}) //FSM - 01/08/2012
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "006", "003", "!EECFLAGS('ALT_EASYLINK')"}) //FSM - 01/08/2012

      If lParcTit //FSM - 27/08/2012
         aAdd(aRecEYC, {EYC->(xFilial("EYC")), "003", "001", "006", "016", "EECFLAGS('ALT_EASYLINK')" }) //FSM - 01/08/2012
      EndIf

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "007", "004", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "008", "006", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "009", "007", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "010", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "011", "009", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "011", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "012", "009", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "013", "010", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "014", "011", ""})

      //RMD - 14/01/15 - Inclusão de condição para execução do evento de criação de título para despesa nacional
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "015", "012", ""})
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "016", "013", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "015", "012", "!EasyGParam('MV_EEC0043',,.F.)"})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "016", "013", "!EasyGParam('MV_EEC0043',,.F.)"})

      //RMD - 14/01/15 - Inclusão de evento para inclusão de pedido de compras para despesa nacional
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "015", "017", "EasyGParam('MV_EEC0043',,.F.)"})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "001", "016", "018", "EasyGParam('MV_EEC0043',,.F.)"})

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "017", "014", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "001", "018", "015", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "001", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "002", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "003", "002", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002", "010", "003", "001", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "004", "005", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "005", "003", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "006", "003", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "007", "004", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "008", "006", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "009", "007", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "010", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "011", "008", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "012", "009", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "013", "010", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "014", "011", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "015", "012", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "016", "013", ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "019", "012", ""})  // GFP - 13/03/2012
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'050' , '050', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'051' , '051', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'052' , '052', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'053' , '053', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'054' , '054', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'055' , '055', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), '001','010' ,'056' , '050', ""})

      If AVFLAGS('EEC_LOGIX')

         //EXCLUSAO
         aAdd(aDelEYCEAI, {EYC->(xFilial('EYC')), '001','010' ,'057' , '051', ""}) //NCF - 30/01/2019 - (EFF) Alt.Encargo com Exclui/Inclui
         aAdd(aDelEYCEAI, {EYC->(xFilial('EYC')), '001','010' ,'060' , '054', ""}) //NCF - 30/01/2019 - (EFF) Alt.Prc.Princ com Exclui/Inclui
         aAdd(aDelEYCEAI, {EYC->(xFilial('EYC')), '001','010' ,'061' , '055', ""}) //NCF - 30/01/2019 - (EFF) Alt.Prc.Juros com Exclui/Inclui

         //INCLUSAO
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'057' , '063', ""})  //NCF - 30/01/2019 - (EFF) Alt.Encargo com Exclui/Inclui
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'057' , '051', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'060' , '066', ""})  //NCF - 30/01/2019 - (EFF) Alt.Prc.Princ com Exclui/Inclui
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'060' , '054', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'061' , '067', ""})  //NCF - 30/01/2019 - (EFF) Alt.Prc.Juros com Exclui/Inclui
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'061' , '055', ""})
      Else
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'057' , '051', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'060' , '054', ""})
         aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'061' , '055', ""})
      EndIf

      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'058' , '052', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'059' , '053', ""})

      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'062' , '062', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'063' , '063', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'064' , '064', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'065' , '065', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'066' , '066', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'067' , '067', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'068' , '068', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'069' , '069', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'070' , '070', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'071' , '071', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'072' , '072', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'072' , '073', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'073' , '074', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'073' , '075', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '003','010' ,'073' , '072', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '004','010' ,'073' , '073', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'074' , '074', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '002','010' ,'074' , '075', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'075' , '076', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'076' , '077', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'077' , '078', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'078' , '079', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'079' , '080', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'080' , '081', ""}) // GFP - 26/01/2012
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'090' , '090', ""})

      //THTS - 21/03/2017 - Tratamento para inclusao e exclusao de adiantamento a fornecedor com integracao Logix
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'091' , '091', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'092' , '092', ""})
      //THTS - 18/04/2017 - Tratamento para compensacao e estorno de adiantamento a fonrnecedor com integracao Logix
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'093' , '093', ""})
      aAdd(aRecEYC, {EYC->(xFilial('EYC')), '001','010' ,'094' , '094', ""})

      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001", "010", "015", "012"})

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), '001','010' ,'082' , '082', ""}) //// NCF - 02/08/2013 - Pedido de Exportação - Aprov. Proforma
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), '001','010' ,'083' , '083', ""}) //// NCF - 02/08/2013 - Pedido de Exportação - Cancelamento

      //AAF - 10/10/2013 - Tratamento de baixa de comissão em título a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'085' , '085', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'086' , '086', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'087' , '087', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001','010' ,'088' , '088', ""})


      //THTS - 19/12/2017 - Esta carga dos eventos do siscoserv estava sendo feita para o codigo 001 referente a integracao do eec. Foi alterada para exlcuir da carga 001 mantendo somente na carga 004
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "020"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "021"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "002"       , "001"       , "021"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "022"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "023"      , "005"        , ""}) //Baixa de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "024"      , "007"        , ""}) //Estorno de titulo a receber
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "025"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "026"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "002"       , "001"       , "026"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "027"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "028"      , "010"        , ""}) //Baixa de titulo a pagar
      aAdd(aDelEYC, {EYC->(xFilial("EYC")), "001"       , "001"       , "029"      , "011"        , ""}) //Estorno de titulo a pagar

      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,"300"       , '001', ""}) //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,"301"       , '002', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'302'       , '003', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'303'       , '004', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'304'       , '006', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'305'       , '005', ""})
      aAdd(aRecEYC, {EYC->(xFilial("EYC")),'001'        ,'002'        ,'306'       , '008', ""})
      //RRC - 13/02/2013 - Foi descontinuada a integração EasyLink da estufagem
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "003"       , "022"      , "001"        , ""}) //Inclusão de container e estufagem
      //aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002"       , "003"       , "022"      , "002"        , ""}) //Inclusão de container e estufagem

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "020"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "021"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002"       , "004"       , "021"      , "003"        , ""}) //Inclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "022"      , "004"        , ""}) //Exclusao de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "023"      , "005"        , ""}) //Baixa de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "024"      , "007"        , ""}) //Estorno de titulo a receber
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "025"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "026"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "002"       , "004"       , "026"      , "008"        , ""}) //Inclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "027"      , "009"        , ""}) //Exclusao de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "028"      , "010"        , ""}) //Baixa de titulo a pagar
      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "004"       , "029"      , "011"        , ""}) //Estorno de titulo a pagar

      aAdd(aRecEYC, {EYC->(xFilial("EYC")), "001"       , "100"       , "100"      , "100"        , ""}) //Envio RE NovoEx

      If !(EYC->(FieldPos("EYC_CONDIC")) > 0)  //NCF - 24/08/2012
         For i := 1 to Len(aRecEYC)
            aDel( aRecEYC[i],Len(aRecEYC[i]) )
            aSize( aRecEYC[i],Len(aRecEYC[i])-1 )
         Next i
      EndIf

      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "TESTE               ", "A",          1,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA_SEND           ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA_SELECTION      ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA_RECEIVE        ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "DATA                ", "D",          8,          0, "@D"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "HORA                ", "C",          8,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "USER                ", "C",         60,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "USUARIO             ", "C",         60,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_SEND            ", "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_IT              ", "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_ELE1            ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_ELE2            ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_ELE3            ", "C",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SEND_FIN            ", "C",       5000,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ERROR_FIN           ", "C",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SERVICE_STATUS      ", "L",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SRV_STATUS          ", "L",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SRV_MSG             ", "C",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CMD                 ", "C",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_NUM             ", "C",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "BAIXA_TITULO        ", "L",          1,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "FIN_SEQ             ", "N",         15,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTMOTBX            ", "C",          3,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTDTBAIXA          ", "D",          8,          0, "@D"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTHIST             ", "C",         60,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "SEND                ", "C",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTVALREC           ", "N",         17,          2, "@E 999,999,999,999.99", ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "AUTTXMOEDA          ", "N",         11,          4, "@E 999999.9999    ", ""})

      //aAdd(aRecEYD, {EYD->(xFilial("EYD")), "XML               ", "X",        100,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"PEDIDOS"              , "A",         20,          0, "@!"                   , ""}) //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"EQUIPMENT"            , "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"PACKAGES"             , "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TOT_EQUIP"            , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TOT_PACKAGE"          , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TOT_VOLUME"           , "N",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"LINE"                 , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"LINENUMBER"           , "N",         20,          5, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"REF_NUM"              , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"XML"                  , "X",        500,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"PESOBR"               , "N",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TIPO_LOC"             , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TIPO_COD_LOC"         , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"COD_LOC"              , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"TIPO_DATA_LOC"        , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"DATA_LOC"             , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"REF_TIPO"             , "A",         20,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"NAVIO"                , "A",        100,          0, "@!"                   , ""})

      //RMD - 16/01/15 - Tags utilizadas na integração de pedido de compra para despesas nacionais.
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"ACAB"                , "A",        100,          0, "@!"                   , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")),"ADET"                , "A",        100,          0, "@!"                   , ""})

      //RRC - 13/02/2013 - Foi descontinuada a integração EasyLink da estufagem
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_SEL           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_IT            ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_CPO           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_ID            ", "C",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_SEL          ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_IT           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_CPO          ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "CONTNR_ID           ", "A",         20,          0, ""                     , ""})
      aAdd(aRecEYD, {EYD->(xFilial("EYD")), "ESTUF_ID            ", "C",         20,          0, ""                     , ""})

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "001", "Inclusao de titulo de adiantamento       "                  , "AVLINK001.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "002", "Exclusao de titulo de adiantamento       "                  , "AVLINK002.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "003", "Inclusao de titulo de receita            "                  , "AVLINK003.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "004", "Exclusao de titulo de receita            "                  , "AVLINK004.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "005", "Baixa de titulo a receber                "                  , "AVLINK005.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "006", "Baixa de titulo a receber e adiantamento "                  , "AVLINK006.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "007", "Estorno de baixa de titulo a receber     "                  , "AVLINK007.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "008", "Inclusao de titulo a pagar               "                  , "AVLINK008.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "009", "Exclusao de titulo a pagar               "                  , "AVLINK009.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "010", "Baixa de titulo a pagar                  "                  , "AVLINK010.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "011", "Estorno de baixa de titulo a pagar       "                  , "AVLINK011.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "012", "Inclusão de titulo de desp. nacional     "                  , "AVLINK012.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "013", "Exclusão de titulo de desp. nacional     "                  , "AVLINK013.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "014", "Inclusão de titulo de desp. internacional"                  , "AVLINK014.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "015", "Exclusão de titulo de desp. internacional"                  , "AVLINK015.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "016", "Alteracao de titulo de receita           "                  ,""              , 'AF200SE1Integ(4)'        }) //FSM - 01/08/2012

      //RMD - 14/01/15 - Criação de pedido de compras para despesas nacionais
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "017", "Inclusão de Pedido de desp. nacional     "                  ,"ELINK001.APH"  , ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "001", "018", "Exclusão de Pedido de desp. nacional     "                  ,"ELINK002.APH"  , ""                        })

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "001", "Inclusao de titulo de adiantamento       "                  ,""              , 'EECAF212(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "002", "Exclusao de titulo de adiantamento       "                  ,""              , 'EECAF212(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "003", "Inclusao de titulo de receita            "                  ,""              , 'EECAF210(3)'             }) // "EasyEnvEAI('EECAF210',3)"})
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "004", "Exclusao de titulo de receita            "                  ,""              , 'EECAF210(5)'             }) // "EasyEnvEAI('EECAF210',5)"})
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "005", "Baixa de titulo a receber                "                  ,""              , 'EECAF213(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "007", "Estorno de baixa de titulo a receber     "                  ,""              , 'EECAF221(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "008", "Inclusao de titulo a pagar               "                  ,""              , 'EECAF214(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "009", "Exclusao de titulo a pagar               "                  ,""              , 'EECAF214(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "010", "Baixa de titulo a pagar                  "                  ,""              , 'EECAF215(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "011", "Estorno de baixa de titulo a pagar       "                  ,""              , 'EECAF222(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "012", "Inclusão de titulo de desp. nacional     "                  ,""              , 'EECAF216(3)'             }) // GFP - 08/03/2012 - EasyEnvEAI('EECAF216',3)
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "013", "Exclusão de titulo de desp. nacional     "                  ,""              , 'EECAF216(5)'             }) // GFP - 08/03/2012 - EasyEnvEAI('EECAF216',5)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '050','Inclusão de Contrato de Financiamento                       ',''              , 'EECAF217(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '051','Inclusão de Encargo em Contrato de Financiamento            ',''              , 'EECAF218(3)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '054','Inclusão de Parcela do Principal em Financiamento           ',''              , 'EECAF218(3)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '055','Inclusão de Parcela de Juros em Financiamento               ',''              , 'EECAF218(3)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '062','Estorno de Contrato de Financiamento                        ',''              , 'EECAF217(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '063','Estorno de Encargo em Contrato de Financiamento             ',''              , 'EECAF218(5)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '066','Estorno de Parcela do Principal em Financiamento            ',''              , 'EECAF218(5)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '067','Estorno de Parcela de Juros em Financiamento                ',''              , 'EECAF218(5)'             }) //FSM - 08/02/2012
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '068','Liquidação de Parcela do Principal em Financiamento         ',''              , 'EECAF226(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '069','Liquidação de Parcela de Juros em Financiamento             ',''              , 'EECAF226(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '070','Estorno de Liquidação de Parcela de Principal               ',''              , 'EECAF229(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '071','Estorno de Liquidação de Parcela de Juros                   ',''              , 'EECAF229(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '072','Baixa do CPV                                                ',''              , 'EECAF223(3)'             }) // FSM - 16/01/2012 - EasyEnvEAI("EECAF223",3)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '073','Lançamento de variação cambial de NF                        ',''              , 'EECAF224(3)'             }) // GFP - 18/01/2012 - EasyEnvEAI("EECAF224",3)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '074','Estorno da Baixa do CPV                                     ',''              , 'EECAF223(5)'             }) // FSM - 16/01/2012 - EasyEnvEAI("EECAF223",5)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '075','Estorno do lançamento de variação cambial de NF             ',''              , 'EECAF224(5)'             }) // GFP - 18/01/2012 - EasyEnvEAI("EECAF224",5)
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '076','Contabilização dos contratos de Financiamento Ativos        ',''              , 'EECAF225(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '077','Liquidação de Encargo em Contrato de Financiamento          ',''              , 'EECAF226(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '078','Estorno da Liquidacao dos Contratos de Financiamento        ',''              , 'EECAF229(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '079','Compensação do Adiantamento                                 ',''              , 'EECAF227(3)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '080','Estorno da Compensação do Adiantamento                      ',''              , 'EECAF230(5)'             })
      aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '081','Contabilização dos contratos de Financiamento Excluidos     ',''              , 'EasyEnvEAI("EECAF228",3)'}) // GFP - 26/01/2012
      //NCF - 09/04/2014 - Tratamento de integração com fluxo alternativo de geração do Pedido
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '082','Alteração/Aprov. de Proforma do Pedido de Exportação        ',''              , 'EasyEnvEAI("EECAP100",3)'})//NCF - 02/09/2013
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '083','Alteração/Cancelamento do Pedido de Exportação              ',''              , 'EasyEnvEAI("EECAP100",5)'})//NCF - 02/09/2013
      //AAF - 10/10/2013 - Tratamento de baixa de comissão em título a receber
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '085','Baixa de Comissão em Título a Receber                       ',''              , 'EECAF231(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '086','Estorno de Baixa de Comissão em Título a Receber            ',''              , 'EECAF232(5)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '087','Inclusao Título a Receber referente a Comissão              ',''              , 'EECAF210(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '088','Estorno de Título a Receber referente a Comissão            ',''              , 'EECAF210(5)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '090','Estorno da Contabilização dos contratos de Financiamento    ',''              , 'EECAF225(5)'             })

      //THTS - 21/03/2017 - Tratamento para inclusao e exclusao de adiantamento a fornecedor com integracao Logix
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '091','Inclusão de adiantamento a fornecedor						   ',''              , 'EECAF520(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '092','Exclusão de adiantamento a fornecedor						   ',''              , 'EECAF520(5)'             })
      //THTS - 18/04/2017 - Tratamento para compensacao e estorno de adiantamento a fonrnecedor com integracao Logix
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '093','Compensação de adiantamento a fornecedor						   ',''              , 'EECAF521(3)'             })
      aAdd(aRecEYE, {      xFilial("EYE") , '010', '094','Estorno Compensação de adiantamento a fornecedor				   ',''              , 'EECAF522(5)'             })

      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '052','Inclusão de Invoice em Financiamento                        ','', 'EasyEnvEAI("ADAPTER",3)'})
      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '053','Inclusão de Liquidação de Invoice em Financiamento          ','', 'EasyEnvEAI("ADAPTER",3)'})
      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '064','Estorno de Invoice em Financiamento                         ','', 'EasyEnvEAI("ADAPTER",5)'})
      //aAdd(aRecEYE, {EYE->(xFilial('EYE')), '010', '065','Estorno de Liquidação de Invoice em Financiamento           ','', 'EasyEnvEAI("ADAPTER",5)'})
      //aAdd(aRecEYE, {EYE->(xFilial("EYE")), "010", "006", "Baixa de titulo a receber e adiantamento                   ","", "EasyEnvEAI('EECAF213',5)"})
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"001" ,"Solicitacao de Booking"                                      , "int_bk_request.xml"  ,""    }) //NCF - 21/06/2012 - Integ. INTTRA
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"002" ,"Recebimento de informacaoes de booking"                      , "int_bk_confirm.xml"  ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"003" ,"Envio de Shipping Instructions"                              , "int_si_send.xml"     ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"004" ,"Inttra Boundary Manager"                                     , "int_si_acknowled.xml",""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"005" ,"Recebimento de BL"                                           , "int_bl_receive.xml"  ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"006" ,"Recebimento de Track and Trace"                              , "int_tt_rec.xml"      ,""    })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")),"002" ,"008" ,"Inttra Boundary Manager"                                     , "int_bd_man.xml"      ,""    })

      //RRC - 13/02/2013 - Foi descontinuada a integração EasyLink da estufagem
      //aAdd(aRecEYE, {EYE->(xFilial("EYE")), "003", "001", "Inclusão de registros de container       "                  , "CONTAINER_INC.XML", ""                    })
      //aAdd(aRecEYE, {EYE->(xFilial("EYE")), "003", "002", "Inclusão de registros de estufagem       "                  , "ESTUFAGEM_INC.XML", ""                    })

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "003", "Inclusao de titulo de receita            "                  , "AVLINK003.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "004", "Exclusao de titulo de receita            "                  , "AVLINK004.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "005", "Baixa de titulo a receber                "                  , "AVLINK005.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "007", "Estorno de baixa de titulo a receber     "                  , "AVLINK007.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "008", "Inclusao de titulo a pagar               "                  , "AVLINK008.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "009", "Exclusao de titulo a pagar               "                  , "AVLINK009.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "010", "Baixa de titulo a pagar                  "                  , "AVLINK010.XML", ""                        })
      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "004", "011", "Estorno de baixa de titulo a pagar       "                  , "AVLINK011.XML", ""                        })

      aAdd(aRecEYE, {EYE->(xFilial("EYE")), "100", "100", "Geração de novo RE - NovoEX              "                  , "novoex_novo_re.xml", ""                   })
      If !(EYE->(FieldPos("EYE_FUNCT")) > 0)  //NCF - 24/08/2012
         For i := 1 to Len(aRecEYE)
            aDel( aRecEYE[i],Len(aRecEYE[i]) )
            aSize( aRecEYE[i],Len(aRecEYE[i])-1 )
         Next i
      EndIf

      If ValType(o) == "U"
         For nInc := 1 To Len(aTabelas)
            /////////////////////////////////////////////////////
            //Verifica se a tabela existe e se possui registros//
            /////////////////////////////////////////////////////
            If (ChkFile(aTabelas[nInc]) .and. Select(aTabelas[nInc]) > 0) .and. !(aTabelas[nInc])->(DbSeek(xFilial()))//(aTabelas[nInc])->(RecCount()) > 0
               //////////////////////////////
               //Não é necessário atualizar//
               //////////////////////////////
               Loop
            Else
               /////////////////////
               //Atualiza a tabela//
               /////////////////////
               DbSelectArea(aTabelas[nInc])
               For nInc2 := 1 To Len(&("aRec"+aTabelas[nInc]))
                  If RecLock(aTabelas[nInc],.T.)
                     For nInc3:=1 To Len(&("aInd"+aTabelas[nInc]))
                        If FieldPos(&("aInd"+aTabelas[nInc])[nInc3])>0
                           FieldPut(FieldPos(&("aInd"+aTabelas[nInc])[nInc3]),&("aRec"+aTabelas[nInc])[nInc2][nInc3])
                        EndIf
                     Next
                  EndIf
               Next
            EndIf
         Next
      Else

         //FDR - 27/07/11
         o:TableStruct("EYA",aIndEYA,1)
         o:TableStruct("EYB",aIndEYB,1)
         o:TableStruct("EYC",aIndEYC,1)
         o:TableStruct("EYD",aIndEYD,1)
         o:TableStruct("EYE",aIndEYE,1)

         If AVFLAGS('EEC_LOGIX')                  //NCF - 18/02/2019 - Verifica flag para implementar ação/serviço de alteração no modo exclui/inclui para os eventos principal,juros e encargos EFF.
            o:DelTableData("EYC",aDelEYCEAI,,.F.)
         EndIf

         o:TableData("EYA",aRecEYA,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYB",aRecEYB,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYC",aRecEYC,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYD",aRecEYD,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:TableData("EYE",aRecEYE,,.F.)//RMD - 22/12/14 - Incluído parâmetro para que não altere os registros já existenstes.
         o:DelTableData("EYC",aDelEYC,,.F.)//THTS - 19/12/2017 - Exclui a carga dos eventos do siscoserv da integracao 001 (SIGAEEC X SIGAFIN e SIGACTB)

      EndIf

   End Sequence

Return Nil

Static Function UTTESWHG (o)

   o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" },2)
   o:TableData("SX3"  ,{'E11_DESRED' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED1_PRCUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED1_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_QTDNCM' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED8_SALISE' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED9_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED9_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'ED9_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDA_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDA_QTDEST' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDC_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDC_QTDEST' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDC_QTDPRO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDD_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDD_QTD_EX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDD_QTD_OR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDE_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDG_PRCUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EDG_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE5_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE7_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE7_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRCFIX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRCUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRECOI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PRENEG' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PSBRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PSLQTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_PSLQUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_QTDFIX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_QTDLOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE8_VLPAG ', TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRCUN ', TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PRECOI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSBRTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSBRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSLQTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_PSLQUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_QT_AC ', TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_SALISE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EE9_VLPAG' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEB_TXCOMI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEC_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEC_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEC_VALCOM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEK_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_OUTROM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLFREM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLMERM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLNFM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEM_VLSEGM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEO_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLFREM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLMERC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLMERM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLNF' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLNFM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLOUTM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EES_VLSEGM' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEX_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEX_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PRCUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PREMI1' , TAM+DEC     })
   o:TableData("SX3"  ,{'EEY_PREMI2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EF8_VL_PCT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG0_CARGO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG0_PARC_C' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG1_QTDMT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EG1_QTDUC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI1_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_DESCON' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_INLAND' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_OUT_DE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_PACKIN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_PRUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI2_QUANT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI3_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_ENCARG' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_FOB_GE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_FOB_TO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_PESO_B' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI4_VAL_CO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI5_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI5_SALDO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'EI9_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIA_VALOR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIB_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EID_DESP' , TAM+DEC     })
   o:TableData("SX3"  ,{'EID_VLCORR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QT_EST' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTDCER' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTUCOF' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTUIPI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIJ_QTUPIS' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_PESO ', TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIS_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EIW_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW0_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW1_LIQMER' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW1_MER_US' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW1_VLRUNR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLLIQ ', TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLMER' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLMOED' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW2_VLRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_PESOB' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EW5_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX6_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH01' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH02' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH03' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH04' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH05' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH06' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH07' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH08' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH09' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYH10' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL01' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL02' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL03' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL04' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL05' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL06' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL07' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL08' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL09' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYL10' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS01' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS02' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS03' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS04' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS05' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS06' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS07' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS08' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS09' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_NYS10' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_VLMAX' , TAM+DEC     })
   o:TableData("SX3"  ,{'EX7_VLMIN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXP_PESBRU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXP_PESLIQ' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PRCINC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PRCTOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PRECO ', TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSBRTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSBRUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSLQTO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_PSLQUN' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_QE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_SALDO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXR_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_QTDEMB' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXS_QTDVNC' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXT_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXU_PESOBR' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXU_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXV_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'EXZ_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY2_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY5_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY5_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY6_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY6_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY7_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY8_SLDATU' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY8_SLDINI' , TAM+DEC     })
   o:TableData("SX3"  ,{'EY9_QTD' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_QTSEGUM' , TAM+DEC     })
   o:TableData("SX3"  ,{'W1_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_ENCARGO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_FOB_TOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_PARID_U' , TAM+DEC     })
   o:TableData("SX3"  ,{'W2_PESO_B ', TAM+DEC     })
   o:TableData("SX3"  ,{'W2_VAL_COM' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_PRECOVE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W3_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W4_FOB_TOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'W4_OUT_DES' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_QT_AC2' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W5_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W6_PESO_BR' , TAM+DEC     })
   o:TableData("SX3"  ,{'W6_PESO_TO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W6_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_PESO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W7_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_PRECO_F' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QT_AC' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QT_AC2' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_QTDE_UM' , TAM+DEC     })
   o:TableData("SX3"  ,{'W8_SALISEN' , TAM+DEC     })
   o:TableData("SX3"  ,{'WA_PGTANT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WA_SLDANT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WD_VAL_PRE' , TAM+DEC     })
   o:TableData("SX3"  ,{'WE_PRECO' , TAM+DEC     })
   o:TableData("SX3"  ,{'WE_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'WE_SALDO_Q' , TAM+DEC     })
   o:TableData("SX3"  ,{'WH_VALOR_R' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO1' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_KILO6' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR1' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'WI_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_01' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_02' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_03' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_04' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_05' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_06' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_07' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_08' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_09' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_10' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_11' , TAM+DEC     })
   o:TableData("SX3"  ,{'WJ_QTD_12' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO01' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO02' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO03' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO04' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO05' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO06' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO07' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO08' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO09' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO10' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO11' , TAM+DEC     })
   o:TableData("SX3"  ,{'WK_QT_PO12' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_DESCONT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_INLAND ', TAM+DEC     })
   o:TableData("SX3"  ,{'WN_OUT_DES' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_PACKING' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_PESOL' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_PRUNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTSEGUM' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTUCOF' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTUIPI' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QTUPIS' , TAM+DEC     })
   o:TableData("SX3"  ,{'WN_QUANT ', TAM+DEC     })
   o:TableData("SX3"  ,{'WP_QT_EST' , TAM+DEC     })
   o:TableData("SX3"  ,{'WS_PESO ', TAM+DEC     })
   o:TableData("SX3"  ,{'WS_QTDE' , TAM+DEC     })
   o:TableData("SX3"  ,{'WT_FOB_TOT' , TAM+DEC     })
   o:TableData("SX3"  ,{'WT_FOB_UNI' , TAM+DEC     })
   o:TableData("SX3"  ,{'WT_VL_UNIT' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_KILO6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YB_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_KILO6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR_K' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR1' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR2' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR3' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR4' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR5' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VALOR6' , TAM+DEC     })
   o:TableData("SX3"  ,{'YR_VL_MIN' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_MAXIMO' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_MINIMO' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_02' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_03' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_04' , TAM+DEC     })
   o:TableData("SX3"  ,{'YW_VLR_05' , TAM+DEC     })


Return Nil

/*
Funcao            : AjustaEYYSXB
Parametros        : Objeto de update PAI
Objetivos         : Excluir relacionamento SX9 errado da SW6 que não contem a loja na chave
Revisao           : -
Autor             : Tiago Henrique Tudisco dos Santos - THTS
Obs.              : O relacionamento correto com o campo Loja foi digitado para a versão 12.1.31 em Janeiro/2021
*/
Static Function AjusSX9SW6(o)
   Local aOrdSX9   := SaveOrd("SX9")
   Local aDadosSX9 := {}
   Local lTemLoja  := .F.
   Local nI := 0

   SX9->(dbSetOrder(2))//X9_CDOM + X9_DOM

   If SX9->(dbSeek("SW6" + "SA2"))
      While SX9->(!Eof()) .And. SX9->X9_DOM == "SA2" .And. SX9->X9_CDOM == "SW6"
         If "A2_LOJA" $ SX9->X9_EXPDOM
            lTemLoja := .T.
         Else
            If SX9->X9_ENABLE == "S"
               aAdd(aDadosSX9,{SX9->X9_DOM, SX9->X9_IDENT,SX9->X9_CDOM,SX9->X9_EXPDOM,SX9->X9_EXPCDOM})
            EndIf
         EndIf
         SX9->(dbSkip())
      End

      If lTemLoja .And. Len(aDadosSX9) > 0
         o:TableStruct( "SX9",{"X9_DOM","X9_IDENT" ,"X9_CDOM"  ,"X9_EXPDOM","X9_EXPCDOM","X9_ENABLE"},2)
         For nI := 1 To Len(aDadosSX9)
            o:TableData("SX9",{aDadosSX9[nI][1],aDadosSX9[nI][2],aDadosSX9[nI][3],aDadosSX9[nI][4],aDadosSX9[nI][5],"N"})
         Next
      EndIf
   EndIf

   RestOrd(aOrdSX9)

Return

Static Function AjusSX9Moe(o)
   Local aOrdSX9   := SaveOrd("SX9")
   Local aDadosSX9 := {}
   Local nI := 0

   SX9->(dbSetOrder(2))//X9_CDOM + X9_DOM
   //Tratamento para excluir relacionamento que contem a funcao dToS, pois da erro. Ja corrigida no AtuSX
   If SX9->(dbSeek("SWB" + "SYE"))
      While SX9->(!Eof()) .And. SX9->X9_DOM == "SYE" .And. SX9->X9_CDOM == "SWB"
         If "DTOS" $ SX9->X9_EXPDOM .And. SX9->X9_ENABLE == "S"
            aAdd(aDadosSX9,{SX9->X9_DOM, SX9->X9_IDENT,SX9->X9_CDOM,SX9->X9_EXPDOM,SX9->X9_EXPCDOM})
         EndIf
         SX9->(dbSkip())
      End
   EndIf
   //Tratamento para excluir relacionamendo da moeda pela tabela de taxas de conversao (SYE). Foram criados os corretos pela tabela de Moeda (SYF)
   If SX9->(dbSeek("SW6" + "SYE"))
      While SX9->(!Eof()) .And. SX9->X9_DOM == "SYE" .And. SX9->X9_CDOM == "SW6"
         If ("W6_FREMOED" $ SX9->X9_EXPCDOM .Or. "W6_SEGMOED" $ SX9->X9_EXPCDOM) .And. SX9->X9_ENABLE == "S"
            aAdd(aDadosSX9,{SX9->X9_DOM, SX9->X9_IDENT,SX9->X9_CDOM,SX9->X9_EXPDOM,SX9->X9_EXPCDOM})
         EndIf
         SX9->(dbSkip())
      End
   EndIf

   If Len(aDadosSX9) > 0
      o:TableStruct( "SX9",{"X9_DOM","X9_IDENT" ,"X9_CDOM"  ,"X9_EXPDOM","X9_EXPCDOM","X9_ENABLE"},2)
      For nI := 1 To Len(aDadosSX9)
         o:TableData("SX9",{aDadosSX9[nI][1],aDadosSX9[nI][2],aDadosSX9[nI][3],aDadosSX9[nI][4],aDadosSX9[nI][5],"N"}) //Desabilita Relacionamento
      Next
   EndIf

   RestOrd(aOrdSX9)
Return

/*
Funcao            : UPDEICSYO
Parametros        : Objeto de update PAI
Objetivos         : Atualizar campo errado em carga de SYO
Revisao           : -
Autor             : Tiago Henrique Tudisco dos Santos - THTS
Obs.              : -
*/
Static Function UPDEICSYO(o)

ChkFile("SYO")
SYO->(dbSetOrder(1)) //YO_FILIAL + YO_CAMPO
If SYO->(dbSeek(xFilial("SYO") + "WKIVFOBTOT")) .And. Alltrim(SYO->YO_ORIGEM) == 'BuscaTudo("SW9",BuscaInvoice()+SW7->W7_FORN,"W9_FOB_TOT")+SW9->W9_FRETEINT+SW9->W9_INLAND+SW9->W9_PACKIN+' //Campo Vlr Invoice do Gerador de Relatório
   o:TableStruct("SYO",{"YO_FILIAL"    ,"YO_CAMPO"    ,"YO_FASE"  ,"YO_ORIGEM"},1)
   o:TableData(  'SYO', {xFilial('SYO'), "WKIVFOBTOT" , "DI"      , 'BuscaTudo("SW9",BuscaInvoice()+SW7->W7_FORN,"W9_FOB_TOT")+SW9->W9_FRETEIN+SW9->W9_INLAND+SW9->W9_PACKING+SW9->W9_OUTDESP+SW9->W9_SEGURO-SW9->W9_DESCONT'})
EndIf

Return
