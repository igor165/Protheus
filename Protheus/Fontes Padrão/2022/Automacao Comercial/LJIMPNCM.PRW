#include "fileio.ch"
#Include "Protheus.ch"
#Include "LjImpNCM.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#Include "FiveWin.ch"
#Include "Folder.ch"

#DEFINE CTRL Chr(10)+Chr(13)              	//Pula linha

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJImpNCM³ Rev.   ³Venda CRM              ³ Data ³16.05.2013 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³TELA DE CHAMADA A IMPORTACAO DE IMPOSTOS PARA SYD E EL0     ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaLoja / SigaFRT                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJImpNCM()

Local lRet := .T.
Local bExec
Local oDlg
Local oRadio

Local nOpcf	:=0
Local nRadio	:=1
Local cFile   :=""
Local cType   :=""
Local nBcoHdl :=0

DEFINE MSDIALOG oDlg FROM  94,1 TO 223,293 TITLE OemToAnsi(STR0001) PIXEL // "Importacao de Impostos NCM/NBS"

@ 07,07 TO 38, 139 OF oDlg  PIXEL

@ 14,17 Say OemToAnsi(STR0002) SIZE 150,7 OF oDlg PIXEL  // "Carga Tributária para uso em Cupons"
@ 22,17 Say OemToAnsi(STR0003) SIZE 100,7 OF oDlg PIXEL  // "e Notas Fiscais - Lei 12.741/2012."

DEFINE SBUTTON FROM 45, 080 TYPE 1 ENABLE OF oDlg ACTION( ChangeFile(.T.,@cFile) , nOpcf := 1,oDlg:End())
DEFINE SBUTTON FROM 45, 113 TYPE 2 ENABLE OF oDlg ACTION (oDlg:End())  

ACTIVATE MSDIALOG oDlg CENTERED

If nOpcf == 1  

	Processa({|| AtuNCM(cFile,@lRet)},STR0004)  // Chamada com regua

	If lRet
		MSGINFO(STR0005 , STR0006 )
	Else
		MSGSTOP(STR0007 , STR0006 )
	EndIf
		
EndIf


Return lRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AtuNCM³ Rev.      ³Venda CRM              ³ Data ³16.05.2013 ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Importacao do arquivo de NCM do governo para a tabela SYD   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaLoja / SigaFRT                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function  AtuNCM(cFile,lRet)

Local aCSVFile 	:= {} 
Local cRootPath 	:= StrTran(GetSrvProfString("RootPath","")+IIf(!IsSrvUnix(),"\","/"),IIf(!IsSrvUnix(),"\\","//"),IIf(!IsSrvUnix(),"\","/"))
Local nX 			:= 0  // comeca em 2 porque a a linha 1 eh cabecalho do arquivo 
Local nY 			:= 0   
Local bOldError := ErrorBlock( {|x| LjVerifErro(x,@cDescErro) } ) // muda code-block de erro
Local cDescErro	:= ''   // Variavel para tratamento de erro
Local nValImp	:= 0 
Local nRegs		:= 0 
Local lNCM		:=	AliasInDic("SYD") 
Local lNBS		:=	AliasInDic("EL0") 
Local lFieldNCM :=.F.
Local lFieldNBS :=.F.
Local cIndex		:= CriaTrab(Nil,.F.)
Local cIndexSb5  := CriaTrab(Nil,.F.)
Local	cChaveB1	:= "B1_FILIAL+B1_POSIPI"
Local	cChaveBI	:= "BI_FILIAL+BI_POSIPI"
Local cChaveB5    := "B5_FILIAL+B5_NBS"
Local lFNCMB1		:=	SB1->(FieldPos("B1_IMPNCM")) > 0
Local lFNCMB0    :=  SB0->(FieldPos("B0_IMPNCM")) > 0
Local lFNCMBI		:=	SBI->(FieldPos("BI_IMPNCM")) > 0
Local lFNCMB5     := SB5->(FieldPos("B5_NBS")) > 0
Local lYDALIQIM2	:=   IIF(lNCM,SYD->(FieldPos("YD_ALIQIM2"))>0,.F.)
Local lEL0ALIQI2	:=   IIF(lNBS,EL0->(FieldPos("EL0_ALIQI2"))>0,.F.)
Local nAliqNac		:= 4 // valor padrao da versao 1 do arquivo csv
Local nAliqImp		:= 5 // valor padrao da versao 1 do arquivo csv
Local nExten			:= 2 // valor padrao da versao 1 do arquivo csv
Local nTabela		:= 3 // valor padrao da versao 1 do arquivo csv
Local cCodNCM		:= '' // preenche o codigo NCM com 0 caso tamnho menor que 8
Local cExtensao		:= '' // Extensao / Excessao
Local cSB1Extensao	:= '' // Extensao / Excessao
Local cSYDExtensao	:= '' // Extensao / Excessao
Local aAreaSb1		:= SB1->(GetArea())
Local aAreaSbI		:= SBI->(GetArea())
Local aAliqSb5       := {} // usada para guardar os codigos da B1 referentes a aliquota de serviço
Local nNbs           := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma arquivo CSV em array   ³
//³ Verifica se ha dados no arquivo   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCSVFile	:= CFG57Csv(cFile)
nRegs := Len(aCSVFile)
If nRegs ==0
	MSGStop(STR0008 , STR0006 )
	lRet :=  .F.
EndIf

ProcRegua(nRegs)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se as tabelas existem          ³
//³ e se os campos de impostos estao criados 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. lNCM
	dbSelectArea('SYD')
	SYD->(dbSetOrder(1))
	lFieldNCM :=	SYD->(FieldPos("YD_ALIQIMP")) > 0

	If !lFieldNCM
		MSGStop(STR0009 , STR0006 ) //"Campo de Imposto nao criado na tabela SYD , utilizar o Update UPDLO112" , " Atualizacao NCM/NBS"  
	EndIf	
EndIf

If lRet .AND.  lNBS
	dbSelectArea('EL0')
	EL0->(dbSetOrder(1))
	lFieldNBS :=	EL0->(FieldPos("EL0_ALIQIM")) > 0 
	
	If !lFieldNBS
		MSGStop(STR0010 , STR0006) //"Campo de Imposto nao criado na tabela EL0 , utilizar o Update UPDLO112" , " Atualizacao NCM/NBS"
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa arquivo 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet  .AND. (lNCM .OR. lNBS)

	If nModulo == 23 
		IndRegua("SBI",cIndex,cChaveBI,,,STR0011) //"Selecionando Registros na BI ..."
	Else
		IndRegua("SB1",cIndex,cChaveB1,,,STR0012) //"Selecionando Registros na B1..."
       IndRegua("SB5",cIndexSB5,cChaveB5,,,STR0013) //"Selecionando Registros na B5..."
	Endif
		
	Begin Transaction

       bOldError := ErrorBlock( {|x| LjVerifErro(x,@cDescErro) } ) // muda code-block de erro

		Begin Sequence
			nAliqNac	:= Ascan(aCSVFile[1],{|x| UPPER(x) == 'ALIQNAC'})
			nAliqImp	:= Ascan(aCSVFile[1],{|x| UPPER(x) == 'ALIQIMP'})
			nExten	:= Ascan(aCSVFile[1],{|x| UPPER(x) == 'EX'})
			nTabela	:= Ascan(aCSVFile[1],{|x| UPPER(x) == 'TABELA'})

			For nX := 2 to  Len(aCSVFile)
					
				IncProc(STR0014 +  alltrim(str(nX)) + STR0015  + cFile )						
				nValImp	:= Val(aCSVFile[nX][nAliqNac])
				nValImp2	:= Val(aCSVFile[nX][nAliqImp])
				cCodNCM	:= Alltrim(aCSVFile[nX][1])
				cExtensao:= IIf(Val(aCSVFile[nX][nExten])>0 ,Alltrim(Str(Val(aCSVFile[nX][nExten]))),'')

				 // no csv nao vem o zero e na SYD esta com 0 no inicio do codigo,
				 // mas apenas para NCM e servico ( tabela 0 e 1 ) , LC116 ( tabela 2 )  não completa com zero
				 If Val(aCSVFile[nX][nTabela])  < 2 .AND.Len(cCodNCM) < 8
				 	cCodNCM := '0'+cCodNCM
				 EndIf

				  // Para ficar com o tamanho do x3 e não falhar nos casos de extensao/excessao
				  cCodNCM+= Space(TamSX3("YD_TEC")[1]-Len(cCodNCM))

				If  lNCM .AND. lFieldNCM .AND.  Val(aCSVFile[nX][nTabela])  == 0
					If SYD->(dbSeek(xFilial('SYD') + cCodNCM))
						While !SYD->(EOf()) .AND.SYD->YD_FILIAL+Alltrim(SYD->YD_TEC)==xFilial("SYD")+Alltrim(cCodNCM)
							cSYDExtensao:= IIf(Val(SYD->YD_EX_NCM)>0 ,Alltrim(Str(Val(SYD->YD_EX_NCM))),'')
							If  cSYDExtensao == cExtensao					
								RecLock( 'SYD',.F.)
								SYD->YD_ALIQIMP := nValImp
								If	 lYDALIQIM2
									SYD->YD_ALIQIM2 := nValImp2
								EndIf
								SYD->(MsUnlock())
							EndIf
							SYD->(dbSkip())
						End		
					EndIf
				EndIf
					
					// Atualiza Servico
				If  lNBS  .AND. lFieldNBS .AND.  Val(aCSVFile[nX][nTabela])  == 1
					If EL0->(dbSeek(xFilial('EL0') + cCodNCM + cExtensao ))
						RecLock('EL0',.F.)
						EL0->EL0_ALIQIM := nValImp
						If lEL0ALIQI2
							EL0->EL0_ALIQI2 := nValImp2
						EndIf
						EL0->(MsUnlock())
					Endif
				EndIf

				If nModulo == 23
					//Atualizando SBI  
						// nao tem extensao no front, deve atualizar na retaguarda e descer via carga
						// nao tem controle de importado no front , devera atualizar na retaguarda e descer via carga
						// se for realizado a carga do xls via front, os produtos serao todos considerados como nacional
					If lFNCMBI .AND. (lFieldNCM .OR.lFieldNBS)
						dbSelectArea("SBI")
						If SBI->(DbSeek(xFilial("SBI")+cCodNCM,.T.))  .AND. Alltrim(cCodNCM) ==  Alltrim(SBI->BI_POSIPI)

							While !SBI->(EOf()) .AND.SBI->BI_FILIAL+Alltrim(SBI->BI_POSIPI)==xFilial("SBI")+Alltrim(cCodNCM)

								RecLock('SBI',.F.)
								SBI->BI_IMPNCM := nValImp

								SBI->(MsUnlock())
								SBI->(dbSkip())

							End
						EndIf
					EndIf
				Else
					//Atualizando SB1
					If (lFieldNCM .OR.lFieldNBS) 

                    //Na Sb1 só haverá produtos NCM ,não haverá serviço, que estará na SB5
					   If Val(aCSVFile[nX][nTabela]) == 0  

    						dbSelectArea("SB1")																// para não pegar parcial
    						If SB1->(DbSeek(xFilial("SB1")+cCodNCM,.T.)) .AND. Alltrim(cCodNCM) ==  Alltrim(SB1->B1_POSIPI)
    							While !SB1->(EOf()) .AND.SB1->B1_FILIAL+Alltrim(SB1->B1_POSIPI)==xFilial("SB1")+Alltrim(cCodNCM)
    
    								cSB1Extensao:= IIf(Val(SB1->B1_EX_NCM)>0 ,Alltrim(Str(Val(SB1->B1_EX_NCM))),'')
    
    								If  cSB1Extensao == cExtensao
    								
    						          IF lFNCMB1 // se existe o campo na SB1		
        									RecLock('SB1',.F.)
        									// se nao for nacional ( Manual IBPT )
        									If !SB1->B1_ORIGEM $' 0345' //importado  
        										SB1->B1_IMPNCM := nValImp2
        									Else
        										SB1->B1_IMPNCM := nValImp
        									EndIf
        									SB1->(MsUnlock())
        								EndIF	
    
                                   //alimenta imposto na SB0 tambem, para futuro desuso do campo B1_IMPNCM
                                   //pois ele nunca podera ser criado na SB1, só tem no update
                                   If lFNCMB0 // se existe o campo na SB0
                                   dbSelectArea("SB0")                             
                                   SB0->(dbSetOrder(1))
                                   If SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD,.T.))
                        
                                       RecLock('SB0',.F.)
                                       // se nao for nacional ( Manual IBPT )
                                       If !SB1->B1_ORIGEM $' 0345' //importado  
                                          SB0->B0_IMPNCM := nValImp2
                                       Else
                                          SB0->B0_IMPNCM := nValImp //nacional
                                       EndIf
                                       SB0->(MsUnlock())
                        
                                   EndIf
                                   EndIf
                                            
    								Endif
    								SB1->(dbSkip())
    							End
    						EndIf
    					ElseIf lFNCMB5  // se for serviço e existir o campos na B5
    					
                        dbSelectArea("SB5")                                                           
                        If SB5->(DbSeek(xFilial("SB5")+cCodNCM,.T.)) .AND. Alltrim(cCodNCM) ==  Alltrim(SB5->B5_NBS)
                            While !SB5->(EOf()) .AND.SB5->B5_FILIAL+Alltrim(SB5->B5_NBS)==xFilial("SB5")+Alltrim(cCodNCM)
                        
                                //vai preencher este array para depois atualizar B1, assim não
                                //precisa ficar trocando de indicedo B1 a cada registro do arquivo xls
                                aAdd( aAliqSb5 ,{SB5->B5_COD,nValImp,nValImp2} )
                            SB5->(dbSkip())
                            End
                        EndIf    

    					EndIf
					EndIf
				Endif
			Next

        dbSelectArea("SB1")                             
        SB1->(dbSetOrder(1))

        // codigos nbs que estão na B5 . Atulizará aliquota na B1 correspondente a este registro
        For nNbs := 1 to Len(aAliqSb5)   
    
            If SB1->(DbSeek(xFilial("SB1")+aAliqSb5[nNbs][1],.T.))

                RecLock('SB1',.F.)
                // se nao for nacional ( Manual IBPT )
                If !SB1->B1_ORIGEM $' 0345' //importado  
                   SB1->B1_IMPNCM := aAliqSb5[nNbs][3]
                Else
                   SB1->B1_IMPNCM := aAliqSb5[nNbs][2] //nacional
                EndIf
                SB1->(MsUnlock())

                //alimenta imposto na SB0 tambem, para futuro desuso do campo B1_IMPNCM
                //pois ele nunca podera ser criado na SB1, só tem no update
                If lFNCMB0 // se existe o campo na SB0
                    dbSelectArea("SB0")
                    SB0->(dbSetOrder(1))
                    If SB0->(DbSeek(xFilial("SB0")+SB1->B1_COD,.T.))
                                            
                        RecLock('SB0',.F.)
                        // se nao for nacional ( Manual IBPT )
                        If !SB1->B1_ORIGEM $' 0345' //importado
                            SB0->B0_IMPNCM := aAliqSb5[nNbs][3]
                        Else
                            SB0->B0_IMPNCM := aAliqSb5[nNbs][2] //nacional
                        EndIf
                        SB0->(MsUnlock())
                                            
                    EndIf
                EndIf

            EndIf
        Next

		Recover
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso tenha ocorrido erro a transaçao sera desfeita³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DisarmTransaction()
		MSGStop( STR0016 , STR0006 )
		lRet := .F.
	End Sequence
	ErrorBlock( bOldError )
	End Transaction
	Ferase(cIndex+OrdBagExt())

EndIf

If nModulo == 23
	RetIndex("SBI")
	RestArea(aAreaSBI)
Else
	RetIndex("SB1")
	RestArea(aAreaSB1)
Endif


// limpando Array
aCSVFile := aSize(aCSVFile,0)
aCSVFile := Nil

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³LjVerifErro ³ Autor ³ Vendas Clientes       ³ Data ³ 22/09/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina analizadora do erro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CONA010                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LjVerifErro(e, cDescErro)
Local lRet := .T.

IF e:gencode > 0  

	LjGravaLog( .T., '-', Replicate("*", 40))
	LjGravaLog( .T., '-', "DESCRIPTION:" + e:DESCRIPTION)				
	LjGravaLog( .T., '-', "ERRORSTACK:" + e:ERRORSTACK)				
	LjGravaLog( .T., '-', Replicate("*", 40))
	Alert( Alltrim(e:DESCRIPTION))
	lRet:=.T.
	cDescErro := "DESCRIPTION: " + e:DESCRIPTION + CTRL
    	cDescErro += "ERRORSTACK:" + CTRL  
    	cDescErro += e:ERRORSTACK
    	lRet := .F.
EndIf

Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ChangeFile³ Autor ³ Venda CRM             ³ Data ³ 16.05.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe arquivo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ChangeFile()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATCONF                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function ChangeFile(lOpen,cFile)

Local cFileChg       

DEFAULT lOpen := .T.

cType    := OemToAnsi("NCM|")+'*.CSV' 

cFileChg	:= cGetFile( cType, OemToAnsi('NCM/NBS'+Subs(cType,1,7)) , 1,, lOpen, 1+16+32, .T. ) //GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE

If  Empty(cFileChg)
	cFile:=""
	Return 
Endif

If  "."$cFileChg
	cFileChg := Substr(cFileChg,1,rat(".", cFileChg)-1)
Endif

cFileChg    := alltrim(cFileChg)
cFile       := Alltrim(cFileChg+Right(cType,4))

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³lj7BuscaImp³ Autor ³ Venda CRM            ³ Data ³ 16.05.13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Escolhe arquivo                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ lj7BuscaImp()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³ cCodNCM	- Codigo a ser Pesquisa na SYD ou NBS                       ³±±
±±³ lServico	- Se eh servico(EL0) ou produto(SYD)                        ³±±
±±³ lImport   - Se eh produto Importado                                   ³±±
±±³ cExtensao - Extensao codigo NCM, NBS não tem extensão                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaLoja/SigaFRT                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Function lj7BuscaImp(cCodNCM,lServico,lImport ,cExtensao , cProduto)

Local nValAliq 		:=	0 
Local aArea			:=	GetArea()       
Local lFieldNCM		:=	IIf( AliasInDic("SYD"),SYD->(FieldPos("YD_ALIQIMP")) > 0 .AND. SYD->(FieldPos("YD_ALIQIM2")) > 0,.F.)  
Local lFieldNBS		:=	IIf( AliasInDic("EL0"),EL0->(FieldPos("EL0_ALIQIM")) > 0 .AND. EL0->(FieldPos("EL0_ALIQI2")) > 0,.F.) 
Local lFieldNB5		:=	IIf( AliasInDic("SB5"),SB5->(FieldPos("B5_NBS")) > 0 ,.F.) 
Local nExtensao		:=  0

DEFAULT cCodNCM		:='' 		// Codigo a ser Pesquisa na SYD ou NBS
DEFAULT lServico	:= .F. 		// Se eh servico ou produto 
DEFAULT lImport		:= .F. 		// Se eh produto Importado 
DEFAULT cExtensao	:= '' 		// Extensao codigo NCM
DEFAULT cproduto    := ''       // codigo do produto ,para o caso de serviço

 // Para ficar com o tamanho do x3 e não falhar nos casos de extensao/excessao
nExtensao:= IIf(Val(cExtensao)>0 ,Val(cExtensao),0)
cCodNCM+= Space(TamSX3("YD_TEC")[1]-Len(cCodNCM))

If lServico
	If lFieldNBS  // existe a tebelas e os campos 
       If lFieldNB5
	       dbSelectArea("SB5")
	       SB5->(dbSetOrder(1))                                                           
	       If SB5->(DbSeek(xFilial("SB5")+Alltrim(cProduto),.T.)) 
	           cCodNCM := Alltrim(SB5->B5_NBS)
	       EndIf
		EndIf	           
		
        If !Empty(cCodNCM) 
            dbSelectArea('EL0')
            EL0->(dbSetOrder(1))
            If EL0->(dbSeek(xFilial('EL0') + cCodNCM ))  //EL0 NÃO TEM EXTENSAO 
                If lImport 
                    nValAliq	:=  EL0-> EL0_ALIQI2
                Else
                    nValAliq	:=  EL0-> EL0_ALIQIM
                EndIf
            EndIf
        EndIf
	EndIf        
Else
	If lFieldNCM   // existe a tebelas e os campos 
		dbSelectArea('SYD')
		SYD->(dbSetOrder(1))
		If SYD->(dbSeek(xFilial('SYD') + cCodNCM))
			// esse laco eh necessario porque o seek pela extensao pode nao funcionar,
			// se a extensao nao estiver cadastrada da forma 00x 			
			While SYD->(!EOF()) .AND.  (xFilial('SYD') == SYD->YD_FILIAL .AND. cCodNCM == SYD->YD_TEC  )    
				If nExtensao == Val(SYD->YD_EX_NCM)  
					If lImport
						nValAliq	:=  SYD-> YD_ALIQIM2
					Else
						nValAliq	:=  SYD-> YD_ALIQIMP
					EndIf
				EndIf	
				SYD->(dbSkip())
			End
					
		Endif
	EndIf
EndIf

RestArea(aArea)

Return nValAliq



