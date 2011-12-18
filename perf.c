#include <windows.h>
#include <caml/mlvalues.h>

value get_perf_counter() 
{
  LARGE_INTEGER  cnt;
  QueryPerformanceCounter(&cnt);
  return copy_int64(cnt.QuadPart);
}

value get_perf_frequency()
{
  LARGE_INTEGER  fr;
  QueryPerformanceFrequency(&fr);
  return copy_int64(fr.QuadPart);
}