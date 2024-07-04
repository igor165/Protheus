#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

/*============================================================* 
Classe    : EASYOPESP
Parametro : -
Retorno   : -
Objetivo  : Está função terá por objetivo tratar as opções de Inclusão e Estorno de todas as Entradas e Saídas
            de produtos sob qualquer operação especial, além de controlar o saldo dessas operações.
By        : Allan Oliveira Monteiro
Data      : 18/03/2011 13:57
Revisão   :
Obs       : -
*=============================================================*/

Function EASYOPESP()
Return Nil

****======================****
Class EASYOPESP From AvObject
****======================****
                                            
   Data aCorresp
   Data lCtrTrans
   Data aRecTrans
   Data oWorkEJ3
   Data oWorkEJ4 
   Data oWorks
   Data cChaveIt
   
   Method New()                                                                       //Inicializador
   Method CreateWorks()                                                               //Cria Works   
   Method InitOperacao(cOpe,cTabela,aAlias,lInclui,lExibeMsg,cMomentOpe,lOnlyLoad)    //Inicializa operações                                  
   Method GetChaveItem(cOpe,cTabela,aAlias)                                           //Busca Chave do Item                                                                      
   Method LoadWorks(cOpe,cTabela,cTipo,cChaveItem,lInclui,lOnlyLoad)                   //Carrega Works EJ3(Entradas/Saídas) e EJ4(Controle de Saldos)
   Method GetChvSld(cOpe,cTabela,cTipo,cChaveItem)                                    //Busca Chaves de Saldos 
   Method CallCritBx(cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao)              //Executa função para regra de Critério de Baixa
   Method CheckSaldo(cOpeEntr,cEntr,cOpeSaida,cSaida,cTipo,aEASYITOPESP,lInclui)      //Verifica se os registro possuem Saldos 
   Method AddWorks(oEASYITOPESP,lInclui)                                              //Grava dados nas Works
   Method SaveOperacao(cNrDue)                                                        //Grava Tabelas EJ3(Entradas/Saídas) e EJ4(Controle de Saldos) 
   Method LoadCorresp(cOpe,cTabela,aAlias)                                            //Executa Macro de Correspondecia    
   Method SetDadoCorresp(cCampo,uDado)                                                //Adiciona registro no array aCorresp
   Method GetDadoCorresp(cCampo)                                                      //Retorna dado de algum campo do array aCorresp 
   Method DeleteWork()                                                                //Exclui as Works
   Method InitTrans()                                                                 //Indica que pode haver Retorno das transações
   Method EndTrans(lOk)                                                               //Retorna a transação dos dados caso alguma operação nao estiver correta
   Method SubstCmpos(cCampo,aAlias)                                                   //Metodo para substituir e executar macro dos campos de correspondencia 
   Method ExecCond(cOpe, cTabela, aAlias, lInclui,lExibeMsg,cMomentOpe,oOperacao)     //Executa a função de condição das Operações Especiais
   
      
End Class




*==================================================================*
Method New() Class EASYOPESP
*==================================================================*

Begin Sequence
   
   //Herança
   _Super:New()

   Self:lCtrTrans := .F.
   Self:aRecTrans := {}   
   Self:aCorresp := {} 
      
   //metodo da Classe AvObjet para indicara a Classe
   Self:setClassName("EASYOPESP")
     
   //Cria Works EJ3 e EJ4
   Self:CreateWorks()
   
   Self:ShowErrors(.T.)
   
End Sequence

Return Self 

*==================================================================*
Method GetChaveItem(cOpe,cTabela,aAlias) Class EASYOPESP 
*==================================================================* 
//Local nLinha,i
Local cChaveItem

DbSelectArea("EJ0")
EJ0->(DbSetOrder(1)) //EJ0_FILIAL+EJ0_COD+EJ0_ENTR

//Verifica se a Operação existe e se controla saldo
If EJ0->(DbSeek(xFilial("EJ0") + AvKey(cOpe,"EJ0_COD") + AvKey(cTabela,"EJ0_ENTR")))


   cChaveItem := Self:SubstCmpos(EJ0->EJ0_CHITEM,aAlias)
   
   If ValType(cChaveItem) == "U"
      cChaveItem := ""
   EndIf 
   
EndIf

Return cChaveItem


*===========================================================================*
Method ExecCond(cOpe, cTabela, aAlias, lInclui,lExibeMsg,cMomentOpe,oOperacao) Class EASYOPESP 
*===========================================================================*
Local lRet := .T.
Local bFunc 
 
Begin Sequence

If Empty(EJ0->EJ0_CONDBX)
   Break
EndIf

//Verifica se a função de condicao esta no repositório
If FindFunction(AllTrim(EJ0->EJ0_CONDBX))  
   TRY
      bFunc := &("{|a,b,c,d,e,f,g| "+AllTrim(EJ0->EJ0_CONDBX)+"(a,b,c,d,e,f,g)}")
      lRet := Eval(bFunc,cOpe,cTabela,aAlias,lInclui,lExibeMsg,cMomentOpe,oOperacao) //Executa a função
   CATCH 
      
   ENDTRY
   
   If ValType(__oError) == "O"
      Self:Error("Erro na execução da função: " + AllTrim(EJ0->EJ0_CONDBX) + " ERRO : " + ENTER + oError:Description)
   EndIf 
   
Else
   Self:Error("Função: " + AllTrim(EJ0->EJ0_CONDBX) + " não se encontra no repositório. Favor solicitar um patch de atualização ao Suporte!")
EndIf

End Sequence

Return lRet 




*========================================================================================*
Method InitOperacao(cOpe, cTabela, aAlias, lInclui,lExibeMsg,cMomentOpe, lOnlyLoad) Class EASYOPESP
*========================================================================================* 
Local lRet := .T.
Local aChavesSld := {} , aEASYITOPESP := {} , aEASYITOPAUX
Local bCodChaveSld
Local oEASYITOPESP
Local cChaveItem
Local i
Local cSaldo := 0  

Default cOpe      := ""
Default cTabela   := "" 
Default aAlias    := {}
Default lInclui   := .T.
Default lExibeMsg := .T.
Default lOnlyLoad := .F.

    
Begin Sequence  

   EJ0->(DbSetOrder(1)) //EJ0_FILIAL+EJ0_COD+EJ0_ENTR

   //Verifica se a Operação existe e se controla saldo
   If EJ0->(DbSeek(xFilial("EJ0") + AvKey(cOpe,"EJ0_COD") + AvKey(cTabela,"EJ0_ENTR")))
      If EJ0->EJ0_CONSLD <> "1"  .Or. !(AllTrim(UPPER(cMomentOpe)) $ AllTrim(UPPER(EJ0->EJ0_MNTOBX)))   .Or. !Self:ExecCond(cOpe, cTabela, aAlias, lInclui,lExibeMsg,cMomentOpe,Self)
         Break
      EndIf
   Else
      Self:Error("Operação informada não cadastrada na Tabela de Operações Especiais.")
      lRet := .F.
      Break  
   EndIf
   
   //Seleciona a Chave do Item
   cChaveItem := Self:GetChaveItem(cOpe,cTabela,aAlias)
   
   //Carrega as Works da tabela EJ3 e EJ4
   Self:LoadWorks(cOpe,cTabela,EJ0->EJ0_TIPO,cChaveItem,lInclui,lOnlyLoad)

   //Verifica se é entrada ou saida para chamar a Função de Critério de Baixa
   If EJ0->EJ0_TIPO == "E"
      EJ1->(DbSetOrder(1))//"EJ1_FILIAL+EJ1_CODE+EJ1_ENTR+EJ1_CODS+EJ1_SAIDA"
      If !lInclui     
         bCodChaveSld := {|cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao| Self:GetChvSld(cOpe,cTabela,EJ0->EJ0_TIPO,cChaveItem,oOperacao)} //Busca todas as chaves da EJ3(Entradas/Saidas)
      Else
         bCodChaveSld := {|cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao| {{"","",0}}} 
      EndIf
   ElseIf EJ0->EJ0_TIPO == "S"
      EJ1->(DbSetOrder(2))//"EJ1_FILIAL+EJ1_CODS+EJ1_SAIDA" 
      If lInclui     
         bCodChaveSld := {|cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao| Self:CallCritBx(cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao)} //Função de Critério de Baixa
      Else
         bCodChaveSld := {|cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao| Self:GetChvSld(cOpe,cTabela,EJ0->EJ0_TIPO,cChaveItem,oOperacao)} //Busca todas as chaves da EJ3(Entradas/Saidas)
      EndIf
   EndIf
   
   //Executando a Macro de Correspondencia
   Self:LoadCorresp(cOpe,cTabela,aAlias)
   
   //Processa apenas a carga dos dados já gravados na base
   If lOnlyLoad
      lRet:= .T.
      Break
   EndIf
    
   EJ1->(DbSeek(xFilial("EJ1")+AvKey(cOpe,"EJ1_CODE")+AvKey(cTabela,"EJ1_ENTR"))) 
   //Efetua o loop para pegar as operações inversas
   Do While EJ1->(!Eof()) .AND. xFilial("EJ1")+cOpe+cTabela == Left((EJ1->&(IndexKey())),Len(xFilial("EJ1")+cOpe+cTabela))
      
      //Inicializa o Vetor
      aEASYITOPAUX := {}
      
      //Executa o metodo de acordo com o tipo para selecionas as chaves de saldos
      aChavesSld := Eval(bCodChaveSld,EJ1->EJ1_CODE,EJ1->EJ1_ENTR,EJ1->EJ1_CODS,EJ1->EJ1_SAIDA,Self:GetDadoCorresp("EJ3_UM"),Self:GetDadoCorresp("EJ3_QTD"),Self)//AOM
      
      //Verifica se a quantida é maior que o Saldo disponivel
      If (EJ0->EJ0_TIPO == "E" .And. !lInclui) .Or. (EJ0->EJ0_TIPO == "S" .And. lInclui)
      
         If !Empty(aChavesSld)
         
            For i := 1 To Len(aChavesSld)
               cSaldo += aChavesSld[i][3]  
            Next i 
            
         EndIf
      
         If Self:GetDadoCorresp("EJ3_QTD") > cSaldo
            Self:Error("A quantidade a ser baixada é maior que o Saldo disponivel para o item: " + AllTrim(Self:GetDadoCorresp("EJ3_COD_I")) + ". A Quantidade é de : " + AllTrim(Str(Self:GetDadoCorresp("EJ3_QTD"))) + " e o Saldo é de: " + AllTrim(Str(cSaldo)) + ".")
            Break
         EndIf
         
      EndIf
      
      
      
      For i:= 1 To Len(aChavesSld)       //Chave item,Ope. Entr     , Entrada     , Ope. Saida  , Saida        ,Tipo(E/S)     , aAlias, Array{Chv Sld , Un, Qtd} , Cmpos Correspondencia,Inclusão?
         oEASYITOPESP := EASYITOPESP():New(cChaveItem, EJ1->EJ1_CODE,EJ1->EJ1_ENTR,EJ1->EJ1_CODS,EJ1->EJ1_SAIDA,EJ0->EJ0_TIPO , aAlias, aChavesSld[i]            , Self:aCorresp        ,lInclui  )//Classe para validar e carregar Item
         
         //Retorna possiveis erros encontrados
         Self:Error(oEASYITOPESP:aError)
         
         //Adiciona objeto da classe no array
         AADD(aEASYITOPESP,oEASYITOPESP)
         
         //Adiciona objeto no vetor para checar saldos
         AADD(aEASYITOPAUX,oEASYITOPESP)
            
      Next i 
       
      //Verifica se o saldo será abatido corretamente
      Self:CheckSaldo(EJ1->EJ1_CODE,EJ1->EJ1_ENTR,EJ1->EJ1_CODS,EJ1->EJ1_SAIDA,EJ0->EJ0_TIPO,aEASYITOPAUX,lInclui)

   EJ1->(DbSkip())    
   EndDo  
   
End Sequence
   
   If !Self:lError
      For i := 1 To Len(aEASYITOPESP)

        //Carregando dados EJ3 e EJ4 de acordo com a operação
        Self:AddWorks(aEASYITOPESP[i],lInclui) 
       Next i    
   Else
      //Exibe os possiveis Erros
      If lExibeMsg
         Self:ShowErrors(.T.)
         Self:ResetError()
      EndIf
      lRet := .F.
   EndIf
   

Return lRet

*==================================================================*
Method CreateWorks() Class EASYOPESP
*==================================================================* 

//Criando work para tabel EJ3
Self:oWorks := EasyWorks() 

Self:oWorkEJ3 := Self:oWorks:NewWork()
Self:oWorkEJ3:cAlias     := "WorkEJ3" 
Self:oWorkEJ3:aCampos    := {{"EJ3_RECNO","N",7,0}}
Self:oWorkEJ3:cTabela    := "EJ3"
Self:oWorkEJ3:lAddIndex  := .T.
Self:oWorkEJ3:cDriver    := "TOPCONN"
Self:oWorkEJ3:lVirtuais  := .T.
Self:oWorkEJ3:lMemo      := .F.
Self:oWorkEJ3:lShared    := .F.
Self:oWorkEJ3:Create() 


//Criando work para tabel EJ4
Self:oWorkEJ4 := Self:oWorks:NewWork()
Self:oWorkEJ4:cAlias     := "WorkEJ4" 
Self:oWorkEJ4:aCampos    := {{"EJ4_RECNO","N",7,0}}
Self:oWorkEJ4:cTabela    := "EJ4"
Self:oWorkEJ4:lAddIndex  := .T.
Self:oWorkEJ4:cDriver    := "TOPCONN"
Self:oWorkEJ4:lVirtuais  := .T.
Self:oWorkEJ4:lMemo      := .F.
Self:oWorkEJ4:lShared    := .F.
Self:oWorkEJ4:Create() 


//Retorna possiveis erros encontrados
Self:Error(Self:oWorkEJ3:aError) 
Self:Error(Self:oWorkEJ4:aError)


Return  Nil 


*==================================================================*
Method  LoadWorks(cOpe,cTabela,cTipo,cChaveItem,lInclui,lOnlyLoad) Class EASYOPESP
*==================================================================*  
Local cQuery := "" , cCond := "", cOpeEJ4 := "" , cTabelaEJ4 := ""
Local lRet := .T. 
Local cChave , nRecno := 0, nIndex := 0
Default lOnlyLoad:= .F.

Begin Sequence

   /*********** ENTRADAS / SAIDAS **********/
   
   If cTipo == "E"
      EJ3->(DbSetOrder(2)) //EJ3_FILIAL+ EJ3_CODE + EJ3_ENTR + EJ3_CHITEM + EJ3_CHAVE
   ElseIf cTipo == "S"
      EJ3->(DbSetOrder(3))//EJ3_FILIAL+ EJ3_CODS + EJ3_SAIDA + EJ3_CHITEM + EJ3_CHAVE
   EndIf 
   
   WorkEJ3->(DbSetOrder(1)) //EJ3_CODE + EJ3_ENTR + EJ3_CODS + EJ3_SAIDA+  EJ3_CHITEM + EJ3_CHAVE
   
   //Carrega WorkEJ3
   EJ3->(DbSeek(xFilial("EJ3") + AvKey(cOpe,"EJ3_CODE") + AvKey(cTabela,"EJ3_ENTR") + AvKey(cChaveItem,"EJ3_CHITEM")))  
   Do While EJ3->(!Eof()) .AND. xFilial("EJ1")+cOpe+cTabela+cChaveItem == Left((EJ3->&(IndexKey())),Len(xFilial("EJ1")+cOpe+cTabela+cChaveItem))
     If SoftLock("EJ3")
        If !(WorkEJ3->(DbSeek(EJ3->(&(WorkEJ3->(IndexKey()))))))
           WorkEJ3->(RecLock("WorkEJ3",.T.))//Inclusao
           AvReplace("EJ3","WorkEJ3") 
           WorkEJ3->EJ3_RECNO := EJ3->(Recno())
           WorkEJ3->(MsUnlock())
        EndIf
        
        If cTipo == "E" .And. !lInclui //Carrega as operaçoes inversas 
        
           nRecno := EJ3->(Recno())//Guarda o recno do registro posicionado
           cChave := EJ3->EJ3_CHAVE 
           nIndex := EJ3->(IndexOrd())
           
           EJ1->(DbSetOrder(1))//"EJ1_FILIAL+EJ1_CODE+EJ1_ENTR+EJ1_CODS+EJ1_SAIDA" 
           EJ3->(DbSetOrder(4))//EJ3_FILIAL+ EJ3_CODE + EJ3_ENTR + EJ3_CODS + EJ3_SAIDA+ EJ3_CHAVE + EJ3_DATA
           
           EJ1->(DbSeek(xFilial("EJ1") + cOpe + cTabela))
           
           Do While EJ1->(!Eof()) .AND. xFilial("EJ1")+cOpe+cTabela == Left((EJ1->&(IndexKey())),Len(xFilial("EJ1")+cOpe+cTabela))
        
              Do While EJ3->(!Eof()) .And. xFilial("EJ3")+EJ3->EJ3_CODE + EJ3->EJ3_ENTR + EJ3->EJ3_CODS + EJ3->EJ3_SAIDA+ EJ3->EJ3_CHAVE == ;
                                           xFilial("EJ1")+EJ1->EJ1_CODE + EJ1->EJ1_ENTR + EJ1->EJ1_CODS + EJ1->EJ1_SAIDA+ AvKey(cChave,"EJ3_CHAVE")
                 If !(WorkEJ3->(DbSeek(EJ3->EJ3_CODE + EJ3->EJ3_ENTR + EJ3->EJ3_CODS + EJ3->EJ3_SAIDA+  EJ3->EJ3_CHITEM + EJ3->EJ3_CHAVE)))
                    WorkEJ3->(RecLock("WorkEJ3",.T.))//Inclusao
                    AvReplace("EJ3","WorkEJ3") 
                    WorkEJ3->EJ3_RECNO := EJ3->(Recno())
                    WorkEJ3->(MsUnlock())
                 EndIf   
              EJ3->(DbSkip())
              EndDo
              
           EJ1->(DbSkip())  
           EndDo
        
        EndIf 
        If !lOnlyLoad
           EJ3->(DbSetOrder(nIndex))
           EJ3->(DbGoTo(nRecno))
        EndIf
     Else
        Self:Error("Não foi possivel carregar todos os dados da tabela de Entradas/Saída, poís possuem registros travados.")
        lRet := .F.
        Break
     EndIf
   EJ3->(DbSkip())
   EndDo
   

   
   /*********** CONTROLE DE SALDOS **********/
   
   //Carrega WorkEJ4 se for (Saída e Inclusão) ou (Entrada e Estorno)
   If (EJ0->EJ0_TIPO == "E" .And. lInclui .And. !lOnlyLoad) .OR. (!lInclui .And. EJ0->EJ0_TIPO == "S")
      Break
   EndIf
        
   If EJ0->EJ0_TIPO == "S"
      cOpeEJ4    := "EJ4_CODS"
      cTabelaEJ4 := "EJ4_SAIDA"
   Else
      cOpeEJ4    := "EJ4_CODE"
      cTabelaEJ4 := "EJ4_ENTR"
   EndIf
   

   cQuery := "SELECT * FROM " + RetSqlName("EJ4") + " EJ4 " 
   cCond  := "WHERE " + cOpeEJ4 + " = '"  + EJ0->EJ0_COD + "' AND " + cTabelaEJ4 + " = '" + EJ0->EJ0_ENTR + "' "
   cCond  += "AND EJ4.EJ4_SLDI > 0 AND EJ4.D_E_L_E_T_ <> '*'" 

   cQuery:=ChangeQuery(cQuery+cCond) 
   
   If Select("QRY_EJ4") > 0
      QRY_EJ4->(DbCloseArea())
   EndIf

   TcQuery cQuery ALIAS "QRY_EJ4" NEW


   TcSetField("QRY_EJ4","EJ4_QTEUM1","N", AVSX3("EJ4_QTEUM1",3), AVSX3("EJ4_QTEUM1",4)) //Qtde 1a Ent.
   TcSetField("QRY_EJ4","EJ4_QTSUM1","N", AVSX3("EJ4_QTSUM1",3), AVSX3("EJ4_QTSUM1",4)) //Qtde da Saida da 1a Ent.
   TcSetField("QRY_EJ4","EJ4_SLD1"  ,"N", AVSX3("EJ4_SLD1",3)  , AVSX3("EJ4_SLD1",4)  ) //Sld 1a Ent.
   TcSetField("QRY_EJ4","EJ4_QTEUMI","N", AVSX3("EJ4_QTEUMI",3), AVSX3("EJ4_QTEUMI",4)) //Qtde Item Entr
   TcSetField("QRY_EJ4","EJ4_QTSUMI","N", AVSX3("EJ4_QTSUMI",3), AVSX3("EJ4_QTSUMI",4)) //Qtde Item Saida
   TcSetField("QRY_EJ4","EJ4_SLDI"  ,"N", AVSX3("EJ4_SLDI",3)  , AVSX3("EJ4_SLDI",4)  ) //Sld Item
   TcSetField("QRY_EJ4","EJ4_QTEUMN","N", AVSX3("EJ4_QTEUMN",3), AVSX3("EJ4_QTEUMN",4)) //Qtde NCM Entr
   TcSetField("QRY_EJ4","EJ4_QTSUMN","N", AVSX3("EJ4_QTSUMN",3), AVSX3("EJ4_QTSUMN",4)) //Qtde NCM Saida 
   TcSetField("QRY_EJ4","EJ4_SLDN"  ,"N", AVSX3("EJ4_SLDN",3)  , AVSX3("EJ4_SLDN",4)  ) //Sld NCM
   TcSetField("QRY_EJ4","EJ4_QTDKGE","N", AVSX3("EJ4_QTDKGE",3), AVSX3("EJ4_QTDKGE",4)) //Qtde Peso Entr     	
   TcSetField("QRY_EJ4","EJ4_QTDKGS","N", AVSX3("EJ4_QTDKGS",3), AVSX3("EJ4_QTDKGS",4)) //Qtde Peso Saida 
   TcSetField("QRY_EJ4","EJ4_SLDKG" ,"N", AVSX3("EJ4_SLDKG",3) , AVSX3("EJ4_SLDKG",4) ) //Sld Peso
   TcSetField("QRY_EJ4","EJ4_DATA"  ,"D", AVSX3("EJ4_DATA",3)  , AVSX3("EJ4_DATA",4)  ) //Data 1a Ent.

   //Carrega Dados na WorkEJ4
   QRY_EJ4->(DbGoTop())
   WorkEJ4->(DbSetOrder(1))//EJ4_FILIAL+EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE
   While QRY_EJ4->(!EOF())
      EJ4->(DbGoTo(QRY_EJ4->R_E_C_N_O_))
      If SoftLock("EJ4") //Verifica se o registro está bloqueado
         If !(WorkEJ4->(DbSeek(QRY_EJ4->(EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE))))
            WorkEJ4->(RecLock("WorkEJ4",.T.))//Inclusao 
            AvReplace("QRY_EJ4","WorkEJ4")
            WorkEJ4->EJ4_RECNO := EJ4->(Recno())
            WorkEJ4->(MsUnlock())
         EndIf
      Else
        Self:Error("Não foi possivel carregar todos os dados da tabela de Controle de Saldos, poís possuem registros travados.")
        lRet := .F.
        Break
      EndIf
   QRY_EJ4->(DbSkip())
   EndDo


End Sequence

Return lRet      


*==================================================================*
Method GetChvSld(cOpe,cTabela,cTipo,cChaveItem,oOperacao) Class EASYOPESP 
*==================================================================* 
Local aChaveSld := {}

If cTipo == "E"
   WorkEJ3->(DbSetOrder(2))// EJ3_CODE + EJ3_ENTR + EJ3_CHITEM + EJ3_CHAVE
ElseIf cTipo == "S"
   WorkEJ3->(DbSetOrder(3))// EJ3_CODS + EJ3_SAIDA+ EJ3_CHITEM + EJ3_CHAVE
EndIf

//Verifica as chaves do saldo carregados na WorkEJ3
WorkEJ3->(DbSeek(AvKey(cOpe,"EJ3_CODE") + AvKey(cTabela,"EJ3_ENTR") +  AvKey(cChaveItem,"EJ3_CHITEM")))
Do While WorkEJ3->(!EOF()) .And. AvKey(cOpe,"EJ3_CODE")+AvKey(cTabela,"EJ3_ENTR")+AvKey(cChaveItem,"EJ3_CHITEM");
                             == Left((WorkEJ3->&(IndexKey())),Len(AvKey(cOpe,"EJ3_CODE")+AvKey(cTabela,"EJ3_ENTR")+AvKey(cChaveItem,"EJ3_CHITEM")))

   //Verifica se a chave esta adicionada no Array
   If aScan(aChaveSld,{|X| AllTrim(X[1]) == AllTrim(WorkEJ3->EJ3_CHAVE)}) == 0                          
      AADD(aChaveSld,{WorkEJ3->EJ3_CHAVE,WorkEJ3->EJ3_UM1,WorkEJ3->EJ3_QTDUM1})
   EndIf
WorkEJ3->(DbSkip())
EndDo

If Empty(aChaveSld)
   AADD(aChaveSld,{"","",0})
EndIf

Return aClone(aChaveSld)

*===========================================================================*
Method CallCritBx(cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao) Class EASYOPESP 
*===========================================================================*
Local nPos := 0
Local cFuncao := ""
Local aChvSld := {}
Local bFunc

Default nQtd := 0
Default cUn  := ""

Begin Sequence

If Empty(EJ0->EJ0_CRITER)
   Break
EndIf

//Verifica se a função de critério esta no repositório
If FindFunction(AllTrim(EJ0->EJ0_CRITER))  
   TRY
      bFunc := &("{|a,b,c,d,e,f,g| "+AllTrim(EJ0->EJ0_CRITER)+"(a,b,c,d,e,f,g)}")
      aChvSld := Eval(bFunc,cOpeEntr,cEntr,cOpeSaida,cSaida,nQtd,cUn,oOperacao) //Executa a função
   CATCH      
   
   ENDTRY
   
   If ValType(__oError) == "O"
      Self:Error("Erro na execução da função: " + AllTrim(EJ0->EJ0_CRITER) + " ERRO : " + ENTER + oError:Description)
   EndIf
   
Else
   Self:Error("Função: " + AllTrim(EJ0->EJ0_CRITER) + " não se encontra no repositório. Favor solicitar um patch de atualização ao Suporte!")
EndIf


End Sequence

Return aChvSld 




*====================================================================================*
Method CheckSaldo(cOpeEntr,cEntr,cOpeSaida,cSaida,cTipo,aEASYITOPESP,lInclui) Class EASYOPESP 
*====================================================================================*
Local lRet := .T. 
Local i , j, nOperacao := 1, nPos
Local nEJ4QTEUM1 := nEJ4QTEUMI := nEJ4QTEUMN := nEJ4QTDKGE := nEJ4QTSUM1 := nEJ4QTSUMI := nEJ4QTSUMN := nEJ4QTDKGS := nEJ4SLD1 := nEJ4SLDI := nEJ4SLDN :=  nEJ4SLDKG := 0 
Local aItemBaixa := {} , aChaveEst := {}
Local nSomaQtd := 0



//Verifica se a operação é (Entrada e Estorno) ou (Saida e Inclusão) para abater os Saldos
If (cTipo == "E" .And. !(lInclui))  .Or. (cTipo == "S" .And. lInclui) 
  nOperacao := -1
EndIf 


//Verifica os Saldos e concatena as quantidades para a mesma chave de Saldo
For i := 1 To Len(aEASYITOPESP)
   If (nPos := aScan(aItemBaixa,{|X| AllTrim(X[1]) == AllTrim(aEASYITOPESP[i]:aChaveSld[1])})) > 0
      aItemBaixa[nPos][2] += aEASYITOPESP[i]:GetDadoEJ3("EJ3_QTDUM1")
      aItemBaixa[nPos][3] += aEASYITOPESP[i]:GetDadoEJ3("EJ3_QTDUMI")
      aItemBaixa[nPos][4] += aEASYITOPESP[i]:GetDadoEJ3("EJ3_QTDUMN") 
      aItemBaixa[nPos][5] += aEASYITOPESP[i]:GetDadoEJ3("EJ3_PESO")
   Else           //Chave de Saldo                 , Quantidade da 1º Entrada               , Quantidade do Item                      , Quantidade NCM                          , Quantidade Peso
      AADD(aItemBaixa,{aEASYITOPESP[i]:aChaveSld[1],aEASYITOPESP[i]:GetDadoEJ3("EJ3_QTDUM1"), aEASYITOPESP[i]:GetDadoEJ3("EJ3_QTDUMI"), aEASYITOPESP[i]:GetDadoEJ3("EJ3_QTDUMN"),aEASYITOPESP[i]:GetDadoEJ3("EJ3_PESO")})
   EndIf 
   
   //Adiciona as Chaves de Saldo para a verificação do estorno
   If cTipo == "E" .And. !(lInclui)
      AADD(aChaveEst,aEASYITOPESP[i]:aChaveSld[1])
   EndIf

Next i 

//Valida o estorno da entrada, verificando se a baixa já nao foi utilizada em uma Saida anterior
If cTipo == "E" .And. !(lInclui)

   For i := 1 To Len(aChaveEst)
   
     WorkEJ3->(DbSetOrder(4))//EJ3_FILIAL+ EJ3_CODE + EJ3_ENTR + EJ3_CODS + EJ3_SAIDA+ EJ3_CHAVE + EJ3_DATA
     While WorkEJ3->EJ3_CODE == AvKey(cOpeEntr,"EJ3_CODE") .And. WorkEJ3->EJ3_ENTR == AvKey(cEntr,"EJ3_ENTR") .And. WorkEJ3->EJ3_CODS == AvKey(cOpeSaida,"EJ3_CODS") .And. ; 
           WorkEJ3->EJ3_SAIDA == AvKey(cSaida,"EJ3_SAIDA") .And. WorkEJ3->EJ3_CHAVE ==  AvKey(aChaveEst[i],"EJ3_CHAVE")
           
          If WorkEJ3->EJ3_TIPO == "S"
             
             For j := 0 To Len(aEASYITOPESP)
                
                If aEASYITOPESP[j]:GetDadoEJ3("EJ3_CHAVE") == WorkEJ3->EJ3_CHAVE .And. aEASYITOPESP[j]:GetDadoEJ3("EJ3_DATA") <= WorkEJ3->EJ3_DATA .And. ;
                   aEASYITOPESP[j]:GetDadoEJ3("EJ3_RECNO") < WorkEJ3->EJ3_RECNO
                
                   nSomaQtd += aEASYITOPESP[j]:GetDadoEJ3("EJ3_QTDUMN")
                
                EndIf
               
             Next j
             
             If  WorkEJ3->EJ3_SLDNCM - nSomaQtd < 0
                Self:Error("Não é possivel realizar o estorno da Entrada pois já foi cadastrada uma Saida para a mesma, na data de " + DtoS(aEASYITOPESP[j]:GetDadoEJ3("EJ3_DATA")))
                lRet := .F. 
             EndIf

          
          EndIf
          
     WorkEJ3->(DbSkip())      
     EndDo
      
   Next i

EndIf




For i := 1 To Len(aItemBaixa)


   WorkEJ4->(DbSetOrder(1))//EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE 
   If WorkEJ4->(DbSeek(AvKey(cOpeEntr,"EJ4_CODE") + AvKey(cEntr,"EJ4_ENTR") + AvKey(cOpeSaida,"EJ4_CODS") + AvKey(cSaida,"EJ4_SAIDA") + AvKey(aItemBaixa[i][1],"EJ4_CHAVE")))
   
      nEJ4QTEUM1 := WorkEJ4->EJ4_QTEUM1 //Qtd 1º Entrada
      nEJ4QTEUMI := WorkEJ4->EJ4_QTEUMI //Qtd Item da Entrada
      nEJ4QTEUMN := WorkEJ4->EJ4_QTEUMN //Qtd NCM da Entrada
      nEJ4QTDKGE := WorkEJ4->EJ4_QTDKGE //Qtd Peso Entrada
      nEJ4QTSUM1 := WorkEJ4->EJ4_QTSUM1 //Qtd da Saida da 1º Entrada
      nEJ4QTSUMI := WorkEJ4->EJ4_QTSUMI //Qtd Item da Saida
      nEJ4QTSUMN := WorkEJ4->EJ4_QTSUMN //Qtd NCM da Saida
      nEJ4QTDKGS := WorkEJ4->EJ4_QTDKGS //Qtd Peso Saida
       

      If aEASYITOPESP[i]:cTipo == "E" //Entrada
         nEJ4QTEUM1 += (nOperacao * aItemBaixa[i][2]) //1º Qtd
         nEJ4QTEUMI += (nOperacao * aItemBaixa[i][3]) //Qtd Item
         nEJ4QTEUMN += (nOperacao * aItemBaixa[i][4]) //Qtd NCM
         nEJ4QTDKGE += (nOperacao * aItemBaixa[i][5]) //Qtd Peso
      ElseIf aEASYITOPESP[i]:cTipo == "S" //Saida
         nEJ4QTSUM1 -= (nOperacao * aItemBaixa[i][2]) //1º Qtd
         nEJ4QTSUMI -= (nOperacao * aItemBaixa[i][3]) //Qtd Item
         nEJ4QTSUMN -= (nOperacao * aItemBaixa[i][4]) //Qtd NCm 
         nEJ4QTDKGS -= (nOperacao * aItemBaixa[i][5]) //Qtd Peso
      EndIf
   
      nEJ4SLD1 := nEJ4QTEUM1 - nEJ4QTSUM1 //Saldo da 1º
      nEJ4SLDI := nEJ4QTEUMI - nEJ4QTSUMI //Saldo do Item
      nEJ4SLDN := nEJ4QTEUMN - nEJ4QTSUMN //Saldo NCM
      nEJ4SLDKG:= nEJ4QTDKGE - nEJ4QTDKGS //Saldo Peso   
      
      //Verifica se os Saldos ficarão negativos e exibe as mensagens dos erros
      If nEJ4SLD1 < 0 .Or. nEJ4SLDI < 0 .Or. nEJ4SLDN < 0 .Or. nEJ4SLDKG < 0
         
         If (cTipo == "E" .And. !(lInclui))//Entrada e Estorno
            Self:Error("Saldo da Operação " + AllTrim(EJ0->EJ0_DESC)     + " é insuficiente para realizar o estorno.") 
            Self:Error("O saldo atual em " + AllTrim(WorkEJ4->EJ4_UM1)   + "  é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLD1)) + " e a quantidade a ser estornada é de: " + AllTrim(Str(aItemBaixa[i][2])))      
            Self:Error("O saldo atual em " + AllTrim(WorkEJ4->EJ4_UMIT)  + "  é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLDI)) + " e a quantidade a ser estornada é de: " + AllTrim(Str(aItemBaixa[i][3])))      
            Self:Error("O saldo atual em " + AllTrim(WorkEJ4->EJ4_UMNCM) + "  é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLDN)) + " e a quantidade a ser estornada é de: " + AllTrim(Str(aItemBaixa[i][4])))      
            Self:Error("O saldo atual em KG é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLDKG)) + " e a quantidade a ser estornada é de: " + AllTrim(Str(aItemBaixa[i][5])))      
         ElseIf cTipo == "S" .And. lInclui//Saida e Inclusão
            Self:Error("Saldo da Operação " + AllTrim(EJ0->EJ0_DESC)     + " é insuficiente para realizar a baixa.") 
            Self:Error("O saldo atual em " + AllTrim(WorkEJ4->EJ4_UM1)   + "  é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLD1)) + " e a quantidade a ser baixada é de: " + AllTrim(Str(aItemBaixa[i][2])))      
            Self:Error("O saldo atual em " + AllTrim(WorkEJ4->EJ4_UMIT)  + "  é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLDI)) + " e a quantidade a ser baixada é de: " + AllTrim(Str(aItemBaixa[i][3])))      
            Self:Error("O saldo atual em " + AllTrim(WorkEJ4->EJ4_UMNCM) + "  é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLDN)) + " e a quantidade a ser baixada é de: " + AllTrim(Str(aItemBaixa[i][4])))     
            Self:Error("O saldo atual em KG é  de: " + AllTrim(Str(WorkEJ4->EJ4_SLDKG)) + " e a quantidade a ser baixada é de: " + AllTrim(Str(aItemBaixa[i][5])))
         EndIf
         lRet := .F.
      EndIf
      
   EndIf
Next i

Return lRet


*==================================================================*
Method SaveOperacao(cNrDue) Class EASYOPESP 
*==================================================================*
Local lSeek
Local aChaveEJ4:= {}, nPos:= 0, cChaveEJ4:= ""
Default cNrDue:= ""

WorkEJ3->(DbGoTop())
WorkEJ4->(DbGoTop())
EJ4->(DbSetOrder(1))//EJ4_FILIAL+EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE
EJ3->(DbSetOrder(1))//EJ3_FILIAL+ EJ3_CODE + EJ3_ENTR + EJ3_CODS + EJ3_SAIDA+  EJ3_CHITEM + EJ3_CHAVE



//Gravando tabela de Entrada/Saída
Do While WorkEJ3->(!EOF())
   lSeek := EJ3->(DbSeek(xFilial("EJ3") + WorkEJ3->EJ3_CODE + WorkEJ3->EJ3_ENTR + WorkEJ3->EJ3_CODS + WorkEJ3->EJ3_SAIDA + WorkEJ3->EJ3_CHITEM + WorkEJ3->EJ3_CHAVE))
   If EJ3->(RecLock("EJ3", !lSeek))  
      If lSeek .And. WorkEJ3->EJ3_QTDUM1 <= 0
         EJ3->(DbDelete()) //Exclusão 
      Else
         AvReplace("WorkEJ3","EJ3") //Inclusão ou Alteração
         If (Empty(EJ3->EJ3_RE) .Or. AllTrim(EJ3->EJ3_RE) <> AllTrim(cNrDue))

            //armazena a chave para replicar a atualização do número da DUE para a tabela EJ4
            cChaveEJ4:= EJ3->(xFilial("EJ3") + WorkEJ3->EJ3_CODE + WorkEJ3->EJ3_ENTR + WorkEJ3->EJ3_CODS + WorkEJ3->EJ3_SAIDA + WorkEJ3->EJ3_CHAVE)
            nPos:= AScan(aChaveEJ4, {|x| x[1] == cChaveEJ4})
            If nPos == 0
               AAdd(aChaveEJ4, {cChaveEJ4, EJ3->EJ3_CHAVE})
            EndIf

            EJ3->EJ3_RE:= cNrDue
         EndIf
      EndIf
   EJ3->(MsUnLock())
   EndIf
WorkEJ3->(DbSkip())
EndDo


//Gravando tabela de Controle de Saldos
Do While WorkEJ4->(!EOF())
   lSeek := EJ4->(DbSeek(xFilial("EJ4") + WorkEJ4->EJ4_CODE + WorkEJ4->EJ4_ENTR + WorkEJ4->EJ4_CODS + WorkEJ4->EJ4_SAIDA + WorkEJ4->EJ4_CHAVE))
   If EJ4->(RecLock("EJ4", !lSeek)) 
      If lSeek .And. WorkEJ4->EJ4_QTEUM1 <= 0  .And. WorkEJ4->EJ4_QTSUM1 <= 0
         EJ4->(DbDelete())//Exclusão 
      Else
         AvReplace("WorkEJ4","EJ4")//Inclusão ou Alteração
         If (Empty(EJ4->EJ4_RE) .Or. AllTrim(EJ4->EJ4_RE) <> AllTrim(cNrDue)) 

            cChaveEJ4:= EJ4->(xFilial("EJ4") + WorkEJ4->EJ4_CODE + WorkEJ4->EJ4_ENTR + WorkEJ4->EJ4_CODS + WorkEJ4->EJ4_SAIDA + WorkEJ4->EJ4_CHAVE)
            nPos:= AScan(aChaveEJ4, {|x| x[1] == cChaveEJ4})

            If nPos > 0
               EJ4->EJ4_RE:= cNrDue
            EndIf
         EndIf
      EndIf
   EJ4->(MsUnLock())
   EndIf
WorkEJ4->(DbSkip())
EndDo


Return Nil

*==================================================================*
Method AddWorks(oEASYITOPESP,lInclui) Class EASYOPESP
*==================================================================*
Local i, nOperacao := 1 
Local cCmpEJ3 := "EJ3_QTD|EJ3_QTDUM1|EJ3_QTDUMI|EJ3_QTDUMN|EJ3_PESO" 
Local cCampoExiste := ""
Local lSeek
Local aAux

//Verifica se a operação é (Entrada e Estorno) ou (Saida e Inclusão) para abater os Saldos
If (oEASYITOPESP:cTipo == "E" .And. !(lInclui))  .Or. (oEASYITOPESP:cTipo == "S" .And. lInclui) 
   nOperacao := -1
EndIf

Begin Sequence
    

   WorkEJ3->(DbSetOrder(1))//EJ3_CODE + EJ3_ENTR + EJ3_CODS + EJ3_SAIDA+  EJ3_CHITEM + EJ3_CHAVE    
   lSeek := WorkEJ3->(DbSeek(AvKey(oEASYITOPESP:GetDadoEJ3("EJ3_CODE") ,"EJ3_CODE") + AvKey(oEASYITOPESP:GetDadoEJ3("EJ3_ENTR") ,"EJ3_ENTR") + ;
                        AvKey(oEASYITOPESP:GetDadoEJ3("EJ3_CODS") ,"EJ3_CODS") +  AvKey(oEASYITOPESP:GetDadoEJ3("EJ3_SAIDA"),"EJ3_SAIDA")+ ;
                        AvKey(oEASYITOPESP:GetDadoEJ3("EJ3_CHITEM"),"EJ3_CHITEM") + AvKey(oEASYITOPESP:GetDadoEJ3("EJ3_CHAVE"),"EJ3_CHAVE")))//EJ3_CODE + EJ3_ENTR + EJ3_CODS + EJ3_SAIDA+  EJ3_CHITEM + EJ3_CHAVE
   
   //Verifica o Controle de Trasações está habilitado
   If Self:lCtrTrans .AND. lSeek
       aAux := {}
       For i := 1 To WorkEJ3->(FCount())
          //Adiciona no vetor o dado da Work como histórico
          aAdd(aAux,WorkEJ3->(FieldGet(i)))
       Next i
       
       If WorkEJ3->(RecLock("WorkEJ3",.F.))
          //Adiciona no vetor o Recno da Work para ser utilizado no controle de transações
          aAdd(Self:aRecTrans,{"DEL","WORKEJ3",WorkEJ3->(RecNo())}) 
          WorkEJ3->(dbDelete())//Exclui
          WorkEJ3->(MsUnLock())
       EndIf
        
       
       If WorkEJ3->(RecLock("WorkEJ3",.T.))
          For i := 1 To WorkEJ3->(FCount())
             //Adiciona o mesmo dado na Work para ser alterado
             WorkEJ3->(FieldPut(i,aAux[i]))
          Next i
          WorkEJ3->(MsUnLock())
          //Adiciona no vetor de controle de transação o recno do novo registro
          aAdd(Self:aRecTrans,{"INC","WORKEJ3",WorkEJ3->(RecNo())})
       EndIf
       
   EndIf
   
   If WorkEJ3->(RecLock("WorkEJ3",!lSeek))
      For i := 1 to WorkEJ3->(FCount())
      
         //Verifica os campos se for as Quantidades efetuar o calculo do saldo
         If WorkEJ3->(FieldName(i)) $ cCmpEJ3
            If oEASYITOPESP:cTipo == "E"
               WorkEJ3->&(FieldName(i)) += (nOperacao * oEASYITOPESP:GetDadoEJ3(WorkEJ3->(FieldName(i))))
            Else
               WorkEJ3->&(FieldName(i)) -= (nOperacao * oEASYITOPESP:GetDadoEJ3(WorkEJ3->(FieldName(i))))
            EndIf   
         Else
            WorkEJ3->&(FieldName(i)) := oEASYITOPESP:GetDadoEJ3(WorkEJ3->(FieldName(i)))
         EndIf
      
      Next i
   WorkEJ3->(MsUnLock())
   EndIf
   
   
   WorkEJ4->(DbSetOrder(1)) //EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE
   lSeek := WorkEJ4->(DbSeek(WorkEJ3->EJ3_CODE + WorkEJ3->EJ3_ENTR + WorkEJ3->EJ3_CODS + WorkEJ3->EJ3_SAIDA + WorkEJ3->EJ3_CHAVE)) 
   WorkEJ4->(RecLock("WorkEJ4",!lSeek))
   If !lSeek //Inclusão
      SX3->(DBSETORDER(2))
      For i := 1 To WorkEJ3->(FCount()) 
         cCampoExiste := "EJ4" + SUBSTR(WorkEJ3->(Fieldname(i)),4,Len(WorkEJ3->(Fieldname(i))))
         If SX3->(DbSeek(AvKey(cCampoExiste,"X3_CAMPO"))) 
            WorkEJ4->&(cCampoExiste) := WorkEJ3->&(Fieldname(i))
         EndIf  
      Next i  
   EndIf
   
   If oEASYITOPESP:cTipo == "E" //Entrada
      WorkEJ4->EJ4_QTEUM1 += (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_QTDUM1")) //1º Qtd
      WorkEJ4->EJ4_QTEUMI += (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_QTDUMI")) //Qtd Item
      WorkEJ4->EJ4_QTEUMN += (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_QTDUMN")) //Qtd NCM 
      WorkEJ4->EJ4_QTDKGE += (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_PESO")  )   //Peso
   ElseIf oEASYITOPESP:cTipo == "S" //Saida
      WorkEJ4->EJ4_QTSUM1 -= (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_QTDUM1")) //1º Qtd
      WorkEJ4->EJ4_QTSUMI -= (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_QTDUMI")) //Qtd Item
      WorkEJ4->EJ4_QTSUMN -= (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_QTDUMN")) //Qtd NCm   
      WorkEJ4->EJ4_QTDKGS -= (nOperacao * oEASYITOPESP:GetDadoEJ3("EJ3_PESO")  )   //Peso
   EndIf
   
   WorkEJ4->EJ4_SLD1   := WorkEJ4->EJ4_QTEUM1 - WorkEJ4->EJ4_QTSUM1 //Saldo da 1º
   WorkEJ4->EJ4_SLDI   := WorkEJ4->EJ4_QTEUMI - WorkEJ4->EJ4_QTSUMI //Saldo do Item
   WorkEJ4->EJ4_SLDN   := WorkEJ4->EJ4_QTEUMN - WorkEJ4->EJ4_QTSUMN //Saldo NCM  
   WorkEJ4->EJ4_SLDKG  := WorkEJ4->EJ4_QTDKGE - WorkEJ4->EJ4_QTDKGS //Saldo Peso
   
   WorkEJ4->(MsUnLock())
   
   
   //Atualiza os saldos na WorkEJ3
   If WorkEJ3->(RecLock("WorkEJ3",.F.))
      WorkEJ3->EJ3_SLDUM1 := WorkEJ4->EJ4_SLD1
      WorkEJ3->EJ3_SLDUMI := WorkEJ4->EJ4_SLDI
      WorkEJ3->EJ3_SLDPES := WorkEJ4->EJ4_SLDKG
      WorkEJ3->EJ3_SLDNCM := WorkEJ4->EJ4_SLDN
   WorkEJ3->(MsUnLock())
   EndIf

End Sequence  

Return Nil 


*==================================================================*
Method InitTrans() Class EASYOPESP
*==================================================================*
   //Indica que o Controle de Transações está habilitado
   Self:lCtrTrans := .T.

Return Nil

 
*==================================================================*
Method EndTrans(lOk) Class EASYOPESP
*==================================================================*
Local i
Default lOk := .T.


//Verifica se os dados da trasação estão OK, caso nao esteja retorna os dados anteriores
If !lOk
   
   //Varre o vetor com os Recnos
   For i := 1 To Len(Self:aRecTrans)
       
      //Posiciona na linha
      (Self:aRecTrans[i][2])->(dbGoTo(Self:aRecTrans[i][3]))
      RecLock(Self:aRecTrans[i][2],.F.)
      
      If Self:aRecTrans[i][1] == "DEL" 
         (Self:aRecTrans[i][2])->(DbReCall())//Desabilita o delete do dado
              
      ElseIf Self:aRecTrans[i][1] == "INC"
         (Self:aRecTrans[i][2])->(DbDelete())//Deleta o dado
      EndIf                                  
      
      (Self:aRecTrans[i][2])->(MsUnLock())
   Next i

EndIf

Self:aRecTrans := {}

Return Nil


*==================================================================*
Method SubstCmpos(cCampo,aAlias) Class EASYOPESP
*==================================================================*
Local i,j,nLin,nLinCmp
Local uInfo
Local aNewCorrespWork:= {}

Default cCampo := ""
Default aAlias := {}

If Type("aCorrespWork") == "A"
   aNewCorrespWork:= AClone(aCorrespWork)
EndIf

Begin Sequence

   //Efetua a alteração do Alias 
   For i := 1 To Len(aAlias)
              

      If (nLin := aScan(aNewCorrespWork,{|X| AllTrim(X[1]) == AllTrim(aAlias[i][1]) .And. AllTrim(X[2]) == aAlias[i][2] })) > 0
               
            
                       
         //Varre o vetor de campos para a substituição
         For nLinCmp := 1 To Len(aNewCorrespWork[nLin][3])
                           
            //Verifica se o campo da correspondecia ao ser executado retornara um valor
            TRY
               uInfo := &(aAlias[i][2] + If(!Empty(aAlias[i][2]),"->","") + aNewCorrespWork[nLin][3][nLinCmp][2])             
            CATCH
                     
            ENDTRY
                  
            If ValType(__oError) == "O"
               uInfo := NIL
            EndIf
                  
            If ValType(uInfo) <> "U"  .And. (!Empty(aAlias[i][2]) .Or. !Empty(uInfo))
                     
               //Substituição dos campos           
               cCampo := StrTran(cCampo,aNewCorrespWork[nLin][3][nLinCmp][1], aNewCorrespWork[nLin][3][nLinCmp][2]) 
                          
            EndIf
                             
         Next nLinCmp
               
      EndIf
                       
      cCampo := StrTran(cCampo, "#"+ aAlias[i][1]+"#", aAlias[i][2])

   Next i
                      
   //Grava conteudo da macro
   TRY
      uInfo := &(cCampo)           
   CATCH 

   ENDTRY
   
   If ValType(__oError) == "O"
      uInfo := Nil
      Self:Error("Erro na execução da macro da tabela de correspondência: " + __oError:Description)
      BREAK
   EndIf

End Sequence

Return uInfo


*==================================================================*
Method LoadCorresp(cOpe,cTabela,aAlias) Class EASYOPESP
*==================================================================*
Local cCampo := "" , uInfo

Begin Sequence

EJ2->(DbSetOrder(1))//EJ2_FILIAL+EJ2_CODE+EJ2_ENTR+EJ2_DE
   If EJ2->(DbSeek(xFilial("EJ2")+AvKey(cOpe,"EJ2_CODE") + AvKey(cTabela,"EJ2_ENTR")))
      Do While EJ2->(!EOF()) .And. xFilial("EJ2") == EJ2->EJ2_FILIAL ;
            .And. EJ2->EJ2_CODE == cOpe  .And. EJ2->EJ2_ENTR == cTabela
             
           //Campo a ser trocado pelo Alias 
           cCampo := EJ2->EJ2_DE 
           
           //Valida e executa a Macro de correspondencia
           uInfo := Self:SubstCmpos(cCampo,aAlias)
           
           //Adiciona no Array de conrrespondecia 
           Self:SetDadoCorresp(EJ2->EJ2_PARA,uInfo)
                      
      EJ2->(DbSkip())
      EndDo
   EndIf 
   
End Sequence

Return Nil 


*==================================================================*
Method GetDadoCorresp(cCampo) Class EASYOPESP
*==================================================================*
Local nPos
Local uRet

//Verifica se o Campo exite no array, se sim pega o dado dele, se não adiciona informação em Branco
if (nPos := aScan(Self:aCorresp,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0
   uRet := Self:aCorresp[nPos][2]
Else
   If EJ3->(FieldPos(cCampo)) > 0
      uRet := CriaVar(cCampo)
   Else
      uRet := WorkEJ3->&(cCampo) 
   EndIf
EndIf

Return uRet

*==================================================================*
Method SetDadoCorresp(cCampo,uDado) Class EASYOPESP
*==================================================================*
Local nPos

//Verifica se o tipo do dado é o mesmo do campo
If AVSX3(cCampo,AV_TIPO) <> ValType(uDado)
   Return Nil
EndIf

//Verifica se o campo existe, se sim adiciona informação nele, se nao adiciona o campo no Array juntamente com a informação.
if (nPos := aScan(Self:aCorresp,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0
   Self:aCorresp[nPos][2] := uDado
Else
   aAdd(Self:aCorresp,{cCampo,uDado})
EndIf

Return Nil   




*===================================*
Method DeleteWork() Class EASYOPESP
*===================================*

//Apaga as Works EJ3 e EJ4
Self:oWorks:CloseWorks()

Return Nil






****======================****
Class EASYITOPESP From AvObject
****======================****

   Data cChaveItem
   Data cOpeCorrente
   Data cTabCorrente
   Data cOpeInversa
   Data cTabInversa
   Data cTipo
   Data aAlias
   Data aChaveSld
   Data lInclui
   Data aDadosEJ3
   
   Method New(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida, cTipo,  aAlias, aChaveSld, lInclui) //Inicializador
   Method CarregaDados(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida)                            //Carrega dados EJ3(Entradas/Saidas)
   Method ValidaDados(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida)                             //Validações
   Method GetDadoEJ3(cCampo)                                                                //Seleciona dados EJ3
   Method SetDadoEJ3(cCampo,uDado)                                                          //Adiciona informação no campo EJ3    
   Method AdaptaBaixa()                                                                     //Adapta as quantidades 
   Method ExecValid(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida, oOperacao)                    //Executa as validações em relação a baixa 
   
End Class



*=========================================================================================================*
Method New(cChaveItem, cOpeEntr, cTabEntr, cOpeSaida, cTabSaida, cTipo,  aAlias, aChaveSld, aCorresp, lInclui) Class EASYITOPESP
*=========================================================================================================*
Self:aDadosEJ3 := {}
Self:cChaveItem:= cChaveItem
Self:cTipo    := cTipo
Self:aAlias   := aAlias
Self:aChaveSld:= aChaveSld
Self:lInclui  := lInclui

Default cOpeEntr  := ""
Default cTabEntr  := ""
Default cOpeSaida := ""
Default cTabSaida := ""
Default aCorresp := {}
Default Self:cTipo    := ""
Default Self:aAlias   := {}
Default Self:aChaveSld:= {}
Default Self:lInclui  := .T.
  


//Verifica o tipo da operação para definir tabela e operação corrente.
If Self:cTipo == "E"
   Self:cOpeCorrente := cOpeEntr
   Self:cTabCorrente := cTabEntr
   Self:cOpeInversa  := cOpeSaida
   Self:cTabInversa  := cTabSaida
ElseIf Self:cTipo == "S"
   Self:cOpeCorrente := cOpeSaida
   Self:cTabCorrente := cTabSaida
   Self:cOpeInversa  := cOpeEntr
   Self:cTabInversa  := cTabEntr
EndIf

Begin Sequence
   
   //Herança
   _Super:New()
     
   //metodo da Classe AvObjet para indicara a Classe
   Self:setClassName("EASYITOPESP")
      
   //Carrega dados EJ3
   If Self:CarregaDados(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida, aCorresp)
    If Self:AdaptaBaixa()
      Self:ValidaDados(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida)
    EndIf
   EndIf
   
   
   
End Sequence

Return Self 

*==============================================================================*
Method CarregaDados(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida, aCorresp) Class EASYITOPESP 
*==============================================================================*
Local lRet := .T.
Local i
Local nPos, cCampo, uInfo, nConv
Local oRefObj

Begin Sequence


   //Adiciona no Array os dados que foram carregados pela WORKEJ3
   WorkEJ3->(dbSetOrder(1))//EJ3_CODE + EJ3_ENTR + EJ3_CODS + EJ3_SAIDA+  EJ3_CHITEM + EJ3_CHAVE
   If WorkEJ3->(dbSeek(AvKey(cOpeEntr,"EJ3_CODE")+AvKey(cTabEntr,"EJ3_ENTR")+AvKey(cOpeSaida,"EJ3_CODS")+AvKey(cTabSaida,"EJ3_SAIDA")+AvKey(Self:cChaveItem,"EJ3_CHITEM")+AvKey(Self:aChaveSld[1],"EJ3_CHAVE"))) .And. ;
      WorkEJ3->EJ3_QTD > 0     
      For i:= 1 To WorkEJ3->(FCount())
         Self:SetDadoEJ3(WorkEJ3->(FieldName(i)),WorkEJ3->(FieldGet(i)))
      Next i
   Else
      //Adiciona no Array os dados que vieram da macro de Correspondencia
      For i := 1 to Len(aCorresp)  
         Self:SetDadoEJ3(aCorresp[i][1],aCorresp[i][2])
      Next i
   EndIf
   
   

   
   /*Verifica se a Chave do Saldo está preenchida, se não tiver adiciona de acordo com a unidade e 
     quantidade executada na macro de correspondencia */
   If Empty(Self:aChaveSld[1])
      For i := 1 To EJ3->(FCount())
         M->&(EJ3->(FieldName(i))) := Self:GetDadoEJ3(EJ3->(FieldName(i)))
      Next i
      
      Self:SetDadoEJ3("EJ3_UM1",Self:GetDadoEJ3("EJ3_UM"))  
      Self:SetDadoEJ3("EJ3_QTDUM1",Self:GetDadoEJ3("EJ3_QTD"))
      
      If !Empty(EJ0->EJ0_CHUSLD)
         Self:aChaveSld[1] := &("M->("+EJ0->EJ0_CHUSLD+")")
      Else
         Self:aChaveSld[1] := ""
      EndIf
      Self:aChaveSld[2] := Self:GetDadoEJ3("EJ3_UM1")
      Self:aChaveSld[3] := Self:GetDadoEJ3("EJ3_QTDUM1")
   EndIf
   
   Self:SetDadoEJ3("EJ3_CODE"  ,cOpeEntr             ) //Codigo Operação entrada
   Self:SetDadoEJ3("EJ3_ENTR"  ,cTabEntr             ) //Entidade de Entrada
   Self:SetDadoEJ3("EJ3_CODS"  ,cOpeSaida            ) //Codigo Operação saida
   Self:SetDadoEJ3("EJ3_SAIDA" ,cTabSaida            ) //Entidade de Saida 
   Self:SetDadoEJ3("EJ3_TIPO"  ,Self:cTipo           ) //Tipo 
   Self:SetDadoEJ3("EJ3_CHITEM",Self:cChaveItem      ) //Chave do Item
   Self:SetDadoEJ3("EJ3_CHAVE" ,Self:aChaveSld[1]    ) //Chave Saldo
   
   //Carrega WorkEJ4
   EJ4->(DbSetOrder(1))
   WorkEJ4->(DbSetOrder(1))
   If EJ4->(dbSeek(xFilial("EJ4")+AvKey(cOpeEntr,"EJ3_CODE")+AvKey(cTabEntr,"EJ3_ENTR")+AvKey(cOpeSaida,"EJ3_CODS")+AvKey(cTabSaida,"EJ3_SAIDA")+AvKey(Self:aChaveSld[1],"EJ3_CHAVE")))
      If !(WorkEJ4->(DbSeek(EJ4->EJ4_CODE + EJ4->EJ4_ENTR + EJ4->EJ4_CODS + EJ4->EJ4_SAIDA + EJ4->EJ4_CHAVE)))
         WorkEJ4->(RecLock("WorkEJ4",.T.))//Inclusao
            AvReplace("EJ4","WorkEJ4")
         WorkEJ4->(MsUnlock())
      EndIf   
   EndIf
   
End Sequence

Return lRet

*=============================================================================*
Method ValidaDados(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida) Class EASYITOPESP 
*=============================================================================*
Local lRet := .T.
Local oRefObj
Local nConv

Begin Sequence
   
   SB1->(DbSetOrder(1))
   SYD->(DbSetOrder(1))
   
   //Verifica se o Código do Item da Tabela de Entradas/Saídas(EJ3) está preenchido.
   If Empty(Self:GetDadoEJ3("EJ3_COD_I")) 
      Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".Código do Item não informado na tabela de Entradas/Saídas.")
      lRet := .F.
      Break
   EndIf 
   
   //Verifica se o item da EJ3 está no cadastro de produto.
   If !SB1->(DbSeek(xFilial("SB1") + Self:GetDadoEJ3("EJ3_COD_I")))
     Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".Item não cadastrado na tabela de Produtos.")
     Break
     lRet := .F.
   EndIF
   
   //Verifica se campo NCM no cadastro de produto está preenchido.
   If Empty(SB1->B1_POSIPI) 
      Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".NCM do Item " + Self:GetDadoEJ3("EJ3_COD_I") + " não informada no cadastro de Produtos.")
      lRet := .F.
      Break
   EndIf 
    
   //Verifica se o NCM do Produto está cadastrado na Tabela de NCM. 
   If !SYD->(DbSeek(xFilial("SYD") + SB1->B1_POSIPI))
     Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".NCM informada no cadastro de produtos não está cadastrada na Tabela de NCM")
     lRet := .F.
     Break
   EndIF
   
   //Verifica se a Unidade de Medida de Entrada está preenchida na tabela de Entrada/Saída.
   If Empty(Self:GetDadoEJ3("EJ3_UM")) 
      Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".Unidade de Medida de Entrada/Saida não está preenchida na tabela de Entradas/Saídas.")
      lRet := .F.
      Break
   EndIf
   
   //Verifica se a Quantidade de Entrada está preenchida na tabela de Entrada/Saída.   
   If Empty(Self:GetDadoEJ3("EJ3_QTD"))
      Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".Quantidade de Entrada/Saida não está preenchida na tabela de Entradas/Saídas.")//VERIFICAR
      lRet := .F.
      Break
   EndIf
   
   //Verifica se a Data de Entrada está preenchida na tabela de Entrada/Saída.
   If Empty(Self:GetDadoEJ3("EJ3_DATA")) .And. ALTERA //NCF - 26/02/2020 - Só é possível validar data na alteração de processo.
      Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".Data de Entrada/Saida não está preenchida na tabela de Entradas/Saídas.")
      lRet := .F.
      Break
   EndIf
   
   
   //Verifica se a Unidade de Medida do Item está preenchida
   If Empty(Self:GetDadoEJ3("EJ3_UMIT"))
      
      WorkEJ4->(DbSetOrder(1)) //EJ4_FILIAL+EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE 
      If WorkEJ4->(DbSeek(cOpeEntr + cTabEntr + cOpeSaida + cTabSaida + Self:aChaveSld[1] ))
        Self:SetDadoEJ3("EJ3_UMIT",WorkEJ4->EJ4_UMIT)
      Else
        If Empty(SB1->B1_UM) 
           Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".Unidade de Medida no cadastro do produto não está preenchida.")
           lRet := .F.
           Break
        Else 
           Self:SetDadoEJ3("EJ3_UMIT",SB1->B1_UM) 
        EndIf
      EndIf
 
   EndIf 
   
   //Verifica se a Unidade de Medida da NCM está preenchida
   If Empty(Self:GetDadoEJ3("EJ3_UMNCM"))
      
      WorkEJ4->(DbSetOrder(1))//EJ4_FILIAL+EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE
      If WorkEJ4->(DbSeek(cOpeEntr + cTabEntr + cOpeSaida + cTabSaida + Self:aChaveSld[1] ))
        Self:SetDadoEJ3("EJ3_UMNCM",WorkEJ4->EJ4_UMNCM)
      Else
        If Empty(SYD->YD_UNID) 
           Self:Error("Não foi possivel realizar a Operação: "+ AllTrim(EJ0->EJ0_DESC) + ".Unidade de Medida no cadastro da NCM não está preenchida.")
           lRet := .F.
           Break
        Else 
           Self:SetDadoEJ3("EJ3_UMNCM",SYD->YD_UNID) 
        EndIf
      EndIf
 
   EndIf 
   
   //Verifica se a Unidade de Medida da 1º entrada está preenchida
   If Empty(Self:GetDadoEJ3("EJ3_UM1"))
      
      WorkEJ4->(DbSetOrder(1))//EJ4_FILIAL+EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE
      If WorkEJ4->(DbSeek(cOpeEntr + cTabEntr + cOpeSaida + cTabSaida + Self:aChaveSld[1] ))
        Self:SetDadoEJ3("EJ3_UM1",WorkEJ4->EJ4_UM1)
      Else
        Self:SetDadoEJ3("EJ3_UM1",Self:GetDadoEJ3("EJ3_UM"))  
      EndIf
 
   EndIf
   
   
   //Verifica se o Peso esta vazio e efetua preenche a mesma de acordo com a conversão de unidade da Correspondencia ou Qrd 1º Entrada
   If Empty(Self:GetDadoEJ3("EJ3_PESO")) 
     If (nConv :=  EasyConvQt(Self:GetDadoEJ3("EJ3_COD_I"),{{Self:GetDadoEJ3("EJ3_UM"),Self:GetDadoEJ3("EJ3_QTD")},{Self:GetDadoEJ3("EJ3_UM1"),Self:GetDadoEJ3("EJ3_QTDUM1")}},"KG",.F.,@oRefObj)) >= 0
        Self:SetDadoEJ3("EJ3_PESO",nConv)
     Else
        Self:Error(oRefObj:aWarning)
        lRet := .F.
        Break
     EndIf
     oRefObj := Nil
   EndIf
   
   
   //Verifica se a Qtd da 1º Entrada esta vazio e efetua preenche a mesma de acordo com a conversão de unidade da Correspondencia
   If Empty(Self:GetDadoEJ3("EJ3_QTDUM1")) 
      If (nConv := EasyConvQt(Self:GetDadoEJ3("EJ3_COD_I"),{{Self:GetDadoEJ3("EJ3_UM"),Self:GetDadoEJ3("EJ3_QTD")},{"KG"      , Self:GetDadoEJ3("EJ3_PESO")}},Self:GetDadoEJ3("EJ3_UM1"),.F.,@oRefObj)) >= 0
         Self:SetDadoEJ3("EJ3_QTDUM1",nConv)
      Else
        Self:Error(oRefObj:aWarning)
        lRet := .F.
        Break
      EndIf
      oRefObj := Nil
   EndIf
   
   //Verifica se Qtd do Item esta vazio e efetua preenche a mesma de acordo com a conversão de unidade da Correspondencia , Qrd 1º Entrada ou Peso
   If Empty(Self:GetDadoEJ3("EJ3_QTDUMI"))                 
      If (nConv := EasyConvQt(Self:GetDadoEJ3("EJ3_COD_I"),{{Self:GetDadoEJ3("EJ3_UM"),Self:GetDadoEJ3("EJ3_QTD")},{Self:GetDadoEJ3("EJ3_UM1"),Self:GetDadoEJ3("EJ3_QTDUM1")},{"KG"      , Self:GetDadoEJ3("EJ3_PESO")}},Self:GetDadoEJ3("EJ3_UMIT"),.F.,@oRefObj)) >= 0
         Self:SetDadoEJ3("EJ3_QTDUMI",nConv)
      Else
        Self:Error(oRefObj:aWarning)
        lRet := .F.
        Break
      EndIf
      oRefObj := Nil
   EndIf
      
   //Verifica se Qtd da NCM esta vazio e efetua preenche a mesma de acordo com a conversão de unidade da Correspondencia , Qrd 1º Entrada , Peso ou Qtd do Item
   If Empty(Self:GetDadoEJ3("EJ3_QTDUMN"))                 
      If (nConv := EasyConvQt(Self:GetDadoEJ3("EJ3_COD_I"),{{Self:GetDadoEJ3("EJ3_UM"),Self:GetDadoEJ3("EJ3_QTD")},{Self:GetDadoEJ3("EJ3_UM1"),Self:GetDadoEJ3("EJ3_QTDUM1")},{"KG"      , Self:GetDadoEJ3("EJ3_PESO")}, {Self:GetDadoEJ3("EJ3_UMIT"),Self:GetDadoEJ3("EJ3_QTDUMI")}},Self:GetDadoEJ3("EJ3_UMNCM"),.F.,@oRefObj)) >= 0
         Self:SetDadoEJ3("EJ3_QTDUMN",nConv)
      Else
        Self:Error(oRefObj:aWarning)
        lRet := .F.
        Break
      EndIf
      oRefObj := Nil
   EndIf
   
   //Executa Função de Validação para baixa
   If !Self:ExecValid(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida,Self)
      lRet := .F.
      Break
   EndIf

End Sequence

Return lRet  







*===========================================================================*
Method ExecValid(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida,oOperacao) Class EASYITOPESP 
*===========================================================================*
Local lRet := .T.
Local bFunc


Begin Sequence 

If Empty(EJ0->EJ0_VALID)
   Break
EndIf

//Verifica se a função de condicao esta no repositório
If FindFunction(AllTrim(EJ0->EJ0_VALID))  
   TRY
      bFunc := &("{|a,b,c,d,e| "+AllTrim(EJ0->EJ0_VALID)+"(a,b,c,d,e)}")
      lRet := Eval(bFunc,cOpeEntr, cTabEntr, cOpeSaida, cTabSaida, oOperacao) //Executa a função
   CATCH 
      
   ENDTRY
   
   If ValType(__oError) == "O"
      Self:Error("Erro na execução da função: " + AllTrim(EJ0->EJ0_VALID) + " ERRO : " + ENTER + oError:Description)
   EndIf
Else
   Self:Error("Função: " + AllTrim(EJ0->EJ0_VALID) + " não se encontra no repositório. Favor solicitar um patch de atualização ao Suporte!")
EndIf


End Sequence

Return lRet 



*==================================================================*
Method GetDadoEJ3(cCampo) Class EASYITOPESP
*==================================================================*
Local nPos
Local uRet

//Verifica se o Campo exite no array, se sim pega o dado dele, se não adiciona informação em Branco
if (nPos := aScan(Self:aDadosEJ3,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0
   uRet := Self:aDadosEJ3[nPos][2]
Else
   If EJ3->(FieldPos(cCampo)) > 0
      uRet := CriaVar(cCampo)
   Else
      uRet := WorkEJ3->&(cCampo) 
   EndIf
EndIf

Return uRet

*==================================================================*
Method SetDadoEJ3(cCampo,uDado) Class EASYITOPESP
*==================================================================*
Local nPos

//Verifica se o campo existe, se sim adiciona informação nele, se nao adiciona o campo no Array juntamente com a informação.
If (nPos := aScan(Self:aDadosEJ3,{|X| AllTrim(X[1]) == AllTrim(cCampo)})) > 0
   Self:aDadosEJ3[nPos][2] := uDado
Else
   aAdd(Self:aDadosEJ3,{cCampo,uDado})
EndIf

Return Nil

*==================================================================*
 Method AdaptaBaixa() Class EASYITOPESP
*==================================================================*
Local lRet := .T.
Local nCoef, i 
Local aCampos := {"EJ3_QTD", "EJ3_QTDUM1" , "EJ3_QTDUMI" , "EJ3_QTDUMN", "EJ3_PESO" }  
Local nConv
Local oRefObj
 
Begin Sequence 
   
   If !(nConv := EasyConvQt(Self:GetDadoEJ3("EJ3_COD_I"),{{Self:GetDadoEJ3("EJ3_UM"),Self:GetDadoEJ3("EJ3_QTD")},{Self:GetDadoEJ3("EJ3_UM1"),Self:GetDadoEJ3("EJ3_QTDUM1")},{"KG"      , Self:GetDadoEJ3("EJ3_PESO")}, {Self:GetDadoEJ3("EJ3_UMIT"),Self:GetDadoEJ3("EJ3_QTDUMI")},{Self:GetDadoEJ3("EJ3_UMNCM"),Self:GetDadoEJ3("EJ3_QTDUMN")}},Self:aChaveSld[2],.F.,@oRefObj)) >= 0
      Self:Error(oRefObj:aWarning)
      oRefObj := Nil
      lRet := .F.
      Break  
   EndIf
   
   //Encontra o coeficiente para adaptação das quantidades
   nCoef := Self:aChaveSld[3] / nConv 

   If nCoef <= 1
      For i := 1 To Len(aCampos)
        //Atualiza dados da EJ3(Entradas/Saidas) de acordo com o Coeficiente
        Self:SetDadoEJ3(aCampos[i],Self:GetDadoEJ3(aCampos[i]) * nCoef) 
      Next i
   Else
      lRet := .F.
      Self:Error("A quantidade informada é maior que o saldo disponivel. Saldo de: " + AllTrim(Str(nConv)) + " e a quantidade de: " + AllTrim(Str(Self:aChaveSld[3])))
   EndIf
   
End Sequence

Return lRet 



/*
Funcao      : F3_EJ0
Parametros  : -
Retorno     : Filtro da tabela
Objetivos   : Apresentar as operações filtradas
Autor       : Allan Oliveira Monteiro 
Data/Hora   : 15/03/2011
Revisao     : 
Obs.        : 
*/

*----------------*
Function F3_EJ0()
*----------------*
Local cAlias := ""

If Isincallstack("EICDI500") .Or. Isincallstack("EICDI501") .Or. Isincallstack("EICDI502")  // GFP - 30/06/2015
   cAlias := "SW8"
EndIf  

If Isincallstack("EICPO400")
   cAlias := "SW3"
EndIf

If Isincallstack("EICGI400") .Or. Isincallstack("EICGI401")
   cAlias := "SW5"
EndIf 

If Isincallstack("EECAP100") 
   cAlias := "EE8"
EndIf 

If Isincallstack("EECAE100") 
   cAlias := "EE9"
EndIf 

Return EJ0->EJ0_ENTR == cAlias


/*
Funcao      : VldGrvCtrlEmb
Parametros  : cOpeEntr, cTabEntr, cOpeSaida, cTabSaida,oOperacao
Retorno     : lRet
Objetivos   : Efetua as validações das Entradas e Saidas
Autor       : Allan Oliveira Monteiro 
Data/Hora   : 15/03/2011
Revisao     : 
Obs.        : 
*/

*====================================================================================*
Function VldGrvCtrlEmb(cOpeEntr, cTabEntr, cOpeSaida, cTabSaida,oOperacao)
*====================================================================================*
Local lRet := .T.

   If nModulo == 17 .And. cTabEntr == "SW8" //EIC

      If Empty(oOperacao:GetDadoEJ3("EJ3_ADICAO"))
         oOperacao:Error("Para realizar a Operação de " + AllTrim(EJ0->EJ0_DESC) + " é necessario possuir adição cadastrada para o item: " + oOperacao:GetDadoEJ3("EJ3_COD_I"))
      EndIf
      
   /*ElseIf nModulo == 29 .And.  cTabEntr == "EE9" .And. ALTERA //NCF - 26/02/2020 - Só é possível informar DUE após processo ter sido incluso.
      
      If Empty( If(!AvFlags("DU-E3"),oOperacao:GetDadoEJ3("EJ3_RE"),M->EEC_NRODUE)   )
         oOperacao:Error("Para realizar a Operação de " + AllTrim(EJ0->EJ0_DESC) + " é necessario possuir DUE/RE cadastrado para o item: " + oOperacao:GetDadoEJ3("EJ3_COD_I"))
      EndIf
   */ //NCF - 28/02/2020 - Nopada pois validacao não permite desmarcar item no processo para que seja informado RE.
   
   EndIf

Return lRet

/*
Funcao      : CondGrvCtrlEmb
Parametros  : cOpe, cTabela, aAlias, lInclui,lExibeMsg,cMomentOpe,oOperacao
Retorno     : lRet
Objetivos   : Verifica a condição para execução da classe EASYOPESP
Autor       : Allan Oliveira Monteiro 
Data/Hora   : 15/03/2011
Revisao     : 
Obs.        : 
*/

*====================================================================================*
Function CondGrvCtrlEmb(cOpe, cTabela, aAlias, lInclui,lExibeMsg,cMomentOpe,oOperacao)
*====================================================================================*
Local lRet := .T.

If lInclui
   
   //Verifica se Existe DI para o processo na Inclusão
   If Empty(M->W6_DI_NUM)
      lRet := .F. 
   EndIf
 
Else 
   
   //Verifica se Existe DI na base do processo para Exclusão
   If Empty(SW6->W6_DI_NUM)
      lRet := .F.
   EndIf

EndIf 
   

Return lRet



/*
Funcao      : EASYFIFO
Parametros  : cOpeEntr,cEntr,cOpeSaida,cSaida,cUn,nQtd,oOperacao
Retorno     : aChvSld - Chave de Saldo
Objetivos   : Busca as chaves para efetuar o critério de baixa
Autor       : Allan Oliveira Monteiro 
Data/Hora   : 15/03/2011
Revisao     : 
Obs.        : 
*/
*====================================================================*
Function EASYFIFO(cOpeEntr,cEntr,cOpeSaida,cSaida,cUn,nQtd,oOperacao)
*====================================================================* 
Local aChvSld    := {}
Local aChvSldAux := {}
Local oRefObj  
Local  i

Begin Sequence 
   
   //Busca na work todas as chaves de saldos para esta operação
   WorkEJ4->(DbSetOrder(1))//EJ4_CODE+EJ4_ENTR+EJ4_CODS+EJ4_SAIDA+EJ4_CHAVE 
   WorkEJ4->(DbSeek(AvKey(cOpeEntr,"EJ4_CODE") + AvKey(cEntr,"EJ4_ENTR") + AvKey(cOpeSaida,"EJ4_CODS") + AvKey(cSaida,"EJ4_SAIDA")))
   Do While WorkEJ4->(!EOF()) .And. AvKey(cOpeEntr,"EJ4_CODE") + AvKey(cEntr,"EJ4_ENTR") + AvKey(cOpeSaida,"EJ4_CODS") + AvKey(cSaida,"EJ4_SAIDA") ; 
                                 == Left((WorkEJ4->&(IndexKey())),Len(AvKey(cOpeEntr,"EJ4_CODE") + AvKey(cEntr,"EJ4_ENTR") + AvKey(cOpeSaida,"EJ4_CODS") + AvKey(cSaida,"EJ4_SAIDA")))
      
      //Permite adicionar apenas as chaves do item selecionado
      If AllTrim(oOperacao:GetDadoCorresp("EJ3_COD_I")) == AllTrim(WorkEJ4->EJ4_COD_I)
         nConv := EasyConvQt(WorkEJ4->EJ4_COD_I,{{WorkEJ4->EJ4_UM1,WorkEJ4->EJ4_SLD1},{WorkEJ4->EJ4_UMIT,WorkEJ4->EJ4_SLDI},{"KG", WorkEJ4->EJ4_SLDKG},{WorkEJ4->EJ4_UMNCM ,WorkEJ4->EJ4_SLDN}},cUn,.F.,@oRefObj)
         AADD(aChvSldAux,{WorkEJ4->EJ4_CHAVE,cUn, nConv,WorkEJ4->EJ4_DATA})
      EndIf

   WorkEJ4->(DbSkip())
   End Do  
   
   //Ordena o Array pela Data da 1º Entrada
   EasyAsort(aChvSldAux,,,{|x,y|  x[4] < y[4]})   
   
   //Carrega o Array ordenado com as chaves de Saldos  
   For i := 1 To Len(aChvSldAux)
      If aChvSldAux[i][3] > 0 
         If nQtd > aChvSldAux[i][3]
            nQtd -= aChvSldAux[i][3]
         Else
            AADD(aChvSld,{aChvSldAux[i][1],aChvSldAux[i][2],nQtd})
            Exit
         EndIf 
      EndIf 
      AADD(aChvSld,{aChvSldAux[i][1],aChvSldAux[i][2],aChvSldAux[i][3]})
   Next i
   
   If Empty(aChvSld)
      AADD(aChvSld,{"","",0})
   EndIf
   
   
End Sequence



Return aChvSld 



/*
Funcao      : ValidOpe
Parametros  : cCampo
Retorno     : lRet 
Objetivos   : efetua a validação das operações selecionadas
Autor       : Allan Oliveira Monteiro 
Data/Hora   : 15/03/2011
Revisao     : 
Obs.        : 
*/
*------------------------*
Function ValidOpe(cCampo)
*------------------------* 
Local lRet := .T. 
Local cCodProd := ""
Local cOper    := "" 

Begin Sequence

   Do Case
      
      Case cCampo == "W3_CODOPE" 
         
         cCodProd := M->W3_COD_I 
         cOper    := M->W3_CODOPE 
         
      Case cCampo == "cCodOpe_W5"
        
         cCodProd :=  Work->WKCOD_I
         cOper    :=  cCodOpe 
        
      Case cCampo == "cCodOpe_W8"
      
         cCodProd := Work_SW8->WKCOD_I
         cOper    := cCodOpe 
        
      Case cCampo == "EE8_CODOPE"
        
         cCodProd := M->EE8_COD_I
         cOper    := M->EE8_CODOPE
      
      Case cCampo == "EE9_CODOPE"
      
         cCodProd := M->EE9_COD_I
         cOper    := M->EE9_CODOPE
   
   EndCase
   
   If !Empty(cCodProd) .And. !Empty(cOper) .And. cOper $ "01/02/03/04"
   
      EYJ->(DbSetOrder(1))//Filial + Cod. Produto
      If EYJ->(DbSeek(xFilial("EYJ") + AvKey(cCodProd,"EYJ_COD"))) 
      
         If EYJ->(FieldPos("EYJ_EMBESP")) > 0 .And. EYJ->EYJ_EMBESP <> "1"  
            MsgInfo("Para esta operação é necessario que o campo 'Emb. Especial?' estar preenchido com o conteudo 'Sim' no cadastro de Dados complementares do Produto : " + AllTrim(cCodProd)+ ".","Aviso")
            lRet := .F.
            Break         
         EndIf
      
      EndIf
      
   
   EndIf


End Sequence


Return lRet
