#Include "Protheus.Ch"
#Include "DiaDs.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIEFSC    ³ Autor ³THIAGO GALVAO SILVEIRA ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para DIEFSC                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN -> nFuncao - Funcao a ser chamada pela principal.      ³±±
±±³          ³ExpC -> String - String qualquer utilizada pelas funcoes.   ³±±
±±³          ³ExpN -> nPosFimCfp - Posicao final do arquivo CFP utilizado ³±±
±±³          ³ pela funcao sfRetCfop().                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DIEFSC (nFuncao,nRegistro) 
	Local	xRet	:=	.T.
	Local	cCfpDia		:=	""
	//
	Default	nFuncao		:=	1
    Default	nRegistro   :=	1
	//
	cCfpDia	:=	"DIEFSC"+Alltrim(str(nRegistro))+".CFP"
	//
	If (nFuncao==1)
		xRet	:=	DIEFSCCfp (cCfpDia,nRegistro)		
	ElseIf (nFuncao==2)	
		xRet	:=	LeCfp (AllTrim (cCfpDia))
	EndIf
	//
Return (xRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIEFSCCfp ³ Autor ³Thiago Galvao Silveira ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo CFP com parametros a serem utilizados no      ³±±
±±³          ³DIEFSC.INI                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DIEFSCCfp (cCfpDia,nReg)
	Local 	cValid 		:= ""
	Local 	nI	 		:= 1
	Local 	nOpcA	 	:= 2
	Local 	lRet	 	:= .T.
	Local 	oDlgGet
	Local	cBarra		:=	""
	Local	cTitJan		:=	""
    //
	Private	aSel		:= {}
	Private aListBox	:= {}
	Private	aMsg	  	:= {}
	Private	aValid	  	:= {}
	Private	aConteudo 	:= {}
	//                                                                                                                                                                                                                
    If nReg==1
       aAdd (aListBox, OemToAnsi ("0001 - CPF do Contabilista"))                 ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0001 - CPF do Contabilista"))                 ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")    
       aAdd (aListBox, OemToAnsi ("0002 - CRC de Contabilista"))                 ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0002 - CRC de Contabilista"))                 ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")    
       aAdd (aListBox, OemToAnsi ("0003 - Nome do Contabilista"))                ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0003 - Nome do Contabilista"))                ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")      
       aAdd (aListBox, OemToAnsi ("0004 - Telefone para contato"))               ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0004 - Telefone para contato"))               ; 	aAdd (aValid, "VLDCFPSC ('C', 'FON')")      
       aAdd (aListBox, OemToAnsi ("0005 - Endereço do Contabilista"))            ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0005 - Endereço do Contabilista"))            ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                              
       aAdd (aListBox, OemToAnsi ("0006 - Número referente ao endereço"))        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0006 - Número referente ao endereço"))        ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")                          
       aAdd (aListBox, OemToAnsi ("0007 - Bairro"))                              ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0007 - Bairro"))                              ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                          
       aAdd (aListBox, OemToAnsi ("0008 - Código do Município"))                 ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0008 - Código do Município" ))                ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")                          
       aAdd (aListBox, OemToAnsi ("0009 - Município"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0009 - Município" ))                          ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                          
       aAdd (aListBox, OemToAnsi ("0010 - CEP"))                                 ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0010 - CEP" ))                                ; 	aAdd (aValid, "VLDCFPSC ('C', 'NUM')")
       aAdd (aListBox, OemToAnsi ("0011 - Unidade da Federação"))                ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0011 - Unidade da Federação"))                ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")
    ElseIf nReg==2                  
       aAdd (aListBox, OemToAnsi ("0001 - Tipo do Logradouro"))                  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0001 - Tipo do Logradouro"))                  ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")    
       aAdd (aListBox, OemToAnsi ("0002 - Logradouro"))                          ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0002 - Logradouro"))                          ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")    
       aAdd (aListBox, OemToAnsi ("0003 - Número referente ao Logradouro"))      ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0003 - Número referente ao Logradouro"))      ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")                          
       aAdd (aListBox, OemToAnsi ("0004 - Complemento"))                         ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0004 - Complemento"))                         ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")      
       aAdd (aListBox, OemToAnsi ("0005 - Código do Município"))                 ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0005 - Código do Município" ))                ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")                          
       aAdd (aListBox, OemToAnsi ("0006 - Espécie"))                             ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0006 - Espécie"))                             ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                          
       aAdd (aListBox, OemToAnsi ("0007 - CPF do Responsável"))                  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0007 - CPF do Responsável"))                  ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")    
       aAdd (aListBox, OemToAnsi ("0008 - Nome do Responsável"))                 ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0008 - Nome do Responsável"))                 ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")      
       aAdd (aListBox, OemToAnsi ("0009 - Endereço do Responsável"))             ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0009 - Endereço do Responsável"))             ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                              
       aAdd (aListBox, OemToAnsi ("0010 - Número referente ao endereço"))        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0010 - Número referente ao endereço"))        ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")                          
       aAdd (aListBox, OemToAnsi ("0011 - Bairro"))                              ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0011 - Bairro"))                              ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                          
       aAdd (aListBox, OemToAnsi ("0012 - Telefone do Responsável"))             ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0012 - Telefone do Responsável"))             ; 	aAdd (aValid, "VLDCFPSC ('C', 'FON')")      
    ElseIf nReg==3                  
       aAdd (aListBox, OemToAnsi ("0001 - DIEF Substitutiva"))                   ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0001 - DIEF Substitutiva"))                   ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")    
       aAdd (aListBox, OemToAnsi ("0002 - Escrita Contábil"))                    ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0002 - Escrita Contábil"))                    ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")    
       aAdd (aListBox, OemToAnsi ("0003 - Livros Fiscais"))                      ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0003 - Livros Fiscais"))                      ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                          
       aAdd (aListBox, OemToAnsi ("0004 - Notas Fiscais"))                       ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0004 - Notas Fiscais"))                       ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")      
       aAdd (aListBox, OemToAnsi ("0005 - IBM PC XT/AT"))                        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0005 - IBM PC XT/AT" ))                       ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                          
       aAdd (aListBox, OemToAnsi ("0006 - Número de Empregados"))                ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0006 - Número de Empregados"))                ; 	aAdd (aValid, "VLDCFPSC ('N', 'NUM')")                          
       aAdd (aListBox, OemToAnsi ("0007 - Data de Entrega"))                     ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0007 - Data de Entrega"))                     ; 	aAdd (aValid, "VLDCFPSC ('D', 'DAT')")    
       aAdd (aListBox, OemToAnsi ("0008 - Quadro T"))                            ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0008 - Quadro T"))                            ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")      
       aAdd (aListBox, OemToAnsi ("0009 - Requerimento"))                        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0009 - Requerimento"))                        ; 	aAdd (aValid, "VLDCFPSC ('C', 'STR')")                              
       aAdd (aListBox, OemToAnsi ("0010 - Receita Bruta de Vendas e Serviços"))  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0010 - Receita Bruta de Vendas e Serviços"))  ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                              
       aAdd (aListBox, OemToAnsi ("0011 - Entrada Bens/Mercadorias e Serviços (Valor em UFIRs)"))                        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0011 - Entrada Bens/Mercadorias e Serviços (Valor em UFIRs)"))                        ; 	aAdd (aValid, "VLDCFPSC ('N', 'VAL')")                              
       aAdd (aListBox, OemToAnsi ("0012 - Receita Bruta do Estabelecimento (Valor em UFIRs)"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0012 - Receita Bruta do Estabelecimento (Valor em UFIRs)"))                           ; 	aAdd (aValid, "VLDCFPSC ('N', 'VAL')")                              
       aAdd (aListBox, OemToAnsi ("0013 - Receita de Vendas de Bens do Ativo Imobilizado (Valor em UFIRs)"))             ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0013 - Receita de Vendas de Bens do Ativo Imobilizado (Valor em UFIRs)"))             ; 	aAdd (aValid, "VLDCFPSC ('N', 'VAL')")                              
       aAdd (aListBox, OemToAnsi ("0014 - Receita Bruta de Outros Estabelecimento da mesma Empresa  (Valor em UFIRs)"))  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0014 - Receita Bruta de Outros Estabelecimento da mesma Empresa  (Valor em UFIRs)"))  ; 	aAdd (aValid, "VLDCFPSC ('N', 'VAL')")                                     
    ElseIf nReg==4                  
       aAdd (aListBox, OemToAnsi ("0001 - ATIVO - Disponibilidades (Valor em R$)"))                        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0001 - ATIVO - Disponibilidades (Valor em R$)"))                        ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0002 - ATIVO - Contas a Receber (Valor em R$)"))                        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0002 - ATIVO - Contas a Receber (Valor em R$)"))                        ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0003 - ATIVO - Estoque de Mercadorias e Matéria-Prima (Valor em R$)"))  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0003 - ATIVO - Estoque de Mercadorias e Matéria-Prima (Valor em R$)"))  ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                          
       aAdd (aListBox, OemToAnsi ("0004 - ATIVO - Outros Estoques (Valor em R$)"))                         ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0004 - ATIVO - Outros Estoques (Valor em R$)"))                         ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")      
       aAdd (aListBox, OemToAnsi ("0005 - ATIVO - Outras Contas do Ativo Circulante (Valor em R$)"))       ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0005 - ATIVO - Outras Contas do Ativo Circulante (Valor em R$)"))       ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                          
       aAdd (aListBox, OemToAnsi ("0006 - ATIVO - Contas a Receber (Valor em R$)"))                        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0006 - ATIVO - Contas a Receber (Valor em R$)"))                        ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                          
       aAdd (aListBox, OemToAnsi ("0007 - ATIVO - Outras Contas do Realizável (Valor em R$)"))             ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0007 - ATIVO - Outras Contas do Realizável (Valor em R$)"))             ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0008 - ATIVO - Investimentos (Valor em R$)"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0008 - ATIVO - Investimentos (Valor em R$)"))                           ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")      
       aAdd (aListBox, OemToAnsi ("0009 - ATIVO - Imobilizado - Liquído (Valor em R$)"))                   ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0009 - ATIVO - Imobilizado - Liquído (Valor em R$)"))                   ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")             
       aAdd (aListBox, OemToAnsi ("0010 - ATIVO - Diferido (Valor em R$)"))                                ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0010 - ATIVO - Diferido (Valor em R$)"))                                ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                              
       aAdd (aListBox, OemToAnsi ("0011 - PASSIVO - Fornecedores (Valor em R$)"))                          ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0011 - PASSIVO - Fornecedores (Valor em R$)"))                          ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                              
       aAdd (aListBox, OemToAnsi ("0012 - PASSIVO - Empréstimos e Financiamentos (Valor em R$)"))          ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0012 - PASSIVO - Empréstimos e Financiamentos (Valor em R$)"))          ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                              
       aAdd (aListBox, OemToAnsi ("0013 - PASSIVO - Outras Contas do Passivo Circulante (Valor em R$)"))   ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0013 - PASSIVO - Outras Contas do Passivo Circulante (Valor em R$)"))   ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                              
       aAdd (aListBox, OemToAnsi ("0014 - PASSIVO - Exigível a Longo Prazo (Valor em R$)"))                ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0014 - PASSIVO - Exigível a Longo Prazo (Valor em R$)"))                ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                              
       aAdd (aListBox, OemToAnsi ("0015 - PASSIVO - Resultados de Exercícios Futuros (Valor em R$)"))      ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0015 - PASSIVO - Resultados de Exercícios Futuros (Valor em R$)"))      ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                                     
       aAdd (aListBox, OemToAnsi ("0016 - PASSIVO - Capital Social (Valor em R$)"))                        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0016 - PASSIVO - Capital Social (Valor em R$)"))                        ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                                     
       aAdd (aListBox, OemToAnsi ("0017 - PASSIVO - Outras Contas do Patrimônio Líquido (Valor em R$)"))   ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0017 - PASSIVO - Outras Contas do Patrimônio Líquido (Valor em R$)"))   ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")                                     
    ElseIf nReg==5                  
       aAdd (aListBox, OemToAnsi ("0001 - Devoluções / Abatimentos e Impostos"))  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0001 - Devoluções / Abatimentos e Impostos")) ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0002 - Custo da Mercadoria Vendida"))          ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0002 - Custo da Mercadoria Vendida"))         ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0003 - Despesas Operacionais"))                ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0003 - Despesas Operacionais"))               ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0004 - Receitas Não Operacionais"))            ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0004 - Receitas Não Operacionais"))           ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0005 - Despesas Não Operacionais"))            ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0005 - Despesas Não Operacionais"))            ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0006 - Saldo da Conta Correção Monetária"))    ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0006 - Saldo da Conta Correção Monetária"))   ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0007 - Provisão para o Imposto de Renda"))     ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0007 - Provisão para o Imposto de Renda"))    ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0008 - Participações e Contribuiçoes"))        ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0008 - Participações e Contribuiçoes"))       ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0009 - PRÓ-LABORE"))                           ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0009 - PRÓ-LABORE"))                          ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0010 - Comissões, Salários, Ordenados"))       ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0010 - Comissões, Salários, Ordenados"))      ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0011 - Combustíveis e Lubrificantes"))         ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0011 - Combustíveis e Lubrificantes"))        ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0012 - Encargos Sociais"))                     ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0012 - Encargos Sociais"))                    ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0013 - Tributos Federais"))                    ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0013 - Tributos Federais"))                   ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0014 - Tributos Estatuais"))                   ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0014 - Tributos Estatuais"))                  ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0015 - Tributos Municipais"))                  ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0015 - Tributos Municipais"))                 ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0016 - Água e Telefone"))                      ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0016 - Água e Telefone"))                     ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0017 - Energia Elétrica"))                     ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0017 - Energia Elétrica"))                    ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0018 - Aluguéis"))                             ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0018 - Aluguéis"))                            ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0019 - Serviços Profissionais"))               ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0019 - Serviços Profissionais"))              ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0020 - Seguros"))                              ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0020 - Seguros"))                             ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0021 - Fretes e Carretos"))                    ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0021 - Fretes e Carretos"))                   ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0022 - Despesas Financeiras"))                 ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0022 - Despesas Financeiras"))                ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
       aAdd (aListBox, OemToAnsi ("0023 - Outras Despesas"))                      ; aAdd (aSel, .T.); aAdd (aMsg, OemToAnsi("0023 - Outras Despesas"))                     ; 	aAdd (aValid, "VLDCFPSC ('N', 'CEN')")    
    EndIf   
    
	For nI := 1 To (Len (aListBox))
		aListBox [nI]	:=	OemToAnsi (aListBox [nI])
		aMsg [nI]		:=	OemToAnsi (aMsg [nI])
	Next (nI)                
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le informacoes do arquivo de configuracao DIEFSC?.CFP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Load (cCfpDia)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ativa ListBox com opcoes para o array da configuracao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nReg==1
	   cBarra	:=	"Informacoes do Contabilista" //"Informacoes do Contabilista"	
   	ElseIf nReg==2
       cBarra	:=	"Informacoes do Estabelecimento e do Responsável Legal"	// "Informacoes do Estabelecimento e do Responsável Legal"	   	
    ElseIf nReg==3 
       cBarra	:=	"Informacoes Iniciais" // "Informacoes Iniciais"	   	   
    ElseIf nReg==4 
       cBarra	:=	"Informacoes sobre o Balanço - ATIVO e PASSIVO" // "Informacoes sobre o Balanço - ATIVO e PASSIVO"	   	   
    ElseIf nReg==5 
       cBarra	:=	"Demonstração de Resultado e Detalhamento das Despesas" // "Demonstração de Resultado e Detalhamento das Despesas"	   	   
    EndIf
	cTitJan	:=	"DIEF - SC"	//"DIEF - SC"
	//
	Define MSDialog oDlgGet Title OemToAnsi (cBarra) From 180, 110 To 550, 700 Pixel Of oMainWnd
	@ 010, 020 Say OemToAnsi (cTitJan) Size 140, 007 Of oDlgGet Pixel
	@ 026, 018 To 155, 277 LABEL "" OF oDlgGet Pixel
	@ 033, 022 ListBox oListBox Var cVar Fields Header "" On DBLCLICK (List (oListBox,nReg)) Size 250, 115 Pixel
	//	
	oListBox:SetArray (aListBox)
    oListBox:bLine := {||{aListBox[oListBox:nAt]}}
	//
	Define SButton From 165, 220 Type 1 Action (nOpca := 1, oDlgGet:End ()) Enable Of oDlgGet
	Define SButton From 165, 248 Type 2 Action (nOpca := 2, oDlgGet:End ()) Enable Of oDlgGet
	//
	Activate MSDialog oDlgGet Centered
	//
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava itens no arquivo de configuracao DIEFSC?.CFP  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (nOpcA==1)
		GravaIt (cCfpDia)
	Endif
Return(lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Load      ³ Autor ³Thiago Galvao Silveira ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega conteudo do arquivo ini passado como parametro.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Arquivo .CFP a ser criado.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Load (ArqIni)
	Local nI			:=	0
	Local cConteudo	:=	""
	Local lRet		:=	.T.
	//	
	If (File (ArqIni))
		For nI := 1 To (Len (aListBox))
			cConteudo	:=	""
			If (IsDigit (SubStr (aListBox[nI], 2, 4)))
				cConteudo	:=	Ler (ArqIni, Substr (aListBox[nI], 2, 4))
				If (Len (cConteudo)<254)
					cConteudo	:=	cConteudo+Space (254-Len (cConteudo))
				EndIf
			Endif
			aAdd (aConteudo, cConteudo)
		Next
	Else
		For nI := 1 To (Len (aListBox))
			aAdd (aConteudo, Space (254))
		Next
	Endif
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GravaIt   ³ Autor ³Thiago Galvao Silveira ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Grava arquivo INI.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> Arquivo .CFP a ser criado.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaIt (ArqIni)
	Local	cArqBkp	:=	StrTran (ArqIni, ".CFP", ".#CF")
	Local	aGravar	:=	{}
	Local	nI		:=	0
	Local	lRet	:=	.T.
	//  
	If File(cArqBkp)
		Ferase(cArqBkp)
	Endif
	FRename(ArqIni,cArqBkp)
	nHandle	:=	MSFCREATE(ArqIni)
	//
	For nI := 1 To (Len (aListBox))
		If (IsDigit (Substr (aListBox[nI], 2, 4)))
			aAdd (aGravar, "["+Substr (aListBox[nI], 2, 4)+"]="+Rtrim (aConteudo[nI])+Chr(13)+Chr(10))
		EndIf
	Next
	For nI := 1 To (Len (aGravar))
		FWrite (nHandle, aGravar[nI], Len(aGravar[nI]))
	Next
	FClose(nHandle)
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³List      ³ Autor ³Thiago Galvao Silveira ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Atualiza parametro clicando.                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO -> oListBox = Objeto listbox.                          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function List (oListBox,nReg)
	Local oDlgGet2
	Local nOpcaGet	:=	2
	Local lUpdated	:=	.F.
	Local bValid
	Local lRet		:=	.T.  
    Local oOpcoes
	Local cOpcao    := ""
	Local aOpcao    := {}
	Local lCombo    := .F.
   
	Private cCampo	:=	"cCpoItem"
	//
	nAt	:=	oListBox:nAt
	//
	Private cValid	:=	"{||"+aValid[nAt]+"}"
	//   
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define opcoes do ComboBox                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nReg==1                               
	   If Substr(aListBox[nAt],1,4) == "0011"
	      DbSelectArea("SX5") 
          DbSeek(xFilial("SX5")+"12AC")
	      While !Eof() .AND. (ALLTRIM(X5_TABELA)=="12")
	      		aAdd(aOpcao,ALLTRIM(X5_CHAVE) + " - " +ALLTRIM(X5_DESCRI))
	            DbSkip()
	      EndDo
	      lCombo := .T.
	   EndIf		
	ElseIf nReg==2
	   If Substr(aListBox[nAt],1,4) == "0001"
          aOpcao    := {"Alameda","Avenida","Estrada","Rodovia","Rua"}
          lCombo    := .T.
       ElseIf Substr(aListBox[nAt],1,4) == "0006"
          aOpcao    := {"M - Microempresa","N - Regime de Apuração Normal","P - Empresa de Pequeno Porte"}
	      lCombo    := .T.
       EndIf
    ElseIf nReg==3
	   If Substr(aListBox[nAt],1,4) $ "0001/0002/0003/0004/0005/0008"
          aOpcao    := {"Sim","Não"}
          lCombo    := .T.
       ElseIf Substr(aListBox[nAt],1,4) == "0009"
          aOpcao    := {"0 - Empresa Normal","1 - Manutençao como ME","2 - Exclusão como ME","3 - Manutenção como EPP","4 - Exclusão como EPP"}
	      lCombo    := .T.
	   EndIf   
	EndIf
   
	If (aSel[nAt])
		&cCampo	:=	aConteudo[nAt]
		bValid	:=	&(cValid)
		//
		Define MSDialog oDlgGet2 Title aMsg[nAt] From  300,100 To 400,620 Pixel Of oListBox
		@ 08, 20 To 30, 237 LABEL "" Of oDlgGet2 Pixel
	    If lCombo
		   @ 15, 24 ComboBox &cCampo items aOpcao size 210,08 of oDlgGet2 pixel
		Else
		   @ 15, 24 MSGet &cCampo Picture "@!" Valid Eval (bValid) Size 210, 08 Of oDlgGet2 Pixel
		EndIf   
		//
		Define SButton From 032, 182 Type 1 Action (lUpdated:=.T.,oDlgGet2:End ()) Enable Of oDlgGet2
		Define SButton From 032, 210 Type 2 Action (lUpdated:=.F.,oDlgGet2:End ()) Enable Of oDlgGet2
		//
		Activate MSDialog oDlgGet2 Centered
		//
		If (lUpdated)
			aConteudo[nAt]	:=	StrTran (&cCampo,'"',"'")
		Endif
	Endif
Return (lRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³BuscaCC   ³ Autor ³Gustavo G. Rueda       ³ Data ³18.05.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca valor da contabilidade caso a entrada no CFP seja     ³±±
±±³          ³ iniciada por # e em seguida a conta contabil. Ex: #010101  ³±±
±±³          ³ Esta informacao eh digitada no quadro de Valores do Ativo/ ³±±
±±³          ³ Passivo(Quadro 4).                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nRet, Valor na forma de numerico                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cCampo -> Campo digitado no CFP                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function BuscaCC (cCampoX)
	Local	cCampo	:=	AllTrim (cCampoX)
	Local	nRet	:=	0
	Local	lMVDIEFSCC	:=	GetNewPar ("MV_DIEFSCCC", .T.)
	//
	If ("#"$SubStr (cCampo, 1, 1))
		cCampo	:=	SubStr (cCampo, 2)
		//
		nRet	:=	Int (DIEFSC_CC (cCampo, MV_PAR01, MV_PAR02, lMVDIEFSCC))
	Else
		nRet	:=	Int (Val (cCampo))
    EndIf
Return (nRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DIEFSC_CC ³ Autor ³Gustavo G. Rueda       ³ Data ³18.05.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca valor da contabilidade caso a para o saldo ou movi-   ³±±
±±³          ³ mento de uma determinada conta contabil, independente se   ³±±
±±³          ³ for SIGACTB ou SIGACON                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³nRet, Valor na forma de numerico (com sinal)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cConta -> Conta contabil                                    ³±±
±±³          ³dDtIni -> Data Inicial para o periodo                       ³±±
±±³          ³dDtFim -> Data final para o periodo                         ³±±
±±³          ³lSldAnt -> Considera(T) ou Nao(F) o saldo anterior          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DIEFSC_CC (cConta, dDtIni, dDtFim, lSldAnt)
	Local	nRet		:=	0
	Local	aSaldoAtu	:=	{}
	Local	cMoeda		:=	"01"
	Local	cTpSaldo	:=	"1"
	Local	nSldAnt		:=	0
	Local	nValSld		:=	0
	Local	nI			:=	0
	Local	nPer		:=	0
	Local	dData		:=	CtoD ("//")
	//
	Default	lSldAnt	:=	.F.
	//
	If (CtbInUse ())
		If (lSldAnt)
			aSaldoAtu	:=	SaldoCT7 (cConta, dDtFim, cMoeda, cTpSaldo, 'CTBXFUN')
			nRet	:=	aSaldoAtu[1]
		Else			
			nRet	:=	MovConta (cConta, MV_PAR01, MV_PAR02, cMoeda, cTpSaldo, 3)
		EndIf			
	Else
		DbSelectArea ("SI1")
			SI1->(DbSetOrder (1))
		SI1->(DbSeek (xFilial ("SI1")+cConta))
		//
		nSldAnt	:=	CalcSaldo (12, Val (cMoeda), .F.)	//Valor do Saldo Anterior		
		//
		nPer	:=	Month (dDtFim)
		For nI := 1 To nPer	//Valor do movimento SEM o Saldo Anterior
			dData	:=	LastDay (CtoD ("01/"+StrZero(nI, 2)+"/"+StrZero (Year (dDtFim),4), "ddmmyy"))
			//
			nValSld	+=	Movimento (cConta, nI, 1, dData)
		Next (nI)
		//
		If (lSldAnt)
			nRet	:=	nValSld+nSldAnt
		Else
			nRet	:=	nValSld
		EndIf
	EndIf
Return (nRet)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ler       ³ Autor ³Thiago Galvao Silveira ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Le o CFP.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T.)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpL -> lEnd                                                ³±±
±±³          ³ExpC -> cCpo                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ler (cArqIni, cCPO, lEnd)
	Local cIni		:=	""
	Local cConteudo	:=	""
	Local nI		:=	0
	//
	lEnd := If (lEnd==NIL, .F., lEnd)
	cCPO := "["+cCPO+"]="
	//
	If !File (cArqIni)
		Help (" ",1,"DIEFSC?.CFP")
		lContinua	:=	.F.
		lEnd		:=	.T.
		Return (cIni)
	Else
		cConteudo	:=	MemoRead (cArqIni)
		nLinhas		:=	MlCount (cConteudo, 254)
		//
		For nI := 1 To nLinhas
			cLinha	:=	AllTrim (MemoLine (cConteudo, 254, nI))
			If (cCPO$cLinha)
				cIni := SubStr (cLinha, 8)
				Exit
			Endif
		Next
	Endif
Return(cIni)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³VLDCFPSC  ³ Autor ³Thiago Galvao Silveira ³ Data ³27.01.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Valida string do CFP.                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> lRet (.T./.F.)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> cTipo - Tipo do campo.                              ³±±
±±³          ³ExpC -> cCampo - Campo a ser tratado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function VldCfpSC (cTipo, cCampo)
	Local	lRet		:=	.T.
	Local	cConteudo	:=	&(ReadVar())
	Local	nI			:=	0
	//
	Default	cTipo	:=	""
	Default	cCampo	:=	""
	//
	cConteudo	:=	Alltrim (cConteudo)
	//
	If (cTipo=="N")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia valores numericos                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !(Isdigit (SubStr (cConteudo, nI, 1))) .And. !"#"$cConteudo  
			lRet	:=	.F.
			If SubStr (cConteudo, nI, 1) == "-"
			   lRet := .T.
			EndIf
		Endif
	ElseIf cTipo=="D"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Avalia datas.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
		If (CToD (cConteudo)==CToD (Space (8)))
		   lRet	:=	.F.
		Endif
	EndIf
	//
	If (cCampo=="VAL")
		If (Len (AllTrim (cConteudo))>16) .OR. !("."$((cConteudo)))
		   Help (" ", 1, "VALOR INVALIDO",,"Inserir Valor no formato 9999999999999.99", 3, 0)	//"Inserir Valor no formato 9999999999999.99"
		   lRet	:=	.F.
		EndIf
	ElseIf (cCampo=="NUM")
		If !IsDigit(cConteudo)
		   Help (" ", 1, "VALOR INVALIDO",,"Inserir Valor numérico", 3, 0)	//"Inserir Valor numérico"
		   lRet	:=	.F.
		EndIf
	ElseIf (cCampo=="FON")
  	    If (Len (AllTrim (cConteudo))<9)
		   Help (" ", 1, "FORMATO INVALIDO",,"Inserir Telefone no Formato 99-9999-9999; 99-9999-9999", 3, 0)	//"Inserir Telefone no Formato 99-9999-9999; 99-9999-9999"
		   lRet	:=	.F.
		EndIf
	ElseIf (cCampo=="DAT") 	
	  	If (Len (AllTrim (cConteudo))<>10)
		   Help (" ", 1, "DATA INVALIDA",,"Inserir Data no Formato DD/MM/AAAA", 3, 0)	//"Inserir Data no Formato DD/MM/AAAA"
		   lRet	:=	.F.
		EndIf   
	ElseIf (cCampo=="CEN") 	
		If (Len (AllTrim (cConteudo))>13) .OR. ("."$((cConteudo))) .OR. (","$((cConteudo)))
		   Help (" ", 1, "VALOR INVALIDO",,"Inserir Valor, sem considerar os centavos, no formato 9999999999999", 3, 0)	//"Inserir Valor, sem considerar os centavos, no formato 9999999999999"
		   lRet	:=	.F.
		EndIf
    EndIf	

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LeCfp     ³ Autor ³Thiago Galvao Silveira ³ Data ³01.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Monta o CFP em um array para ser utilizado no INI.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL -> aRet - array conteudo CFP.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC -> cArquivo - Arquivo CFP.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LeCfp (cArquivo)
	Local	cConteudo	:= MemoRead (cArquivo)
	Local	nLinhas		:= MlCount (cConteudo, 254)
	Local	nI			:= 0
	Local	aRet		:= {}
	//
	For nI := 1 To nLinhas
		cLinha	:=	AllTrim (MemoLine (cConteudo, 254, nI))
		aAdd (aRet, {SubStr (cLinha, 2, 3), SubStr (cLinha, 8)})
	Next
Return (aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValDIEF   ³ Autor ³Thiago Galvao Silveira ³ Data ³10.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena os valores da DIEF                                ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function ValDIEF(nRecBrut,aBalanco,aResDesp,dIni,dFim)

Local aValDIEF  := {}                              
Local cValDIEF  := ""
Local cFisApur  := ""
Local nCont     := 1
Local nCod		:= 1
Local aCod      := {"001","002","003","021","014","005","006","007","012","013","009"}
Local aVal      := {} // Valores da DIEF
local nTot      := 0  // Totalizador     
Local nAtDisp   := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="001"})][2]), 0) // Disponibilidades
Local nAtCnRec  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="002"})][2]), 0) // Contas a receber
Local nAtEstM   := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="003"})][2]), 0) // Estoque de Mercadorias
Local nAtOutEs  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="004"})][2]), 0) // Outros Estoques
Local nAtOutCn  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="005"})][2]), 0) // Outras Contas do Ativo Circulante
Local nAtCnRc   := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="006"})][2]), 0) // Contas a Receber
Local nAtOutRz  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="007"})][2]), 0) // Outras Contas do Realizavel
Local nAtInv    := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="008"})][2]), 0) // Investimentos
Local nAtImobL  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="009"})][2]), 0) // Imobilizado (Liquido)
Local nAtImob   := 0  // Ativo Imobilizado                                              
Local nAtDifer  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="010"})][2]), 0) // Diferido
Local nPsForn   := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="011"})][2]), 0) // Fornecedores
Local nPsEmFin  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="012"})][2]), 0) // Empréstimos e Financiamentos
Local nPsOutCn  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="013"})][2]), 0) // Outras Contas do Passivo Circulante
Local nPsExLP   := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="014"})][2]), 0) // Exigível a Longo Prazo
Local nPsResEF  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="015"})][2]), 0) // Resultado de Exercícios Futuros
Local nPsCapSc  := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="016"})][2]), 0) // Capital Social
Local nPsCnPL   := Iif(Len(aBalanco)>0, BuscaCC (aBalanco[aScan(aBalanco,{|x| x[1]=="017"})][2]), 0) // Outras Contas do Patrimonio Liquido
Local nAtCirc   := 0  // Ativo Circulante
Local nAtRLP    := 0  // Realizavel a Longo Prazo
Local nAtPerm   := 0  // Ativo Permanente
Local nAtTot    := 0  // Total Geral do Ativo
Local nPsCirc   := 0  // Passivo Circulante
Local PsPatLiq  := 0  // Patrimônio Líquido
Local nPsTot    := 0  // Total Geral do Passivo
Local nDevAbat  := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="001"})][2]), 0) // Devolucoes / Abatimentos e Impostos
Local nMercVd   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="002"})][2]), 0) // Custo da Mercadoria Vendida
Local nDespOp   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="003"})][2]), 0) // Despesas Operacionais
Local nRecNOP   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="004"})][2]), 0) // Receitas Não Operacionais
Local nDespNOP  := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="005"})][2]), 0) // Despesas Não Operacionais
Local nSdCnMon  := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="006"})][2]), 0) // Saldo da Conta Correção Monetária
Local nImpRend  := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="007"})][2]), 0) // Provisão para Imposto de Renda
Local nPartCt   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="008"})][2]), 0) // Participacoes e Contribuicoes
Local nRecLiq   := nRecBrut-nDevAbat // Receita Líquida Vendas / Serviços
Local nLcBrut   := nRecLiq-nMercVd   // Lucro Bruto
Local nLucPjOP  := nLcBrut-nDespOp   // Lucro / Prejuizo Operacional
Local nResBIR   := nLucPjOP+nRecNOP-nDespNOP+nSdCnMon // Resultado Antes do IR
Local nResAIR   := nResBIR-nImpRend  // Resultado apos o IR
Local nLucPrej  := nResAIR-nPartCt   // Lucro ou Prejuizo
Local nPrLab    := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="009"})][2]), 0) // Pro-Labore
Local nComis    := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="010"})][2]), 0) // Comissoes salarios e ordenados
Local nCombus   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="011"})][2]), 0) // Combustiveis lubrificantes
Local nEncSoc   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="012"})][2]), 0) // Encargos Sociais
Local nTrbFed   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="013"})][2]), 0) // Tributos Federais
Local nTrbEst   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="014"})][2]), 0) // Tributos Estatuais
Local nTrbMun   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="015"})][2]), 0) // Tributos Municipais
Local nAgTel    := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="016"})][2]), 0) // Agua e Telefone
Local nEnElet   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="017"})][2]), 0) // Energia Eletrica
Local nAlug     := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="018"})][2]), 0) // Alugueis
Local nSvProf   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="019"})][2]), 0) // Servicos Profissionais
Local nSeguro   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="020"})][2]), 0) // Seguros
Local nFrete    := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="021"})][2]), 0) // Fretes e Carretos
Local nDspFin   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="022"})][2]), 0) // Despesas Financeiras
Local nOutDsp   := Iif(Len(aResDesp)>0, Val(aResDesp[aScan(aResDesp,{|x| x[1]=="023"})][2]), 0) // Outras Despesas
Local nTotDsp   := nPrLab+nComis+nCombus+nEncSoc+nTrbFed+nTrbEst+nTrbMun+nAgTel+nEnElet+nALug+nSvProf+nSeguro+nFrete+nDspFin+nOutDsp
Local aEstINI   := {} 
Local nEstINI   := 0  // Estoque Inicial
Local aEstFIM   := {} 
Local nEstFIM   := 0  // Estoque Final
Local nValAdic  := 0  // Valor Adicionado - Campo 149
Local aEntradas := {}
Local aSaidas   := {}
Local aEntExc   := {}
Local aSdExc    := {}
Local cRegApur  := ""
Local nX        := 1 
Local nPos1     := 1
Local nPos2     := 1 
Private cIndSB6 := ""
Private nIndSB6 := 0

AADD(aValDIEF,{"CodDIEF","C",3,0})
AADD(aValDIEF,{"VALOR","C",19,2})               
cValDIEF := CriaTrab(aValDIEF,.T.)           
dbUseArea(.T.,__LocalDriver,cValDIEF,"VAL",.T.,.F.)

cFisApur := FisApur("IC",Year(dDmaFin),Month(dDmaFin),5,0,"*",.F.,{},1,.T.,"APU","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Registro 22 - Codigos e Valores da DIEF            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

IIF(nRecBrut <> 0,aADD(aVal,{"008",StrTran(StrZero(Int(nRecBrut),19,2),".",","),0}),.T.) // Receita Bruta

DbSelectArea("APU")
DbGoTop()
 
//Imposto sobre a circulacao de mercadorias e servicos 

IF DbSeek("001")
    While nCont <= 14
          IF nCont == 6  .OR. nCont == 14 .AND. nTot <> 0
             IIF (nCont==6,aADD(aVal,{strZero(nCont+8,3),StrTran(StrZero(Int(nTot),19,2),".",","),0}),.T.)
             IIF (nCont==14,aADD(aVal,{strZero(nCont+8,3),StrTran(StrZero(Int(nTot),19,2),".",","),0}),.T.)
             nTot = 0
          ElseIf nCont <> 11  
             DbSeek(aCod[nCod])
             IIF(Valor <> 0,aADD(aVal,{strZero(nCont+8,3),StrTran(StrZero(Round(VALOR,0),19,2),".",","),nTot+=Round(VALOR,0)}),.T.)
             nCod +=1
          EndIf
          nCont += 1   
    EndDo
EndIf
                            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Informacoes sobre o balanco                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

// Ativo Permanente 
DbSelectArea("SFA") 
SFA->(DbSetOrder(2))
SFA->(DbSeek(xFilial("SFA")+DTOS(dIni),.t.))
While xFilial("SFA")==SFA->FA_FILIAL .And. DTOS(SFA->FA_DATA) <= DTOS(dFim) .And. !SFA->(Eof())
      nAtImob += FA_VALOR
      SFA->(DbSkip())
EndDo
nAtImob := nAtImob+nAtImobL // Soma o valor do ativo do SFA com o valor informado pelo o usuario
nAtImob := Round(nAtImob,0)

nAtCirc   := nAtDisp+nAtCnRec+nAtEstM+nAtOutEs+nAtOutCn
nAtRLP    := nAtCnRc+nAtOutRz
nAtPerm   := nAtInv+nAtImob+nAtDifer
nAtTot    := nAtCirc+nAtRLP+nAtPerm
nPsCirc   := nPsForn+nPsEmFin+nPsOutCn
PsPatLiq  := nPsCapSc+nPsCnPL
nPsTot    := nPsCirc+nPsExLP+nPsResEF+PsPatLiq

IIF(nAtCirc  <> 0,aADD(aVal,{"023",StrTran(StrZero(nAtCirc,19,2),".",","),0}),.T.)
IIF(nAtDisp  <> 0,aADD(aVal,{"024",StrTran(StrZero(nAtDisp,19,2),".",","),0}),.T.)
IIF(nAtCnRec <> 0,aADD(aVal,{"025",StrTran(StrZero(nAtCnRec,19,2),".",","),0}),.T.)
IIF(nAtEstM  <> 0,aADD(aVal,{"026",StrTran(StrZero(nAtEstM,19,2),".",","),0}),.T.)
IIF(nAtOutEs <> 0,aADD(aVal,{"027",StrTran(StrZero(nAtOutEs,19,2),".",","),0}),.T.)
IIF(nAtOutCn <> 0,aADD(aVal,{"028",StrTran(StrZero(nAtOutCn,19,2),".",","),0}),.T.)
IIF(nAtRLP   <> 0,aADD(aVal,{"029",StrTran(StrZero(nAtRLP,19,2),".",","),0}),.T.)
IIF(nAtCnRc  <> 0,aADD(aVal,{"030",StrTran(StrZero(nAtCnRc,19,2),".",","),0}),.T.)
IIF(nAtOutRz <> 0,aADD(aVal,{"031",StrTran(StrZero(nAtOutRz,19,2),".",","),0}),.T.)
IIF(nAtPerm  <> 0,aADD(aVal,{"032",StrTran(StrZero(nAtPerm,19,2),".",","),0}),.T.)
IIF(nAtInv   <> 0,aADD(aVal,{"033",StrTran(StrZero(nAtInv,19,2),".",","),0}),.T.)
IIF(nAtImob  <> 0,aADD(aVal,{"034",StrTran(StrZero(nAtImob,19,2),".",","),0}),.T.)
IIF(nAtDifer <> 0,aADD(aVal,{"035",StrTran(StrZero(nAtDifer,19,2),".",","),0}),.T.)
IIF(nAtTot   <> 0,aADD(aVal,{"036",StrTran(StrZero(nAtTot,19,2),".",","),0}),.T.)
IIF(nPsCirc  <> 0,aADD(aVal,{"037",StrTran(StrZero(nPsCirc,19,2),".",","),0}),.T.)
IIF(nPsForn  <> 0,aADD(aVal,{"038",StrTran(StrZero(nPsForn,19,2),".",","),0}),.T.)
IIF(nPsEmFin <> 0,aADD(aVal,{"039",StrTran(StrZero(nPsEmFin,19,2),".",","),0}),.T.)
IIF(nPsOutCn <> 0,aADD(aVal,{"040",StrTran(StrZero(nPsOutCn,19,2),".",","),0}),.T.)
IIF(nPsExLP  <> 0,aADD(aVal,{"041",StrTran(StrZero(nPsExLP,19,2),".",","),0}),.T.)
IIF(nPsResEF <> 0,aADD(aVal,{"042",StrTran(StrZero(nPsResEF,19,2),".",","),0}),.T.)
IIF(PsPatLiq <> 0,aADD(aVal,{"043",StrTran(StrZero(PsPatLiq,19,2),".",","),0}),.T.)
IIF(nPsCapSc <> 0,aADD(aVal,{"044",StrTran(StrZero(nPsCapSc,19,2),".",","),0}),.T.)
IIF(nPsCnPL  <> 0,aADD(aVal,{"045",StrTran(StrZero(nPsCnPL,19,2),".",","),0}),.T.)
IIF(nPsTot   <> 0,aADD(aVal,{"046",StrTran(StrZero(nPsTot,19,2),".",","),0}),.T.)
IIF(nRecBrut <> 0,aADD(aVal,{"047",StrTran(StrZero(nRecBrut,19,2),".",","),0}),.T.)
IIF(nDevAbat <> 0,aADD(aVal,{"048",StrTran(StrZero(nDevAbat,19,2),".",","),0}),.T.)
IIF(nRecLiq  <> 0,aADD(aVal,{"049",StrTran(StrZero(nRecLiq,19,2),".",","),0}),.T.)
IIF(nMercVd  <> 0,aADD(aVal,{"050",StrTran(StrZero(nMercVd,19,2),".",","),0}),.T.)
IIF(nLcBrut  <> 0,aADD(aVal,{"051",StrTran(StrZero(nLcBrut,19,2),".",","),0}),.T.)
IIF(nDespOp  <> 0,aADD(aVal,{"052",StrTran(StrZero(nDespOp,19,2),".",","),0}),.T.)
IIF(nLucPjOP <> 0,aADD(aVal,{"053",StrTran(StrZero(nLucPjOP,19,2),".",","),0}),.T.)
IIF(nRecNOP  <> 0,aADD(aVal,{"054",StrTran(StrZero(nRecNOP,19,2),".",","),0}),.T.)
IIF(nDespNOP <> 0,aADD(aVal,{"055",StrTran(StrZero(nDespNOP,19,2),".",","),0}),.T.)
IIF(nSdCnMon <> 0,aADD(aVal,{"056",StrTran(StrZero(nSdCnMon,19,2),".",","),0}),.T.)
IIF(nResBIR  <> 0,aADD(aVal,{"057",StrTran(StrZero(nResBIR,19,2),".",","),0}),.T.)
IIF(nImpRend <> 0,aADD(aVal,{"058",StrTran(StrZero(nImpRend,19,2),".",","),0}),.T.)
IIF(nResAIR  <> 0,aADD(aVal,{"059",StrTran(StrZero(nResAIR,19,2),".",","),0}),.T.)
IIF(nPartCt  <> 0,aADD(aVal,{"060",StrTran(StrZero(nPartCt,19,2),".",","),0}),.T.)
IIF(nLucPrej <> 0,aADD(aVal,{"061",StrTran(StrZero(nLucPrej,19,2),".",","),0}),.T.)
IIF(nPrLab   <> 0,aADD(aVal,{"062",StrTran(StrZero(nPrLab,19,2),".",","),0}),.T.)
IIF(nComis   <> 0,aADD(aVal,{"063",StrTran(StrZero(nComis,19,2),".",","),0}),.T.)
IIF(nCombus  <> 0,aADD(aVal,{"064",StrTran(StrZero(nCombus,19,2),".",","),0}),.T.)
IIF(nEncSoc  <> 0,aADD(aVal,{"065",StrTran(StrZero(nEncSoc,19,2),".",","),0}),.T.)
IIF(nTrbFed  <> 0,aADD(aVal,{"066",StrTran(StrZero(nTrbFed,19,2),".",","),0}),.T.)
IIF(nTrbEst  <> 0,aADD(aVal,{"067",StrTran(StrZero(nTrbEst,19,2),".",","),0}),.T.)
IIF(nTrbMun  <> 0,aADD(aVal,{"068",StrTran(StrZero(nTrbMun,19,2),".",","),0}),.T.)
IIF(nAgTel   <> 0,aADD(aVal,{"069",StrTran(StrZero(nAgTel,19,2),".",","),0}),.T.)
IIF(nEnElet  <> 0,aADD(aVal,{"070",StrTran(StrZero(nEnElet,19,2),".",","),0}),.T.)
IIF(nAlug    <> 0,aADD(aVal,{"071",StrTran(StrZero(nAlug,19,2),".",","),0}),.T.)
IIF(nSvProf  <> 0,aADD(aVal,{"072",StrTran(StrZero(nSvProf,19,2),".",","),0}),.T.)
IIF(nSeguro  <> 0,aADD(aVal,{"073",StrTran(StrZero(nSeguro,19,2),".",","),0}),.T.)
IIF(nFrete   <> 0,aADD(aVal,{"074",StrTran(StrZero(nFrete,19,2),".",","),0}),.T.)
IIF(nDspFin  <> 0,aADD(aVal,{"075",StrTran(StrZero(nDspFin,19,2),".",","),0}),.T.)
IIF(nOutDsp  <> 0,aADD(aVal,{"076",StrTran(StrZero(nOutDsp,19,2),".",","),0}),.T.)
IIF(nTotDsp  <> 0,aADD(aVal,{"077",StrTran(StrZero(nTotDsp,19,2),".",","),0}),.T.)

// Resumo do Livro Registro de Inventario
DbSelectArea("SB1") 
DbGoTop()

While !Eof()
      aEstINI:= FsPrdInv(B1_COD,.F.,StoD(AllTrim(Str(Year(dDmaFin)-1))+"1231"))
      nEstINI+= Round(aEstINI[1][2],0)
      aEstFIM:= FsPrdInv(B1_COD,.F.,StoD(AllTrim(Str(Year(dDmaFin)))+"1231"))
      nEstFIM+= Round(aEstFIM[1][2],0)
      DbSkip()
EndDo

IIF(Int(nEstINI) <> 0,aADD(aVal,{"078",StrTran(StrZero(Int(nEstINI),19,2),".",","),0}),.T.)
IIF(Int(nEstFIM) <> 0,aADD(aVal,{"079",StrTran(StrZero(Int(nEstFIM),19,2),".",","),0}),.T.)

// Resumo do Livro Registro de Apuracao do ICMS
// Exclusoes das Entradas e das Saidas

cRegApur := ResumeF3("IC",ddmainc,ddmafin,"*",.F.,.T.,1,.F.,2,Nil,Nil,{},{},"",.T.,"RF3",.F.,.F.,.F.)

DbSelectArea("RF3") 
DbGoTop()

aEntradas := {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
aSaidas   := {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
aEntExc   := {{0,0,0,0,0,0}}
aSdExc    := {{0,0,0,0,0,0}}

While !Eof()
    If Substr(CFOP,1,1)=="1" 
       aEntradas[1][1]+= Round(VALCONT,0)
       aEntradas[1][2]+= Round(BASEICM,0)
       aEntradas[1][3]+= Round(ISENICM,0)
       aEntradas[1][4]+= Round(OUTRICM,0)
    EndIf
    If Substr(CFOP,1,1)=="2" 
       aEntradas[2][1]+= Round(VALCONT,0)
       aEntradas[2][2]+= Round(BASEICM,0)
       aEntradas[2][3]+= Round(ISENICM,0)
       aEntradas[2][4]+= Round(OUTRICM,0)
    EndIf
    If Substr(CFOP,1,1)=="3" 
       aEntradas[3][1]+= Round(VALCONT,0)
       aEntradas[3][2]+= Round(BASEICM,0)
       aEntradas[3][3]+= Round(ISENICM,0)
       aEntradas[3][4]+= Round(OUTRICM,0)
    EndIf
    If Substr(CFOP,1,1)=="5"    
       aSaidas[1][1]+= Round(VALCONT,0)
       aSaidas[1][2]+= Round(BASEICM,0)
       aSaidas[1][3]+= Round(ISENICM,0)
       aSaidas[1][4]+= Round(OUTRICM,0)
    EndIf
    If Substr(CFOP,1,1)=="6"    
       aSaidas[2][1]+= Round(VALCONT,0)
       aSaidas[2][2]+= Round(BASEICM,0)
       aSaidas[2][3]+= Round(ISENICM,0)
       aSaidas[2][4]+= Round(OUTRICM,0)
    EndIf
    If Substr(CFOP,1,1)=="7"    
       aSaidas[3][1]+= Round(VALCONT,0)
       aSaidas[3][2]+= Round(BASEICM,0)
       aSaidas[3][3]+= Round(ISENICM,0)
       aSaidas[3][4]+= Round(OUTRICM,0)
    EndIf
    If Substr(CFOP,1,1) <= "3" 
       aEntradas[4][1]+= Round(VALCONT,0)
       aEntradas[4][2]+= Round(BASEICM,0)
       aEntradas[4][3]+= Round(ISENICM,0)
       aEntradas[4][4]+= Round(OUTRICM,0)
    EndIf    
    If Substr(CFOP,1,1) >= "5"     
       aSaidas[4][1]+= Round(VALCONT,0)
       aSaidas[4][2]+= Round(BASEICM,0)
       aSaidas[4][3]+= Round(ISENICM,0)
       aSaidas[4][4]+= Round(OUTRICM,0)
    EndIf                      
    If Substr(CFOP,1,1) <= "3" 
       If Substr(CFOP,2,3) $ "406/407/551/552/553/554/555/556/557/601/602/603/604/908/909" //114
          aEntExc[1][1]+= Round(VALCONT,0)
          aEntExc[1][5]+= Round(VALCONT,0)
       ElseIf  Substr(CFOP,2,3) $ "901/902/903/915/916/924/925" //119   
          aEntExc[1][2]+= Round(VALCONT,0)
          aEntExc[1][5]+= Round(VALCONT,0)
       ElseIf  Substr(CFOP,2,3) $ "414/415/601/602/603/604/904/912/913/914/917/918/919/920/921/922/923/926/930/949" //120
          aEntExc[1][3]+= Round(VALCONT,0)
          aEntExc[1][5]+= Round(VALCONT,0)
       ElseIf  Substr(CFOP,2,3) $ "663/664/905/906/907" //121
          aEntExc[1][4]+= Round(VALCONT,0)    
          aEntExc[1][5]+= Round(VALCONT,0)
       EndIf
    EndIf                      
    If Substr(CFOP,1,1) >= "5" 
       If Substr(CFOP,2,3) $ "412/413/551/552/553/554/555/556/557/908/909" //130
          aSdExc[1][1]+= Round(VALCONT,0)
          aSdExc[1][5]+= Round(VALCONT,0)
       ElseIf  Substr(CFOP,2,3) $ "901/902/903/915/916/924/925" //135   
          aSdExc[1][2]+= Round(VALCONT,0)
          aSdExc[1][5]+= Round(VALCONT,0)
       ElseIf  Substr(CFOP,2,3) $ "358/414/415/602/603/657/912/913/914/917/918/919/920/921/922/923/926/929/930/949" //136
          aSdExc[1][3]+= Round(VALCONT,0)       
          aSdExc[1][5]+= Round(VALCONT,0)
       ElseIf  Substr(CFOP,2,3) $ "663/664/665/666/905/906/907" //137
          aSdExc[1][4]+= Round(VALCONT,0)    
          aSdExc[1][5]+= Round(VALCONT,0)
       EndIf
    EndIf
    dBSkip()
EndDo

nCont := 81

While nCont <= 112
      If nCont <=96
         IIF(Int(aEntradas[nPos1][nPos2])<>0,aADD(aVal,{strZero(nCont,3),StrTran(StrZero(Int(aEntradas[nPos1][nPos2]),19,2),".",","),0}),.T.)
         IF nPos1<4 
            nPos1+=1
         Else
            nPos1:=1
            nPos2+=1
         EndIf   
      EndIF
      IIF (nCont==97,nPos1:=1,.T.)
      IIF (nCont==97,nPos2:=1,.T.)      
      If nCont>= 97 .AND. nCont <=112
         IIF(Int(aSaidas[nPos1][nPos2])<>0,aADD(aVal,{strZero(nCont,3),StrTran(StrZero(Int(aSaidas[nPos1][nPos2]),19,2),".",","),0}),.T.)
         IF nPos1<4 
            nPos1+=1
         Else
            nPos1:=1
            nPos2+=1
         EndIf   
      EndIF      
      nCont+= 1
EndDo

// Exclusoes das Entradas
IIF(Int(aEntExc[1][1]) <> 0,aADD(aVal,{"114",StrTran(StrZero(Int(aEntExc[1][1]),19,2),".",","),0}),.T.)
IIF(Int(aEntExc[1][2]) <> 0,aADD(aVal,{"119",StrTran(StrZero(Int(aEntExc[1][2]),19,2),".",","),0}),.T.)
IIF(Int(aEntExc[1][3]) <> 0,aADD(aVal,{"120",StrTran(StrZero(Int(aEntExc[1][3]),19,2),".",","),0}),.T.)
IIF(Int(aEntExc[1][4]) <> 0,aADD(aVal,{"121",StrTran(StrZero(Int(aEntExc[1][4]),19,2),".",","),0}),.T.)
IIF(Int(aEntExc[1][5]) <> 0,aADD(aVal,{"128",StrTran(StrZero(Int(aEntExc[1][5]),19,2),".",","),0}),.T.)

// Exclusoes das Saidas
IIF(Int(aSdExc[1][1]) <> 0,aADD(aVal,{"130",StrTran(StrZero(Int(aSdExc[1][1]),19,2),".",","),0}),.T.)
IIF(Int(aSdExc[1][2]) <> 0,aADD(aVal,{"135",StrTran(StrZero(Int(aSdExc[1][2]),19,2),".",","),0}),.T.)
IIF(Int(aSdExc[1][3]) <> 0,aADD(aVal,{"136",StrTran(StrZero(Int(aSdExc[1][3]),19,2),".",","),0}),.T.)
IIF(Int(aSdExc[1][4]) <> 0,aADD(aVal,{"137",StrTran(StrZero(Int(aSdExc[1][4]),19,2),".",","),0}),.T.)
IIF(Int(aSdExc[1][5]) <> 0,aADD(aVal,{"144",StrTran(StrZero(Int(aSdExc[1][5]),19,2),".",","),0}),.T.)
                       
// Valor Adicionados
IIF(Int(aSaidas[4][1])   <> 0,aADD(aVal,{"145",StrTran(StrZero(Int(aSaidas[4][1]),19,2),".",","),0}),.T.)
IIF(Int(aSdExc[1][5])    <> 0,aADD(aVal,{"146",StrTran(StrZero(Int(aSdExc[1][5]),19,2),".",","),0}),.T.)
IIF(Int(aEntradas[4][1]) <> 0,aADD(aVal,{"147",StrTran(StrZero(Int(aEntradas[4][1]),19,2),".",","),0}),.T.)
IIF(Int(aEntExc[1][5])   <> 0,aADD(aVal,{"148",StrTran(StrZero(Int(aEntExc[1][5]),19,2),".",","),0}),.T.)
nValAdic:= Int(aSaidas[4][1])-Int(aSdExc[1][5])-Int(aEntradas[4][1])+Int(aEntExc[1][5])
IIF(Int(nValAdic)        <> 0,aADD(aVal,{"149",StrTran(StrZero(Int(nValAdic),19,2),".",","),0}),.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Armazena os valores da DIEF                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

For nX := 1 to len(aVal)
	RecLock("VAL",.T.)
    CodDIEF := aVal[nX][1]
    VALOR   := aVal[nX][2]
	MsUnLock()
Next nX

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValMun    ³ Autor ³Thiago Galvao Silveira ³ Data ³26.04.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o codigo do Estado especificado                    ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/                       
Function ValMun(dIni,dFim)
Local aValMun := {}
Local cValMun := ""
Local aMunEnt := {}
Local nTotEnt := 0
Local aMunSai := {}
Local nTotSai := 0
Local cEntSai := "" 
Local nMun    := 0
Local nMx     := 1
Local aArea	  := {}

AADD(aValMun,{"ENTSAI","C",1,0})
AADD(aValMun,{"CODMUN","C",5,0})
AADD(aValMun,{"VALOR","C",19,2})               
cValMun := CriaTrab(aValMun,.T.)           
dbUseArea(.T.,__LocalDriver,cValMun,"MUN",.T.,.F.)

DbSelectArea("SF3")
DbGoTop()
While !Eof() .And. DTOS(F3_ENTRADA) >= DTOS(dIni) .AND. DTOS(F3_ENTRADA) <= DTOS(dFim)
      aArea	  := GetArea()
      If AllTRim(SF3->F3_ESPECIE) == "NFP" .AND. SubStr(F3_CFO,1,1) == "1"
         cEntSai := "E"      
         dbSelectArea("SA2")
         dbSetorder(1)
         If DbSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA) .AND. !Empty(SA2->A2_COD_MUN)
            nMun:=Ascan(aMunEnt,{|x|x[2]==SA2->A2_COD_MUN}) 
            If nMun==0
               AADD(aMunEnt,{cEntSai,SA2->A2_COD_MUN, SF3->F3_VALCONT})
            Else
               aMunEnt[nMun,3]+= SF3->F3_VALCONT
            EndIf
            nTotEnt += SF3->F3_VALCONT
         EndIf
      ElseIf SubStr(F3_CFO,1,3) $ "535/525/530"
         cEntSai := "S"
         DbSelectArea("SA1")
         DbSetOrder(1)
         If dbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA) .AND. !Empty(SA1->A1_COD_MUN)
            nMun:=Ascan(aMunSai,{|x|x[2]==SA1->A1_COD_MUN})
            If nMun==0                           
               AADD(aMunSai,{cEntSai,SA1->A1_COD_MUN,SF3->F3_VALCONT})      
            Else
               aMunSai[nMun,3] += SF3->F3_VALCONT
            EndIf
            nTotSai += SF3->F3_VALCONT
         EndIf
      EndIf
      RestArea(aArea)
      DbSkip()
EndDo

For nMx := 1 to len(aMunEnt)
	RecLock("MUN",.T.)
    ENTSAI  := aMunEnt[nMx,1]
    CODMUN  := aMunEnt[nMx,2]
    VALOR   := StrTran(StrZero(Int(aMunEnt[nMx,3]),19,2),".",",")
	MsUnLock()
Next nMx      
IF nTotEnt > 0
   RecLock("MUN",.T.)
   ENTSAI  := "E"
   CODMUN  := "99996"
   VALOR   := StrTran(StrZero(Int(nTotEnt),19,2),".",",")
   MsUnLock()
EndIf

For nMx := 1 to len(aMunSai)
	RecLock("MUN",.T.)
    ENTSAI  := aMunSai[nMx,1]
    CODMUN  := aMunSai[nMx,2]
    VALOR   := StrTran(StrZero(Int(aMunSai[nMx,3]),19,2),".",",")
	MsUnLock()
Next nMx      
IF nTotSai > 0
   RecLock("MUN",.T.)
   ENTSAI  := "S"
   CODMUN  := "99996"
   VALOR   := StrTran(StrZero(Int(nTotSai),19,2),".",",")
   MsUnLock()
EndIf

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CodEstSC  ³ Autor ³Thiago Galvao Silveira ³ Data ³23.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o codigo do Estado especificado                    ³±±	
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function CodEstSC(cEstado)
Local  cCodEst   := 0
Local  nPos		:= 0
Local  aCodEst	:= {}    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados da Tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

AADD(aCodEst,{"AC","01"})
AADD(aCodEst,{"AL","02"})
AADD(aCodEst,{"AP","03"})
AADD(aCodEst,{"AM","04"})
AADD(aCodEst,{"BA","05"})
AADD(aCodEst,{"CE","06"})
AADD(aCodEst,{"DF","07"})
AADD(aCodEst,{"ES","08"})
AADD(aCodEst,{"GO","10"})
AADD(aCodEst,{"MA","12"})
AADD(aCodEst,{"MT","13"})
AADD(aCodEst,{"MS","28"})
AADD(aCodEst,{"MG","14"})
AADD(aCodEst,{"PA","15"})
AADD(aCodEst,{"PB","16"})
AADD(aCodEst,{"PR","17"})
AADD(aCodEst,{"PE","18"})
AADD(aCodEst,{"PI","19"})
AADD(aCodEst,{"RN","20"})
AADD(aCodEst,{"RS","21"})
AADD(aCodEst,{"RJ","22"})
AADD(aCodEst,{"RO","23"})
AADD(aCodEst,{"RR","24"})
AADD(aCodEst,{"SC","25"})
AADD(aCodEst,{"SP","26"})
AADD(aCodEst,{"SE","27"})
AADD(aCodEst,{"TO","29"})

nPos	:= Ascan(aCodEst,{|x|x[1]==cEstado})
cCodEst	:= aCodEst[nPos,2]
  
Return(cCodEst)
