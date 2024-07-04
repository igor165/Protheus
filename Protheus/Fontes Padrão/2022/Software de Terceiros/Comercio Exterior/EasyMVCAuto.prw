#INCLUDE "AVERAGE.CH"

Static __oEasyAutoError

Function EasyAutoError()
Return __oEasyAutoError

Function EasyMVCAuto(cModel,nOpc,aDataModel,oRet,lInJob,cEmp,cFil,nMod)
Local oObj
Default cEmp := SM0->M0_CODIGO
Default cFil := SM0->M0_CODFIL
Default nMod := nModulo
Default oRet := AvObject():New()
Default lInJob := .F.

oObj := EasyJobCall(lInJob,"EasyCallAuto",cEmp,cFil,nMod,{"EasyAutoMVC",cModel,nOpc,aDataModel})
oRet:Error(oObj:aError)
oRet:Warning(oObj:aWarning)
__oEasyAutoError := oRet

Return !oRet:lError

Function EasyAutoMVC(cModel,nOpc,aDataModels,oErrors)
Local i,j,k,l
Local lRet := .T.
Local aModelDat
Local oModel //:= FWLoadModel(cModel)
Local nOpcItem := 0
Local nLinha   := 0
Local aDataGrid := {}
Local oItemModel
Local aChave := {}
Local aHead := {}
Local aReg := {}
Local aOldReg := {}
Local lRegOk := .T.
Local nPosOld := 0
Local nPosNew := 0
Local nPosRel := 0
Local cItemAlias := ""
Local aChaveCapa := {}
Local aChaveItem := {}
Local aUnqItem
Local aDados := {}

Default oErrors := AvObject():New()

Private lAlteracao := .F.
Private Inclui := nOpc == 3
Private Altera := nOpc == 4
Private Exclui := nOpc == 5
Private aModelData

If Type("oModelAuto") == "O" .AND. GetClassName(oModelAuto) == "MPFORMMODEL" .AND. oModelAuto:GetID() == cModel
   oModel := oModelAuto
Else
   oModel := FWLoadModel(cModel)
EndIf

If Len(aDataModels) == 2 .AND. ValType(aDataModels[1]) == "C"
   aModelData := {aDataModels}
Else
   aModelData := aDataModels
EndIf

Begin Sequence
   
   If Len(aDataModels) == 0
      oErrors:Error("Nao foram indicados os dados a serem utilizados no modelo "+cModel+" para execucao automatica.")
      Break
   EndIf
   
   If Len(oModel:aModelStruct) == 0
      oErrors:Error("Erro ao utilizar o modelo "+cModel+". A estrutura nao esta definida.")
      Break
   EndIf
   
   If (nPosMod := aScan(aModelData,{|X| AllTrim(X[1]) == AllTrim(oModel:aModelStruct[1][3]:cId)})) == 0
      oErrors:Error("Nao foram indicados os dados a serem utilizados no modelo "+cModel+" referente ao formulario principal ("+AllTrim(oModel:aModelStruct[1][3]:cId)+").")
      Break
   EndIf

   cTable := oModel:aModelStruct[1][3]:oFormModelStruct:aTable[1]
   
   If (nOpc == 4 .OR. nOpc == 5) .AND. !(Len(aModelData[nPosMod]) >= 3 .AND. aModelData[nPosMod][3] > 0 .OR. EasySeekAuto(cTable,aModelData[nPosMod][2]))
      oErrors:Error("Registro nao localizado para "+if(nopc==4,"alteracao","exclusao")+" em execucao automatica na tabela "+cTable)
      Break
   EndIf
   
   oModel:SetOperation(nOpc)
   oModel:Activate()
   
   RegToMemory(cTable,nOpc == 3,.F.) //AAF - Utilizado o 3o parametro com .F. para nao carregar do dicionario
   
   If nOpc <> 5
      For i:= 1 To Len(aModelData)
          cForm  := aModelData[i][1]
          aDados := aModelData[i][2]
          
          If ValType(aDados) == "B"
             Eval(aDados,oModel)
          ElseIf (nPosForm := aScan(oModel:aModelStruct,{|X| X[2] == cForm})) > 0 .OR. (nPosForm := aScan(oModel:aModelStruct,{|X| aScan(X[4],{|X| X[2] == cForm})>0})) > 0
             If oModel:aModelStruct[nPosForm][2] == cForm
                
                aUnqItem   := aClone(oModel:aModelStruct[nPosForm][3]:oFormModelStruct:aTable[2])
                /*aChaveCapa := {}
                For j := 1 To Len(aUnqItem)
                   aAdd(aChaveCapa,aUnqItem[j])
                Next j*/
                
                If !(lRet := AtuData(oModel,@oErrors,cForm,aDados,nOpc))
                   Break
                EndIf

             ElseIf (nPosForm2 := aScan(oModel:aModelStruct[nPosForm][4],{|X| X[2] == cForm})) > 0 .AND. oModel:aModelStruct[nPosForm][4][nPosForm2][1] == "GRID"
                aDataGrid := aDados//aDados[i]
                oItemModel := oModel:aModelStruct[nPosForm][4][nPosForm2][3]
                cItemAlias := oItemModel:oFormModelStruct:aTable[1]

                //aUnqItem   := EasyQuebraChave((cItemAlias)->(IndexKey(oItemModel:aUnique[1])),.F.)
                aUnqItem   := EasyQuebraChave(oItemModel:cOrderBy,.F.)
                If Len(aUnqItem) == 0 .OR. Empty(aUnqItem[1])
                   aUnqItem := aClone(oItemModel:oFormModelStruct:aTable[2])
                EndIf
                aChaveItem := {}
                For j := 1 To Len(aUnqItem)
                   If aScan(oItemModel:aRelation,{|X| AllTrim(X[1]) == AllTrim(aUnqItem[j])}) == 0
                      aAdd(aChaveItem,aUnqItem[j])
                   EndIf
                Next j
                
                aHead := oItemModel:aHeader
                
                For j := 1 To Len(aDataGrid)
                   aReg := aDataGrid[j]
                   
                   If ValType(aReg) == "A" .AND. Len(aReg) # 0     // GFP - 17/02/2014              
                   	  
                      nOpcItem := 0
                   	  nLinha   := 0
                      For k := 1 To Len(oItemModel:aDataModel) //MCF - 19/05/2015
                         aOldReg := oItemModel:aDataModel[k][1][1]

                	     lRegOk := .T.
                 	     For l := 1 to Len(aChaveItem)
                	        If (nPosOld := aScan(aHead,{|X| AllTrim(Upper(X[2])) == aChaveItem[l]})) > 0 .AND.;
                   	           (nPosNew := aScan(aReg ,{|X| AllTrim(Upper(X[1])) == aChaveItem[l]})) > 0
                 			   If !AllTrim(Upper(aOldReg[nPosOld])) == AllTrim(Upper(aReg[nPosNew][2]))
			                      lRegOk := .F.
                   	     		  EXIT
                			   EndIf
                  			Else
                 			   oErrors:Error("Campo chave ("+AllTrim(aChaveItem[l])+") não encontrado no registro "+AllTrim(Str(k))+" do alias "+cItemAlias)
			                   lRegOk := .F.
                	     	   Break
                 			EndIf
                   	     Next l
		 
                  		 If lRegOk
                       	    nLinha   := k
                 		    If (nPosNew := aScan(aReg ,{|X| AllTrim(Upper(X[1])) == "AUTDELETA"})) > 0 .AND. aReg[nPosNew][2] $ cSim
                  			   nOpcItem := 5
                  			Else
                  			   nOpcItem := 4
                  			Endif
                  			
                  			EXIT
                  		 EndIf
                  	  Next k
                      
                      If nOpcItem == 0
                         nOpcItem := 3
                      EndIf
                      
                      If !(lRet := ManuItemDt(oModel,@oErrors,cForm,aReg,nOpcItem,nLinha))
                         Break
                      EndIf
                     
                   EndIf
                Next j
             EndIf      
          EndIf
       
      Next i
   Else
      lAlteracao := .T.
   EndIf
  
   If lRet .AND. !oModel:VldData()
      lRet := .F.
      oErrors:Error(GetErrMessage(oModel))
   EndIf
   
   If lRet .And. lAlteracao .AND. !oModel:CommitData()
      lRet := .F.
      oErrors:Error(GetErrMessage(oModel))
   EndIf
   
End Sequence

If !lRet .AND. oModel:lActivate .AND. nOpc <> 5
   oErrors:Warning(ReadData(oModel))
Else
   oErrors:Warning(ReadData(oModel,aModelData))
EndIf

oModel:Deactivate()

If !(Type("oModelAuto") == "O" .AND. GetClassName(oModelAuto) == "MPFORMMODEL" .AND. oModel:GetID() == cModel)
   FreeObj(oModel) //Necessário para eliminar objetos que possuem referencia circular.
EndIf

Return !oErrors:lError

Static Function ManuItemDt(oModel,oErrors,cForm,aReg,nOpcao,nLinha)
Local lRet := .T.
Local oModelGrid := oModel:GetModel():GetModel(cForm) 
Local nQtdItem := 0
Local nPosAutDel := 0
Begin Sequence

   If nOpcao == 3

	  nQtdItem := oModelGrid:GetQtdLine()
      If nQtdItem == 1// Tratamento para inclusão quando não há nenhum item, a quantidade começa com 1
         nQtdItem := 0
      EndIf

      //Incluimos uma nova linha de item
      If nQtdItem == oModelGrid:AddLine()
         // Se por algum motivo o metodo AddLine() não consegue incluir a linha, ele retorna a quantidade de linhas já existem no grid. 
         // Se conseguir retorna a quantidade mais 1
         oErrors:Error(GetErrMessage(oModel))
         lRet    := .F.
         Break
      EndIf
      lAlteracao := .T.
   Else
      oModelGrid:GoLine(nLinha)
   EndIf
 
   If nOpcao <> 5
      If (nPosAutDel := aScan(aReg,{|X| AllTrim(Upper(X[1])) == "AUTDELETA"})) > 0 .AND. aReg[nPosAutDel][2] $ cSim // Retira do vetor
         aDel(aReg,nPosAutDel)
         aSize(aReg,Len(aReg)-1)
      ElseIf nPosAutDel > 0 .And. aReg[nPosAutDel][2] $ cNao
         EasyHelp("Campo 'AUTDELETA' somente na opção de exclusão.","Atenção")
         lRet := .F.
         Break
      EndIf

      If !(lRet := AtuData(oModel,@oErrors,cForm,aReg,nOpcao,.T.))
         Break
      EndIf
   Else
      If !oModelGrid:DeleteLine()
         oErrors:Error(GetErrMessage(oModel))
         lRet    := .F.
         Break  
      EndIf
      lAlteracao := .T.
   EndIf
	
End Sequence
	
Return lRet

Static Function AtuData(oModel,oErrors,cForm,aReg,nOpcao,lDetail)
Local j
Local lRet := .T.
Local cWhen
Local lReg := .T.
Local nPosChv, uDado
Local aFields := oModel:GetModel(cForm):oFormModelStruct:aFields
Local lProces   := .F.
Local lProcTrig := .F.
local lRefazGatilho, lSetValue
Default lDetail := .F.

Begin Sequence
   
   //RRC - 08/05/2013 - O campo EJY_PROCES possui gatilho para os campos EJY_EXPORT, EJY_LOJEXP, EJY_IMPORT e EJY_LOJIMP, sendo assim, já passa pela validação
   lProces := aScan(aReg,{|X| AllTrim(X[1]) == "EJY_PROCES"}) > 0        
   
   For j := 1 To Len(aReg)
      //RRC - 16/05/2013 - Variável para controlar se deve executar os gatilhos do campo EJY_PROCES
      lProcTrig := .F.
      If Empty(cWhen := Posicione("SX3", 2, aReg[j][1], "X3_WHEN")) .Or. &(cWhen)

         If aScan(aFields,{|X| AllTrim(X[3]) == AllTrim(aReg[j][1])}) > 0//(nPosChv := aScan(aChave,{|X| AllTrim(Upper(X[1])) == AllTrim(Upper(aReg[j][1]))})) == 0 .OR. nOpcao == 3 .AND. !aChave[nPosChv][2] 

            /*If lDetail
               lReg := ValType(oModel:GetModel():GetValue(cForm, aReg[j][1])) <> ValType(aReg[j][2]) .OR. oModel:GetModel():GetValue(cForm, aReg[j][1]) <> aReg[j][2]
            EndIf*/

            //If lReg 
            //RRC - 16/05/2013 - Siscoserv: Para o campo "EJY_PROCES" existe uma condição para que mesmo se o dado esteja igual, execute os gatilhos que podem atualizar dados cadastros de Cliente ou Fornecedor no RAS/RVS, como o Endereço   
            If ValType(oModel:GetModel():GetValue(cForm, aReg[j][1])) <> ValType(aReg[j][2]) .Or. oModel:GetModel():GetValue(cForm, aReg[j][1]) <> aReg[j][2] .Or. (lProcTrig := ( Len(aReg[j]) >= 4 .And. ValType(aReg[j][4]) == "L" .And. aReg[j][4]))
               lAlteracao := .T.
               lSetValue:= .F.
               lRefazGatilho:= .F.
               If !Empty(oModel:GetModel():GetValue(cForm, aReg[j][1]))
                  lRefazGatilho:= .T.
               EndIf
               uDado := If(ValType(aReg[j][2]) == "C", AvKey(aReg[j][2],aReg[j][1],.F.),aReg[j][2])
               //RRC - 19/04/2013 - Arredonda valor com a quantidade de decimais informado no campo
               If ValType(uDado) == "N"
                  uDado := Round(uDado,AvSx3(aReg[j][1],AV_DECIMAL))
               EndIf
               //RRC - 08/05/2013 - O campo EJY_PROCES possui gatilho para os campos EJY_EXPORT, EJY_LOJEXP, EJY_IMPORT e EJY_LOJIMP, sendo assim, já passa pela validação
               If !lProces .Or. !(aReg[j][1] == "EJY_EXPORT" .Or. aReg[j][1] == "EJY_LOJEXP" .Or. aReg[j][1] == "EJY_IMPORT" .Or. aReg[j][1] == "EJY_LOJIMP")  
                  If lProcTrig //Significa que é o campo EJY_PROCES e que não houve alteração em seu conteúdo, porém, executa os gatilhos para atualização de dados cadastrais
                     If ValType(oModel:GetModel("EJYMASTER")) == "O" 
                        oModel:GetModel("EJYMASTER"):RunTrigger(aReg[j][1],uDado)
                     EndIf
                  ElseIf (aReg[j][3] == .T. .AND. !(oModel:LoadValue(cForm, aReg[j][1], uDado))) .OR. !(lSetValue:= oModel:SetValue(cForm, aReg[j][1], uDado))
                     lRet := .F.
                     oErrors:Error(GetErrMessage(oModel))
                  Else
                     /* Com o SetValue, os gatilhos são disparados com os dados que constavam no modelo antes da atualização.
                        O bloco abaixo executa o gatilho com os valores atualizados no modelo. */
                     If lSetValue .And. lRefazGatilho
                        oModel:GetModel(cForm):RunTrigger(aReg[j][1])
                     EndIf
                  EndIf
               EndIf
            EndIf

         EndIf
      EndIf
   Next j

End Sequence

Return lRet

Static Function ReadData(oModel,aModelData)
Local aTexto := {}
Local nPosForm, j, nPos

For nPosForm := 1 To Len(oModel:aModelStruct)
   cForm   := oModel:aModelStruct[nPosForm][2]
   aStruct := oModel:aModelStruct[nPosForm][3]:oFormModelStruct:GetFields()
   aAdd(aTexto,{"Formulário",cForm})

   //If oModel:aModelStruct[nPosForm][1] == "FIELD"
      If aModelData <> NIL //.AND. oModel:aModelStruct[nPosForm][1] == "GRID"
         nPos := aScan(aModelData,{|X| AllTrim(X[1]) == AllTrim(cForm)})
         For j := 1 To Len(aModelData[nPos][2])
            uDado := aModelData[nPos][2][j][2]
            aAdd(aTexto,{aModelData[nPos][2][j][1],AvConvert(ValType(uDado),"C",,uDado)})
         Next j
      Else
         For j := 1 To Len(aStruct)
            uDado := oModel:GetValue(cForm, aStruct[j][3])
            aAdd(aTexto,{aStruct[j][3],AvConvert(ValType(uDado),"C",,uDado)})
         Next j
      EndIf
   //ElseIf 
   //EndIf      
Next

SX3->(dbSetOrder(2))
cTexto := ""
For j := 1 To Len(aTexto)
   cTexto += PadL(aTexto[j][1]+If(SX3->(dbSeek(aTexto[j][1])),"("+AvSX3(aTexto[j][1],AV_TITULO)+")",""),Len(SX3->X3_TITULO)+Len(SX3->X3_CAMPO)+2)+": "+if(SX3->X3_TIPO=="C","'","")+aTexto[j][2]+if(SX3->X3_TIPO=="C","'","")+Chr(13)+Chr(10)
Next j

Return cTexto

Static Function GetErrMessage(oModel)
Local cRet := ""
Local aErro

aErro   := oModel:GetErrorMessage(.T.)
// A estrutura do vetor com erro é:
//  [1] Id do formulário de origem
//  [2] Id do campo de origem
//  [3] Id do formulário de erro
//  [4] Id do campo de erro
//  [5] Id do erro
//  [6] mensagem do erro
//  [7] mensagem da solução
//  [8] Valor atribuido
//  [9] Valor anterior

If !Empty(aErro[4]) .AND. SX3->(dbSetOrder(2),dbSeek(aErro[4]))
   xInfo := if(ValType(aErro[8])=="U",aErro[9],aErro[8])
   cRet += "Erro ao preencher campo '"+PadR(AvSX3(aErro[4],AV_TITULO),Len(SX3->X3_TITULO))+"' com valor "+if(ValType(xInfo)=="C","'","")+AllTrim(AvConvert(ValType(xInfo),"C",,xInfo))+if(ValType(xInfo)=="C","'","")+": "+aErro[6]+" "
Else
   cRet += "Registro Inválido ("+AllTrim(aErro[3])+"): "+AllTrim(aErro[6])+" Solução: "+AllTrim(aErro[7])
EndIf

Return cRet

Static Function EasyHelp(cText,cTit)

cHelpTit  := StrTran(cTit ,Chr(13)+Chr(10)," ")//"##TITULO##"
cHelpText := StrTran(cText,Chr(13)+Chr(10)," ")//"##"+Repl("A",10)+Repl(Chr(13)+Chr(10),20)+"##"

Help("",1,"AVG",cHelpTit,cHelpText,1,0,.F.)

Return Nil

Function EasyCallAuto(cFuncao,cModel,nOpc,aDataModels)
Local oErros := AvObject():New()
Local cMsg   := ""

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

//TRY
   MSExecAuto(&("{|cModel,nOpc,aDataModels,oErros| "+AllTrim(cFuncao)+"(cModel,nOpc,aDataModels,@oErros)}"),cModel,nOpc,aDataModels,@oErros)
//CATCH

//END TRY

If Type("__OError") == "O"
   oErros:Error(StrTran(__OError:Errorstack,Chr(10),Chr(13)+Chr(10)))
EndIf

If ValType(NomeAutoLog()) == "C" .And. !Empty(MemoRead(NomeAutoLog())) 
   cMsg := MemoRead(NomeAutoLog())        
   FErase(NomeAutoLog())
EndIf

oErros:Error(cMsg,!lMsErroAuto)

Return oErros

Function EasyJobCall(lInJob,cFuncao,cEmp,cFil,nMod,aParam)
Local oRet
Local nMaxTry
Local nTentativas := 0
Default lInJob := .T.
Default cEmp := SM0->M0_CODIGO
Default cFil := SM0->M0_CODFIL
Default nMod := nModulo

oRet := AvObject():New()

//Pode haver outra integracao em execucao
nMaxTry := 4*20 //20 Segundos
If lInJob
   Do While !GlbLock() .AND. nTentativas < nMaxTry
      sleep( 250 )
      nTentativas++
   EndDo
EndIf

Begin Sequence

   If nTentativas >= nMaxTry
      oRet:Error("Falha ao iniciar execucao automatica. Nao foi possivel iniciar nova thread.")
      BREAK
   EndIf
   
   If lInJob
      PutGlbValue("lInEasyJob", Alltrim( Str( 1 ) ) )
      PutGlbValue("aErrors"        , "{}")
      PutGlbValue("aWarning"       , "{}")
      
      StartJob("EasyInJob",GetEnvServer(),.T.,.T.,cFuncao,cEmp,cFil,nMod,aParam)
      PutGlbValue("lInEasyJob", Alltrim( Str(0) ) )
      
      aArray := &(GetGlbValue("aErrors"))
      AEval(aArray,{|X,i| aArray[i] := StrTran(X,"#-#",Chr(13)+Chr(10))})
      oRet:Error(aArray)
      
      aArray := &(GetGlbValue("aWarning"))
      AEval(aArray,{|X,i| aArray[i] := StrTran(X,"#-#",Chr(13)+Chr(10))})
      oRet:Warning(aArray)
      
      ClearGlbValue("lInEasyJob")
      ClearGlbValue("aWarning")
      ClearGlbValue("aErrors")
      
      GlbUnLock()
   Else
      oRet := EasyInJob(.F.,cFuncao,,,,aParam)
   EndIf
   
End Sequence

Return oRet

Function EasyInJob(lInJob,cFuncao,cEmp,cFil,nMod,aParam)
Local i
Local cRet
Default lInJob := .T.
Private aParams := aParam

If lInJob
   RpcSetType(3)
   RpcSetEnv(cEmp,cFil)
   Private nModulo := nMod
EndIf
//RRC - 09/05/2013 - Inicializa a variável oErros como Private
Private oErros := AvObject():New()

cParams := " "
cVars   := " "
For i := 1 To Len(aParam)
   cVars   += "a"+AllTrim(str(i))+","
   cParams += "aParams["+AllTrim(Str(i))+"],"
Next i
cVars   := Left(cVars,Len(cVars)-1)
cParams := Left(cParams,Len(cParams)-1)

//TRY
   Private bBlock := &("{|"+cVars+"| "+AllTrim(cFuncao)+"("+cVars+")}")
   Private oRet := &("Eval(bBlock,"+cParams+")")
   
   If ValType(oRet) == "O"
      oErros:Error(oRet:aError)
      oErros:Warning(oRet:aWarning)
   EndIf
//CATCH

//END TRY

If Type("__OError") == "O"
   oErros:Error(StrTran(__OError:Errorstack,Chr(10),Chr(13)+Chr(10)))
EndIf

If lInJob
   cRet := ""
   aEval(oErros:aError,{|X| cRet += Chr(34) + X + Chr(34) + "," })
   If !Empty(cRet)
      cRet := Left(cRet,Len(cRet)-1)
   EndIf
   PutGlbValue("aErrors","{"+StrTran(cRet,Chr(13)+Chr(10),"#-#")+"}")
   
   cRet := ""
   aEval(oErros:aWarning,{|X| cRet += Chr(34) + X + Chr(34) + "," })
   If !Empty(cRet)
      cRet := Left(cRet,Len(cRet)-1)
   EndIf
   PutGlbValue("aWarning","{"+StrTran(cRet,Chr(13)+Chr(10),"#-#")+"}")
   GlbUnLock()
EndIf

Return oErros


Function EasyMbAuto(nOpcAuto,aDadosAuto,cAliasAuto,lSeek,lPos,oModel,aDadosMVC)
Local lRet
Local nOpc

Default lPos    := .F.

If lPos
	nOpc := nOpcAuto
Else
	nOpc := Ascan(aRotina,{|x| x[4] == nOpcAuto})
EndIf

If nOpc > 0
    If "VIEWDEF" $ Upper(aRotina[nOpc][2])
        lRet := FWMVCRotAuto(oModel,cAliasAuto,aRotina[nOpc][4],aDadosMVC,lSeek,lPos)
    Else
        lRet := MBrowseAuto(nOpcAuto,aDadosAuto,cAliasAuto,lSeek,lPos)
    EndIf
Else
    lRet := .F.
EndIf

Return lRet