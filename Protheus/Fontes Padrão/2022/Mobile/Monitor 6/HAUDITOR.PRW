#include "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ HandAudit³ Autor ³ Marcelo Vieira        ³ Data ³ 27/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gerar um auditor dos validacoes do protheus                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista    ³ Data   ³Motivo da Alteracao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function HAuditor()
Local cFile   := "AUDITSFA.##R"
Local cRootPath:= Trim(GetSrvProfString("RootPath",""))
Local cPathPalm:= GetMv("MV_RELT" ,,"\RELATO\") 
Local nHandle  := 0 
Local aCfgData:={}
Local aPE:={}
Local ni:=1
Private aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }

MSGSTOP( OEMTOANSI("Este auditor tem o objetivo de auxiliar na implantacao do" +;
                   "SFA, listando os campos  do  dicionario  das  tabelas que " +;
                   "fazem parte da solucao SFA." ) )
                   
If File(cRootPath+cPathPalm+cFile)
   Ferase(cRootPath+cPathPalm+cFile)
endif

nHandle:=FCreate(cPathPalm+cFile)

// Busca Configuracoes No apxSrv.ini
FWrite(nHandle, DtoC(MsDate()) + " - " + Time()   + Chr(13) + Chr(10)) 
FWrite(nHandle, "SFA - Auditor de validacoes -  SC5 - CAB. DO PEDIDO "  +  Chr(13) + Chr(10))
FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))

//GetPvProfString(<sessao>,<chave>,<valor padrao>,<nome do arquivo ini>) 
cLinha1:=GetSrvProfString("Enable","")
cLinha2:=GetSrvProfString("RPCEnable","")  
cLinha3:=GetSrvProfString("RPCEnv","")
cLinha4:=GetSrvProfString("RpcTimeOut","")
cLinha5:=GetSrvProfString("Port","")

FWrite(nHandle, clinha1 +  Chr(13) + Chr(10) )
FWrite(nHandle, clinha2 +  Chr(13) + Chr(10) )
FWrite(nHandle, clinha3 +  Chr(13) + Chr(10) )
FWrite(nHandle, clinha4 +  Chr(13) + Chr(10) )
FWrite(nHandle, clinha5 +  Chr(13) + Chr(10) ) 
FWrite(nHandle, "Verifique se a sessao [GENTCPIP] foi criada no ini o Server do Protheus" +  Chr(13) + Chr(10))

// Primeiro Verifica o dicionario no SX3
dbSelectArea( "SX3" )
dbSetOrder(1)

DbSeek( "SC5" )
// Busca Validacoes do SC5
FWrite(nHandle, DtoC(MsDate()) + " - " + Time()   + Chr(13) + Chr(10)) 
FWrite(nHandle, "SFA - Auditor de validacoes -  SC5 - CAB. DO PEDIDO "  +  Chr(13) + Chr(10))
FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))

DO While sx3->(!eof()) .and. SX3->X3_ARQUIVO="SC5" 
   FWrite(nHandle, " TIPO       = "+ IF(SX3->X3_PROPRI="U","Criado por Usuario","Padrao Siga")+ Chr(13) + Chr(10))
   FWrite(nHandle, " X3_CAMPO   = "  + SX3->X3_CAMPO + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_VALID   = "  + Alltrim(SX3->X3_VALID)    + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_RELACAO = "  + Alltrim(SX3->X3_RELACAO)  + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_VLDUSER = "  + Alltrim(SX3->X3_VLDUSER)  + Chr(13) + Chr(10))
   FWrite(nHandle, Chr(13) + Chr(10))
   If SX7->( dbSeek( SX3->X3_CAMPO ) )
      FWrite(nHandle, space(20) + ">> GATILHO" + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_CAMPO = " + SX7->X7_CAMPO + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_REGRA = " + SX7->X7_REGRA + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_CDOMN = " + SX7->X7_CDOMIN   + Chr(13) + Chr(10) )       
   Endif
   FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))
   
   sx3->( dbSkip() )
EndDo

DbSeek( "SC6" )
FWrite(nHandle, DtoC(MsDate()) + " - " + Time()    + Chr(13) + Chr(10)) 
FWrite(nHandle, "SFA -  Auditor  de validacoes -  SC6 - ITENS DO PEDIDO"     +  Chr(13) + Chr(10))
FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))
 
DO While sx3->(!eof()) .and. SX3->X3_ARQUIVO="SC6" 
   FWrite(nHandle, " TIPO       = "  + IF(SX3->X3_PROPRI="U","Criado por Usuario","Padrao Siga")+ Chr(13) + Chr(10))
   FWrite(nHandle, " X3_CAMPO   = "  + SX3->X3_CAMPO + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_VALID   = "  + Alltrim(SX3->X3_VALID)    + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_RELACAO = "  + Alltrim(SX3->X3_RELACAO)  + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_VLDUSER = "  + Alltrim(SX3->X3_VLDUSER)  + Chr(13) + Chr(10))
   FWrite(nHandle, Chr(13) + Chr(10))
   If SX7->( dbSeek(SX3->X3_CAMPO) )
      FWrite(nHandle, space(20) + ">> GATILHO" + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_CAMPO = " + SX7->X7_CAMPO + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_REGRA = " + Alltrim(SX7->X7_REGRA) + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_CDOMN = " + Alltrim(SX7->X7_CDOMIN)   + Chr(13) + Chr(10) )       
   Endif
   FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))

   sx3->( dbSkip() )
   
EndDo

DbSeek( "SA1" )
FWrite(nHandle, DtoC(MsDate()) + " - " + Time()    + Chr(13) + Chr(10)) 
FWrite(nHandle, "SFA -  Auditor  de validacoes -  SA1 - CLIENTES "     +  Chr(13) + Chr(10))
FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))
 
DO While sx3->(!eof()) .and. SX3->X3_ARQUIVO="SA1" 
   FWrite(nHandle, " TIPO       = "  + IF(SX3->X3_PROPRI="U","Criado por Usuario","Padrao Siga")+ Chr(13) + Chr(10))
   FWrite(nHandle, " X3_CAMPO   = "  + SX3->X3_CAMPO + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_VALID   = "  + Alltrim(SX3->X3_VALID)    + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_RELACAO = "  + Alltrim(SX3->X3_RELACAO)  + Chr(13) + Chr(10))
   FWrite(nHandle, " X3_VLDUSER = "  + Alltrim(SX3->X3_VLDUSER)  + Chr(13) + Chr(10))
   FWrite(nHandle,  Chr(13) + Chr(10))
   If SX7->( dbSeek(SX3->X3_CAMPO) )
      FWrite(nHandle, space(20) + ">> GATILHO " + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_CAMPO = " + SX7->X7_CAMPO + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_REGRA = " + Alltrim(SX7->X7_REGRA) + Chr(13) + Chr(10) ) 
      FWrite(nHandle, space(20) + "  X7_CDOMN = " + Alltrim(SX7->X7_CDOMIN) + Chr(13) + Chr(10) )       
   Endif
   FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))

   sx3->( dbSkip() )
   
EndDo

// Parametros

aadd(aCfgData,{"MV_BONUSTS" ,GetMv("MV_BONUSTS" ,,"502"),"Parametro do Mod. Faturamento, o Tes do Item de Bonificacao" })  
aadd(aCfgData,{"MV_PRODUPL" ,GetMv("MV_PRODUPL"  ,,"F"),"Indica a possibilidade da repeticao de um produto em um pedido  (Protheus)"})   
aadd(aCfgData,{"MV_SFAVIEW" ,GetMv("MV_SFAVIEW"  ,,"C"),"View da Visita de Negocios (Cliente ou Roteiro)" }) 
aadd(aCfgData,{"MV_SFAPVIEW",GetMv("MV_SFAPVIEW" ,,"0"),"Permissao de View da Visita de Negocios" + Chr(13) + Chr(10)+ ;
														 " ** -> 0 ou se nao houver o Parametro - Cliente/Roteiro"+ Chr(13) + Chr(10)+ ;
														 " ** -> 1 - Roteiro"+ Chr(13) + Chr(10) + ;
														 " ** -> 2 - Cliente" })    
aadd(aCfgData,{"MV_SFAMTES",GetMv("MV_SFAMTES" ,,"N"),"Manipula o TES" + Chr(13) + Chr(10) + ;
													   "N= Nao (Utiliza o Tes do Cadastro de Produto)" + Chr(13) + Chr(10)+ ; 
 													   "S= Sim (Vendedor escolhe o TES na Operacao de Pedido)" })     
 															
aadd(aCfgData,{"MV_SFAPLC"  ,GetMv("MV_SFAPLC" ,,"9999"), "Preh - Limite de Credito. Utilizado para Clientes cadastrados no SFA." })  

aadd(aCfgData,{"MV_SFABLOQ" ,GetMv("MV_SFABLOQ" ,,"T"), "Verificacao de Credito  do Protheus"})     

aadd(aCfgData,{"MV_SFAASS" ,GetMv("MV_SFAASS" ,,"F"),"** Usar Assinatura Digital (nao disponivel)" })    

aadd(aCfgData,{"MV_SFATPRO",GetMv("MV_SFATPRO",,"1"),"Telas do Produto: " + Chr(13) + Chr(10) + ;   
	           										   "1 - Avancado (Tela Padrao de Produto)"+ Chr(13) + Chr(10) + ;
													   "2 - Basico (Tela de Produto sem Grupo)" + Chr(13) + Chr(10) + ;
													   "3 - Especifico (Ponto de Entrada)" })

aadd(aCfgData,{"MV_SFATPED",GetMv("MV_SFATPED",,"1"), "Telas de Pedido: "  + Chr(13) + Chr(10) + ;
													   "1 - Tela Pedido V 1.0" + Chr(13) + Chr(10) + ;
													   "2 - Tela Pedido V 2.0" + Chr(13) + Chr(10) + ; 
													   "3 - Tela Pedido Ponto de Entrada" }) 
aadd(aCfgData,{"MV_DTSYNC",GetMv("MV_DTSYNC",,"7" ), "Quantidade de Dias sem sincronismo" })     
aadd(aCfgData,{"MV_PLMPRD",GetMv("MV_PLMPRD",,"S" ), "Indica se usa exportacao 'generica'. O 'defaut e 'S' " })     
aadd(aCfgData,{"MV_PLGENFR",GetMv("MV_PLGENFR",,24 ),"Indica tempo de espera para gerar pasta generica. O defaut e 24hs " })     

aadd(aCfgData,{"MV_PLMTPPR",GetMv("MV_PLMTPPR",,"PA"),"Tipo de produto para exportar (filtra pelo campo B1_TIPO) " })     
aadd(aCfgData,{"MV_QTPEDPM",GetMv("MV_QTPEDPM",,"1")   ,"Quantidade de Pedidos a serem enviados para o Palm" })     


// Busca parametros 
FWrite(nHandle, DtoC(MsDate()) + " - " + Time()   + Chr(13) + Chr(10)) 
FWrite(nHandle, "SFA -  Auditor  de validacoes - Parametros   "  +  Chr(13) + Chr(10))
FWrite(nHandle, Replicate("=",080)  +  Chr(13) + Chr(10))

For ni:=1 to Len(aCfgdata)
	If ValType(aCfgdata[ni,2]) = "N"
		uValor2 := Str(aCfgdata[ni,2],5,2)
	ElseIf ValType(aCfgdata[ni,2]) = "D"
		uValor2 := DtoC(aCfgdata[ni,2])
	Else
		uValor2 := aCfgdata[ni,2]
	EndIf		
	If ValType(aCfgdata[ni,3]) = "N"
		uValor3 := Str(aCfgdata[ni,3],5,2)
	ElseIf ValType(aCfgdata[ni,3]) = "D"
		uValor3 := DtoC(aCfgdata[ni,3])
	Else
		uValor3 := aCfgdata[ni,3]
	EndIf		 
 
    FWrite(nHandle, aCfgdata[ni,1] + " = " + uValor2 + " : " + uValor3 + Chr(13) + Chr(10))  
    FWrite(nHandle, "*** DEFAUT NAO EXISTINDO O PARAMETRO E : " + uValor2 + Chr(13) + Chr(10))
    FWrite(nHandle, "" + Chr(13) + Chr(10))
next

aadd(aPE,{"U_AFVM020A"})    
aadd(aPE,{"U_MTA410"  })    
aadd(aPE,{"U_MTA410I" })    
aadd(aPE,{"U_MTA410T" })    
aadd(aPE,{"U_M030INC" })    
aadd(aPE,{"U_M030ALT" })    

// Busca Pontos de entrada
FWrite(nHandle, DtoC(MsDate()) + " - " + Time()   + Chr(13) + Chr(10)) 
FWrite(nHandle, "SFA -  Auditor  de validacoes - Pontos de Entrada   "  +  Chr(13) + Chr(10))
FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))
FWrite(nHandle, "*                                                        "  +  Chr(13) + Chr(10))                                                                                                    
FWrite(nHandle, "*  ATENCAO !!! Revisar os pontos de entrada  que usam    "  +  Chr(13) + Chr(10))
FWrite(nHandle, "*  funcoes  de tela para para usuarios  ex.: MsgStop()   "  +  Chr(13) + Chr(10))
FWrite(nHandle, "*  Deve-se fazer o desvio usando a variavel L410Auto     "  +  Chr(13) + Chr(10))
FWrite(nHandle, "*                                                        "  +  Chr(13) + Chr(10))                                                                                                    
FWrite(nHandle, Replicate("=",080) +  Chr(13) + Chr(10))

For ni:=1 to Len(aPE) 

    If FindFunction( aPE[ni,1] )
       FWrite(nHandle, aPE[ni,1] + Chr(13) + Chr(10))
       FWrite(nHandle, " >> Favor revisar o P.E. acima, verificando a existencia de comandos/funcoes de tela" + Chr(13) + Chr(10))       
       FWrite(nHandle, "    (Ex.: Alert(),MsgStop() e Etc...)." + Chr(13) + Chr(10))       
       FWrite(nHandle, "    Estes comandos/funcoes NAO podem ser utilizados no JOB ou rotinas automaticas." + Chr(13) + Chr(10))       
       FWrite(nHandle, "    Exemplo de Funcao Revisada:" + Chr(13) + Chr(10))       
       FWrite(nHandle, "" + Chr(13) + Chr(10))              
       FWrite(nHandle, '    if Type("L410Auto")!="U" .And. L410Auto' + Chr(13) + Chr(10))       
       FWrite(nHandle, "       //nao tem funcao de tela" + Chr(13) + Chr(10))       
       FWrite(nHandle, "    Else" + Chr(13) + Chr(10))       
       FWrite(nHandle, '       MsgAlert("Exemplo")' + Chr(13) + Chr(10))       
       FWrite(nHandle, "    Endif" + Chr(13) + Chr(10))       
       FWrite(nHandle, "" + Chr(13) + Chr(10))              
    Else   
       FWrite(nHandle, "PONTO DE ENTRADA = " + aPE[ni,1] + " >> NAO COMPILADO NO RPO !!!" + Chr(13) + Chr(10))
       FWrite(nHandle, "" + Chr(13) + Chr(10))              
    Endif   
next

FWrite(nHandle, Replicate("=",60)+ " Auditoria completada"  +  Chr(13) + Chr(10))
FClose(nHandle) 

If File(cRootPath+cPathPalm+cfile )
	ShowMemo(cRootPath+cPathPalm+cFile)
EndIf

Return
