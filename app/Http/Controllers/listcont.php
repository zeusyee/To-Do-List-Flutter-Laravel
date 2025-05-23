<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\to_list;
use Illuminate\Support\Facades\Auth;


class listcont extends Controller
{
    // Ambil semua to-do milik user yang login
    public function index(Request $request)
    {
        $todos = to_list::where('id_users', $request->user()->id)->get();
        return response()->json($todos);
    }

    // Tambah to-do baru
    public function store(Request $request)
    {
        $data = $request->validate([
            'list' => 'required|string',
            'tanggal' => 'required|date',
            'deskripsi' => 'nullable|string',
            'status' => 'nullable|in:low,medium,high',
        ]);

        try {
            $todo = to_list::create([
                'id_users' => Auth::id(), // pastikan user sudah login
                'list' => $data['list'],
                'tanggal' => $data['tanggal'],
                'deskripsi' => $data['deskripsi'] ?? null,
                'status' => $data['status'] ?? 'low', // default ke 'low' jika tidak ada
            ]);

            return response()->json([
                'message' => 'To-do berhasil dibuat.',
                'data' => $todo
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Gagal menyimpan data.',
                'error' => $e->getMessage() // opsional: hanya tampilkan ini saat debug
            ], 500);
        }
    }


    // Update to-do
    public function update(Request $request, $id)
    {
        $todo = to_list::where('id_todo', $id)
                        ->where('id_users', $request->user()->id)
                        ->firstOrFail();

        $data = $request->validate([
            'list' => 'sometimes|string',
            'tanggal' => 'sometimes|date',
            'deskripsi' => 'nullable|string',
            'status' => 'nullable|in:low,medium,high',
            'selesai' => 'sometimes|boolean',
        ]);

        $todo->update($data);

        return response()->json($todo);
    }

    // Hapus to-do
    public function destroy(Request $request, $id)
    {
       $todo = to_list::where('id_todo', $id)
        ->where('id_users', auth()->id()) // pastikan user hanya bisa hapus miliknya
        ->first();

        if (!$todo) {
            return response()->json(['message' => 'To-do tidak ditemukan'], 404);
        }

        $todo->delete();
        return response()->json(['message' => 'To-do berhasil dihapus']);
    }
}
