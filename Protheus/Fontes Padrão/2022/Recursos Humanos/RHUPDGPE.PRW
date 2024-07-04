#include "rwmake.ch"
#include "protheus.ch"
#include "RHUPDGPE.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fRhUpdMsg ³ Autor ³ Marcelo Silveira	    ³ Data ³ 04/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna informacoes do compatibilizador                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Retornar informacao sobre a atualizacao conforme o indice  ³±±
±±³          ³ Ver exemplo no fonte GPEM020 - Folha Nova                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  
Function fRhUpdMsg( nUpd )

    Local cMsg := ""

    DEFAULT nUpd := 0

    If nUpd > 0

        Do Case
            Case nUpd == 197 ; cMsg := "197 - " + STR0277
            Case nUpd == 198 ; cMsg := "198 - " + STR0285
            Case nUpd == 201 ; cMsg := "201 - " + STR0291
            Case nUpd == 206 ; cMsg := "206 - " + STR0298
            Case nUpd == 207 ; cMsg := "207 - " + STR0299
            Case nUpd == 210 ; cMsg := "210 - " + STR0300
            Case nUpd == 211 ; cMsg := "211 - " + STR0303
        End Case
        
        If !Empty(cMsg)
            cMsg := STR0280 + CRLF + CRLF + cMsg  //#"Para acessar esta rotina atualize o sistema com o compatibilizador RHUPDMOD, executando a(s) opcao(es) abaixo:"
        EndIf

    EndIf

Return(cMsg)
