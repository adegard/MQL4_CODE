//------------------------------------------------------------------
#property link      "www.pc-dream.it"
//------------------------------------------------------------------
//#property indicator_chart_window //to show in the same window of chart
#property indicator_separate_window  //to show in separate window
#property indicator_buffers 4
#property indicator_color1  Blue
#property indicator_color2  Red
#property indicator_color3  clrMediumTurquoise
#property indicator_color4  clrIndigo

#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2

double dotUp[];
double dotDn[];
double Equityline[];
double dotSt[];

string NameStrat="MA cross over/under";
// INSERT DECLARATIONS AND CACULATIONS OF EA CODE TO BACKTEST//////////////////

double realDigits=MarketInfo(_Symbol,MODE_DIGITS);
double gPointPow = MathPow(10, realDigits);
double brokerSpread = MarketInfo(_Symbol,MODE_SPREAD)/gPointPow;


//--------------------------------------------------------
//
//--------------------------------------------------------
int init()
{
  
   string comment = 
   "brokerSpread : "+(string)NormalizeDouble(brokerSpread,4);  
   Comment(comment);
   
   IndicatorBuffers(4);
   SetIndexBuffer(0,dotUp); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,241);
   SetIndexBuffer(1,dotDn); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,242);
   SetIndexBuffer(2,Equityline); SetIndexStyle(2,DRAW_LINE); 
   SetIndexBuffer(3,dotSt); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,251);
   SetIndexLabel(0,"BUY_Trend");
   SetIndexLabel(1,"SELL_Trend");
   SetIndexLabel(2,"Equityline");
   SetIndexLabel(3,"STOP_Trend");
   string shortName="Equity Backtest"+ ", Strategy: "+NameStrat +". ";
   IndicatorShortName(shortName);

   return(0);
}
int deinit() { return(0); }

string pos="";

//--------------------------------------------------------
//
//--------------------------------------------------------

int start()
{

 ObjectsDeleteAll();
 
// __________________________________________________

// __________________________________________________

   int counted_bars=Bars-1; //IndicatorCounted();
  //    if(counted_bars<0) return(-1);
  //    if(counted_bars>0) counted_bars--;
  //         int limit=MathMin(Bars-counted_bars,Bars-1);

      Equityline[counted_bars]=1000;  //HERE INSERT STRATING VALUE OF EQUITY LINE

   for (int i=counted_bars-1; i>=0; i--)
   {
      dotUp[i] = EMPTY_VALUE;
      dotDn[i] = EMPTY_VALUE;
      
      ////////////////////HERE PUT CODE OF INDICATORS CALCULATION ////////////////////////////

         double IMA_slow    = iMA(NULL,PERIOD_CURRENT,70,0,MODE_EMA,PRICE_TYPICAL,i);         
         double IMA_slow_prev    = iMA(NULL,PERIOD_CURRENT,70,0,MODE_EMA,PRICE_TYPICAL,i+1);
         
         double IMA_fast    = iMA(NULL,PERIOD_CURRENT,15,0,MODE_EMA,PRICE_TYPICAL,i);         
         double IMA_fast_prev    = iMA(NULL,PERIOD_CURRENT,15,0,MODE_EMA,PRICE_TYPICAL,i+1);

// ENTRY RULES/////// HERE PUT ENTRY RULES/////////////////////////
         if( pos=="")
           {
               if((IMA_fast>IMA_slow))  //<---INSERT LOGIC TO BUY ENTRY
                 {Equityline[i]=Equityline[i+1]*((Close[i])/Close[i+1]);
                 dotUp[i] = Equityline[i];
                 pos="BUY_T";
                 } 
                 else
                   {
                    Equityline[i]=Equityline[i+1];
                   }

               if((IMA_fast<IMA_slow))  //<---INSERT LOGIC TO SELLSHORT ENTRY
                 {Equityline[i]=Equityline[i+1]/((Close[i])/Close[i+1]);
                 dotDn[i] = Equityline[i];
                 pos="SELL_T";
                 }
                 else
                   {
                    Equityline[i]=Equityline[i+1];
                   }
           }
        


// CLOSING RULES/////// HERE PUT EXIT RULES/////////////////////////

            if (pos=="BUY_T")
                  {
                  if   (IMA_fast<IMA_slow && IMA_fast_prev>IMA_slow_prev) { // <---INSERT HERE LOGIC TO CLOSE BUY ORDER AT MARKET -stop loss or take profit...
                  Equityline[i]=Equityline[i+1]*((Close[i]-brokerSpread)/Close[i+1]);
                  pos=""; 
                  dotSt[i] =  Equityline[i]; }
                  else
                    {
                     Equityline[i]=Equityline[i+1]*((Close[i])/Close[i+1]);
                    }
                  }
            if (pos=="SELL_T")
                  {
                  if   (IMA_fast>IMA_slow && IMA_fast_prev<IMA_slow_prev) {  // <---INSERT HERE LOGIC TO CLOSE SELL ORDER AT MARKET
                  Equityline[i]=Equityline[i+1]/((Close[i]-brokerSpread)/Close[i+1]);
                  pos=""; 
                  dotSt[i] =  Equityline[i]; }
                  else
                    {
                     Equityline[i]=Equityline[i+1]/((Close[i])/Close[i+1]);
                    }
                  }
   }
   return(0);
}  

 