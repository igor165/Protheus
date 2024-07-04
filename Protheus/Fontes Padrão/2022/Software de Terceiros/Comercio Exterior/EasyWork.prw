#Include "AVERAGE.CH"

/*
Programa        : EASYWORK.PRW
Objetivo        : Criacao de tabelas temporarias
Autor           : Alessandro Alves Ferreira
Revisão         : 
Data/Hora       : 05/05/2011
Obs.            : 
*/


Function EasyWorks()
Return EasyWorks():New()

Class EasyWorks From AvObject
   Data aWorks
   Data cArquivo
   Data cDir
   Data IndexLabel
   
   Method New()
   Method NewWork()
   Method Create()
   Method AbreWork()
   Method Disponivel()
   Method CloseWorks()
   Method DeletaArquivo()
EndClass

Class EasyWork From AvObject
   Data cAlias     
   Data cTabela    
   Data cFileName                    //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
   Data aCampos   
   Data aIndex    
   Data lAddIndex 
   Data cDriver   
   Data lVirtuais 
   Data lMemo     
   Data lShared   
   Data lFilial
   Data oEasyWorks
   
   Method New()
   Method Create()
EndClass

Method New(oEasyWorks) Class EasyWork
   _Super:New()
   Self:SetClassName("EasyWork")
   
   Self:cAlias    := NIL
   Self:cTabela   := NIL
   Self:aCampos   := NIL
   Self:aIndex    := NIL
   Self:lAddIndex := NIL
   Self:cDriver   := NIL
   Self:lVirtuais := NIL
   Self:lMemo     := NIL
   Self:lShared   := NIL
   Self:lFilial   := NIL
   
   Self:oEasyWorks:= oEasyWorks
Return Self

Method Create() Class EasyWork
   Self:cDriver   := "TOPCONN" //forçar o uso no banco de dados - FWTemporaryTable (uso de temporários no banco)
Return Self:oEasyWorks:Create(Self:cAlias,Self:cTabela,Self:aCampos,Self:aIndex,Self:lAddIndex,Self:lFilial,Self:cDriver,Self:lVirtuais,Self:lMemo,Self:lShared,Self)   //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica

Method New() Class EasyWorks
   _Super:New()
   Self:SetClassName("EasyWork")
   
   Self:aWorks   := {}
   Self:cArquivo := "WorkFile"
   Self:cDir     := "\Comex" //"\Comex\" //FSM - 19/07/2012
   Self:IndexLabel:= "Index"
Return Self

Method NewWork() Class EasyWorks
Return EasyWork():New(Self)

Method Create(cAlias,cTabela,aCampos,aIndex,lAddIndex,lFilial,cDriver,lVirtuais,lMemo,lShared,oWork) Class EasyWorks    //AAF/NCF - 13/09/2013 - Ajustes para melhora de performance Integ. Pedido Expo. Msg. Unica
Local aCpos     := {}
Local cFileName
Local i
Local lRet := .T.
Local oTempTable

Default lShared  := .F.
Default cTabela  := ""
Default aCampos  := {}
Default cDriver  := "TOPCONN"
Default lVirtuais:= .T.
Default lMemo    := .F.
Default lAddIndex:= .T.
Default lFilial  := .F.
Default aIndex   := {}

Begin Sequence
  
   //Monta estrutura com base na tabela de referencia indicada
   If !Empty(cTabela) .AND. ChkFile(cTabela)
      aEval((cTabela)->(dbStruct())   ,{|X| IF(lFilial .OR. !("FILIAL" $ X[1]),aAdd(aCpos,X),)})
      aEval(GetVirtuais(cTabela,lMemo),{|X| aAdd(aCpos,X)})
   EndIf
   
   //Adiciona os indices da tabela de referencia indicada
   If !Empty(cTabela) .AND. lAddIndex
      If (cTabela)->(FieldPos(cTabela+"_FILIAL")) > 0
         cFilCpo := cTabela+"_FILIAL"
      ElseIf (cTabela)->(FieldPos(SubStr(cTabela,2,2)+"_FILIAL")) > 0
         cFilCpo := SubStr(cTabela,2,2)+"_FILIAL"
      EndIf
      
      aEval((cTabela)->(RetIndexKeys()),{|X,i| aAdd(aIndex,NIL), aIns(aIndex,i), aIndex[i] := if(lFilial,X,StrTran(X,cFilCpo+"+",""))})
   EndIf
   
   //Adiciona o campos extras recebidos
   aEval(aCampos,{|X| aAdd(aCpos,X)})
   
   If Select(cAlias) > 0
      (cAlias)->(DbCloseArea())
   EndIf
   
   oTempTable:= FWTemporaryTable():New(cAlias)

   //Cria a work com a estrutura da tabela
   oTempTable:SetFields(aCpos)

   //Criação dos índices
   SplitIndex(@aIndex)

   //Cria os Indices
   For i := 1 To Len(aIndex)
      oTempTable:AddIndex(Self:IndexLabel + AllTrim(Str(i)), aIndex[i])
   Next i

   //Criação da tabela temporária
   oTempTable:Create() 
      
   //Armazena o nome temporário da tabela
   oWork:cFileName:= oTempTable:GetRealName()

   //Mantem no objeto a lista das works em uso
   aAdd(Self:aWorks,{cAlias, oWork:cFileName, cDriver, lShared, Len(aIndex), oTempTable})
   
End Sequence   

Return lRet

Method AbreWork(cAlias,cAliasNew) Class EasyWorks
Local lRet := .T.
Local i := 0
Default cAliasNew := cAlias

   If (nPosAlias := aScan(Self:aWorks,{|X| AllTrim(X[1]) == AllTrim(cAlias)})) > 0
      
      //Abre todos os indices
      dbUseArea(.T.,Self:aWorks[nPosAlias][3],Self:aWorks[nPosAlias][6]:cTableName,cAliasNew,Self:aWorks[nPosAlias][4],.F.)
      
      If Used()
         (cAliasNew)->(dbClearInd())
         For i := 1 To Self:aWorks[nPosAlias][5]
            (cAliasNew)->(dbSetIndex(Self:aWorks[nPosAlias][6]:cIndexName + Self:IndexLabel + AllTrim(Str(i))))
         Next i
      Else
         Self:Error("Erro ao abrir work "+cAlias+".")
         lRet := .F.
      EndIf
   Else
      Self:Error("Work "+cAlias+" não encontrada.")
      lRet := .F.
   EndIf
   
Return lRet

Method CloseWorks() Class EasyWorks
Local i

Begin Sequence
   
   For i := 1 To Len(Self:aWorks)
      If Select(Self:aWorks[i][1]) > 0
         (Self:aWorks[i][1])->(dbCloseArea())
         Self:aWorks[i][6]:Delete()
      EndIf
   Next i

   
   Self:aWorks := {}
End Sequence

Return Nil

Method Disponivel(cFileName,cDriver,lIndex) Class EasyWorks
Local lRet := .T.
//Local cOldArea := Alias()
Default lIndex := .F.

If !Empty(cFileName)
   If lIndex
      lRet := !MsFile(,cFileName,cDriver) 
   Else
      lRet := !MsFile(cFileName,,cDriver)
   EndIf
Else
   lRet := .F.
EndIf

Return lRet

Method DeletaArquivo(cFileName,cDriver,lIndex) Class EasyWorks
Local lRet := .T.
Local cRootPath := GetSrvProfString("ROOTPATH","") + "\System\"
Default lIndex := .F.

//If TCSQLEXEC("DROP TABLE "+cFileName) < 0
//TcDelFile(cFileName)

cFileName:= Alltrim(cFileName)  //TRP - 28/09/2012 - Utilização da função Alltrim. 

If lIndex .AND. MsFile("",cFileName,AllTrim(Upper(cDriver))) .AND. !MsErase("",cFileName,AllTrim(Upper(cDriver))) .OR. ;
   !lIndex .AND. MsFile(cFileName,,AllTrim(Upper(cDriver))) .AND.  !MsErase(cFileName,,AllTrim(Upper(cDriver))) //!Self:Disponivel(cFileName,cDriver)
   If AllTrim(Upper(cDriver)) == "TOPCONN"
      Self:Warning("Falha ao excluir arquivo temporário: "+TCSQLError())
   Else
      Self:Warning("Falha ao excluir arquivo temporário: "+Str(FError()))
   EndIf
   lRet := .F.
EndIf

If !lIndex .And. MsFile(cFileName,,AllTrim(Upper(cDriver))) .And.  !MsErase(cFileName,,AllTrim(Upper(cDriver)))
   lRet := .F.
Else
   If lIndex
      If AllTrim(Upper(cDriver)) <> "TOPCONN" .And. File(cRootPath+cFileName)
         If FErase(cRootPath+cFileName) <> 0
            lRet := .F.
         EndIf
      EndIf   
   EndIf
EndIf

If !lRet
   If AllTrim(Upper(cDriver)) == "TOPCONN"
      Self:Warning("Falha ao excluir arquivo temporário: "+TCSQLError())
   Else
      Self:Warning("Falha ao excluir arquivo temporário: "+Str(FError()))
   EndIf
EndIf

Return lRet
Static Function RetIndexKeys()
Local aIndex := {}
Local i

If !Empty(Alias())
   
   For i := 1 To dbOrderInfo(9)//dbOrderInfo(DBOI_OrderCount)
      aAdd(aIndex,IndexKey(i))
   Next i
   
EndIf

Return aIndex

Static Function GetVirtuais(cAlias,lMemo)
Local aRet  := {}
Default lMemo := .F.

SX3->(dbSetOrder(1))
SX3->(dbSeek(cAlias))
Do While SX3->( !EoF() .AND. X3_ARQUIVO == cAlias )
   
   If SX3->X3_CONTEXT == "V" .AND. (lMemo .OR. SX3->X3_TIPO <> "M")
      aAdd(aRet,SX3->({X3_CAMPO,X3_TIPO,X3_TAMANHO,X3_DECIMAL}))
   EndIf
   
   SX3->(dbSkip())
EndDo

Return aRet

/**
Retorna o índice organizado por array 
*/
Static Function SplitIndex(aIndex)
Local nPos, nCont
Local cChave
Local aNewIndex:= {}

   For nCont:= 1 To Len(aIndex)
      
      cChave:= aIndex[nCont]
      
      aNewIndex:= {}
      While (nPos := At("+", cChave)) > 0

         AAdd(aNewIndex, FormatField(Left(cChave, nPos - 1)))
         cChave := SubStr(cChave, nPos + 1)
      EndDo
      AAdd(aNewIndex, FormatField(cChave))

      aIndex[nCont]:= AClone(aNewIndex)
   
   Next

Return

/**
Remove as sintaxes de funções do campo
 */
Static Function FormatField(cField)
Local cTempField:= Upper(cField)
Local nPos

   //Remoção das funções DtoS() e Str() do campo
   cTempField:= StrTran(cTempField, "DTOS(", "")
   cTempField:= StrTran(cTempField, "STR(", "")

   nPos:= At(",", cTempField)
   If nPos > 0
      cTempField:= Left(cTempField, nPos - 1) 
   EndIf

   nPos:= At(")", cTempField)
   If nPos > 0
      cTempField:= Left(cTempField, nPos - 1) 
   EndIf

Return cTempField