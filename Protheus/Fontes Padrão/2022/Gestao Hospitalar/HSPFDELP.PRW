Static lEmpOk := .F.

#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"

Function HS_LstEmp()
 Local aEmp := {}
 
 DbSelectArea("SM0")
 DbGoTop()
 While !Eof()
  aAdd(aEmp, {SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL})
   
  DbSkip()
 End 
Return(aEmp)

Function HS_AbreEmp(xEnvironment, xEmpresa, xModulo, xTabelas)
 Local nCon := 0, lRet := .T.
 Local cTopDataBase := GetPvProfString(xEnvironment, "TopDatabase", "MSSQL7"   , GetADV97())
 Local cTopServer   := GetPvProfString(xEnvironment, "TopServer"  , "LOCALHOST", GetADV97())
 Local cTopAlias    := GetPvProfString(xEnvironment, "TopAlias"   , "ORFEU"    , GetADV97())
 Local cTopConType  := GetPvProfString(xEnvironment, "TopConType" , "TCPIP"    , GetADV97())
 Local cLocalFiles  := GetPvProfString(xEnvironment, "LocalFiles" , "ADS"      , GetADV97())
 
 xModulo := IIF(xModulo == Nil, "SIGACFG", xModulo)
 
 If     cLocalFiles == "ADS"
  cLocalFiles := "DBFCDXADS"
 ElseIf cLocalFiles == "CTRRE" 
  cLocalFiles := "CTRRECDX"
 ElseIf cLocalFiles == "BTRIEVE"
  cLocalFiles := "BTVCDX"
 Else
  cLocalFiles := "DBFCDX"
 EndIf
 
 lEmpOk := Type("SM0->M0_CODIGO") == "C"
 If !lEmpOk
  #IFDEF TOP             
   QOut("TopDataBase = " + cTopDataBase)
   QOut("TopServer   = " + cTopServer  )
   QOut("TopAlias    = " + cTopAlias   )
   QOut("TopConType  = " + cTopConType )
   TCConType(cTopConType)
   nCon := TCLink(cTopDataBase + "/" + cTopAlias, cTopServer)
   If nCon < 0
    qOut("Falha de conexão com o TOPConnect")
    lRet := .F.
   Else 
  #ENDIF
  
  If xEmpresa == Nil           
   QOut(cLocalFiles)
   //DbUseArea(.T., cLocalFiles, "SIGAMAT.EMP", "SM0", .T., .F.) 
   xEmpresa := SM0->M0_CODIGO + SM0->M0_CODFIL
   dbCloseArea()
  EndIf 
        
  If xTabelas <> Nil
   Prepare Environment Empresa SubStr(xEmpresa, 1, 2) Filial SubStr(xEmpresa, 3, 2) Modulo xModulo Tables xTabelas
  Else
   Prepare Environment Empresa SubStr(xEmpresa, 1, 2) Filial SubStr(xEmpresa, 3, 2) Modulo xModulo
  End 
  
  QOut("Empresa : " + SubStr(xEmpresa, 1, 2) + "   Filial : " + SubStr(xEmpresa, 3, 2) + "  Modulo : " + xModulo + ", Inicializado com sucesso....")
 
  #IFDEF TOP   
   EndIf
  #ENDIF 
 EndIf
Return({lRet, nCon})

Function HS_FechaEmp(nCon)
 If !lEmpOk
  DbCloseAll()
  #IFDEF TOP
   TCUnLink(nCon)
  #ENDIF 
 EndIf 
Return(.T.)

Function HS_Arq2Vet(cAlias)
 Local aRet := {}
 
 DbSelectArea(cAlias)
 DbSetOrder(1)
 DbSeek(xFilial(cAlias))
 While !Eof()
   aAdd(aRet, {GAV->GAV_REGATE, GAV->GAV_REGGER, GAV->GAV_NOME, GAV->GAV_CODLOC, GAV->GAV_QUARTO, GAV->GAV_LEITO})
 
  DbSkip()
 End 
 
Return(aRet)