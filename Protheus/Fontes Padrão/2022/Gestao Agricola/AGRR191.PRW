#include 'rwmake.ch'
#include 'msole.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçào    ³ AGRR191  ³ Autor ³ Danyel Bernuci        ³ Data ³ 13/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Autorizacao de Saida							              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Clientes Microsiga                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRR191()  

Local oDlgWord := Nil

Private	cPerg	 	:= 'AGR191'
Private uDoc   		:= Nil
Private aInfo	 	:= {}

	@ 000,000 To 180,300 Dialog oDlgWord Title OemToAnsi("Autorizacao de Saida")												
	@ 020,020 Say OemToAnsi("Esta rotina consiste em imprimir autorizacao")
	@ 028,020 Say OemToAnsi("de Saida em duas Unidades de Medidas") 
	@ 010,010 To 060,137
	@ 065,025 BmpButton Type 5 Action Eval( { || Pergunte(cPerg,.t.) } )
	@ 065,060 BmpButton Type 6 Action (OLE_CloseFile(uDoc),OLE_CloseLink(uDoc),Eval( { || Pergunte(cPerg,.f.) , AGR191IMP() } ))
	@ 065,095 BmpButton Type 2 Action (Close(oDlgWord),nOpc := 2)
	Activate Dialog oDlgWord Centered

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçào    ³AGR191PROC³ Autor ³ Danyel Bernuci        ³ Data ³ 13/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Seleciona o Modelo do Documento							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGRR191                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGR191PROC()
Local 	sAlias		:= 	GetArea()
Local	cNameVar	:=	ReadVar()
Local 	cTipo			:= "Modelo de Documentos(*.DOT)  |*.DOT | "													
Local 	cNewPathArq	:= cGetFile(cTipo,OemToAnsi("Selecione o Documento de Saida"))									

IF !Empty( cNewPathArq )
	IF Upper( Subst( AllTrim( cNewPathArq), - 3 ) ) == Upper( AllTrim( "DOT" ) )	
		Aviso( "Arquivo Selecionado" , cNewPathArq , { "OK" } )								
    Else
    	MsgAlert( "Arquivo Inválido ", "Atenção" )															
    	Return
    EndIF
Else
    Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo." ,{ "OK" } )													
    Return
EndIF

&cNameVar	:=	cNewPathArq

RestArea(sAlias)

Return .t.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçào    ³AGR191IMP ³ Autor ³ Danyel Bernuci        ³ Data ³ 13/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Importa as Variaveis para o Modelo do Documento			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGRR191                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGR191IMP()
Local uVar   := {} 
  
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Inicializa o Ole com o MS-Word 97 ( 8.0 )						        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


 	uDoc := OLE_CreateLink('TMsOleWord97') ; OLE_NewFile(uDoc,mv_par02)
  	uVar := AGR191VAR()
  
        /*
   		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Ajustando as Variaveis do Documento                          ³
   		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
		Aeval(	uVar																								,; 
				{ |x| OLE_SetDocumentVar( uDoc, x[1]  																,;
											IF( Subst( AllTrim( x[3] ) , 4 , 2 )  == "->"          			    ,; 
												Transform( x[2] , PesqPict( Subst( AllTrim( x[3] ) , 1 , 3 )		,;
																			Subst( AllTrim( x[3] )  				,;
										        			         			  - ( Len( AllTrim( x[3] ) ) - 5 )	 ;	
										          								 )	  	 							 ; 
																	      )                                          ;
												         )															,; 
												Transform( x[2] , x[3] )                                     		 ;
				  	 						  ) 														 	 		 ; 
										)																			 ;
				}     																 							 	 ;
			 )
		/*
   		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
        ³ Atualiza as Variaveis                                        ³
   		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   		*/ 
        OLE_UpDateFields(uDoc)
 	    /*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Imprimindo o Documento                                                 ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		*/
        
        OLE_SetProperty( uDoc, '450', .F. )
        
        
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funçào    ³AGR191VAR ³ Autor ³ Danyel Bernuci        ³ Data ³ 14/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descriçào ³ Faz o Tratamento das Variaveis							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ AGRR191                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function AGR191VAR()
Local	aMeses	:=	{"Janeiro","Fevereiro","Marco","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Local	cDsclio	:=	Space(40)
Local	cRgclio	:=	Space(20)
Local	cCgclio	:=	Space(14)
Local	cInclio	:=	Space(20)
Local	cEnclio	:=	Space(30)
Local	cMuclio	:=	Space(02)
Local	cUfclio	:=	Space(02)
Local	cDsArma	:=	Space(40)
Local	cRgArma	:=	Space(20)
Local	cCgArma	:=	Space(14)
Local	cInArma	:=	Space(20)
Local	cEnArma	:=	Space(30)
Local	cMuArma	:=	Space(30)
Local	cUfArma	:=	Space(02)
Local	cDtaExt	:=	""
Local	cExtens	:=	""
Local	nQtdUn	:=	0
Local	nQtdSeg	:=	0
Local	cUm		:=	Space(02)
Local	cSegum	:=	Space(02)

Local	uVetor	:= 	{}
Local	__k,__i
Local	aFilName:=	{"REAIS","REAL","CENTAVOS","CENTAVO"} 
Local	aVarName:=	{"cExtUm"}
Private	cExtUm	:=	""
Private	cExtSeg	:=	""	 
      
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona na Autorizacao Saida³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      	DbSelectArea("NPD")
	  	DBSetOrder(1)
	  	If DbSeek(xFilial("NPD")+mv_par01)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o Produto Relacionado a Transferencia³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SB1")
			DbSetOrder(1)
			If DbSeek(xFilial("SB1")+npd->npd_codpro)	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verifica as Informacoes do Cliente origem³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("SA1")
				DbSetOrder(1)
				If DbSeek(xFilial("SA1")+npd->npd_codcli+npd->npd_lojcli)
					cDsclio	:=	Alltrim(sa1->a1_nome)
					cRgclio	:=	Alltrim(sa1->a1_pfisica)
					cCgclio	:=	Alltrim(sa1->a1_cgc)
					If Len(cCgclio)<14
						cCgclio	:=	Alltrim(Transform(cCgclio,"@r 999.999.999-99"))					
					Else
						cCgclio	:=	Alltrim(Transform(cCgclio,"@r 999.999.999/9999-99"))					
					Endif										
					cInclio	:=	Alltrim(sa1->a1_inscr)
					cEnclio	:=	Alltrim(sa1->a1_end)
					cMuclio	:=	Upper(SubStr(Alltrim(sa1->a1_mun),1,1))+Lower(SubStr(Alltrim(sa1->a1_mun),2,(Len(Alltrim(sa1->a1_mun))-1)))  
					cUfclio	:=	Alltrim(sa1->a1_est)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Verifica as Informacoes do Armazem  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DbSelectArea("NNR")
					DbSetOrder(1)
					If DbSeek(xFilial("NNR")+npd->npd_arm)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Verifica o cliente amarrado ao Armazem  ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DbSelectArea("SA1")
						DbSetOrder(1)
						If DbSeek(xFilial("SA1")+nnr->nnr_codcli+nnr->nnr_lojcli)							
							cDsArma	:=	Alltrim(sa1->a1_nome)
							cRgArma	:=	Alltrim(sa1->a1_pfisica)
							cCgArma	:=	Alltrim(sa1->a1_cgc)
							If Len(cCgArma)<14
								cCgArma	:=	Alltrim(Transform(cCgArma,"@r 999.999.999-99"))					
							Else
								cCgArma	:=	Alltrim(Transform(cCgArma,"@r 999.999.999/9999-99"))					
							Endif										
							cInArma	:=	Alltrim(sa1->a1_inscr)
							cEnArma	:=	Alltrim(sa1->a1_end)
							cMuArma	:=	Upper(SubStr(Alltrim(sa1->a1_mun),1,1))+Lower(SubStr(Alltrim(sa1->a1_mun),2,(Len(Alltrim(sa1->a1_mun))-1)))  
							cUfArma	:=	Alltrim(sa1->a1_est)								
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Verifica a Safra  ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea("NN1")
							DbSetOrder(1)
							If DbSeek(xFilial("NN1")+npd->npd_safra)							
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se existe a primeira unidade de medida³
								//³e se a mesma eh diferente da unidade padrao	  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Len(Alltrim(mv_par03))>0 .And. Alltrim(mv_par03)<>Alltrim(sb1->b1_um)	  
	 								cUm		:=	Alltrim(mv_par03)	
									nQtdUn	:=	Agrx001(Alltrim(sb1->b1_um),Alltrim(mv_par03),npd->npd_qtdpro)									
									cExtUm	:=	Extenso(Round(nQtdUn,2))										
								Else
	 								cUm		:=	Alltrim(sb1->b1_um)
									nQtdUn	:=	Round(npd->npd_qtdpro,2)
									cExtUm	:=	Alltrim(Extenso(nQtdUn))									
								Endif	
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se existe a segunda unidade de medida ³
								//³e se a mesma eh diferente da unidade padrao	  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							 	If Len(Alltrim(mv_par04))>0 .And. Alltrim(mv_par04)<>Alltrim(sb1->b1_um)	   
	 								cSegum	:=	Alltrim(mv_par04)
									nQtdSeg	:=	Agrx001(Alltrim(sb1->b1_um),Alltrim(mv_par04),npd->npd_qtdpro)
									cExtSeg	:=	Alltrim(Extenso(Round(nQtdSeg,2)))										
							 		Aadd(aVarName,"cExtSeg")
							 	Endif
							 					        
				   				cDtaExt	:=	Alltrim(Str(Day(npd->npd_datemi)))+Space(01)+'de'+Space(01)+aMeses[Month(npd->npd_datemi)]+Space(01)+'de'+Space(01)+Alltrim(Str(Year(npd->npd_datemi)))
								
								For __k	:=	1 To Len(aVarName)
									For __i	:= 1 To Len(aFilName)
										If At(aFilName[__i],(&(aVarName[__k])))>0
											&(aVarName[__k])	:=	Alltrim(Stuff((&(aVarName[__k])),(At(aFilName[__i],(&(aVarName[__k])))),Len(Alltrim(aFilName[__i])),""))	
									    Endif
								    Next __i
								Next __k        								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Faz a formatacao do extenso a ser impresso na autorizacao³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								cExtens	:=	Alltrim(Transform(nQtdUn,"@e 999,999,999.99"))+Space(01)+Alltrim(cUm)+Space(01)+"("+cExtUm+")"+Space(01)+Lower(Alltrim(Posicione('SAH',1,xFilial('SAH')+cUm,"AH_DESCPO")))+Space(01)+"de"+Space(01)+Lower(Alltrim(sb1->b1_desc))								
								If nQtdSeg>0 
									cExtens	+=	Space(01)+"que"+Space(01)+"corresponde"+Space(01)+"a"+Space(01)+Alltrim(Transform(nQtdSeg,"@e 999,999,999.99"))+Space(01)+Alltrim(cSegum)+Space(01)+"("+cExtSeg+")"+Space(01)+Lower(Alltrim(Posicione('SAH',1,xFilial('SAH')+cSegum,"AH_DESCPO")))
						        Endif
								aAdd( uVetor, {"VAR_CODIGO",Alltrim(npd->npd_numero) ,"NPD->NPD_NUMERO"	,"Codigo Transferencia"    	})
								aAdd( uVetor, {"VAR_DATADC",cDtaExt					 ,""				,"Data por Extenso"         })
								aAdd( uVetor, {"VAR_SAFRA1",npd->npd_safra			 ,"NPD->NPD_SAFRA"	,"Safra"                    })
								aAdd( uVetor, {"VAR_SAFDES",Alltrim(nn1->nn1_descri) ,"NN1->NN1_DESCRI"	,"Descricao da Safra"       })
								aAdd( uVetor, {"VAR_DSARMA",cDsArma					 ,""				,"Descricao do Armazem"     })
								aAdd( uVetor, {"VAR_RGARMA",cRgArma					 ,""				,"Rg do Armazem" 		    })
								aAdd( uVetor, {"VAR_CGARMA",cCgArma					 ,""				,"Cnpj/Cpf do Armazem"      })
								aAdd( uVetor, {"VAR_INARMA",cInArma					 ,""				,"Inscricao do Armazem"     })
								aAdd( uVetor, {"VAR_ENARMA",cEnArma					 ,""				,"Endereco do Armazem"	    })
								aAdd( uVetor, {"VAR_MUARMA",cMuArma					 ,""				,"Municipio do Armazem"     })
								aAdd( uVetor, {"VAR_UFARMA",cUfArma					 ,""				,"Estado do Armazem"	    })
								aAdd( uVetor, {"VAR_DSCLIO",cDsclio					 ,""				,"Descricao Cliente Origem" })
								aAdd( uVetor, {"VAR_RGCLIO",cRgclio					 ,""				,"Rg Cliente Origem" 		})
								aAdd( uVetor, {"VAR_CGCLIO",cCgclio					 ,""				,"Cnpj/Cpf Cliente Origem" 	})
								aAdd( uVetor, {"VAR_INCLIO",cInclio					 ,""				,"Inscricao Cliente Origem"	})
								aAdd( uVetor, {"VAR_ENCLIO",cEnclio					 ,""				,"Endereco Cliente Origem" 	})
								aAdd( uVetor, {"VAR_MUCLIO",cMuclio					 ,""				,"Municipio Cliente Origem"	})
								aAdd( uVetor, {"VAR_UFCLIO",cUfclio					 ,""				,"Estado Cliente Origem"  	})
								aAdd( uVetor, {"VAR_EXTENS",cExtens					 ,""				,"Extenso das Unidades"  	})
								aAdd( uVetor, {"VAR_OBSERV",Alltrim(npd->npd_obs)   ,"NPD->NPD_OBS"		,"Observacao"               })
							Else							
								Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes da safra, favor verifique!',{'Ok'})	  																		
							Endif
						Else
							Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do cliente relacionado ao armazem, favor verifique!',{'Ok'})	  																		
						Endif
					Else
						Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do armazem, favor verifique!',{'Ok'})	  												
						Endif
				Else
					Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do cliente origem, favor verifique!',{'Ok'})	  			
				Endif		
	  		Else
				Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes do produto da Safra, favor verifique!',{'Ok'})	  				  		
	  		Endif
	  	Else
			Aviso('ATENCAO!',Alltrim(cUsername)+', nao existe informacoes da transferencia para o relatorio, favor verifique!',{'Ok'})	  
	  	Endif	
                                                                                                         
Return(uVetor)
